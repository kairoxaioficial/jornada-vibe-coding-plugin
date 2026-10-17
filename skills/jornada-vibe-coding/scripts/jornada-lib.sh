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

jornada_global_flag() { printf '%s' "$JORNADA_HOME/global-on"; }

jornada_global_is_active() {
  [ -f "$(jornada_global_flag)" ]
}

jornada_global_activate() {
  mkdir -p "$JORNADA_HOME" 2>/dev/null
  : > "$(jornada_global_flag)"
}

jornada_global_deactivate() {
  rm -f "$(jornada_global_flag)"
}

jornada_is_active() {
  local session="$1" root="$2"
  jornada_global_is_active && return 0
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
jornada_instalador() {
  local d
  d="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
  [ -f "$d/instalar-ferramentas.sh" ] && { printf '%s' "$d/instalar-ferramentas.sh"; return 0; }
  [ -n "${CLAUDE_PLUGIN_ROOT:-}" ] && [ -f "$CLAUDE_PLUGIN_ROOT/scripts/instalar-ferramentas.sh" ] && \
    { printf '%s' "$CLAUDE_PLUGIN_ROOT/scripts/instalar-ferramentas.sh"; return 0; }
  return 1
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
  local inst marca hoje
  inst="$(jornada_instalador)" || return 0
  mkdir -p "$JORNADA_HOME" 2>/dev/null
  marca="$JORNADA_HOME/ultima-instalacao"
  hoje="$(date +%Y-%m-%d)"
  [ -f "$marca" ] && [ "$(cat "$marca" 2>/dev/null)" = "$hoje" ] && return 0
  printf '%s' "$hoje" > "$marca"
  nohup bash "$inst" >"$JORNADA_HOME/instalacao.log" 2>&1 &
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

# --- caveman: SEMPRE ativo ---
# Garante o arquivo de estado do caveman (o plugin le o nivel dali).
jornada_ativar_caveman() {
  local f="$HOME/.claude/.caveman-active"
  [ -f "$f" ] || { mkdir -p "$HOME/.claude" 2>/dev/null; printf 'full' > "$f" 2>/dev/null; }
  return 0
}

# Plugin caveman instalado e nao desligado? Ele mesmo injeta as regras de compressao em todo prompt.
jornada_caveman_plugin() {
  grep -q '"caveman@' "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null || return 1
  ! grep -q '"caveman@[^"]*"[[:space:]]*:[[:space:]]*false' "$HOME/.claude/settings.json" 2>/dev/null
}

# Regras sempre ativas do bloco completo. As regras gerais do caveman so entram
# quando o plugin nao esta instalado (com ele, seriam texto repetido).
jornada_regras_sempre_ativas() {
  jornada_caveman_plugin || cat <<'REGRAS'
CAVEMAN (SEMPRE ATIVO, nivel full) — saida comprimida: sem preambulo, sem resumo final, sem "vou fazer", sem narrar tool call, sem elogio, sem emoji decorativo. Fragmentos ok. Resultado primeiro.
NUNCA comprimir: codigo, comandos, caminhos de arquivo, mensagens de erro, numeros, versoes, avisos de seguranca.
REGRAS
  cat <<'REGRAS'
NUNCA comprimir o que fica gravado: documentos da metodologia (PRD, FSD, STATUS, ERROS, PLANO), checklists em linguagem leiga e mensagens de commit sao escritos em portugues normal, por extenso.
Responder sempre no idioma do usuario.
REGRAS
  jornada_regra_ponytail_desligado
}

# ponytail fica DESLIGADO com a Jornada ativa (decisao do usuario, 16/10/2026).
jornada_regra_ponytail_desligado() {
  cat <<'REGRA'
PONYTAIL DESLIGADO enquanto a Jornada estiver ativa: nao invocar a skill ponytail nem aplicar a regua "o minimo que funciona", mesmo que outro hook, skill ou CLAUDE.md peca. Padrao: qualidade de produto conforme FSD e DESIGN — completo (estados carregando/vazio/erro/sucesso), seguro, acessivel, responsivo, bonito e intuitivo — sem sair do escopo do FSD.
REGRA
}

# --- injecao enxuta: bloco completo x bloco curto ---
# O texto injetado fica no historico da conversa; repetir o protocolo inteiro a
# cada prompt so ocupava contexto. Completo: 1o prompt da sessao, ao ativar,
# depois do SessionStart (inicio, retomada, /clear, compactacao) e a cada
# JORNADA_REFORCO prompts. Na duvida, completo.
jornada_reforco() {
  case "${JORNADA_REFORCO:-}" in ''|*[!0-9]*) printf '10' ;; *) printf '%s' "$JORNADA_REFORCO" ;; esac
}

jornada_injecao_file() {
  mkdir -p "$JORNADA_HOME/injecao" 2>/dev/null
  printf '%s' "$JORNADA_HOME/injecao/$(jornada_slug "${1:-sem-sessao}")"
}

# Apaga a marca da sessao: o proximo prompt recebe o bloco completo.
jornada_injecao_zerar() {
  [ -n "${1:-}" ] && rm -f "$(jornada_injecao_file "$1")"
  return 0
}

# Imprime "completo" ou "curto" e atualiza o contador. $1 sessao, $2 forcar (1/0).
jornada_injecao_modo() {
  local session="$1" forcar="${2:-0}" f n
  [ -n "$session" ] || { echo completo; return 0; }
  f="$(jornada_injecao_file "$session")"
  n="$(cat "$f" 2>/dev/null)"
  case "$n" in ''|*[!0-9]*) forcar=1 ;; esac
  if [ "$forcar" = "1" ] || [ "$n" -ge $(( $(jornada_reforco) - 1 )) ]; then
    printf '0' > "$f" 2>/dev/null
    echo completo; return 0
  fi
  if printf '%s' "$((n + 1))" > "$f" 2>/dev/null; then echo curto; else echo completo; fi
}

# --- detector de esforco (FSD 9a) ---
# Marca por sessao: tamanho do transcript no inicio do processo (o /effort vale
# so para o processo; o que veio antes de reiniciar nao conta mais).
jornada_esforco_marca() {
  local slug
  mkdir -p "$JORNADA_HOME/esforco" 2>/dev/null
  slug="$(jornada_slug "${1:-sem-sessao}")"
  case "$slug" in .|..) slug="sessao-$slug" ;; esac
  printf '%s' "$JORNADA_HOME/esforco/$slug"
}

# $1 sessao, $2 transcript_path. Grava o tamanho atual do transcript; limpa marcas velhas.
jornada_esforco_inicio() {
  local f t n
  f="$(jornada_esforco_marca "${1:-}")"
  t="${2:-}"
  n=0
  [ -n "$t" ] && [ -f "$t" ] && n="$(wc -c < "$t" 2>/dev/null | tr -d ' ')"
  case "$n" in ''|*[!0-9]*) n=0 ;; esac
  printf '%s' "$n" > "$f" 2>/dev/null
  find "$JORNADA_HOME/esforco" -type f -mtime +7 -delete 2>/dev/null
  return 0
}

# $1 sessao, $2 transcript_path. Imprime UMA linha com o esforco e o Ultracode.
# Nada do transcript e executado: so grep. Nunca jq no transcript (pode ter dezenas de MB).
jornada_esforco() {
  local session="${1:-}" t="${2:-}" f off size trecho linhas nivel="" origem="" ultra="nao detectado" u modelo st
  if [ -n "$t" ] && [ -f "$t" ]; then
    f="$(jornada_esforco_marca "$session")"
    off="$(cat "$f" 2>/dev/null)"
    size="$(wc -c < "$t" 2>/dev/null | tr -d ' ')"
    case "$off" in ''|*[!0-9]*) off=0 ;; esac
    case "$size" in ''|*[!0-9]*) size=0 ;; esac
    [ "$off" -gt "$size" ] && off=0
    # so saidas de comando local do usuario (nunca texto do modelo nem resultado de ferramenta)
    # grep le o arquivo direto (-b da o byte inicial de cada linha; pipe de tail seria 5x mais lento no grep do macOS)
    linhas="$(LC_ALL=C grep -a -b -F '<local-command-stdout>' < "$t" 2>/dev/null \
      | LC_ALL=C awk -v o="$off" '{ n = index($0, ":"); if (substr($0, 1, n - 1) + 0 >= o) print substr($0, n + 1) }' \
      | LC_ALL=C grep -a -F '"type":"user"' | LC_ALL=C grep -a -v -F '"type":"tool_result"' | LC_ALL=C grep -a -E '"(content|text)": ?"<local-command-stdout>')"
    if [ -n "$linhas" ]; then
      nivel="$(printf '%s\n' "$linhas" | LC_ALL=C grep -a -o -E "Set effort level to [A-Za-z0-9_-]+|set to '[A-Za-z0-9_-]+'" \
        | sed -E "s/^Set effort level to //; s/^set to '//; s/'$//" | grep -x -E '[a-z]{1,12}' | tail -1)"
      [ -n "$nivel" ] && origem="/effort"
      u="$(printf '%s\n' "$linhas" | LC_ALL=C grep -a -o -E 'Ultracode (on|off)' | tail -1)"
      case "$u" in "Ultracode on") ultra="ligado" ;; "Ultracode off") ultra="desligado" ;; esac
    fi
  fi
  # 1. a variavel tem precedencia sobre o /effort
  u="$(printf '%s' "${CLAUDE_CODE_EFFORT_LEVEL:-}" | tr '[:upper:]' '[:lower:]')"
  if [ -n "$u" ]; then
    case "$u" in *[!a-z]*) ;; *) if [ "${#u}" -le 12 ]; then nivel="$u"; origem="variavel CLAUDE_CODE_EFFORT_LEVEL"; fi ;; esac
  fi
  # 3. configuracoes
  st="$HOME/.claude/settings.json"
  if [ -z "$nivel" ] && [ -f "$st" ] && command -v jq >/dev/null 2>&1; then
    modelo=""
    if [ -n "$t" ] && [ -f "$t" ]; then
      modelo="$(tail -c 2097152 "$t" 2>/dev/null | LC_ALL=C grep -a -F '"model":"claude-' \
        | LC_ALL=C grep -a -o -E '"model":"claude-[A-Za-z0-9._-]+"' | tail -1 | sed -E 's/^"model":"//; s/"$//')"
    fi
    nivel="$(jq -r --arg m "$modelo" \
      '(if $m == "" then null else (try .modelSettings[$m].effortLevel catch null) end) // (try .effortLevel catch null) // empty | select(type == "string")' \
      "$st" 2>/dev/null | tr '[:upper:]' '[:lower:]' | head -1)"
    case "$nivel" in ''|*[!a-z]*) nivel="" ;; *) [ "${#nivel}" -le 12 ] && origem="configuracoes" || nivel="" ;; esac
  fi
  if [ -n "$nivel" ]; then
    printf 'Esforco da sessao: %s (%s) | Ultracode: %s' "$nivel" "$origem" "$ultra"
  else
    printf 'Esforco da sessao: padrao do modelo | Ultracode: %s' "$ultra"
  fi
}

# --- registro de edicoes da sessao (para cobrar atualizacao dos documentos) ---
jornada_edits_file() {
  local session="$1" root="$2"
  mkdir -p "$JORNADA_HOME/edits" 2>/dev/null
  printf '%s' "$JORNADA_HOME/edits/$(jornada_slug "${session:-sem-sessao}--$root")"
}

# Documentos da metodologia (para nao contar como "codigo alterado").
jornada_is_doc_metodologia() {
  case "$1" in
    */PRD.md|PRD.md|*/DECISOES_TECNICAS.md|DECISOES_TECNICAS.md|*/INSUMOS.md|INSUMOS.md|\
    */CLAUDE.md|CLAUDE.md|*/docs/FSD.md|*/docs/DESIGN.md|*/docs/PLANO.md|*/docs/STATUS.md|*/docs/ERROS.md|*/docs/MANUTENCAO.md) return 0 ;;
  esac
  return 1
}
