#!/bin/bash
# Hook UserPromptSubmit — Jornada IA Vibe Coding.
# Ativa/desativa o modo sessão e injeta o protocolo obrigatório em TODO comando
# enquanto o modo estiver ativo. Silencioso quando inativo.
set -u
. "$(dirname "$0")/jornada-lib.sh"

payload="$(cat 2>/dev/null)"
session="$(printf '%s' "$payload" | jq -r '.session_id // ""' 2>/dev/null)"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // ""' 2>/dev/null)"
prompt="$(printf '%s' "$payload" | jq -r '.prompt // ""' 2>/dev/null)"
[ -n "$cwd" ] || cwd="$PWD"
root="$(jornada_root "$cwd")"
low="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

# --- desativar (checar antes de ativar) ---
case "$low" in
  */jornada-vibe-coding\ off*|*/jornada-vibe-coding\ desativar*|*/jornada\ off*|*desativar\ a\ jornada*|*desativar\ jornada*|*desligar\ jornada*|*parar\ jornada*|*jornada\ off*)
    jornada_deactivate "$session" "$root"
    echo "[jornada-vibe-coding] Modo metodologia DESATIVADO para esta sessao e para $root."
    exit 0 ;;
esac

# --- ativar ---
activated=0
case "$low" in
  */jornada-vibe-coding*|*ativar\ a\ jornada*|*ativar\ jornada*|*jornada\ on*|*ativar\ metodologia*|*modo\ jornada*)
    jornada_activate "$session" "$root"; activated=1 ;;
esac

jornada_is_active "$session" "$root" || exit 0

missing_core="$(jornada_missing "$root" core)"
missing_all="$(jornada_missing "$root" all)"
if [ -z "$missing_all" ]; then docs_state="COMPLETOS"; else docs_state="FALTANDO: $missing_all"; fi

agents_warn=""
[ -f "$root/AGENTS.md" ] && agents_warn="ATENCAO: existe AGENTS.md em $root. Migrar o conteudo para CLAUDE.md (git mv AGENTS.md CLAUDE.md), atualizar referencias e NAO manter os dois."

if [ "$activated" = "1" ]; then
  jornada_garantir_ferramentas
  echo "[jornada-vibe-coding] MODO METODOLOGIA ATIVADO (sessao + projeto $root)."
  echo "Leia o SKILL.md da metodologia Jornada IA Vibe Coding agora e siga o protocolo P1-P8 em TODOS os comandos seguintes ate desativar."
fi

jornada_ativar_caveman

cat <<EOF
<metodologia-jornada-vibe-coding estado="ATIVA">
Projeto: $root
Documentos da metodologia: $docs_state
$agents_warn

REGRA DURA: nenhum codigo antes dos documentos. O hook PreToolUse bloqueia Edit/Write/MultiEdit em arquivos de codigo enquanto faltar: $JORNADA_CORE_DOCS

Para QUALQUER pedido (criar / alterar / implementar / corrigir), execute nesta ordem:
P0 FERRAMENTAS OBRIGATORIAS (uso automatico em TODO passo): tokensave, rtk, code-review-graph, graphify, tokenoptim (CLI) + ponytail e caveman (plugins). As CLI faltantes ja sao baixadas e instaladas em segundo plano pelo proprio plugin (log ~/.claude/jornada/instalacao.log) — nao pedir permissao, so nao dependa delas antes de terminar. Se faltarem os plugins, pedir ao usuario: /plugin marketplace add DietrichGebert/ponytail + /plugin install ponytail@ponytail e /plugin marketplace add JuliusBrussee/caveman + /plugin install caveman@caveman. TRAVA: o hook PreToolUse bloqueia Read/Grep/Glob em arquivos de codigo enquanto o P1 nao for feito; a trava cai na primeira chamada de mcp__tokensave__* ou mcp__code-review-graph__*. Combinar quantas ferramentas couberem no mesmo passo — quanto mais, menos token. Insumos longos->graphify(+tokenoptim). Mapear->tokensave(_context,_search,_entities)+code-review-graph(arquitetura,fluxos), em paralelo na mesma mensagem. Planejar/impacto->tokensave(_impact,_callers)+code-review-graph(get_impact_radius_tool)+graphify se houver graphify-out. Codificar->ponytail sempre+tokensave(_body,_signature) em vez de Read. Terminal->rtk automatico. Revisar->code-review-graph(detect_changes_tool,get_review_context_tool)+tokensave(_diff_context). Busca ampla->subagente. Relatar->caveman. Detalhes: references/ferramentas-token.md.
P1 LER COM ECONOMIA DE TOKEN antes de opinar ou editar: mcp__tokensave__tokensave_context / _search / _callers / _entities (rodar 'tokensave init' se nao houver indice) e code-review-graph (build_or_update_graph_tool, get_architecture_overview_tool, get_impact_radius_tool). rtk ja filtra saida de Bash. Buscas amplas -> subagente. Nunca ler arquivo inteiro sem necessidade.
P2 DOCUMENTOS: se faltar qualquer um, usar a skill estruturar-projeto. Na PRIMEIRA vez o projeto INTEIRO tem de ser varrido, sem amostragem: rodar scripts/inventario-projeto.sh, cobrir 100% dos modulos do inventario (grafo primeiro; leitura direta obrigatoria em migrations, rotas, .env.example, manifestos, middleware/permissoes, README), entregar a TABELA DE COBERTURA (pasta -> como foi coberto -> o que faz -> entidades -> pendencias) e so entao escrever PRD, DECISOES_TECNICAS, FSD, DESIGN, INSUMOS, CLAUDE.md. Cada afirmacao dos documentos aponta a origem no codigo; o que nao der para inferir vira 'PENDENTE - confirmar com o usuario'. STATUS.md e ERROS.md nascem VAZIOS. Tudo isso ANTES de tocar em codigo. Usar CLAUDE.md — NUNCA criar AGENTS.md.
P3 CLASSIFICAR o pedido: (a) edicao simples -> codigo + STATUS + ERROS; (b) recurso novo / alteracao grande / mudanca de escopo ou stack -> atualizar PRD.md, docs/FSD.md, DECISOES_TECNICAS.md, INSUMOS.md, docs/DESIGN.md (se UI) ANTES do codigo.
P4 PLANEJAR: registrar a tarefa em docs/PLANO.md (etapas) e abrir a etapa em docs/STATUS.md antes da primeira edicao de codigo.
P5 EXECUTAR UMA etapa por comando, conforme PLANO/FSD/DESIGN. Nao construir varias etapas de uma vez. Nao usar tecnologia fora do FSD.
P6 TESTAR de verdade: lint, typecheck, testes, build, migrations, subir servidor; se houver UI, screenshot + responsividade em docs/screenshots/. Sistema criado != sistema testado.
P7 REGISTRAR SEMPRE: docs/STATUS.md (etapa, arquivos alterados, testes e resultado, data, proxima etapa) e docs/ERROS.md (TODO erro, mesmo ja corrigido, com causa e correcao; consultar ERROS.md ANTES de corrigir). Etapas/subpassos descobertos no caminho -> adicionar em PLANO.md e STATUS.md.
P8 ENTREGAR: commit com mensagem clara + Checklist 1 (o que foi feito, linguagem leiga) + Checklist 2 (o que testar e como: acao -> resultado esperado) + Checklist 3 (regressao). Ao concluir uma etapa do STATUS.md, anexar tambem o checklist acumulado de todas as etapas ja feitas.
Concluiu todas as etapas do PLANO -> Revisao de Seguranca (Passo 5) -> Documentacao (Passo 6) -> Deploy (Passo 7) se pedido.

$(jornada_regras_sempre_ativas)

Prompt verbatim de cada fase: o SKILL.md da metodologia Jornada IA Vibe Coding e references/. Desativar: "/jornada-vibe-coding off".
</metodologia-jornada-vibe-coding>
EOF
exit 0
