#!/bin/bash
# Hook UserPromptSubmit — Jornada IA Vibe Coding.
# Ativa/desativa o modo sessão e injeta o protocolo obrigatório em TODO comando
# enquanto o modo estiver ativo. Silencioso quando inativo.
set -u
. "$(dirname "$0")/jornada-lib.sh"

payload="$(cat 2>/dev/null)"
session="$(printf '%s' "$payload" | jq -r '.session_id // ""' 2>/dev/null)"
cwd="$(printf '%s' "$payload" | jq -r '.cwd // ""' 2>/dev/null)"
prompt="$(printf '%s' "$payload" | jq -r '.prompt // ""' 2>/dev/null)"
transcript="$(printf '%s' "$payload" | jq -r '.transcript_path // ""' 2>/dev/null)"
[ -n "$cwd" ] || cwd="$PWD"
root="$(jornada_root "$cwd")"
low="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"
# So o texto do usuario liga ou desliga: notificacao de tarefa em segundo plano nao conta, e
# caminhos com jornada-vibe-coding (skills/jornada-vibe-coding/..., ~/jornada-vibe-coding-plugin)
# saem antes da comparacao.
comando=""
case "${low#"${low%%[![:space:]]*}"}" in
  "<task-notification"*) ;;
  *) comando="$(printf '%s' "$low" | sed -E 's#[[:alnum:]_.~-]+/jornada-vibe-coding[[:alnum:]_./-]*##g; s#/jornada-vibe-coding[[:alnum:]_/-]+##g')" ;;
esac

# --- desativar (checar antes de ativar) ---
case "$comando" in
  */jornada-vibe-coding\ off\ global*|*jornada\ off\ em\ todos*|*desativar\ jornada\ em\ todos*)
    jornada_global_deactivate
    jornada_deactivate "$session" "$root"
    echo "[jornada-vibe-coding] Modo metodologia DESATIVADO globalmente (todas sessoes/projetos)."
    exit 0 ;;
  */jornada-vibe-coding\ off*|*/jornada-vibe-coding\ desativar*|*/jornada\ off*|*desativar\ a\ jornada*|*desativar\ jornada*|*desligar\ jornada*|*parar\ jornada*|*jornada\ off*)
    jornada_deactivate "$session" "$root"
    echo "[jornada-vibe-coding] Modo metodologia DESATIVADO para esta sessao e para $root."
    exit 0 ;;
esac

# --- ativar ---
activated=0
case "$comando" in
  *todas\ as\ sess*e\ todos\ os\ projeto*|*todas\ sess*e\ todos\ projeto*|*jornada\ em\ todos\ os\ projetos*|*jornada-vibe-coding\ global*|*jornada\ global*)
    jornada_global_activate; jornada_activate "$session" "$root"; activated=1 ;;
  */jornada-vibe-coding*|*ativar\ a\ jornada*|*ativar\ jornada*|*jornada\ on*|*ativar\ metodologia*|*modo\ jornada*)
    jornada_activate "$session" "$root"; activated=1 ;;
esac

jornada_is_active "$session" "$root" || exit 0

missing_core="$(jornada_missing "$root" core)"
missing_all="$(jornada_missing "$root" all)"
if [ -z "$missing_all" ]; then docs_state="COMPLETOS"; else docs_state="FALTANDO: $missing_all"; fi

agents_warn=""
[ -f "$root/AGENTS.md" ] && agents_warn="ATENCAO: existe AGENTS.md em $root. Migrar o conteudo para CLAUDE.md (git mv AGENTS.md CLAUDE.md), atualizar referencias e NAO manter os dois."

if [ "$activated" = "1" ]; then
  jornada_garantir_ferramentas
  echo "[jornada-vibe-coding] MODO METODOLOGIA ATIVADO (sessao + projeto $root)."
  echo "Leia o SKILL.md da metodologia Jornada IA Vibe Coding agora e siga o protocolo P1-P8 em TODOS os comandos seguintes ate desativar."
fi

jornada_ativar_caveman

esforco_linha="$(jornada_esforco "$session" "$transcript")"

# Bloco curto: o protocolo completo ja esta no historico desta conversa.
if [ "$(jornada_injecao_modo "$session" "$activated")" = "curto" ]; then
  avisos=""
  [ -n "$agents_warn" ] && avisos="$agents_warn
"
  [ -n "$missing_core" ] && avisos="${avisos}REGRA DURA: nenhum codigo antes dos documentos; faltam: $missing_core (usar a skill estruturar-projeto).
"
  cat <<EOF
<metodologia-jornada-vibe-coding estado="ATIVA" bloco="curto">
Projeto: $root | Documentos: $docs_state
$esforco_linha
${avisos}Protocolo P0-P8 completo: no ultimo bloco completo desta conversa (volta a cada $(jornada_reforco) comandos e depois de compactar/limpar); nada foi relaxado. Essencial: grafo antes de ler codigo; documentos antes do codigo; matriz de impacto; PLANO e STATUS antes de editar; UMA etapa por comando; Opus planeja e escreve a ordem de servico, jornada-executor (Sonnet) implementa, Opus revisa e roda os testes de novo; testar de verdade; STATUS e ERROS sempre; commit + checklists 1-2-3 em linguagem leiga; ponytail desligado; documentos, checklists e commits em portugues normal; esforco: conversa em high, executor high (xhigh nas dificeis, max nas mais complexas), Ultracode so em frente grande com ok do usuario.
</metodologia-jornada-vibe-coding>
EOF
  exit 0
fi

cat <<EOF
<metodologia-jornada-vibe-coding estado="ATIVA" bloco="completo">
Projeto: $root
$esforco_linha
Documentos da metodologia: $docs_state
$agents_warn

REGRA DURA: nenhum codigo antes dos documentos. O hook PreToolUse bloqueia Edit/Write/MultiEdit em arquivos de codigo enquanto faltar: $JORNADA_CORE_DOCS

Para QUALQUER pedido (criar / alterar / implementar / corrigir), execute nesta ordem:
P0 FERRAMENTAS OBRIGATORIAS (uso automatico em TODO passo): tokensave, rtk, code-review-graph, graphify, tokenoptim (CLI) + caveman, context-mode, token-optimizer e claude-hud (plugins). As CLI faltantes ja sao baixadas e instaladas em segundo plano pelo proprio plugin (log ~/.claude/jornada/instalacao.log) — nao pedir permissao, so nao dependa delas antes de terminar. Se faltar o plugin caveman, pedir ao usuario: /plugin marketplace add JuliusBrussee/caveman + /plugin install caveman@caveman. TRAVA: o hook PreToolUse bloqueia Read/Grep/Glob em arquivos de codigo enquanto o P1 nao for feito; a trava cai na primeira chamada de mcp__tokensave__* ou mcp__code-review-graph__*. Combinar quantas ferramentas couberem no mesmo passo — quanto mais, menos token. Insumos longos->graphify(+tokenoptim). Mapear->tokensave(_context,_search,_entities)+code-review-graph(arquitetura,fluxos), em paralelo na mesma mensagem. Planejar/impacto->tokensave(_impact,_callers)+code-review-graph(get_impact_radius_tool)+graphify se houver graphify-out. Codificar->tokensave(_body,_signature) em vez de Read. Terminal->rtk automatico. Revisar->code-review-graph(detect_changes_tool,get_review_context_tool)+tokensave(_diff_context). Saida grande (log, JSON, web, snapshot de navegador, contar/filtrar muitos arquivos)->context-mode (ctx_execute/ctx_batch_execute/ctx_execute_file; ctx_fetch_and_index+ctx_search para docs), so o resultado entra no contexto; para editar, Read normal. Busca ampla->subagente. Relatar->caveman. Medir->npx -y ccusage@latest daily, rtk gain, /context-mode:ctx-stats; auditoria de desperdicio->skill token-optimizer (so auditar); contexto ocupado->barra do claude-hud. Detalhes: references/ferramentas-token.md.
P1 LER COM ECONOMIA DE TOKEN antes de opinar ou editar: mcp__tokensave__tokensave_context / _search / _callers / _entities (rodar 'tokensave init' se nao houver indice) e code-review-graph (build_or_update_graph_tool, get_architecture_overview_tool, get_impact_radius_tool). rtk ja filtra saida de Bash. Buscas amplas -> subagente. Nunca ler arquivo inteiro sem necessidade.
P2 DOCUMENTOS: se faltar qualquer um, usar a skill estruturar-projeto. Na PRIMEIRA vez o projeto INTEIRO tem de ser varrido, sem amostragem: rodar scripts/inventario-projeto.sh, cobrir 100% dos modulos do inventario (grafo primeiro; leitura direta obrigatoria em migrations, rotas, .env.example, manifestos, middleware/permissoes, README), entregar a TABELA DE COBERTURA (pasta -> como foi coberto -> o que faz -> entidades -> pendencias) e so entao escrever PRD, DECISOES_TECNICAS, FSD, DESIGN, INSUMOS, CLAUDE.md. Cada afirmacao dos documentos aponta a origem no codigo; o que nao der para inferir vira 'PENDENTE - confirmar com o usuario'. STATUS.md e ERROS.md nascem VAZIOS. Tudo isso ANTES de tocar em codigo. Usar CLAUDE.md — NUNCA criar AGENTS.md.
P3 CLASSIFICAR pela MATRIZ DE IMPACTO (nao pelo tamanho aparente do pedido): funcionalidade nova/alterada/removida ou regra de negocio -> PRD.md + docs/FSD.md; entidade, tabela, campo, migration, rota, endpoint, tela, fluxo -> docs/FSD.md; stack, banco, biblioteca, hospedagem, auth, perfil, permissao -> DECISOES_TECNICAS.md; variavel de ambiente, config, integracao externa, dependencia -> INSUMOS.md + DECISOES_TECNICAS.md; cor, fonte, espacamento, componente, padrao visual -> docs/DESIGN.md; etapa nova descoberta -> docs/PLANO.md; mudou como rodar/testar -> CLAUDE.md. Recurso novo ou mudanca grande: atualizar os documentos ANTES do codigo.
P4 PLANEJAR: registrar a tarefa em docs/PLANO.md (etapas) e abrir a etapa em docs/STATUS.md antes da primeira edicao de codigo. Antes da ordem de servico: LISTA DE ANGULOS (concorrencia e travas; permissao com campo vazio; entrada estranha; cancelar, repetir e reprovar depois de aprovar; dado real da producao; estados de erro, vazio e carregando; frases de tela que prometem algo; teste que reprova sem a mudanca; integracao com outras frentes; 360 px, teclado e leitor de tela) - cada angulo vira requisito na ordem de servico ou 'nao se aplica'.
P5 EXECUTAR UMA etapa por comando, conforme PLANO/FSD/DESIGN. Nao construir varias etapas de uma vez. Nao usar tecnologia fora do FSD. ROTEAMENTO DE MODELOS: voce (Opus) le pelo grafo, planeja e escreve a ORDEM DE SERVICO da etapa; a implementacao vai para o subagente jornada-executor (Sonnet) pela ferramenta Agent (subagent_type "jornada-executor"; como plugin, "jornada-vibe-coding:jornada-executor"). Fazer direto, sem delegar: mudanca pequena (ate ~30 linhas em ate 2 arquivos), codigo sensivel de seguranca (auth, sessao, permissao/RLS, criptografia, pagamento, segredos, upload), documentos da metodologia, correcao apos 2 rodadas sem sucesso do executor. Modelo da ordem de servico e checklist de revisao: references/roteamento-modelos.md. Se voce nao for Opus, avisar o usuario (/model opus) antes de planejar. Executor em effort high (fixado no agente); passar effort "xhigh" na chamada em migration ou dado de producao, concorrencia e travas, integracao externa e partes de permissao ou pagamento fora do nucleo sensivel. Etapa mais complexa (duas ou mais dessas dificuldades juntas, ou maquina de estados com 5+ estados) e nova tentativa de etapa xhigh que falhou: effort "max". Executor novo por etapa; consertos da auditoria em executor novo; paralelo so com arquivos separados, numeros reservados, banco de ensaio proprio e a sessao principal como dona de documentos e ferramentas.
P6 TESTAR de verdade: lint, typecheck, testes, build, migrations, subir servidor; se houver UI, screenshot + responsividade em docs/screenshots/. Sistema criado != sistema testado. Trabalho do executor: REVISAR o diff contra ordem de servico, FSD, DESIGN e seguranca, rodar os testes de novo e validar a UI por screenshot antes do commit; ajustes por SendMessage ao mesmo executor (ate 2 rodadas, depois assumir). Teste novo so vale se reprovar sem a mudanca. Antes de publicar frente grande ou arriscada: auditoria adversarial (Ultracode, com ok do usuario).
P7 REGISTRAR SEMPRE: docs/STATUS.md (etapa, arquivos alterados, testes e resultado, data, proxima etapa) e docs/ERROS.md (TODO erro, mesmo ja corrigido, com causa e correcao; consultar ERROS.md ANTES de corrigir). Etapas/subpassos descobertos no caminho -> PLANO.md e STATUS.md. E REVISAR a matriz do P3: atualizar TODO documento que a mudanca afetou (PRD, FSD, DECISOES_TECNICAS, INSUMOS, DESIGN, CLAUDE.md). Ao fechar, dizer em uma linha quais documentos foram atualizados e, para os que nao foram, qual foi conferido e por que nao precisou mexer. O hook Stop bloqueia o encerramento se houve codigo alterado sem STATUS.md atualizado.
P8 ENTREGAR: commit com mensagem clara + Checklist 1 (o que foi feito, linguagem leiga) + Checklist 2 (o que testar e como: acao -> resultado esperado) + Checklist 3 (regressao). Ao concluir uma etapa do STATUS.md, anexar tambem o checklist acumulado de todas as etapas ja feitas.
Concluiu todas as etapas do PLANO -> Revisao de Seguranca (Passo 5) -> Documentacao (Passo 6) -> Deploy (Passo 7) se pedido.
ESFORCO E ULTRACODE: conversa principal em high; etapa comum sem Ultracode. Se a linha 'Esforco da sessao' mostrar max ou Ultracode ligado numa etapa comum, pedir ao usuario UMA vez: /effort ultracode off e depois /effort high (se ele mantiver, respeitar). Frente grande ou arriscada (3+ modulos, 10+ arquivos, migration em producao, concorrencia, permissao, pagamento, publicacao): perguntar antes se quer planejar por angulos e auditar com Ultracode, mostrando o tamanho estimado em agentes; com o ok (ou com a palavra ultracode no pedido do usuario) usar a ferramenta Workflow: angulos e revisores model opus effort high; buscas e verificadores model sonnet effort medium; implementacao agentType jornada-executor. Mesmo com o Ultracode da sessao ligado, workflow so nesses casos. Detalhes: references/roteamento-modelos.md.

$(jornada_regras_sempre_ativas)

Prompt verbatim de cada fase: o SKILL.md da metodologia Jornada IA Vibe Coding e references/. Desativar: "/jornada-vibe-coding off".
Este bloco completo volta a cada $(jornada_reforco) comandos e depois de compactar/limpar; nos demais chega um lembrete curto — as regras daqui continuam valendo.
</metodologia-jornada-vibe-coding>
EOF
exit 0
