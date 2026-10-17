#!/bin/bash
# Testes dos hooks da Jornada IA Vibe Coding.
# Chama os hooks como o Claude Code chama (JSON na entrada padrao), com HOME e
# projeto temporarios dentro de tests/.tmp-*; nao mexe no estado real.
# Uso: bash tests/testar-hooks.sh   (codigo de saida 1 se algum teste falhar)
set -u
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
S="$RAIZ/skills/jornada-vibe-coding/scripts"
TMP="$(mktemp -d "$RAIZ/tests/.tmp-XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

export HOME="$TMP/home"
export JORNADA_HOME="$HOME/.claude/jornada"
mkdir -p "$JORNADA_HOME" "$HOME/.claude/plugins"
# evita a instalacao automatica em segundo plano durante o teste
date +%Y-%m-%d > "$JORNADA_HOME/ultima-instalacao"
PROJ="$TMP/proj"
mkdir -p "$PROJ" && git -C "$PROJ" init -q

total=0; falhas=0
ok()    { total=$((total+1)); printf 'ok    %s\n' "$1"; }
falha() { total=$((total+1)); falhas=$((falhas+1)); printf 'FALHA %s\n' "$1"; }
contem()     { printf '%s' "$1" | grep -q -- "$2"; }

prompt() { # $1 sessao, $2 texto do prompt
  jq -n --arg s "$1" --arg c "$PROJ" --arg p "$2" \
    '{session_id:$s, cwd:$c, prompt:$p, hook_event_name:"UserPromptSubmit"}' | bash "$S/jornada-context.sh"
}
inicio() { # $1 sessao, $2 source (startup|resume|clear|compact)
  jq -n --arg s "$1" --arg c "$PROJ" --arg src "${2:-startup}" \
    '{session_id:$s, cwd:$c, source:$src, hook_event_name:"SessionStart"}' | bash "$S/verificar-ferramentas.sh"
}
editar() { # $1 caminho do arquivo
  jq -n --arg s "s-guard" --arg c "$PROJ" --arg f "$1" \
    '{session_id:$s, cwd:$c, tool_name:"Edit", tool_input:{file_path:$f}, hook_event_name:"PreToolUse"}' | bash "$S/jornada-guard.sh"
}

# 1. sintaxe de todos os scripts
for f in "$S"/*.sh "$RAIZ"/instalar.sh "$RAIZ"/scripts/*.sh "$RAIZ"/tests/*.sh; do
  if bash -n "$f" 2>/dev/null; then ok "sintaxe $(basename "$f")"; else falha "sintaxe $(basename "$f")"; fi
done

# 2. Jornada ligada: o prompt recebe o bloco da metodologia
: > "$JORNADA_HOME/global-on"
saida="$(prompt s1 "criar tela de login")"
if contem "$saida" "<metodologia-jornada-vibe-coding"; then ok "bloco injetado com a Jornada ativa"; else falha "bloco injetado com a Jornada ativa"; fi

# 3. ponytail: so aparece na regra que o desliga
saidas="$saida
$(inicio s1 startup)"
if printf '%s\n' "$saidas" | grep -i ponytail | grep -v -q -i deslig; then
  falha "nenhum hook manda usar o ponytail"
else ok "nenhum hook manda usar o ponytail"; fi
if contem "$saida" "PONYTAIL DESLIGADO"; then ok "bloco diz que o ponytail fica desligado"; else falha "bloco diz que o ponytail fica desligado"; fi
achados="$(grep -rIn -i ponytail "$RAIZ/skills" "$RAIZ/hooks" "$RAIZ/scripts" "$RAIZ/instalar.sh" 2>/dev/null | grep -v -i deslig)"
if [ -z "$achados" ]; then ok "skills e scripts sem ponytail"; else falha "skills e scripts sem ponytail: $achados"; fi

# 4. trava de edicao
if contem "$(editar "$PROJ/app.js")" '"deny"'; then ok "trava nega codigo sem documentos"; else falha "trava nega codigo sem documentos"; fi
if [ -z "$(editar "$PROJ/README.md")" ]; then ok "trava libera documento"; else falha "trava libera documento"; fi
mkdir -p "$PROJ/docs" && touch "$PROJ/PRD.md" "$PROJ/docs/FSD.md" "$PROJ/docs/PLANO.md" "$PROJ/docs/STATUS.md" "$PROJ/docs/ERROS.md"
if [ -z "$(editar "$PROJ/app.js")" ]; then ok "trava libera codigo com documentos"; else falha "trava libera codigo com documentos"; fi

# 5. roteamento de modelos: agente executor no Sonnet e protocolo apontando para ele
AG="$RAIZ/agents/jornada-executor.md"
cabecalho() { awk 'NR==1 && /^---$/ {f=1; next} f && /^---$/ {exit} f' "$1" 2>/dev/null; }
if cabecalho "$AG" | grep -q '^model: sonnet$'; then ok "agente jornada-executor com model: sonnet"; else falha "agente jornada-executor com model: sonnet"; fi
if cabecalho "$AG" | grep -q '^name: jornada-executor$'; then ok "agente com name jornada-executor"; else falha "agente com name jornada-executor"; fi
if contem "$saida" "jornada-executor" && contem "$saida" "ORDEM DE SERVICO"; then ok "protocolo manda delegar ao executor"; else falha "protocolo manda delegar ao executor"; fi
if [ -f "$S/../references/roteamento-modelos.md" ] && grep -q "roteamento-modelos.md" "$S/../SKILL.md"; then ok "guia de roteamento existe e o SKILL.md aponta"; else falha "guia de roteamento existe e o SKILL.md aponta"; fi
if grep -q 'agents/\*.md' "$RAIZ/instalar.sh"; then ok "instalar.sh copia os agentes"; else falha "instalar.sh copia os agentes"; fi

# 6. SessionStart e prompt calados com a Jornada desligada
rm -f "$JORNADA_HOME/global-on"
if [ -z "$(inicio s0 startup)" ]; then ok "SessionStart calado com a Jornada desligada"; else falha "SessionStart calado com a Jornada desligada"; fi
if [ -z "$(prompt s0 "oi")" ]; then ok "prompt sem bloco com a Jornada desligada"; else falha "prompt sem bloco com a Jornada desligada"; fi
: > "$JORNADA_HOME/global-on"
ss="$(inicio s0 startup)"
if contem "$ss" "Disponiveis" && ! contem "$ss" "Regras obrigatorias"; then ok "SessionStart ativo so lista as ferramentas"; else falha "SessionStart ativo so lista as ferramentas"; fi

# 7. injecao enxuta: completo, curto, completo a cada JORNADA_REFORCO e depois do SessionStart
export JORNADA_REFORCO=3
seq=""
for i in 1 2 3 4 5; do
  b="$(prompt s2 "pedido $i")"
  if contem "$b" 'bloco="completo"'; then seq="${seq}C"; elif contem "$b" 'bloco="curto"'; then seq="${seq}c"; else seq="${seq}?"; fi
  [ "$i" = "2" ] && curto="$b"
done
if [ "$seq" = "CccCc" ]; then ok "ciclo completo/curto a cada 3 ($seq)"; else falha "ciclo completo/curto a cada 3 (esperado CccCc, veio $seq)"; fi
inicio s2 compact >/dev/null
if contem "$(prompt s2 "depois de compactar")" 'bloco="completo"'; then ok "completo depois de compactar"; else falha "completo depois de compactar"; fi
if ! contem "$curto" "P0 FERRAMENTAS" && [ "${#curto}" -lt 1500 ]; then ok "bloco curto sem o protocolo inteiro (${#curto} bytes)"; else falha "bloco curto sem o protocolo inteiro (${#curto} bytes)"; fi
if contem "$curto" "jornada-executor" && contem "$curto" "UMA etapa por comando"; then ok "bloco curto traz as regras essenciais"; else falha "bloco curto traz as regras essenciais"; fi
prompt s3 "um" >/dev/null; prompt s3 "dois" >/dev/null
if contem "$(prompt s3 "/jornada-vibe-coding")" 'bloco="completo"'; then ok "ativar forca o bloco completo"; else falha "ativar forca o bloco completo"; fi
unset JORNADA_REFORCO

# 8. caveman: regras gerais so sem o plugin instalado
sem="$(prompt s4 "x")"
printf '{"plugins":{"caveman@caveman":[]}}' > "$HOME/.claude/plugins/installed_plugins.json"
com="$(prompt s5 "x")"
if contem "$sem" "CAVEMAN (SEMPRE ATIVO" && ! contem "$com" "CAVEMAN (SEMPRE ATIVO" && contem "$com" "NUNCA comprimir o que fica gravado"; then
  ok "regras do caveman so sem o plugin"; else falha "regras do caveman so sem o plugin"; fi

# 9. SKILL.md enxuto: cada ponteiro para references/detalhes-skill.md acha a secao
SK="$S/../SKILL.md"; DT="$S/../references/detalhes-skill.md"
secoes="$(grep 'detalhes-skill.md` →' "$SK" | sed 's/.*detalhes-skill.md` → //' | grep -o '"[^"]*"' | tr -d '"')"
faltam=""
while IFS= read -r h; do [ -n "$h" ] && ! grep -qF -- "$h" "$DT" && faltam="$faltam [$h]"; done <<EOF
$secoes
EOF
if [ -n "$secoes" ] && [ -z "$faltam" ]; then ok "ponteiros do SKILL.md resolvem ($(printf '%s\n' "$secoes" | wc -l | tr -d ' ') secoes)"; else falha "ponteiros do SKILL.md resolvem:$faltam"; fi
tam="$(wc -c < "$SK" | tr -d ' ')"
if [ "$tam" -lt 50000 ]; then ok "SKILL.md com menos de 50 KB ($tam bytes)"; else falha "SKILL.md com menos de 50 KB ($tam bytes)"; fi

echo
echo "$total testes, $falhas falhas"
[ "$falhas" -eq 0 ]
