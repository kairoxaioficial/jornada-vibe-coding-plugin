#!/bin/bash
# Biblioteca comum dos hooks da metodologia Jornada IA Vibe Coding.
# Sem efeitos colaterais: apenas funções.

JORNADA_HOME="${JORNADA_HOME:-$HOME/.claude/jornada}"

# Documentos exigidos ANTES de qualquer código (bloqueiam edição de código).
JORNADA_CORE_DOCS="PRD.md docs/FSD.md docs/PLANO.md docs/STATUS.md docs/ERROS.md"
# Conjunto completo da metodologia (reportado, não bloqueante).
JORNADA_ALL_DOCS="PRD.md DECISOES_TECNICAS.md CLAUDE.md INSUMOS.md docs/DESIGN.md docs/FSD.md docs/PLANO.md docs/STATUS.md docs/ERROS.md"

# Raiz do projeto: sobe até achar .git ou um documento da metodologia.
jornada_root() {
  local d="$1"
  [ -d "$d" ] || d="$(dirname "$d")"
  while [ -n "$d" ] && [ "$d" != "/" ] && [ "$d" != "." ]; do
    if [ -d "$d/.git" ] || [ -f "$d/docs/STATUS.md" ] || [ -f "$d/PRD.md" ]; then
      printf '%s' "$d"; return 0
    fi
    d="$(dirname "$d")"
  done
  printf '%s' "$1"
}

jornada_slug() { printf '%s' "$1" | tr '/ ' '--'; }

jornada_activate() {
  local session="$1" root="$2"
  mkdir -p "$JORNADA_HOME/sessions" "$JORNADA_HOME/projects" 2>/dev/null
  [ -n "$session" ] && : > "$JORNADA_HOME/sessions/$session"
  [ -n "$root" ] && : > "$JORNADA_HOME/projects/$(jornada_slug "$root")"
  return 0
}

jornada_deactivate() {
  local session="$1" root="$2"
  [ -n "$session" ] && rm -f "$JORNADA_HOME/sessions/$session"
  [ -n "$root" ] && rm -f "$JORNADA_HOME/projects/$(jornada_slug "$root")"
  return 0
}

jornada_is_active() {
  local session="$1" root="$2"
  [ -n "$session" ] && [ -f "$JORNADA_HOME/sessions/$session" ] && return 0
  [ -n "$root" ] && [ -f "$JORNADA_HOME/projects/$(jornada_slug "$root")" ] && return 0
  return 1
}

# Lista (separada por espaço) dos docs faltantes. $2 = "core" | "all"
jornada_missing() {
  local root="$1" set="${2:-core}" list miss="" f
  if [ "$set" = "all" ]; then list="$JORNADA_ALL_DOCS"; else list="$JORNADA_CORE_DOCS"; fi
  for f in $list; do
    [ -f "$root/$f" ] || miss="$miss $f"
  done
  printf '%s' "${miss# }"
}

# Caminhos onde a metodologia NUNCA deve bloquear/injetar (config, temporários, home puro).
jornada_is_exempt_path() {
  local p="$1"
  case "$p" in
    "$HOME"/.claude/*|"$HOME"/.config/*|/tmp/*|/private/tmp/*|/var/folders/*) return 0 ;;
  esac
  return 1
}
