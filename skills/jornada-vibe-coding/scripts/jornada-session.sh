#!/bin/bash
# CLI do modo sessao da metodologia Jornada IA Vibe Coding.
# Uso: jornada-session.sh on|off|status [diretorio]
set -u
. "$(dirname "$0")/jornada-lib.sh"

action="${1:-status}"
target="${2:-$PWD}"
root="$(jornada_root "$target")"

case "$action" in
  on|ativar)
    jornada_activate "" "$root"
    jornada_garantir_ferramentas
    echo "jornada: ATIVA em $root"
    ;;
  off|desativar)
    jornada_deactivate "" "$root"
    echo "jornada: DESATIVADA em $root"
    ;;
  status)
    if jornada_is_active "" "$root"; then echo "jornada: ATIVA em $root"; else echo "jornada: inativa em $root"; fi
    ;;
  *)
    echo "uso: jornada-session.sh on|off|status [diretorio]" >&2; exit 1 ;;
esac

miss_all="$(jornada_missing "$root" all)"
miss_core="$(jornada_missing "$root" core)"
[ -z "$miss_all" ] && echo "docs: completos" || echo "docs faltando: $miss_all"
[ -n "$miss_core" ] && echo "BLOQUEIO ATIVO em codigo ate criar: $miss_core"
[ -f "$root/AGENTS.md" ] && echo "AGENTS.md encontrado -> migrar para CLAUDE.md (git mv AGENTS.md CLAUDE.md)"
exit 0
