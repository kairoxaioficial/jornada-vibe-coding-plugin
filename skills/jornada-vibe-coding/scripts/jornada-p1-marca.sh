#!/bin/bash
# Hook PostToolUse (ferramentas de grafo) — Jornada IA Vibe Coding.
# Registra que o P1 (mapeamento com economia de token) foi feito nesta sessao/projeto.
set -u
. "$(dirname "$0")/jornada-lib.sh"

payload="$(cat 2>/dev/null)"
command -v jq >/dev/null 2>&1 || exit 0

session="$(printf '%s' "$payload" | jq -r '.session_id // ""')"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // ""')"
root="$(jornada_root "${cwd:-$PWD}")"

jornada_p1_marca "$session" "$root"
exit 0
