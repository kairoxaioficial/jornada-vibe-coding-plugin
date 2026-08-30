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

# Raiz do plugin (contem scripts/instalar-ferramentas.sh).
jornada_plugin_root() {
  if [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -f "$CLAUDE_PLUGIN_ROOT/scripts/instalar-ferramentas.sh" ]; then
    printf '%s' "$CLAUDE_PLUGIN_ROOT"; return 0
  fi
  local d
  d="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." 2>/dev/null && pwd)"
  [ -f "$d/scripts/instalar-ferramentas.sh" ] && printf '%s' "$d"
}

# Ferramentas obrigatorias de linha de comando presentes?
jornada_ferramentas_faltando() {
  local falta="" c
  for c in tokensave rtk code-review-graph graphify; do
    command -v "$c" >/dev/null 2>&1 || falta="$falta $c"
  done
  command -v tokenoptim >/dev/null 2>&1 || command -v llm-tokenoptim >/dev/null 2>&1 || falta="$falta tokenoptim"
  printf '%s' "${falta# }"
}

# Instala em segundo plano o que faltar. Roda no maximo 1x por dia.
jornada_garantir_ferramentas() {
  [ -n "$(jornada_ferramentas_faltando)" ] || return 0
  local raiz marca hoje
  raiz="$(jornada_plugin_root)"; [ -n "$raiz" ] || return 0
  mkdir -p "$JORNADA_HOME" 2>/dev/null
  marca="$JORNADA_HOME/ultima-instalacao"
  hoje="$(date +%Y-%m-%d)"
  [ -f "$marca" ] && [ "$(cat "$marca" 2>/dev/null)" = "$hoje" ] && return 0
  printf '%s' "$hoje" > "$marca"
  nohup bash "$raiz/scripts/instalar-ferramentas.sh" >"$JORNADA_HOME/instalacao.log" 2>&1 &
  return 0
}

# --- P1: mapeamento com grafo feito nesta sessao/projeto? ---
jornada_p1_marca() {
  local session="$1" root="$2"
  mkdir -p "$JORNADA_HOME/p1" 2>/dev/null
  : > "$JORNADA_HOME/p1/$(jornada_slug "${session:-sem-sessao}--$root")"
}

jornada_p1_feito() {
  local session="$1" root="$2"
  [ -f "$JORNADA_HOME/p1/$(jornada_slug "${session:-sem-sessao}--$root")" ]
}

# Arquivo de codigo? (documentos e configs nao contam)
jornada_is_codigo() {
  case "$1" in
    *.md|*.txt|*.json|*.yml|*.yaml|*.toml|*.ini|*.env|*.env.*|*.lock|*.csv|*.svg|*.png|*.jpg|*.jpeg|*.gif|*.pdf) return 1 ;;
    *.*) return 0 ;;
  esac
  return 1
}

# --- ponytail + caveman: SEMPRE ativos ---
# Garante o arquivo de estado do caveman (o plugin le o nivel dali).
jornada_ativar_caveman() {
  local f="$HOME/.claude/.caveman-active"
  [ -f "$f" ] || { mkdir -p "$HOME/.claude" 2>/dev/null; printf 'full' > "$f" 2>/dev/null; }
  return 0
}

# Regras de ponytail e caveman em texto, injetadas em todo prompt.
# Funcionam mesmo se os plugins ainda nao estiverem instalados.
jornada_regras_sempre_ativas() {
  cat <<'REGRAS'
PONYTAIL (SEMPRE ATIVO) — escada obrigatoria antes de escrever qualquer codigo:
1 a tarefa precisa existir? 2 ja existe no projeto? 3 resolve com recurso nativo da linguagem/plataforma? 4 resolve com dependencia ja instalada? 5 resolve em uma linha? 6 so entao o minimo que funciona.
Nunca cortar validacao, tratamento de erro, seguranca ou acessibilidade. Nao adicionar dependencia, abstracao, camada, config ou arquivo que a tarefa nao exigiu.

CAVEMAN (SEMPRE ATIVO, nivel full) — saida comprimida: sem preambulo, sem resumo final, sem "vou fazer", sem narrar tool call, sem elogio, sem emoji decorativo. Fragmentos ok. Resultado primeiro.
NUNCA comprimir: codigo, comandos, caminhos de arquivo, mensagens de erro, numeros, versoes, avisos de seguranca.
NUNCA comprimir o que fica gravado: documentos da metodologia (PRD, FSD, STATUS, ERROS, PLANO), checklists em linguagem leiga e mensagens de commit sao escritos em portugues normal, por extenso.
Responder sempre no idioma do usuario.
REGRAS
}
