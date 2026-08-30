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
for skill in jornada-vibe-coding estruturar-projeto; do
  # remove a versao antiga para nao aninhar pastas nem deixar arquivo orfao
  rm -rf "$DESTINO/$skill"
  cp -R "$ORIGEM/skills/$skill" "$DESTINO/$skill"
done
chmod +x "$DESTINO/jornada-vibe-coding/scripts/"*.sh
echo "    Skills copiadas para $DESTINO"

BASE='$HOME/.claude/skills/jornada-vibe-coding/scripts'

[ -f "$CFG" ] || echo '{}' > "$CFG"
BACKUP="$CFG.backup-$(date +%Y%m%d-%H%M%S)"
cp "$CFG" "$BACKUP"
echo "    Backup do settings.json em $BACKUP"

# evento | matcher (vazio = sem matcher) | script
HOOKS="
SessionStart||$BASE/verificar-ferramentas.sh
UserPromptSubmit||$BASE/jornada-context.sh
PreToolUse|Edit|Write|MultiEdit|NotebookEdit|$BASE/jornada-guard.sh
PreToolUse|Read|Grep|Glob|$BASE/jornada-p1-guard.sh
PostToolUse|mcp__tokensave__.*|mcp__code-review-graph__.*|$BASE/jornada-p1-marca.sh
PostToolUse|Edit|Write|MultiEdit|NotebookEdit|$BASE/jornada-registrar-edicao.sh
Stop||$BASE/jornada-stop-guard.sh
"

TMP="$BACKUP"
while IFS= read -r linha; do
  [ -n "$linha" ] || continue
  evento="${linha%%|*}"
  resto="${linha#*|}"
  script="${resto##*|}"
  matcher="${resto%|*}"
  saida="$CFG.tmp.$$"
  jq --arg ev "$evento" --arg m "$matcher" --arg c "$script" '
    ({type:"command", command:$c, timeout:(if ($c|test("verificar-ferramentas")) then 20 else 10 end)}) as $novo
    | .hooks //= {}
    | .hooks[$ev] //= []
    | if ([.hooks[$ev][]?.hooks[]?.command] | index($c)) then .
      else .hooks[$ev] += [ (if $m == "" then {hooks:[$novo]} else {matcher:$m, hooks:[$novo]} end) ]
      end
  ' "$TMP" > "$saida" && mv "$saida" "$CFG"
  TMP="$CFG"
done <<EOF
$HOOKS
EOF

echo "    Hooks registrados em $CFG"
echo
echo "==> Agora as ferramentas obrigatorias de economia de tokens"
bash "$ORIGEM/scripts/instalar-ferramentas.sh" || echo "    (alguma ferramenta falhou; rode depois: bash scripts/instalar-ferramentas.sh)"
echo
echo "==> Pronto. Feche e abra o Claude Code, depois digite: /jornada-vibe-coding"
