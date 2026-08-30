#!/bin/bash
# Instalador manual da metodologia Jornada IA Vibe Coding (alternativa ao plugin).
# Copia as skills para ~/.claude/skills e registra os dois hooks em ~/.claude/settings.json.
set -eu

ORIGEM="$(cd "$(dirname "$0")" && pwd)"
DESTINO="$HOME/.claude/skills"
CFG="$HOME/.claude/settings.json"

echo "==> Instalando a metodologia Jornada IA Vibe Coding"

if ! command -v jq >/dev/null 2>&1; then
  echo "ERRO: o programa 'jq' nao esta instalado e e necessario."
  echo "No macOS instale com:  brew install jq"
  echo "No Ubuntu/Debian:      sudo apt install jq"
  exit 1
fi

mkdir -p "$DESTINO"
cp -R "$ORIGEM/skills/jornada-vibe-coding" "$DESTINO/"
cp -R "$ORIGEM/skills/estruturar-projeto" "$DESTINO/"
chmod +x "$DESTINO/jornada-vibe-coding/scripts/"*.sh
echo "    Skills copiadas para $DESTINO"

CTX='$HOME/.claude/skills/jornada-vibe-coding/scripts/jornada-context.sh'
GUARD='$HOME/.claude/skills/jornada-vibe-coding/scripts/jornada-guard.sh'

[ -f "$CFG" ] || echo '{}' > "$CFG"
BACKUP="$CFG.backup-$(date +%Y%m%d-%H%M%S)"
cp "$CFG" "$BACKUP"
echo "    Backup do settings.json em $BACKUP"

jq --arg ctx "$CTX" --arg guard "$GUARD" '
  .hooks //= {}
  | .hooks.UserPromptSubmit //= []
  | .hooks.PreToolUse //= []
  | if ([.hooks.UserPromptSubmit[]?.hooks[]?.command] | index($ctx)) then .
    else .hooks.UserPromptSubmit += [{hooks: [{type: "command", command: $ctx}]}] end
  | if ([.hooks.PreToolUse[]?.hooks[]?.command] | index($guard)) then .
    else .hooks.PreToolUse += [{matcher: "Edit|Write|MultiEdit|NotebookEdit", hooks: [{type: "command", command: $guard}]}] end
' "$BACKUP" > "$CFG"

echo "    Hooks registrados em $CFG"
echo
echo "==> Pronto. Feche e abra o Claude Code, depois digite: /jornada-vibe-coding"
