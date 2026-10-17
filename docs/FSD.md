# FSD — Especificação Funcional do Sistema

> Projeto: plugin Jornada IA Vibe Coding (`jornada-vibe-coding-plugin`)
> Versão do sistema descrita: 1.2.1 · Última atualização: 17/10/2026
> Cada item aponta a origem no código. O que não pôde ser confirmado está marcado como PENDENTE.

## 1. Visão geral

Plugin do Claude Code que transforma a metodologia Jornada IA Vibe Coding em modo persistente: hooks injetam o protocolo P0–P8 nos comandos, travam o que fere a metodologia (código sem documentos, `AGENTS.md`, leitura de código antes do grafo, encerrar sem `STATUS.md`) e duas skills trazem o fluxo completo (`jornada-vibe-coding`) e o bootstrap de documentos (`estruturar-projeto`). A partir da 1.2.0 o plugin também traz o subagente `jornada-executor` (Sonnet), que implementa as etapas planejadas pela sessão principal (Opus).

## 2. Documentos do projeto

`PRD.md` (o quê), `DECISOES_TECNICAS.md` (por quê), este FSD (como), `INSUMOS.md` (dependências), `docs/DESIGN.md` (padrão de mensagens), `docs/PLANO.md`, `docs/STATUS.md`, `docs/ERROS.md`, `CLAUDE.md` (como trabalhar no repositório). Documentos de uso: `README.md`, `INSTALAR.md`, `METODOLOGIA.md`.

## 3. Stack

`bash` + `jq` nos hooks; Markdown nas skills, referências, templates e agente; JSON nos manifestos (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, `hooks/hooks.json`).

## 4. Ambientes

| Ambiente | Como os hooks são registrados | Onde ficam os arquivos |
|---|---|---|
| Instalação direta (máquina do usuário) | `instalar.sh` grava os hooks em `~/.claude/settings.json` apontando para `$HOME/.claude/skills/jornada-vibe-coding/scripts/` | `~/.claude/skills/jornada-vibe-coding`, `~/.claude/skills/estruturar-projeto`, `~/.claude/agents/jornada-executor.md` |
| Plugin | `hooks/hooks.json` com `${CLAUDE_PLUGIN_ROOT}` | Pasta do plugin; o agente aparece como `jornada-vibe-coding:jornada-executor` |

## 5. Arquitetura

```
Usuário digita ──► UserPromptSubmit ─► jornada-context.sh ─► bloco completo ou curto no contexto
Sessão começa/compacta ─► SessionStart ─► verificar-ferramentas.sh ─► lista de ferramentas + zera contador do bloco
Modelo edita arquivo ─► PreToolUse(Edit|Write|MultiEdit|NotebookEdit) ─► jornada-guard.sh ─► nega se faltar documento / AGENTS.md
Modelo lê código ─► PreToolUse(Read|Grep|Glob|Bash) ─► jornada-p1-guard.sh ─► nega antes do grafo
Modelo usa grafo ─► PostToolUse(mcp__tokensave__*|mcp__code-review-graph__*) ─► jornada-p1-marca.sh ─► libera leitura
Modelo editou ─► PostToolUse(Edit|Write|...) ─► jornada-registrar-edicao.sh ─► anota arquivo
Modelo encerra ─► Stop ─► jornada-stop-guard.sh ─► bloqueia se código mudou sem STATUS.md
Sessão principal (Opus) ─► Agent(jornada-executor, Sonnet) ─► implementa a etapa ─► relatório curto ─► Opus revisa
```

Todas as funções comuns ficam em `skills/jornada-vibe-coding/scripts/jornada-lib.sh`.

## 6. Hooks

| Evento | Script | Entrada usada | Efeito |
|---|---|---|---|
| SessionStart | `verificar-ferramentas.sh` | `session_id`, `cwd`, `source`, `transcript_path` | Instala em segundo plano o que faltar (no máximo 1x por dia), grava o nível do caveman, zera o contador do bloco da sessão; no início ou retomada do processo grava o ponto de partida do detector de esforço (seção 9a); **só se a Jornada estiver ativa** injeta a lista de ferramentas disponíveis/ausentes (e como instalar as ausentes) |
| UserPromptSubmit | `jornada-context.sh` | `session_id`, `cwd`, `prompt`, `transcript_path` | Ativa/desativa pelo texto do prompt; se ativa, injeta o bloco completo ou o curto (seção 8), com a linha de esforço (seção 9a) |
| PreToolUse Edit/Write/MultiEdit/NotebookEdit | `jornada-guard.sh` | `tool_input.file_path`, `cwd` | Nega `AGENTS.md`; nega arquivo que não seja documento enquanto faltar `PRD.md`, `docs/FSD.md`, `docs/PLANO.md`, `docs/STATUS.md` ou `docs/ERROS.md`; caminhos em `~/.claude`, `/tmp` e a pasta pessoal passam |
| PreToolUse Read/Grep/Glob/Bash | `jornada-p1-guard.sh` | `tool_input`, `cwd` | Nega leitura de arquivo de código antes da primeira consulta ao grafo na sessão |
| PostToolUse tokensave/code-review-graph | `jornada-p1-marca.sh` | `session_id`, `cwd` | Grava a marca de P1 feito |
| PostToolUse Edit/Write/... | `jornada-registrar-edicao.sh` | `tool_input.file_path` | Anota o arquivo editado |
| Stop | `jornada-stop-guard.sh` | `session_id`, `cwd`, `stop_hook_active` | Bloqueia o encerramento se houve código alterado sem `docs/STATUS.md` |

## 7. Estado em disco (`$JORNADA_HOME`, padrão `~/.claude/jornada`)

| Caminho | Significado |
|---|---|
| `global-on` | Jornada ligada em todas as sessões e projetos |
| `sessions/<session_id>` | Ligada nesta sessão |
| `projects/<raiz-com-hifens>` | Ligada neste projeto |
| `p1/<sessao>--<raiz>` | Grafo já consultado (libera leitura) |
| `edits/<sessao>--<raiz>` | Arquivos editados na sessão |
| `injecao/<session_id>` (novo na 1.2.0) | Quantos comandos desde o último bloco completo |
| `esforco/<session_id>` (novo na 1.2.1) | Tamanho do histórico da conversa no último início ou retomada do processo; o detector de esforço só lê o que veio depois |
| `ultima-instalacao`, `instalacao.log` | Controle e log da instalação automática |

## 8. Protocolo injetado (1.2.0, ampliado na 1.2.1)

**Bloco completo** — protocolo P0–P8 inteiro, regra de roteamento de modelos, regra "ponytail desligado", regra de compressão. Enviado quando: (a) o comando ativou a Jornada; (b) não existe `injecao/<session_id>` (1ª mensagem da sessão, ou o SessionStart apagou a marca ao iniciar, retomar, limpar ou compactar); (c) o contador chegou a `JORNADA_REFORCO` (padrão 10).

**Bloco curto** — raiz do projeto, estado dos documentos, aviso de `AGENTS.md` se houver, e uma linha com as regras que não podem falhar (grafo antes de ler, documentos antes do código, uma etapa por comando, Opus planeja/revisa e o executor Sonnet implementa, testar de verdade, STATUS/ERROS, matriz de impacto, checklists, ponytail desligado). Enviado nos demais comandos.

Regra de compressão: com o plugin caveman instalado (`caveman@` em `~/.claude/plugins/installed_plugins.json`) e não desligado (`"caveman@...": false` em `enabledPlugins` do `~/.claude/settings.json` conta como desligado), o bloco leva só a regra própria da metodologia (documentos, checklists e commits em prosa normal); sem o plugin, leva o texto completo das regras de compressão.

Se a marca não puder ser lida ou gravada, o hook manda o bloco completo (falha para o lado seguro).

**Linha de esforço (1.2.1)** — os dois blocos trazem `Esforco da sessao: <nivel> (<origem>) | Ultracode: <ligado|desligado|nao detectado>`, calculada pelo detector da seção 9a. O bloco completo traz também: P4 com a lista de ângulos; P5 com o esforço do executor, o ciclo do executor e o paralelismo seguro; P6 com o teste que reprova sem a mudança e a auditoria antes de publicar; e uma linha "ESFORCO E ULTRACODE" com quando pedir ao usuário para mudar o esforço e quando perguntar sobre o Ultracode. O bloco curto resume essas regras em uma linha.

## 9. Roteamento de modelos

Detalhe operacional em `skills/jornada-vibe-coding/references/roteamento-modelos.md`.

1. **Sessão principal (Opus):** P1 leitura pelo grafo, P2–P4 documentos e plano, e a **ordem de serviço** da etapa (objetivo, contexto a ler, arquivos, contratos, regras, interface, segurança, ângulos, testes, esforço, paralelo, fora do escopo, critério de pronto).
2. **Executor (`jornada-executor`, Sonnet):** recebe a ordem de serviço pela ferramenta Agent, implementa a etapa, escreve e roda os testes, registra os erros em `docs/ERROS.md` e devolve um relatório curto. Não faz commit, não muda PRD/FSD/DECISOES/DESIGN/PLANO/STATUS, não decide arquitetura, para e relata quando a ordem de serviço não basta.
3. **Revisão (Opus):** confere o diff contra a ordem de serviço, o FSD, o DESIGN e a segurança; roda os testes de novo; valida a interface por screenshot quando houver; pede correções ao mesmo executor (SendMessage) até 2 rodadas; depois assume. Fecha com STATUS, matriz de impacto, commit e os três checklists.
4. **Fica no Opus, sem delegar:** mudança pequena (até ~30 linhas em até 2 arquivos), código sensível de segurança, documentos da metodologia, correção após 2 rodadas sem sucesso.
5. Se a sessão principal não estiver no Opus, o modelo avisa o usuário (`/model opus`) antes de planejar.
6. **Lista de ângulos (1.2.1):** antes de cada ordem de serviço, o Opus passa por dez ângulos — concorrência e travas; permissão com campo vazio ou anônimo; entrada estranha (vazia, longa, caracteres invisíveis, outro alfabeto, duplicada); cancelar, repetir, desfazer e reprovar depois de aprovar; dado real da produção (volume, contadores, registros antigos); estados de erro, vazio e carregando; frases de tela que prometem algo; teste que reprova sem a mudança; integração com outras frentes (migrations, numeração, textos, ferramentas); 360 px, teclado e leitor de tela. Cada ângulo vira requisito na ordem de serviço ou "não se aplica".
7. **Esforço (1.2.1):** o agente tem `effort: high`; a sessão principal passa `effort: "xhigh"` na chamada quando a etapa envolve migration ou dado de produção, concorrência e travas, integração externa, ou partes de permissão ou pagamento fora do núcleo sensível (o núcleo continua com o Opus, item 4), e `effort: "max"` na etapa mais complexa — duas ou mais dessas dificuldades juntas, ou máquina de estados com cinco ou mais estados — e na nova tentativa, num executor novo, de uma etapa `xhigh` que voltou sem sucesso depois das rodadas de ajuste (se falhar de novo, o Opus assume). A conversa principal deve estar em `high`; o modelo não muda isso sozinho — pede ao usuário, uma vez, com base na linha de esforço do bloco.
8. **Ultracode (1.2.1):** só em frente grande ou arriscada (3 ou mais módulos, 10 ou mais arquivos, migration em produção, concorrência, permissão, pagamento ou publicação), e só depois de perguntar ao usuário mostrando o tamanho estimado — salvo quando ele mesmo pediu no comando. Dois usos: planejamento por ângulos (um agente Opus por grupo de ângulos, síntese na sessão principal, plano aprovado pelo usuário antes da execução) e auditoria adversarial antes de publicar (revisores Opus por dimensão; cada achado conferido por verificadores Sonnet — dois para gravidade média ou maior, um para baixa; os confirmados vão para um executor novo). Dentro de qualquer workflow, quem implementa é o `jornada-executor`; buscas e verificações rodam no Sonnet. Sem a ferramenta Workflow, os mesmos papéis rodam como subagentes em paralelo.
9. **Ciclo do executor e paralelismo (1.2.1):** um executor novo por etapa; `SendMessage` só para as até 2 rodadas de ajuste da mesma etapa; consertos da auditoria vão para um executor novo com a lista. Executores em paralelo só com arquivos separados, números reservados (migrations, decisões, identificadores), banco de ensaio próprio (nunca ensaiar em paralelo contra a produção) e um dono só para documentos e ferramentas compartilhadas.
10. **Teste que reprova sem a mudança (1.2.1):** todo teste novo é conferido desfazendo o trecho da mudança, vendo o teste reprovar e restaurando; o relatório do executor diz como foi feito.

Agente: `agents/jornada-executor.md` no repositório; a instalação direta copia para `~/.claude/agents/`.

## 9a. Detector de esforço (1.2.1)

Função `jornada_esforco` em `scripts/jornada-lib.sh`, chamada pelo `jornada-context.sh` com o `transcript_path` e o `session_id` do payload. Ordem:

1. Variável `CLAUDE_CODE_EFFORT_LEVEL` definida → esse nível, origem "variavel CLAUDE_CODE_EFFORT_LEVEL" (a documentação diz que ela tem precedência sobre o `/effort`). Ela substitui só o nível; o Ultracode continua vindo do histórico.
2. Senão, o histórico da sessão a partir do ponto gravado em `esforco/<session_id>`, olhando só as saídas de comando local (texto que começa com `<local-command-stdout>`), nunca o texto do modelo nem resultado de ferramenta: o último `Set effort level to <nivel>` (ou `set to '<nivel>'`, quando a organização limita o nível) dá o nível, origem "/effort"; a última menção `Ultracode on` ou `Ultracode off` dá o Ultracode.
3. Senão, `~/.claude/settings.json`: `modelSettings["<modelo>"].effortLevel`, com o modelo tirado do último `"model":"claude-..."` do histórico, e depois `effortLevel`; origem "configuracoes".
4. Nada encontrado → "padrao do modelo".

Sem menção no histórico, o Ultracode aparece como "nao detectado": a sessão pode ter começado com `claude --effort ultracode`, e nesse caso o próprio Claude Code avisa o modelo. O SessionStart com `source` igual a `startup` ou `resume` grava em `esforco/<session_id>` o tamanho atual do histórico, porque o `/effort` vale só para o processo e o que veio antes de reiniciar não conta mais. Limite conhecido: depois de `/clear` o histórico é novo e o detector volta às configurações até o próximo `/effort`.

Implementação: `grep -a -b -F '<local-command-stdout>' < histórico` (o `-b` dá o byte inicial de cada linha; ler por pipe era cinco vezes mais lento no macOS — ERRO-005); um `awk` filtra a partir do ponto gravado, e só passam linhas com `"type":"user"`, sem `"type":"tool_result"` e com a string começando em `<local-command-stdout>`. O modelo do passo 3 é procurado só nos últimos 2 MB do histórico. Medido: cerca de 200 ms num histórico de 20 MB; nos históricos reais desta máquina (7 e 9 MB) a linha saiu certa: `max (/effort) | Ultracode: ligado`.

Formato conferido no código do Claude Code instalado em 17/10/2026: `Set effort level to <nivel> (this session only): <descricao>`, com ` · Ultracode on` ou ` · Ultracode off` no fim quando o Ultracode muda.

## 10. Skills e referências

| Item | Função |
|---|---|
| `skills/jornada-vibe-coding/SKILL.md` | Núcleo da metodologia: modo sessão, protocolo, regras R1–R10, fases e passos, fluxos especiais, matriz de impacto, ferramentas, roteamento de modelos |
| `skills/jornada-vibe-coding/references/*.md` | Prompts verbatim das fases (capítulos do material da Hostnet), ferramentas de token, roteamento de modelos e, na 1.2.0, `detalhes-skill.md` com as seções longas e raras retiradas do SKILL.md sem alteração |
| `skills/jornada-vibe-coding/templates/*.md` | Modelos dos 10 documentos |
| `skills/estruturar-projeto/SKILL.md` | Bootstrap: inventário, varredura completa, tabela de cobertura, geração dos documentos |
| `skills/jornada-vibe-coding/scripts/inventario-projeto.sh` | Inventário do projeto para o cold start |

## 11. Instalação

- `instalar.sh`: copia as duas skills para `~/.claude/skills`, copia `agents/*.md` para `~/.claude/agents` (novo na 1.2.0), faz backup do `settings.json` e registra os hooks.
- `scripts/instalar-ferramentas.sh` e `scripts/verificar-ferramentas.sh` na raiz: atalhos para os scripts dentro da skill.
- `skills/jornada-vibe-coding/scripts/instalar-ferramentas.sh`: instala as 9 ferramentas (`--check` só confere).

## 12. Estrutura de pastas

```
.claude-plugin/       plugin.json, marketplace.json
agents/               jornada-executor.md (novo na 1.2.0)
hooks/hooks.json      hooks no formato de plugin
scripts/              atalhos do instalador
skills/
  jornada-vibe-coding/  SKILL.md, references/, templates/, scripts/
  estruturar-projeto/   SKILL.md
tests/testar-hooks.sh (novo na 1.2.0)
docs/                 FSD, DESIGN, PLANO, STATUS, ERROS
PRD.md DECISOES_TECNICAS.md INSUMOS.md CLAUDE.md README.md INSTALAR.md METODOLOGIA.md instalar.sh LICENSE
```

## 13. Testes

`bash tests/testar-hooks.sh` — cria `HOME` e projeto temporários dentro de `tests/.tmp-*`, chama os hooks com JSON na entrada padrão e confere:
1. Bloco completo na 1ª mensagem, curto na 2ª, completo de novo depois do SessionStart e no 10º comando.
2. Nenhuma saída de hook manda usar o ponytail (só a regra que o desliga).
3. SessionStart calado quando a Jornada está desligada.
4. Trava de edição nega código sem documentos e libera documento.
5. Sintaxe de todos os scripts (`bash -n`).
6. Agente `jornada-executor` com `model: sonnet`; protocolo e SKILL.md apontando para ele; `instalar.sh` copiando os agentes.
7. Regras do caveman só sem o plugin (ou com o plugin desligado).
8. Cada ponteiro do SKILL.md para `references/detalhes-skill.md` acha a seção; SKILL.md abaixo de 50 KB.
9. (1.2.1) Agente com `effort: high`; guia de roteamento com a lista de ângulos, a política do Ultracode, a auditoria antes de publicar, o ciclo do executor e o paralelismo seguro; SKILL.md mandando usar a ferramenta Workflow só com o ok do usuário.
10. (1.2.1) Detector de esforço: nível e Ultracode lidos só de saída de comando local; o texto do modelo não conta; o SessionStart de início ignora o `/effort` anterior; variável e configurações como reserva.
11. (1.2.1) Linha de esforço nos dois blocos; bloco curto ainda abaixo de 1.500 bytes.
12. (1.2.1) Notificação de tarefa e caminhos com `jornada-vibe-coding` não ligam nem desligam a Jornada; `/jornada-vibe-coding off` digitado desliga.

Teste real (fora do script, 16/10/2026): sessão `claude -p --model opus` numa pasta temporária pediu ao `jornada-executor` uma etapa de um arquivo; `modelUsage` do resultado mostrou `claude-opus-5-5` (sessão principal) e `claude-sonnet-5-5` (executor), o arquivo foi criado e o relatório veio no formato do agente.

## 14. Segurança

- O texto do prompt nunca é executado; só comparado em `case`.
- Arquivos de estado: nome derivado do `session_id`/raiz com `/` trocado por `-`, sempre dentro de `$JORNADA_HOME`.
- Nenhum segredo é lido, gravado ou enviado.
- O executor não faz commit nem push; quem publica é a sessão principal, depois da revisão.
- (1.2.1) Ligar e desligar a Jornada só vale para texto do usuário: notificações de tarefas em segundo plano (`<task-notification>`) e caminhos de arquivo com `jornada-vibe-coding` não contam (ERRO-006). Sem isso, um relatório de agente que citasse `/jornada-vibe-coding off` desligaria as travas.
- (1.2.1) O detector de esforço só extrai texto do histórico com grep; o nível impresso é filtrado para letras minúsculas (até 12), o modelo vai ao jq como argumento e a marca da sessão fica sempre dentro de `$JORNADA_HOME` (`.` e `..` viram `sessao-.` e `sessao-..`).

## 15. Não se aplica

Banco de dados, migrations, autenticação de usuários, telas, uploads, exportações, APIs e logs de aplicação: o plugin não tem nenhum desses componentes.

## 16. Critérios de aceitação técnica (1.2.0)

- Nenhum arquivo do repositório nem da cópia instalada manda usar o ponytail; o bloco injetado diz que ele fica desligado.
- O bloco completo aparece na 1ª mensagem, depois de compactar/limpar e a cada 10 comandos; nos demais, o curto.
- O SessionStart não injeta nada com a Jornada desligada.
- O agente `jornada-executor` existe em `~/.claude/agents/` com `model: sonnet`.
- `bash tests/testar-hooks.sh` termina sem falhas.
- Versão `1.2.0` em `.claude-plugin/plugin.json`, publicada no GitHub.

### Critérios de aceitação técnica (1.2.1)

- O agente `jornada-executor` instalado tem `model: sonnet` e `effort: high`.
- Os dois blocos trazem a linha de esforço com a origem; o detector passa nos testes (variável, `/effort`, Ultracode, reinício, configurações).
- O guia `references/roteamento-modelos.md` traz a lista de ângulos, a política do Ultracode (pergunta antes, tamanho estimado, papéis e modelos), a auditoria antes de publicar, o ciclo do executor, o paralelismo seguro e a regra do teste que reprova sem a mudança.
- `bash tests/testar-hooks.sh` termina sem falhas; versão `1.2.1` publicada no GitHub.

## 17. Pendências

- PENDENTE - confirmar com o usuário: levar as mudanças da 1.2.0 e da 1.2.1 para a skill `ia5k`.
- Limite do detector de esforço: depois de `/clear`, volta às configurações até o próximo `/effort` (seção 9a).
- Limites conhecidos herdados da 1.0 continuam no PRD, seção 11.

## Apêndice A — Tabela de cobertura do cold start (16/10/2026)

Inventário: `scripts/inventario-projeto.sh` → 44 arquivos versionados (24 `.md`, 14 `.sh`, 4 `.json`, mais `LICENSE` e `.gitignore`).

| Pasta / módulo | Como foi coberto | O que faz | Entidades | Pendências |
|---|---|---|---|---|
| `.claude-plugin/` | Leitura direta (manifestos) | Nome, versão 1.1.0, marketplace `jornada` | — | — |
| `hooks/hooks.json` | Leitura direta | Registra os 7 hooks no formato de plugin | — | — |
| `skills/jornada-vibe-coding/scripts/` (11 scripts) | Grafo code-review-graph (31 funções bash) + leitura direta de lib, context, guard, p1-guard, p1-marca, registrar-edicao, stop-guard, session, verificar-ferramentas | Hooks e funções comuns | Estado em `~/.claude/jornada` | — |
| `skills/jornada-vibe-coding/SKILL.md` | Mapa de seções com tamanho (85 seções, 57 KB) + diff com a cópia instalada | Núcleo da metodologia | — | — |
| `skills/jornada-vibe-coding/references/` (8 arquivos) | Tamanhos + títulos; diff de `ferramentas-token.md` | Capítulos verbatim e ferramentas | — | — |
| `skills/jornada-vibe-coding/templates/` (10 arquivos) | Títulos das seções | Modelos dos documentos | — | — |
| `skills/estruturar-projeto/SKILL.md` | Títulos + trechos com ponytail | Bootstrap de documentos | — | — |
| `scripts/` (raiz) | Leitura direta | Atalhos para os scripts da skill | — | — |
| `instalar.sh` | Leitura direta | Instalação direta (skills + hooks) | — | — |
| `README.md`, `INSTALAR.md`, `METODOLOGIA.md` | Títulos + trechos com ponytail | Documentação de uso | — | — |
| `.mcp.json`, `.gitignore`, `LICENSE`, `CLAUDE.md` | Leitura direta | Configuração local do grafo, exclusões, licença, instruções | — | — |
| Cópia instalada `~/.claude/skills/jornada-vibe-coding` | `diff -rq` + diff linha a linha | Mais nova que o repositório: ponytail já removido em 05/10/2026 e não publicado | — | Sincronizar com o repositório (etapa 2) |
