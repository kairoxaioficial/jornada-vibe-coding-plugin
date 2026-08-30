#!/bin/bash
# Hook SessionStart — Jornada IA Vibe Coding.
# Verifica as ferramentas OBRIGATORIAS de economia de tokens e injeta no contexto
# do Claude quais estao disponiveis e como instalar as que faltam.
set -u
cat >/dev/null 2>&1   # descarta o payload do hook

RAIZ="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
tem() { command -v "$1" >/dev/null 2>&1; }

disp=""; falta=""
add() { if tem "$1"; then disp="$disp $1"; else falta="$falta $1"; fi; }
add tokensave
add rtk
add code-review-graph
add graphify
if tem tokenoptim || tem llm-tokenoptim; then disp="$disp tokenoptim"; else falta="$falta tokenoptim"; fi

# plugins do Claude Code: procurados no disco
for pl in ponytail caveman; do
  if ls -d "$HOME"/.claude/plugins/*/"$pl"* >/dev/null 2>&1 || ls -d "$HOME"/.claude/skills/"$pl" >/dev/null 2>&1; then
    disp="$disp $pl"
  else
    falta="$falta $pl"
  fi
done

ctx="FERRAMENTAS DE ECONOMIA DE TOKENS (Jornada IA Vibe Coding) — USO OBRIGATORIO.
Disponiveis:${disp:- nenhuma}.
Ausentes:${falta:- nenhuma}.

Regras obrigatorias enquanto trabalhar neste projeto:
- Explorar codigo: usar mcp__tokensave__tokensave_context / _search / _callers / _callees / _impact ANTES de ler arquivos inteiros.
- Review e impacto: usar mcp__code-review-graph__detect_changes_tool, _get_review_context_tool, _get_impact_radius_tool, _semantic_search_nodes_tool em vez de Grep amplo.
- Busca ampla em varios arquivos: delegar a subagente, nunca despejar arquivos inteiros no contexto principal.
- Escrever codigo: aplicar a skill ponytail (solucao mais simples que funciona, sem over-engineering).
- Terminal: rtk filtra a saida automaticamente; nunca contornar com 'rtk proxy'.
- Perguntas sobre a arquitetura do projeto: consultar graphify (graphify-out/) antes de ler arquivos.
- Saida: manter respostas comprimidas (caveman) sem perder codigo, caminhos, comandos e mensagens de erro.

Se alguma ferramenta estiver AUSENTE e for necessaria para a tarefa, INSTALE antes de continuar rodando:
  bash \"$RAIZ/scripts/instalar-ferramentas.sh\"
Os plugins ponytail e caveman precisam ser instalados dentro do Claude Code:
  /plugin marketplace add DietrichGebert/ponytail
  /plugin install ponytail@ponytail
  /plugin marketplace add JuliusBrussee/caveman
  /plugin install caveman@caveman"

if command -v jq >/dev/null 2>&1; then
  jq -n --arg c "$ctx" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
else
  printf '%s\n' "$ctx"
fi
exit 0
