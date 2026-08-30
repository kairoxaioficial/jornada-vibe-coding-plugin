#!/bin/bash
# Hook PreToolUse (Edit|Write|MultiEdit|NotebookEdit) — Jornada IA Vibe Coding.
# Enquanto o modo metodologia estiver ativo:
#   1. bloqueia criacao/edicao de AGENTS.md (o padrao do usuario e CLAUDE.md);
#   2. bloqueia edicao de CODIGO enquanto faltarem os documentos da metodologia.
# Documentos, docs/, README, configs e caminhos isentos passam sempre.
set -u
. "$(dirname "$0")/jornada-lib.sh"

deny() { jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; exit 0; }

payload="$(cat 2>/dev/null)"
session="$(printf '%s' "$payload" | jq -r '.session_id // ""' 2>/dev/null)"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // ""' 2>/dev/null)"
path="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // ""' 2>/dev/null)"
[ -n "$cwd" ] || cwd="$PWD"
[ -n "$path" ] || exit 0
case "$path" in /*) ;; *) path="$cwd/$path" ;; esac

root="$(jornada_root "$path")"
jornada_is_active "$session" "$root" || jornada_is_active "$session" "$(jornada_root "$cwd")" || exit 0
[ "$root" = "$HOME" ] && exit 0
jornada_is_exempt_path "$path" && exit 0

base="$(basename "$path")"

# 1. AGENTS.md nunca — padrao do projeto e CLAUDE.md.
if [ "$base" = "AGENTS.md" ]; then
  deny "Metodologia Jornada ativa: este projeto usa CLAUDE.md, nao AGENTS.md. Escreva o conteudo em $root/CLAUDE.md. Se ja existir um AGENTS.md, migre o conteudo para CLAUDE.md (git mv AGENTS.md CLAUDE.md) e ajuste as referencias nos documentos."
fi

# 2. Documentos/config/docs passam sempre (sao justamente o que deve vir antes).
case "$path" in
  */docs/*|*/.github/*|*/.claude/*) exit 0 ;;
esac
case "$base" in
  PRD.md|DECISOES_TECNICAS.md|CLAUDE.md|INSUMOS.md|FSD.md|DESIGN.md|PLANO.md|STATUS.md|ERROS.md|CHECKLIST.md|MANUTENCAO.md|COMO-PEDIR-MUDANCAS.md|README.md|.gitignore|.gitattributes|deploy-exclude.txt)
    exit 0 ;;
esac

missing="$(jornada_missing "$root" core)"
[ -z "$missing" ] && exit 0

deny "Metodologia Jornada IA Vibe Coding ativa: nenhum codigo antes dos documentos. Faltam em $root: $missing. Faca nesta ordem: (1) ler o codigo com tokensave/code-review-graph; (2) usar a skill estruturar-projeto para criar TODOS os documentos (STATUS.md e ERROS.md vazios, CLAUDE.md em vez de AGENTS.md); (3) registrar a tarefa em docs/PLANO.md e docs/STATUS.md; (4) so entao editar codigo. Para sair do modo: '/jornada-vibe-coding off'."
