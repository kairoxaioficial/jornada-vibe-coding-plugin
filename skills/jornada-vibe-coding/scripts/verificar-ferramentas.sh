#!/bin/bash
# Hook SessionStart — Jornada IA Vibe Coding.
# Zera o contador do bloco injetado (o proximo prompt recebe o protocolo completo),
# instala em segundo plano o que faltar e, SO com a Jornada ativa, injeta quais
# ferramentas de economia de tokens estao disponiveis e como instalar as ausentes.
# As regras de uso nao vao aqui: chegam no bloco completo do proximo prompt.
set -u
payload="$(cat 2>/dev/null)"

AQUI="$(cd "$(dirname "$0")" && pwd)"
INSTALADOR="$AQUI/instalar-ferramentas.sh"
tem() { command -v "$1" >/dev/null 2>&1; }

LIB="$AQUI/jornada-lib.sh"
[ -f "$LIB" ] || exit 0
. "$LIB"
# Instala em segundo plano o que estiver faltando (no maximo 1x por dia).
jornada_garantir_ferramentas 2>/dev/null || true
jornada_ativar_caveman 2>/dev/null || true

session=""; cwd=""
if tem jq; then
  session="$(printf '%s' "$payload" | jq -r '.session_id // ""' 2>/dev/null)"
  cwd="$(printf '%s' "$payload" | jq -r '.cwd // ""' 2>/dev/null)"
fi
[ -n "$cwd" ] || cwd="$PWD"
jornada_injecao_zerar "$session"
jornada_is_active "$session" "$(jornada_root "$cwd")" || exit 0

disp=""; falta=""
add() { if tem "$1"; then disp="$disp $1"; else falta="$falta $1"; fi; }
add tokensave
add rtk
add code-review-graph
add graphify
if tem tokenoptim || tem llm-tokenoptim; then disp="$disp tokenoptim"; else falta="$falta tokenoptim"; fi

# plugins do Claude Code: procurados no disco
for pl in caveman context-mode token-optimizer claude-hud; do
  if ls -d "$HOME"/.claude/plugins/cache/*/"$pl" >/dev/null 2>&1 || ls -d "$HOME"/.claude/skills/"$pl" >/dev/null 2>&1; then
    disp="$disp $pl"
  else
    falta="$falta $pl"
  fi
done

ctx="FERRAMENTAS DE ECONOMIA DE TOKENS (Jornada IA Vibe Coding) — USO OBRIGATORIO. Disponiveis:${disp:- nenhuma}. Ausentes:${falta:- nenhuma}. Regras de uso: P0 do bloco <metodologia-jornada-vibe-coding> do proximo comando e references/ferramentas-token.md."

# Instrucoes de instalacao so quando algo falta (economiza token em toda sessao).
if [ -n "$falta" ]; then
  ctx="$ctx

As ferramentas de linha de comando ausentes ja estao sendo instaladas em segundo plano
(log: ~/.claude/jornada/instalacao.log). Para forcar agora:
  bash \"$INSTALADOR\"
Plugins faltando: rode o instalador acima (usa 'claude plugin install'). Ou, dentro do Claude Code:
  /plugin marketplace add JuliusBrussee/caveman        /plugin install caveman@caveman
  /plugin marketplace add mksglu/context-mode          /plugin install context-mode@context-mode
  /plugin marketplace add alexgreensh/token-optimizer  /plugin install token-optimizer@alexgreensh-token-optimizer
  /plugin marketplace add jarrodwatts/claude-hud       /plugin install claude-hud@claude-hud"
fi

if command -v jq >/dev/null 2>&1; then
  jq -n --arg c "$ctx" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
else
  printf '%s\n' "$ctx"
fi
exit 0
