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

prompt() { # $1 sessao, $2 texto do prompt, $3 transcript_path (opcional)
  jq -n --arg s "$1" --arg c "$PROJ" --arg p "$2" --arg t "${3:-}" \
    '{session_id:$s, cwd:$c, prompt:$p, transcript_path:$t, hook_event_name:"UserPromptSubmit"}' | bash "$S/jornada-context.sh"
}
inicio() { # $1 sessao, $2 source (startup|resume|clear|compact), $3 transcript_path (opcional)
  jq -n --arg s "$1" --arg c "$PROJ" --arg src "${2:-startup}" --arg t "${3:-}" \
    '{session_id:$s, cwd:$c, source:$src, transcript_path:$t, hook_event_name:"SessionStart"}' | bash "$S/verificar-ferramentas.sh"
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

# 5b. 1.2.1: esforco proprio do executor e regras novas do guia de roteamento
if cabecalho "$AG" | grep -q '^effort: high$'; then ok "agente jornada-executor com effort: high"; else falha "agente jornada-executor com effort: high"; fi
RT="$S/../references/roteamento-modelos.md"; faltam=""
for sec in "## Lista de ângulos" "## Esforço" "## Ultracode" "## Ciclo do executor" "## Paralelismo seguro" "reprova sem a mudança"; do
  grep -qF -- "$sec" "$RT" || faltam="$faltam [$sec]"
done
if [ -z "$faltam" ]; then ok "guia de roteamento com as regras da 1.2.1"; else falha "guia de roteamento com as regras da 1.2.1:$faltam"; fi
if grep -qF 'ferramenta **Workflow**' "$S/../SKILL.md" && grep -qF '/effort ultracode off' "$S/../SKILL.md"; then ok "SKILL.md com a politica do Ultracode e do esforco"; else falha "SKILL.md com a politica do Ultracode e do esforco"; fi
if grep -qF 'reprova sem a mudança' "$AG"; then ok "executor confere teste que reprova sem a mudanca"; else falha "executor confere teste que reprova sem a mudanca"; fi
if grep -qF 'effort: "max"' "$RT" && contem "$saida" 'effort "max"'; then ok "max nas etapas mais complexas (guia e bloco)"; else falha "max nas etapas mais complexas (guia e bloco)"; fi

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
printf '{"enabledPlugins":{"caveman@caveman": false}}' > "$HOME/.claude/settings.json"
if contem "$(prompt s6 "x")" "CAVEMAN (SEMPRE ATIVO"; then ok "plugin caveman desligado: regras voltam"; else falha "plugin caveman desligado: regras voltam"; fi
rm -f "$HOME/.claude/settings.json"

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

# 10. detector de esforco (1.2.1): linha "Esforco da sessao" nos blocos
PONTO="$(printf '\302\267')"
cmd_user() { # $1 texto de /effort; formato "content" (string)
  jq -nc --arg t "<local-command-stdout>$1</local-command-stdout>" '{type:"user",message:{role:"user",content:$t}}'
}
T="$TMP/transcript-e1.jsonl"
cmd_user "Set effort level to max (this session only): Maximum capability with deepest reasoning. $PONTO Ultracode on" > "$T"
l="$(prompt e1 "x" "$T" | grep '^Esforco da sessao')"
if contem "$l" "Esforco da sessao: max (/effort) | Ultracode: ligado"; then ok "esforco: /effort max com Ultracode ligado"; else falha "esforco: /effort max com Ultracode ligado ($l)"; fi
jq -nc --arg t "<local-command-stdout>Set effort level to low</local-command-stdout>" '{type:"assistant",message:{role:"assistant",content:[{type:"text",text:$t}]}}' >> "$T"
jq -nc --arg t "<local-command-stdout>x Set effort level to low</local-command-stdout>" '{type:"user",message:{role:"user",content:[{type:"tool_result",content:$t}]}}' >> "$T"
jq -nc --arg t "x Set effort level to low" '{type:"user",message:{role:"user",content:$t}}' >> "$T"
l="$(prompt e1 "x" "$T" | grep '^Esforco da sessao')"
if contem "$l" "max (/effort)"; then ok "esforco: texto do modelo e resultado de ferramenta nao contam"; else falha "esforco: texto do modelo e resultado de ferramenta nao contam ($l)"; fi
cmd_user "Set effort level to high (this session only): x $PONTO Ultracode off" >> "$T"
l="$(prompt e1 "x" "$T" | grep '^Esforco da sessao')"
if contem "$l" "high (/effort) | Ultracode: desligado"; then ok "esforco: vale o ultimo /effort"; else falha "esforco: vale o ultimo /effort ($l)"; fi
printf '%s\n' '{"type":"user","message":{"role":"user","content":[{"type":"text","text":"<local-command-stdout>Set effort level to xhigh (this session only): x</local-command-stdout>"}]}}' >> "$T"
l="$(prompt e1 "x" "$T" | grep '^Esforco da sessao')"
if contem "$l" "xhigh (/effort) | Ultracode: desligado"; then ok "esforco: formato text do transcript"; else falha "esforco: formato text do transcript ($l)"; fi
cmd_user "Set effort level to hi9h (this session only): x" >> "$T"
l="$(prompt e1 "x" "$T" | grep '^Esforco da sessao')"
if contem "$l" "xhigh (/effort)"; then ok "esforco: nivel com digito e ignorado"; else falha "esforco: nivel com digito e ignorado ($l)"; fi
# SessionStart startup grava o ponto de partida; sem /effort novo cai nas configuracoes
printf '%s\n' '{"type":"assistant","message":{"model":"claude-opus-5-5","role":"assistant","content":[]}}' >> "$T"
printf '{"modelSettings":{"claude-opus-5-5":{"effortLevel":"medium"}},"effortLevel":"low"}' > "$HOME/.claude/settings.json"
inicio e1 startup "$T" >/dev/null
l="$(prompt e1 "x" "$T" | grep '^Esforco da sessao')"
if contem "$l" "medium (configuracoes)"; then ok "esforco: startup zera o ponto de partida e cai nas configuracoes"; else falha "esforco: startup zera o ponto de partida e cai nas configuracoes ($l)"; fi
cmd_user "Set effort level to low (this session only): x" >> "$T"
l="$(prompt e1 "x" "$T" | grep '^Esforco da sessao')"
if contem "$l" "low (/effort)"; then ok "esforco: /effort depois do startup volta a valer"; else falha "esforco: /effort depois do startup volta a valer ($l)"; fi
printf '{"effortLevel":"high"}' > "$HOME/.claude/settings.json"
l="$(prompt e2 "x" | grep '^Esforco da sessao')"
if contem "$l" "high (configuracoes)"; then ok "esforco: effortLevel geral sem transcript"; else falha "esforco: effortLevel geral sem transcript ($l)"; fi
rm -f "$HOME/.claude/settings.json"
export CLAUDE_CODE_EFFORT_LEVEL=low
l="$(prompt e1 "x" "$T" | grep '^Esforco da sessao')"
unset CLAUDE_CODE_EFFORT_LEVEL
if contem "$l" "low (variavel CLAUDE_CODE_EFFORT_LEVEL)"; then ok "esforco: variavel CLAUDE_CODE_EFFORT_LEVEL"; else falha "esforco: variavel CLAUDE_CODE_EFFORT_LEVEL ($l)"; fi
l="$(prompt e3 "x" | grep '^Esforco da sessao')"
if [ "$l" = "Esforco da sessao: padrao do modelo | Ultracode: nao detectado" ]; then ok "esforco: sem transcript e sem configuracoes"; else falha "esforco: sem transcript e sem configuracoes ($l)"; fi
l="$(prompt e4 "x" "$TMP/nao-existe.jsonl" | grep '^Esforco da sessao')"
if contem "$l" "padrao do modelo"; then ok "esforco: transcript inexistente nao quebra"; else falha "esforco: transcript inexistente nao quebra ($l)"; fi
if contem "$curto" "Esforco da sessao" && [ "$(printf '%s' "$curto" | wc -c | tr -d ' ')" -lt 1500 ]; then ok "bloco curto com a linha de esforco ($(printf '%s' "$curto" | wc -c | tr -d ' ') bytes)"; else falha "bloco curto com a linha de esforco abaixo de 1500 bytes"; fi
completo="$(prompt e5 "x")"
if contem "$completo" "LISTA DE ANGULOS" && contem "$completo" "ESFORCO E ULTRACODE" && contem "$completo" "Esforco da sessao" && contem "$completo" 'effort "xhigh"'; then ok "bloco completo com angulos, esforco e Ultracode"; else falha "bloco completo com angulos, esforco e Ultracode"; fi
# desempenho: transcript de ~20 MB
if command -v perl >/dev/null 2>&1; then
  G="$TMP/transcript-grande.jsonl"
  yes '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"linha comum de conversa com bastante texto para encher o arquivo, sem nada de esforco, repetida muitas vezes para simular um historico longo de sessao"}]}}' | head -c 20000000 > "$G"
  printf '\n' >> "$G"; cmd_user "Set effort level to max (this session only): x $PONTO Ultracode on" >> "$G"
  ini="$(perl -MTime::HiRes=time -e 'printf "%.3f", time')"
  l="$(prompt e6 "x" "$G" | grep '^Esforco da sessao')"
  fim="$(perl -MTime::HiRes=time -e 'printf "%.3f", time')"
  dur="$(perl -e "printf '%.0f', ($fim - $ini) * 1000")"
  if contem "$l" "max (/effort) | Ultracode: ligado" && [ "$dur" -lt 1000 ]; then ok "esforco: transcript de 20 MB em ${dur} ms"; else falha "esforco: transcript de 20 MB em ${dur} ms ($l)"; fi
fi

# 11. so o texto do usuario liga ou desliga (notificacao de tarefa e caminhos nao contam)
rm -f "$JORNADA_HOME/global-on"
PROJ_ANTES="$PROJ"; PROJ="$TMP/proj-ativacao"; mkdir -p "$PROJ" && git -C "$PROJ" init -q
prompt n1 "<task-notification> relatorio: skills/jornada-vibe-coding/scripts/jornada-lib.sh alterado </task-notification>" >/dev/null
if [ -z "$(prompt n1 "oi")" ]; then ok "notificacao de tarefa nao liga a Jornada"; else falha "notificacao de tarefa nao liga a Jornada"; fi
prompt n2 "abre o ~/jornada-vibe-coding-plugin e le skills/jornada-vibe-coding/SKILL.md" >/dev/null
if [ -z "$(prompt n2 "oi")" ]; then ok "caminho com jornada-vibe-coding nao liga a Jornada"; else falha "caminho com jornada-vibe-coding nao liga a Jornada"; fi
prompt n3 "/jornada-vibe-coding" >/dev/null
prompt n3 "<task-notification> o bloco diz: Desativar: /jornada-vibe-coding off </task-notification>" >/dev/null
if [ -n "$(prompt n3 "oi")" ]; then ok "notificacao de tarefa nao desliga a Jornada"; else falha "notificacao de tarefa nao desliga a Jornada"; fi
prompt n3 "/jornada-vibe-coding off" >/dev/null
if [ -z "$(prompt n3 "oi")" ]; then ok "/jornada-vibe-coding off digitado desliga"; else falha "/jornada-vibe-coding off digitado desliga"; fi
PROJ="$PROJ_ANTES"; : > "$JORNADA_HOME/global-on"

echo
echo "$total testes, $falhas falhas"
[ "$falhas" -eq 0 ]
