# PRD — Product Requirements Document

> **Projeto:** Jornada IA Vibe Coding — sistema de metodologia para Claude Code
> **Versão:** 1.2.1
> **Última atualização:** 17/10/2026 (v1.2.1: lista de ângulos, esforço do executor, Ultracode com pergunta antes, auditoria antes de publicar, aviso de esforço; v1.2: sem ponytail, Opus planeja e Sonnet executa, injeção enxuta)
> **Status:** ✅ Aprovado (descreve o sistema já construído e em uso)

## 1. Objetivo do sistema

Garantir que todo desenvolvimento feito com o Claude Code siga a metodologia "Jornada IA Vibe Coding" (Hostnet) do começo ao fim — documentos antes de código, trabalho em etapas, testes de verdade, registro de tudo — sem depender da memória ou da boa vontade do modelo de IA. O sistema transforma a metodologia, que originalmente era um conjunto de prompts para copiar e colar, em um modo persistente do Claude Code: uma vez ativado, ele acompanha todos os comandos da sessão e do projeto, injeta o protocolo obrigatório em cada pedido, bloqueia o que fere a metodologia e cobra o que ficou faltando antes de deixar encerrar.

Objetivo secundário: fazer tudo isso gastando o mínimo possível de tokens, usando nove ferramentas de economia (grafos de código, filtros de terminal, compressão de saída, processamento fora do contexto, medição) como parte integrante da metodologia — não como um extra — e dividindo o trabalho entre dois modelos: o Opus lê, planeja e revisa; o Sonnet escreve o código de cada etapa. Economia nunca às custas de qualidade, segurança, beleza ou facilidade de uso do sistema entregue.

## 2. Problema que será resolvido

Desenvolver com IA sem método ("vibe coding" puro) produz problemas conhecidos e repetidos:

- A IA escreve código sem entender o sistema, sem requisitos escritos e sem plano — e o resultado diverge do que o usuário queria.
- A IA constrói tudo de uma vez, sem testar, e declara pronto o que nunca rodou.
- Erros se repetem porque ninguém registra o que já quebrou e por quê.
- O conhecimento do projeto fica preso na conversa: quando o chat acaba, o contexto morre.
- Regras combinadas no início da sessão são esquecidas pelo modelo dezenas de mensagens depois.
- Ler arquivos inteiros e despejar saída bruta de terminal consome tokens que não precisavam ser gastos.

A metodologia da Hostnet resolve o método, mas cobrava disciplina manual: o usuário precisava lembrar de colar o prompt certo, na ordem certa, em um chat novo por fase. Este sistema resolve a disciplina: as regras viram travas automáticas (hooks) que valem mesmo quando o modelo "esquece", e o fluxo inteiro fica disponível como skill dentro do Claude Code.

## 3. Público usuário

- **Usuário direto:** o desenvolvedor que usa o Claude Code no dia a dia (hoje, o Adriel), em qualquer projeto — novo (greenfield) ou já existente (brownfield).
- **Beneficiário indireto:** o cliente ou dono do sistema desenvolvido, que recebe checklists em linguagem leiga, documentação de manutenção e um projeto rastreável, mesmo sem entender de programação.

## 4. Perfis de usuário

| Perfil | O que pode fazer |
|---|---|
| Desenvolvedor (usuário do Claude Code) | Ativar/desativar o modo (`/jornada-vibe-coding` / `off`), consultar o estado (`status`), pedir criação/alteração/correção de qualquer coisa, aprovar documentos (DESIGN, PRD, FSD), responder às perguntas obrigatórias, executar os testes manuais dos checklists. |
| Modelo principal (Claude Opus, planejador e revisor) | Seguir o protocolo P0–P8 injetado nos comandos, ler o código pelo grafo, criar/atualizar os documentos, planejar a etapa e escrever a ordem de serviço, revisar o trabalho do executor, testar, registrar STATUS/ERROS, fazer o commit e entregar os checklists. Não pode: editar código sem documentos, criar AGENTS.md, ler código bruto antes do mapeamento por grafo, encerrar com STATUS desatualizado. |
| Executor (Claude Sonnet, subagente `jornada-executor`) | Implementar uma etapa a partir da ordem de serviço, escrever e rodar os testes, registrar os erros em `docs/ERROS.md` e devolver um relatório curto. Não pode: planejar, mudar arquitetura ou escopo, editar PRD/FSD/DECISOES/DESIGN/PLANO/STATUS, fazer commit ou push. |
| Cliente leigo (leitor) | Ler os checklists de entrega, o `docs/COMO-PEDIR-MUDANCAS.md` e o `docs/MANUTENCAO.md` para acompanhar e pedir mudanças sem conhecimento técnico. |

## 5. Funcionalidades da primeira versão (v1)

**Modo sessão (núcleo)**
- [x] Ativação persistente por comando explícito; vale para toda a sessão e todo o projeto até desativar.
- [x] Injeção automática do protocolo P1–P8 em **todo** prompt seguinte, com o estado real dos documentos do projeto (o que existe, o que falta).
- [x] Estado consultável a qualquer momento (`on` / `off` / `status`).

**Travas (garantia por hook, não por memória do modelo)**
- [x] Bloqueio de edição de código enquanto faltar qualquer documento obrigatório (`PRD.md`, `docs/FSD.md`, `docs/PLANO.md`, `docs/STATUS.md`, `docs/ERROS.md`). Documentos, `docs/`, configs e caminhos isentos passam sempre.
- [x] Bloqueio permanente da criação de `AGENTS.md` (o padrão do usuário é `CLAUDE.md`).
- [x] Bloqueio da leitura direta de arquivos de código até o mapeamento por grafo (P1) ser feito na sessão; a trava cai sozinha na primeira consulta ao grafo.
- [x] Registro automático de tudo que foi editado na sessão.
- [x] Bloqueio do encerramento da sessão se houve alteração de código sem `docs/STATUS.md` atualizado — devolve a matriz de impacto e o trabalho continua.

**Ferramentas de economia de tokens (P0)**
- [x] Verificação das sete ferramentas a cada início de sessão, com instalação automática em segundo plano das que faltarem (no máximo uma vez por dia, com log).
- [x] Regras "sempre ligadas" de saída comprimida (caveman), injetadas em todo prompt.
- [x] Tabela de combinação obrigatória: qual ferramenta usar em cada passo da metodologia.

**Fluxo completo da metodologia (prompts verbatim)**
- [x] Fase 1 — Análise: chat de dúvidas, design system, explorar a ideia (entrevista incremental), PRD, decisões técnicas, FSD (28 seções), validação do FSD.
- [x] Fase 2 — Codificação: chat de ajuda, validação de insumos, estrutura inicial, Git/GitHub, codificação em etapas (uma fase por comando), revisão de segurança, documentação final (modo manutenção), deploy.
- [x] Fluxos especiais: edição simples, recurso maior, pedido de alteração, rollback, criação de skills, outras stacks.
- [x] Regra 0: perguntar "Quer desenvolver mais a ideia?" antes de montar documentação de pedido novo.

**Bootstrap de projetos (skill companheira `estruturar-projeto`)**
- [x] Cold start em projeto com código: inventário completo do projeto (script próprio), varredura de 100% dos módulos (sem amostragem), tabela de cobertura obrigatória antes dos documentos, e só então geração de PRD, DECISOES_TECNICAS, FSD, DESIGN, INSUMOS e CLAUDE.md — com STATUS e ERROS nascendo vazios.
- [x] Greenfield: criação da estrutura de documentos a partir da ideia, na ordem da Fase 1.

**Documentos e entregas**
- [x] Dez templates prontos (PRD, DESIGN, DECISOES_TECNICAS, FSD, INSUMOS, PLANO, STATUS, ERROS, CLAUDE.md, CHECKLIST).
- [x] Matriz de impacto: tabela que diz qual documento atualizar para cada tipo de mudança, com regra de fechamento (declarar o que foi atualizado e o que não precisou).
- [x] Três checklists em linguagem leiga ao fim de cada entrega: o que foi feito, o que testar e como, o que não pode ter quebrado (regressão).

**Versão 1.2 (16/10/2026)**
- [x] ponytail removido: com a Jornada ativa, vale o padrão de qualidade de produto definido no FSD e no DESIGN (completo, seguro, acessível, bonito), sem extrapolar o escopo.
- [x] Roteamento de modelos: o Opus lê pelo grafo, planeja, escreve a ordem de serviço e revisa; o subagente `jornada-executor` (Sonnet) implementa e testa a etapa. Mudança pequena, código sensível de segurança e documentos ficam no Opus.
- [x] Injeção enxuta: protocolo completo na 1ª mensagem, ao ativar, depois de compactar/limpar e a cada 10 comandos; lembrete curto nos demais.
- [x] Sem regras duplicadas: o SessionStart só fala quando a Jornada está ativa, e as regras do caveman não são repetidas quando o plugin dele está instalado.
- [x] SKILL.md mais leve: detalhes de fases raras ficam em `references/detalhes-skill.md`, lidos quando a fase chega.
- [x] Testes automatizados dos hooks (`tests/testar-hooks.sh`).

**Versão 1.2.1 (17/10/2026)**
- [ ] Lista de ângulos obrigatória antes de cada ordem de serviço: concorrência e travas; permissão com campo vazio ou anônimo; entrada estranha; cancelar, repetir, desfazer e reprovar depois de aprovar; dado real da produção; estados de erro, vazio e carregando; frases de tela que prometem algo; teste que reprova sem a mudança; integração com outras frentes; 360 px, teclado e leitor de tela.
- [ ] Executor com esforço próprio: `high` por padrão; `xhigh` nas etapas difíceis (migration e dado de produção, concorrência e travas, integração externa, partes de permissão ou pagamento fora do núcleo sensível).
- [ ] Ultracode só em frente grande ou arriscada, perguntando antes e mostrando o tamanho estimado: planejamento por ângulos (Opus) e auditoria adversarial antes de publicar (revisores no Opus, verificadores no Sonnet). Quem implementa é sempre o `jornada-executor`.
- [ ] Aviso de esforço: o bloco injetado mostra o esforço e o Ultracode da sessão; quando não combinam com a fase do trabalho, o modelo pede ao usuário, uma vez, para ajustar.
- [ ] Executor novo por etapa; consertos da auditoria vão para um executor novo; trabalho em paralelo só com arquivos separados, números reservados, banco de ensaio próprio e um dono para documentos e ferramentas compartilhadas.
- [ ] Teste novo só vale se reprovar sem a mudança.

## 6. Funcionalidades que ficam fora da primeira versão

- Ativação automática da metodologia sem comando explícito do usuário (decisão deliberada: o modo só liga quando pedido).
- Bloqueio de escrita de código via Bash (`cat >`, `sed -i`, scaffolds) — limite conhecido e documentado; contornar a trava por Bash é violação da metodologia, mas a contenção é por regra, não por hook.
- Verificação automática da **qualidade** dos documentos (os hooks conferem existência, não conteúdo; quem valida conteúdo é o passo de validação do FSD e a revisão de insumos, executados pelo modelo).
- Validação visual (screenshots, responsividade) garantida por hook — hoje é obrigação do modelo (regra R5), sem trava automática.
- Suporte a mais de um usuário/máquina compartilhando o mesmo estado de sessão.
- Painel ou relatório consolidado do histórico de sessões e edições.

## 7. Regras de negócio

- Nenhum código antes dos documentos. Faltou documento → criar todos primeiro (bootstrap), depois planejar, depois codificar.
- Uma fase por comando. Nunca construir duas fases no mesmo turno, mesmo "sobrando contexto".
- Sistema criado ≠ sistema testado. Nenhuma etapa é declarada concluída sem teste real executado.
- Todo erro é registrado em `docs/ERROS.md` (mesmo já corrigido), e o histórico é consultado **antes** de corrigir erro novo.
- `docs/STATUS.md` é atualizado a cada avanço — e o encerramento da sessão é bloqueado se isso não aconteceu.
- O arquivo de instruções do projeto é `CLAUDE.md`; `AGENTS.md` nunca é criado, e se existir deve ser migrado.
- O mapeamento por grafo (P1) vem antes de qualquer leitura bruta de código, em toda sessão.
- O FSD define a tecnologia; a IA não inventa stack, biblioteca ou padrão fora dele sem perguntar.
- Checklists de entrega são sempre em linguagem leiga, com "ação → resultado esperado".
- A compressão de saída (caveman) nunca alcança o que fica gravado: documentos da metodologia, checklists e mensagens de commit saem em português normal, por extenso. Código, comandos, caminhos, erros, números e versões nunca são comprimidos.
- No cold start, a cobertura do projeto é total (100% dos módulos do inventário); amostragem não vale. Ao mesmo tempo, ler arquivo inteiro quando o grafo resolvia é desperdício — as duas regras valem juntas.
- Concluídas todas as etapas do PLANO: revisão de segurança → documentação final → deploy (se pedido), nesta ordem.
- Quem planeja e revisa é o Opus; quem implementa a etapa é o executor Sonnet, sempre a partir de uma ordem de serviço escrita. O executor nunca faz commit e para quando a ordem de serviço não basta. Mudança pequena, código sensível de segurança e documentos não são delegados.
- Com a Jornada ativa, o ponytail fica desligado, mesmo que outra regra peça.
- (v1.2.1) Antes de cada ordem de serviço, o Opus passa pela lista de ângulos; cada ângulo vira requisito na ordem de serviço ou "não se aplica".
- (v1.2.1) Workflow com vários agentes (Ultracode) só em frente grande ou arriscada, e só com o ok do usuário dado depois de ver o tamanho estimado — salvo quando o próprio usuário pediu no comando. Dentro do workflow, quem implementa é o `jornada-executor`; buscas e verificações rodam no Sonnet; ângulos e revisões, no Opus.
- (v1.2.1) Esforço: conversa principal em `high`; executor em `high`, e `xhigh` nas etapas difíceis; `max` só por escolha do usuário, para um problema muito difícil. O modelo não muda o esforço da conversa sozinho: pede ao usuário, uma vez.
- (v1.2.1) Teste novo só vale se reprovar sem a mudança.

## 8. Informações que o sistema precisa controlar

- **Estado de ativação por sessão:** quais sessões do Claude Code estão com o modo ligado.
- **Estado de ativação por projeto:** quais projetos estão sob a metodologia (sobrevive entre sessões).
- **Marca de P1 por sessão/projeto:** se o mapeamento por grafo já foi feito (libera a leitura de código).
- **Registro de edições da sessão:** quais arquivos foram alterados (insumo da trava de encerramento).
- **Situação dos documentos do projeto:** existência de cada documento obrigatório, verificada a cada prompt.
- **Situação das nove ferramentas:** instaladas/faltando, com log de instalação automática.
- **Contador de injeção por sessão:** quantos comandos desde o último protocolo completo (decide bloco completo ou curto).
- **Ponto de partida do aviso de esforço por sessão (v1.2.1):** tamanho do histórico da conversa no último início ou retomada do processo; o esforço e o Ultracode são lidos do `/effort` registrado depois dele, ou das configurações.
- **Nível do modo de saída comprimida:** persistido entre sessões.
- **Os dez documentos do projeto em si** (PRD, DESIGN, DECISOES_TECNICAS, FSD, INSUMOS, PLANO, STATUS, ERROS, CLAUDE.md, CHECKLIST) — criados e mantidos dentro de cada projeto, não no sistema.

## 9. Fluxos principais de uso

1. **Ativar o modo:** usuário digita `/jornada-vibe-coding` → sessão e projeto ficam marcados → todo prompt seguinte chega ao modelo com o protocolo P1–P8 e o estado dos documentos → o modelo confere o que existe/falta antes de qualquer coisa.
2. **Pedido de desenvolvimento com documentos completos:** usuário pede algo → P1 mapear pelo grafo → P3 classificar a mudança pela matriz de impacto → P4 registrar em PLANO/STATUS → P5 executar uma etapa → P6 testar de verdade → P7 registrar STATUS/ERROS e atualizar os documentos afetados → P8 commit + três checklists em linguagem leiga → parar e aguardar o próximo comando.
3. **Pedido em projeto sem documentos (cold start):** a trava bloqueia a edição de código → bootstrap `estruturar-projeto`: inventário completo, varredura de 100% dos módulos, tabela de cobertura, geração de todos os documentos (STATUS e ERROS vazios) → só então o pedido original é planejado e executado pelo fluxo 2.
4. **Sistema novo do zero (greenfield):** Regra 0 ("Quer desenvolver mais a ideia?") → Fase 1 na ordem (design system → explorar ideia → PRD → decisões técnicas → FSD → validação) com aprovação do usuário em cada documento → Fase 2 (insumos → estrutura → Git → codificação em etapas, uma por comando) → revisão de segurança → documentação final → deploy se pedido.
5. **Edição simples (bug pequeno, ajuste):** aplicar direto → testar → atualizar STATUS e ERROS → entregar checklists. PRD/FSD não são tocados.
6. **Tentativa de violação:** modelo tenta editar código sem documentos, criar AGENTS.md ou ler código antes do P1 → o hook devolve mensagem explicando o que falta → o modelo corrige o caminho (cria documentos, faz o mapeamento) e repete a ação.
7. **Encerramento:** modelo tenta encerrar com código alterado e STATUS desatualizado → a trava devolve a matriz de impacto → o modelo atualiza os documentos e declara, em uma linha, o que atualizou e o que conferiu sem precisar mexer.

## 10. Critérios de aceitação

- Com o modo ativo, é impossível editar arquivo de código (pelas ferramentas de edição) em projeto sem os cinco documentos obrigatórios — e a mensagem de bloqueio diz exatamente o que falta.
- `AGENTS.md` nunca é criado, em nenhuma circunstância, com o modo ativo.
- Todo prompt do usuário, enquanto o modo estiver ativo, chega ao modelo acompanhado do protocolo P1–P8 e do estado real dos documentos do projeto.
- A leitura direta de código só funciona depois de uma consulta ao grafo na sessão — e volta a funcionar sozinha, sem intervenção do usuário.
- Uma sessão que alterou código não encerra sem `docs/STATUS.md` atualizado.
- Ao início de cada sessão, as ferramentas faltantes começam a ser instaladas sozinhas, sem pedir permissão e sem travar o trabalho.
- Toda entrega termina com os três checklists em linguagem leiga e com a linha de fechamento da matriz de impacto.
- O bootstrap em projeto existente produz a tabela de cobertura fechando com o inventário **antes** de qualquer documento ser escrito.
- Desativar o modo (`off`) devolve o Claude Code ao comportamento normal imediatamente.
- (v1.2) Nenhuma instrução do plugin manda usar o ponytail; o bloco injetado diz que ele fica desligado.
- (v1.2) O protocolo completo chega na 1ª mensagem da sessão, depois de compactar/limpar e a cada 10 comandos; nos demais chega o lembrete curto.
- (v1.2) As etapas de código são implementadas pelo executor Sonnet e revisadas pelo Opus antes do commit.
- (v1.2.1) O bloco injetado mostra o esforço e o Ultracode da sessão, com a origem da informação.
- (v1.2.1) O executor roda em `high` por padrão; a ordem de serviço declara quando a etapa vai em `xhigh`.
- (v1.2.1) Nenhum workflow com vários agentes é aberto sem o ok do usuário, salvo quando ele mesmo pediu no comando.
- (v1.2.1) Toda ordem de serviço traz os ângulos considerados, e todo teste novo foi visto reprovando sem a mudança.
- (v1.2.1) Notificações de tarefas em segundo plano e caminhos de arquivo não ligam nem desligam a metodologia; só o texto do usuário.

## 11. Dúvidas ou decisões pendentes

- [ ] Cobrir escrita de código via Bash (hoje é o limite conhecido da trava — contenção só por regra).
- [ ] Trava automática para a validação visual (R5) — hoje depende da disciplina do modelo.
- [ ] Verificação de qualidade mínima dos documentos pelos hooks (ex.: STATUS atualizado de verdade vs. tocado por tocar).
- [ ] O passo de deploy é escrito para a Hostnet (GitHub Actions + rsync); generalizar para outras hospedagens está descrito no capítulo "Outras Stacks", mas sem prompt verbatim próprio por provedor.
- [ ] Relatório consolidado do histórico (`~/.claude/jornada/edits/`, `p1/`, `sessions/`) para auditoria entre sessões.

---
*O PRD explica O QUE o sistema faz. O porquê das escolhas está em `DECISOES_TECNICAS.md` e o como, em `docs/FSD.md`.*
