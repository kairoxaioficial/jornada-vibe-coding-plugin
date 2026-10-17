# Roteamento de modelos — o Opus planeja e revisa, o Sonnet executa

> Versão 1.2.1 · 17/10/2026. Vale sempre que a Jornada estiver ativa.

## Por que dividir

- Escrever código é a parte que mais gera tokens de saída (os mais caros) e a que mais faz chamadas de ferramenta — e cada chamada relê o contexto inteiro da conversa.
- No executor, esse trabalho roda no Sonnet e num contexto pequeno: só a ordem de serviço e o código da etapa. Na sessão principal entra apenas o relatório curto que ele devolve.
- A sessão principal (Opus) fica enxuta: compacta menos, perde menos detalhe e gasta o raciocínio onde ele faz diferença — entender o sistema, decidir, especificar e revisar.
- Segunda opinião de verdade: quem revisa não é quem escreveu.

## Quem faz o quê

| Passo | Quem |
|---|---|
| P1 Ler o código pelo grafo | Opus |
| P2–P4 Documentos, matriz de impacto, plano | Opus |
| Lista de ângulos (toda etapa) | Opus |
| Planejamento por ângulos de frente grande ou arriscada (com o ok do usuário) | Workflow: um agente Opus por grupo de ângulos; síntese no Opus |
| Ordem de serviço da etapa | Opus (modelo abaixo) |
| P5 Implementar a etapa | Executor Sonnet (`jornada-executor`), em `high`; `xhigh` nas etapas difíceis; `max` nas mais complexas |
| P6 Testes automatizados | Executor escreve, roda e confere que cada teste novo reprova sem a mudança; o Opus roda de novo na revisão |
| P6 Validação visual (screenshot desktop e na menor largura do DESIGN, 360 ou 375 px) | Opus — é julgamento de beleza e de facilidade de uso |
| Revisão do diff | Opus (checklist abaixo) |
| Auditoria antes de publicar frente grande ou arriscada (com o ok do usuário) | Workflow: revisores Opus por dimensão; verificadores Sonnet; consertos por um executor novo |
| P7 `STATUS.md` e matriz de impacto | Opus; o executor registra os erros dele no `ERROS.md` e o Opus confere |
| P8 Commit e checklists em linguagem leiga | Opus |
| Revisão de segurança final (Passo 5) | Opus |

## Quando NÃO delegar (o Opus faz direto)

- Mudança pequena: até ~30 linhas em até 2 arquivos — delegar custaria mais do que fazer.
- Código sensível de segurança: autenticação, sessão, permissões/RLS, criptografia, pagamento, segredos, upload de arquivo.
- Documentos da metodologia (PRD, FSD, DECISOES_TECNICAS, DESIGN, PLANO, STATUS).
- Depois de 2 rodadas de correção sem sucesso do executor (numa etapa em `xhigh`, antes disso vem uma nova tentativa em `max` — seção Ciclo do executor).
- Quando a etapa depende de uma decisão do usuário: perguntar ao usuário primeiro, delegar depois.

## Lista de ângulos (toda etapa, antes da ordem de serviço)

Passar por cada ângulo e decidir: vira requisito na ordem de serviço (regras, interface, segurança ou testes) ou "não se aplica — motivo curto". Não é burocracia: na noite de 16 para 17/10/2026, no projeto ARCA, 22 dos 62 defeitos confirmados pela auditoria eram casos que o plano não previu, e esta lista teria pegado cerca de 24 deles — incluindo o único grave e os dois deadlocks.

1. **Concorrência e travas:** duas pessoas ou processos ao mesmo tempo; ordem das travas (deadlock); clique duplo; a mesma requisição repetida.
2. **Permissão com campo vazio:** sem responsável, sem dono, usuário anônimo, papel novo; quem vê e quem altera em cada caso.
3. **Entrada estranha:** vazia, só espaços, muito longa, caracteres invisíveis, letra de outro alfabeto parecida (homoglifo), pontuação e acentos, duplicada.
4. **Ciclo de vida:** cancelar, repetir, desfazer, reprovar depois de aprovar, item cancelado que renasce, voltar sem gravar.
5. **Dado real da produção:** volume, contadores e sequências (limite de dígitos), registros antigos fora do padrão, migrations que rodam em sequência com outras.
6. **Estados:** carregando, vazio, erro, sucesso; falha de rede ou do banco no meio da ação.
7. **Frases de tela que prometem algo:** cada frase tem de ser verdade em todos os caminhos ("vai para o orçamento novo", "o faturamento é aberto agora").
8. **Teste que reprova sem a mudança:** que teste prova a etapa; ele precisa reprovar quando a mudança é desfeita.
9. **Integração:** o que outras etapas ou frentes tocam — migrations, numeração, textos, ferramentas, documentos.
10. **360 px, teclado e leitor de tela:** largura mínima do DESIGN, foco visível, rótulos.

## Ordem de serviço (copiar e preencher)

```
ORDEM DE SERVIÇO — Etapa N: <nome>   (projeto: <raiz>)
1. Objetivo: <o que o usuário vai ver funcionando, em 1-2 frases>
2. Ler antes (só isto): <FSD §x, DESIGN §y, PRD regra z, ERROS ERRO-nnn, arquivos e símbolos>
3. Arquivos: criar <caminho> — <conteúdo>; alterar <caminho>:<símbolo> — <mudança>
4. Contratos: <assinaturas e tipos; rotas (método, caminho, entrada, saídas e códigos); schema/migration>
5. Regras de negócio e validações: <regra — origem no PRD/FSD>
6. Interface: <componentes e tokens do DESIGN; estados carregando/vazio/erro/sucesso; textos exatos; responsivo da menor largura do DESIGN a 1280 px; acessibilidade; animação>
7. Segurança: <entradas a validar; autorização exigida; segredos por variável de ambiente; riscos desta etapa>
8. Ângulos: <os 10 da lista — requisito, ou "não se aplica — motivo">
9. Testes obrigatórios: <casos: feliz, borda, erro, permissão>; cada teste novo reprova sem a mudança; comandos: <lint, typecheck, testes, build>
10. Esforço: high | xhigh | max — <motivo, se não for high>
11. Paralelo: não | sim — <arquivos exclusivos, números reservados, banco de ensaio>
12. Fora do escopo: <o que não fazer>
13. Pronto quando: <critérios que dá para conferir>
```

Quanto mais exata a ordem de serviço, melhor o resultado: o executor não adivinha — o que faltar, ele para e relata como `BLOQUEIO`.

## Esforço

| Quem | Esforço | Como |
|---|---|---|
| Conversa principal (Opus) | `high` | Comando do usuário (`/effort high`). A Jornada não muda: lê a linha `Esforco da sessao` do bloco injetado e pede, uma vez, quando não combina |
| Executor (`jornada-executor`) | `high` | Fixado no agente (`effort: high`) |
| Executor em etapa difícil | `xhigh` | Parâmetro `effort: "xhigh"` na chamada Agent. Etapa difícil: migration ou dado de produção, concorrência e travas, integração externa, partes de permissão ou pagamento fora do núcleo sensível (o núcleo fica com o Opus) |
| Executor em etapa mais complexa | `max` | Parâmetro `effort: "max"` na chamada Agent. Mais complexa: junta duas ou mais dificuldades da linha de cima (ex.: migration em produção com concorrência), é uma máquina de estados com cinco ou mais estados (aprovar, reprovar, cancelar, repetir, renascer…), ou é a nova tentativa de uma etapa em `xhigh` que voltou sem sucesso |
| Agentes de ângulos e revisores (workflow) | `high`, modelo `opus` | Opções `model` e `effort` do agente no script do workflow |
| Buscas e verificadores (workflow) | `medium`, modelo `sonnet` | Opções `model` e `effort` do agente no script do workflow |

- `max` no executor só nos casos da tabela; na conversa principal, só por escolha do usuário. A documentação do Claude Code avisa que ele tem retorno decrescente e tende a pensar demais — por isso nunca é o padrão.
- Quando pedir ao usuário: etapa comum com a linha dizendo `max` ou `Ultracode: ligado` → uma vez: "`/effort ultracode off` e depois `/effort high`" (quando desliga, a resposta do `/effort` termina em "· Ultracode off"). Se o usuário mantiver, respeitar e não repetir.

## Ultracode — workflows com vários agentes

O Ultracode não é um modelo mais inteligente: é o Claude Code abrindo vários agentes em paralelo, um conferindo o outro. Vale a pena em frente grande ou arriscada; ligado na sessão inteira, consumiu cerca de 43% do limite semanal numa noite (203 agentes no Opus, no ARCA).

**Quando:** frente grande ou arriscada — 3 ou mais módulos, 10 ou mais arquivos, migration em produção, concorrência, permissão, pagamento, ou publicação para clientes.

**Perguntar antes**, mostrando o tamanho estimado. Exemplo:

> Esta frente é grande (migration em produção e 3 módulos). Quer planejar por ângulos com Ultracode? São cerca de 5 agentes no Opus antes de qualquer código. (sim / não)

Com o "sim" — ou quando o próprio usuário escreveu `ultracode` no pedido —, chamar a ferramenta **Workflow**. Mesmo com o Ultracode da sessão ligado, a Jornada só abre workflow nesses casos (decisão do usuário em 17/10/2026). Sem a ferramenta Workflow, os mesmos papéis rodam como subagentes em paralelo (ferramenta Agent, várias chamadas na mesma mensagem).

Dentro do workflow o modelo não é escolhido sozinho: os agentes herdam o da sessão. Por isso cada agente leva `model` e `effort` explícitos.

**Planejamento por ângulos (antes do código):**
1. Opcional: buscas pelo grafo para mapear o que a frente toca — `model: "sonnet"`, `effort: "medium"`.
2. Um agente por grupo de ângulos — `model: "opus"`, `effort: "high"`: (a) concorrência, dado real e integração; (b) permissão, entrada estranha e ciclo de vida; (c) estados, frases de tela, 360 px e acessibilidade; (d) testes e critérios de aceite.
3. Síntese na sessão principal: plano, etapas e ordens de serviço. O usuário aprova o plano antes da execução — planejamento e execução são workflows separados.

Tamanho típico: 4 a 6 agentes.

**Execução:** sempre pelo `jornada-executor` (no workflow, `agentType: "jornada-executor"`; como plugin, `"jornada-vibe-coding:jornada-executor"`), uma etapa por agente, em sequência; em paralelo só no modo seguro (seção Paralelismo seguro).

**Auditoria antes de publicar (adversarial):**
1. Congelar a versão (commit) — a auditoria nunca lê código que ainda está mudando.
2. Revisores por dimensão — `model: "opus"`, `effort: "high"`: correção e regras de negócio; segurança e permissão; concorrência e dados; interface, textos, 360 px e acessibilidade; testes (cada teste novo reprova sem a mudança?).
3. Cada achado vai para verificadores que tentam derrubá-lo (na dúvida, derrubado) — `model: "sonnet"`, `effort: "medium"`: dois para gravidade média ou maior, um para baixa.
4. A sessão principal junta os confirmados, sem duplicados, e manda a lista a um executor novo; depois roda os testes de novo e faz o commit.

Tamanho típico: 5 revisores mais 1 ou 2 verificadores por achado — de 15 a 40 agentes. Acima de 25 agentes o Claude Code avisa que o workflow é grande.

No ARCA, as quatro auditorias acharam 54 defeitos novos (1 grave, cerca de 20 médios) ao custo de 186 agentes; os verificadores foram de 55% a 67% deles — no Sonnet, essa parte custa metade.

## Ciclo do executor

- Um executor novo para cada etapa, com a ordem de serviço inteira no `prompt`.
- `SendMessage` ao mesmo executor só para as até 2 rodadas de ajuste da mesma etapa; depois o Opus assume.
- Escalonamento: numa etapa em `xhigh` que continua sem sucesso depois das 2 rodadas, antes de o Opus assumir vem uma nova tentativa num executor novo em `max`, com a ordem de serviço e o relatório da falha.
- Nunca manter um executor vivo entre etapas nem esperando auditoria: o contexto dele cresce e cada passo relê tudo (no ARCA, agentes vivos a noite toda chegaram a 965 mil tokens de contexto).
- Consertos pedidos pela auditoria vão para um executor novo, com a lista de defeitos e os pontos do código — não com o histórico.

## Paralelismo seguro

Executores em paralelo só quando tudo isto vale:
- arquivos e módulos separados, sem sobreposição;
- números reservados antes, na ordem de serviço de cada um: migrations, decisões, identificadores;
- banco de ensaio próprio para cada frente — nunca ensaiar em paralelo contra o banco de produção;
- um dono só para documentos (`STATUS`, `ERROS`, `DECISOES`) e ferramentas compartilhadas: a sessão principal;
- juntar cedo, e auditar só depois de juntar.

Leitura e auditoria sem escrita podem rodar em paralelo à vontade. No ARCA, os dois auditores só de leitura rodaram em paralelo sem nenhum problema, enquanto a execução em paralelo trouxe os dois incidentes de produção da noite: a numeração de cards esgotada pelos ensaios e uma ferramenta de ensaio compartilhada gravando na produção por cerca de 1h43.

## Como chamar

- Ferramenta Agent com `subagent_type: "jornada-executor"` (instalado como plugin: `jornada-vibe-coding:jornada-executor`) e a ordem de serviço inteira no `prompt`. Etapa difícil: acrescentar `effort: "xhigh"`; etapa mais complexa: `effort: "max"`.
- Um executor por etapa (seção Ciclo do executor).
- Etapas independentes podem ir para executores em paralelo, na mesma mensagem, só no modo seguro (seção Paralelismo seguro).

## Revisão do Opus (antes do commit)

1. `git diff --stat` e o diff só dos arquivos da etapa (ou `detect_changes_tool` + `get_review_context_tool`).
2. Ordem de serviço item a item: o "pronto quando" foi cumprido? Os ângulos viraram código e teste?
3. Segurança: validação de entrada, autorização, segredos, injeção, XSS/CSRF quando houver web.
4. Interface: screenshot desktop e na menor largura do DESIGN; estados; textos; acessibilidade; aderência ao DESIGN.
5. Rodar os testes de novo — sistema criado não é sistema testado. Conferir no relatório que cada teste novo reprovou sem a mudança.
6. Ajustes: até 2 rodadas com o executor; depois disso, o Opus assume.
7. Fechar: `STATUS.md`, matriz de impacto, commit, checklists 1-2-3.

## Modelo da sessão principal

A sessão principal precisa estar no Opus (`/model opus`; nesta máquina, `"model": "opus"` no `~/.claude/settings.json`). Se o modelo atual não for o Opus, avisar o usuário antes de planejar.

## Medir

`npx -y ccusage@latest daily --breakdown` mostra o gasto por dia separado por modelo; compare uma etapa antes e depois da divisão.
