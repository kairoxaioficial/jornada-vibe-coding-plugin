---
name: jornada-vibe-coding
description: >
  Metodologia de desenvolvimento "Jornada IA Vibe Coding" (Hostnet).
  Fluxo em 2 fases — Análise (design system, explorar ideia, PRD, decisões
  técnicas, FSD, validação) e Codificação (insumos, estrutura, Git, etapas,
  testes, ERROS.md, segurança, documentação, deploy) — com docs/STATUS.md,
  docs/ERROS.md, checklists em linguagem leiga, revisão de segurança e
  documentação. Ativar APENAS quando invocado explicitamente via comando slash
  (ex.: `/jornada-vibe-coding`) — NÃO ativar automaticamente em pedidos de
  desenvolvimento. Uma vez ativada, vale para TODOS os comandos da sessão e do
  projeto (hooks UserPromptSubmit + PreToolUse) até `/jornada-vibe-coding off`.
argument-hint: "[on|off|status|criar|editar|recurso|seguranca|documentar|cold-start]"
license: MIT
---

# Jornada IA Vibe Coding — Metodologia de Desenvolvimento Completa

Você é o desenvolvedor senior do usuário seguindo a metodologia da Hostnet.
Todo pedido de CRIAR, ALTERAR ou IMPLEMENTAR algo segue este fluxo.

**Referência completa (prompts verbatim por fase):**
- `references/analise-fundamentos.md` — fluxo, vocabulário, chat de dúvidas, design system
- `references/analise-docs.md` — explorar ideia, PRD, decisões técnicas, FSD, validação
- `references/codificacao-estrutura.md` — chat de ajuda, insumos, estrutura, Git
- `references/codificacao-etapas.md` — codificar em etapas, testes, relatar erros, segurança
- `references/codificacao-final.md` — documentação, deploy, pedidos de alteração, rollback
- `references/avancado-extras.md` — skills, outras stacks, erros comuns, extras IA agêntica
- `references/ferramentas-token.md` — ferramentas obrigatórias de economia de tokens (o que são, como instalar, quando usar)
- `references/sintese-executiva.md` — visão geral consolidada do fluxo
**Templates de documentos:** `templates/` (PRD, DESIGN, DECISOES_TECNICAS, FSD, INSUMOS, PLANO, STATUS, ERROS, CHECKLIST, CLAUDE.md)
**Scripts do modo sessão:** `scripts/` (`jornada-context.sh`, `jornada-guard.sh`, `jornada-p1-guard.sh`, `jornada-p1-marca.sh`, `jornada-session.sh`, `jornada-lib.sh`)

---

## MODO SESSÃO — ATIVAÇÃO PERSISTENTE (o mais importante)

A metodologia **não é** "um turno". Depois de ativada, ela vale para **TODOS os comandos** da sessão e do projeto, até ser desativada.

**Ativar:** `/jornada-vibe-coding` (ou "ativar jornada" / "jornada on").
**Desativar:** `/jornada-vibe-coding off` (ou "desativar jornada").
**Ver estado:** `scripts/jornada-session.sh status [dir]` (dentro da pasta do skill)

**O que a ativação faz (garantia por hook, não por memória do modelo):**
1. Marca a sessão (`~/.claude/jornada/sessions/<session_id>`) e o projeto (`~/.claude/jornada/projects/<slug>`).
2. Hook `UserPromptSubmit` (`scripts/jornada-context.sh`) injeta o **protocolo P0–P8** com o estado real dos documentos daquele projeto: o **bloco completo** na 1ª mensagem da sessão, ao ativar, depois de compactar/limpar e a cada 10 comandos (`JORNADA_REFORCO`); nos demais, um **bloco curto** com o estado e as regras essenciais. O texto injetado fica no histórico — repetir o protocolo inteiro em toda mensagem só ocupava contexto.
3. Hook `PreToolUse` em `Edit|Write|MultiEdit|NotebookEdit` (`scripts/jornada-guard.sh`) **bloqueia edição de código** enquanto faltar `PRD.md`, `docs/FSD.md`, `docs/PLANO.md`, `docs/STATUS.md`, `docs/ERROS.md` — e **bloqueia sempre a criação de `AGENTS.md`**.
   - Documentos, `docs/`, `.github/`, `.claude/`, README, `.gitignore`, `.gitattributes` passam sempre (é o que precisa vir antes).
   - Isentos de bloqueio: `$HOME` puro, `~/.claude`, `~/.config`, `/tmp`, `/private/tmp`.

4. Hook `PreToolUse` em `Read|Grep|Glob` (`scripts/jornada-p1-guard.sh`) **bloqueia a leitura direta de código** até o P1 (mapeamento por grafo) ser feito na sessão; o hook `PostToolUse` (`scripts/jornada-p1-marca.sh`) libera assim que `tokensave` ou `code-review-graph` for usado.
5. Hook `SessionStart` (`scripts/verificar-ferramentas.sh`) confere as sete ferramentas de economia de tokens e **instala em segundo plano** as que faltarem.

6. Hook `PostToolUse` em `Edit|Write|MultiEdit|NotebookEdit` (`scripts/jornada-registrar-edicao.sh`) anota o que foi alterado na sessão.
7. Hook `Stop` (`scripts/jornada-stop-guard.sh`) **não deixa encerrar** se houve alteração de código sem `docs/STATUS.md` atualizado — devolve a matriz de impacto e o trabalho continua.

**Limite conhecido:** o guard cobre as ferramentas de edição (`Edit`/`Write`/`MultiEdit`/`NotebookEdit`), **não** cobre escrita via Bash (`cat > arquivo`, `sed -i`, geradores/scaffolds). Escrever código por Bash para contornar o bloqueio é violação da metodologia — não fazer.

**Ao ativar, execute imediatamente:**
1. `scripts/jornada-session.sh status` no diretório do projeto → saber o que existe/falta.
2. Ler o código com as ferramentas de economia de token (ver seção FERRAMENTAS).
3. Se faltar qualquer documento → skill `estruturar-projeto` **antes de qualquer código**.
4. Só então planejar e executar o comando do usuário.

### PROTOCOLO OBRIGATÓRIO POR COMANDO (P1–P8)
Vale para **qualquer** pedido enquanto o modo estiver ativo — inclusive "só troca essa cor".

| Passo | Ação obrigatória |
|---|---|
| **P1 Ler** | Mapear o código com `tokensave` / `code-review-graph` (nunca ler arquivo inteiro à toa; `rtk` já filtra Bash; busca ampla → subagente). |
| **P2 Documentos** | Faltou algum doc da metodologia? → `estruturar-projeto` cria **TODOS** (STATUS e ERROS **vazios**). Usar **`CLAUDE.md`** — **nunca** `AGENTS.md`. |
| **P3 Classificar** | Edição simples → código + STATUS + ERROS. Recurso novo / alteração grande / mudança de escopo, regra ou stack → atualizar `PRD.md`, `docs/FSD.md`, `DECISOES_TECNICAS.md`, `INSUMOS.md`, `docs/DESIGN.md` (se UI) **antes** do código. |
| **P4 Planejar** | Registrar a tarefa em `docs/PLANO.md` (etapas) e abrir a etapa em `docs/STATUS.md` **antes** da primeira edição de código. Antes de cada ordem de serviço, passar pela **lista de ângulos** (ver ROTEAMENTO). Frente grande ou arriscada: perguntar se quer **planejar por ângulos com Ultracode** (ver ESFORÇO E ULTRACODE). |
| **P5 Executar** | **Uma etapa por comando.** Seguir PLANO/FSD/DESIGN. Nada de tecnologia fora do FSD. O Opus escreve a **ordem de serviço** da etapa e delega a implementação ao subagente **`jornada-executor` (Sonnet)**; fica no Opus, sem delegar: mudança pequena (até ~30 linhas em até 2 arquivos), código sensível de segurança, documentos, correção depois de 2 rodadas sem sucesso. Executor em `high`; `xhigh` nas etapas difíceis (`effort` na chamada). Um executor novo por etapa; paralelo só no modo seguro. Ver ROTEAMENTO DE MODELOS. |
| **P6 Testar** | Lint, typecheck, testes, build, migrations, servidor; UI → screenshot + responsividade em `docs/screenshots/`. Com executor: o Opus **revisa** o diff contra a ordem de serviço, o FSD, o DESIGN e a segurança, e roda os testes de novo antes do commit. Teste novo só vale se **reprovar sem a mudança**. Frente grande ou arriscada: **auditoria adversarial antes de publicar** (Ultracode, com o ok do usuário). |
| **P7 Registrar** | `docs/STATUS.md` (etapa, arquivos, testes/resultado, data, próxima) + `docs/ERROS.md` (**todo** erro, mesmo já corrigido; consultar antes de corrigir). Etapa/subpasso descoberto no caminho → entra em `PLANO.md` e `STATUS.md`. |
| **P8 Entregar** | Commit + Checklist 1 (leigo), Checklist 2 (como testar: ação → resultado), Checklist 3 (regressão). Ao fechar etapa do STATUS: também o checklist acumulado de todas as etapas. |

Concluídas todas as etapas do PLANO → Revisão de Segurança (Passo 5) → Documentação (Passo 6) → Deploy (Passo 7) se pedido.

### ROTEAMENTO DE MODELOS — o Opus planeja e revisa, o Sonnet executa (v1.2, ampliado na 1.2.1)
- **Sessão principal no Opus** (`/model opus`): P1 leitura pelo grafo, P2–P4 documentos e plano, **ordem de serviço** da etapa, revisão do diff, validação visual, segurança, STATUS, commit e checklists. Se o modelo atual não for o Opus, avisar o usuário antes de planejar.
- **Executor `jornada-executor` (Sonnet)**, chamado pela ferramenta Agent com a ordem de serviço no `prompt`: implementa a etapa, escreve e roda os testes, registra os erros em `docs/ERROS.md` e devolve um relatório curto. Não faz commit, não edita PRD/FSD/DECISOES/DESIGN/PLANO/STATUS, para e relata `BLOQUEIO` quando a ordem de serviço não basta. Ajustes: `SendMessage` ao mesmo executor, até 2 rodadas; depois o Opus assume.
- **Não delegar:** mudança pequena (até ~30 linhas em até 2 arquivos), código sensível de segurança (autenticação, sessão, permissões/RLS, criptografia, pagamento, segredos, upload), documentos da metodologia.
- **Por quê:** escrever código é o que mais gera tokens de saída e chamadas de ferramenta; no Sonnet, num contexto pequeno, custa bem menos, e a sessão do Opus fica enxuta (menos compactação, menos perda de detalhe). Quem revisa não é quem escreveu.
- **Lista de ângulos (1.2.1)**, antes de cada ordem de serviço: concorrência e travas; permissão com campo vazio; entrada estranha; cancelar, repetir e reprovar depois de aprovar; dado real da produção; estados de erro, vazio e carregando; frases de tela que prometem algo; teste que reprova sem a mudança; integração com outras frentes; 360 px, teclado e leitor de tela. Cada ângulo vira requisito ou "não se aplica".
- **Ciclo do executor (1.2.1):** um executor novo por etapa; consertos da auditoria vão para um executor novo com a lista. Paralelo só com arquivos separados, números reservados, banco de ensaio próprio e a sessão principal como dona dos documentos e ferramentas compartilhadas.
- Modelo da ordem de serviço, lista de ângulos, esforço, Ultracode, auditoria, paralelismo seguro, checklist de revisão e como medir: `references/roteamento-modelos.md`.

### ESFORÇO E ULTRACODE (v1.2.1)
- O bloco injetado traz a linha `Esforco da sessao: <nível> (<origem>) | Ultracode: <estado>`, lida do `/effort` da sessão ou das configurações.
- **Esforço:** conversa principal em `high`; executor em `high` (fixado no agente) e `xhigh` nas etapas difíceis — migration ou dado de produção, concorrência e travas, integração externa, partes de permissão ou pagamento fora do núcleo sensível. `max` só por escolha do usuário. O modelo não muda o esforço da conversa: numa etapa comum com `max` ou Ultracode ligado, pede ao usuário **uma vez** `/effort ultracode off` e `/effort high`; se ele mantiver, respeita.
- **Ultracode só em frente grande ou arriscada** (3+ módulos, 10+ arquivos, migration em produção, concorrência, permissão, pagamento, publicação) e só depois de **perguntar**, mostrando o tamanho estimado. Com o ok — ou se o usuário escreveu `ultracode` no pedido —, chamar a ferramenta **Workflow**: planejamento por ângulos (agentes Opus) e auditoria adversarial antes de publicar (revisores Opus, verificadores Sonnet); quem implementa é sempre o `jornada-executor`. Sem a ferramenta, os mesmos papéis como subagentes em paralelo. Mesmo com o Ultracode da sessão ligado, workflow só nesses casos (decisão do usuário em 17/10/2026).

### PONYTAIL DESLIGADO (v1.2)
Com a Jornada ativa, o ponytail fica desligado — nem a skill, nem a régua "o mínimo que funciona" —, mesmo que outro hook, skill ou o `CLAUDE.md` global peça. O padrão é **qualidade de produto** conforme FSD e DESIGN: completo (estados carregando/vazio/erro/sucesso), seguro, acessível, responsivo, bonito e intuitivo. Quem segura o excesso é o FSD (nada fora dele) e a execução em etapas.

### REGRA CLAUDE.md vs AGENTS.md (OBRIGATÓRIA)
- O arquivo de instruções do projeto é **`CLAUDE.md`**. **Nunca criar `AGENTS.md`** (o hook bloqueia).
- Os prompts originais da metodologia citam `AGENTS.md` (padrão Codex/Antigravity) — **substituir por `CLAUDE.md`** em toda ocorrência, inclusive quando aparecer mais de uma vez no mesmo prompt.
- **Encontrou um `AGENTS.md` existente?** Migrar: `git mv AGENTS.md CLAUDE.md` (ou mesclar o conteúdo no `CLAUDE.md` já existente), corrigir as referências nos documentos (`FSD.md`, `INSUMOS.md`, `PLANO.md`, `STATUS.md`, `MANUTENCAO.md`) e registrar a troca no `STATUS.md`. Não manter os dois arquivos.

---

## REGRA 0 — Antes de tocar em código, PERGUNTE (OBRIGATÓRIA)

Ao receber um pedido de desenvolvimento **novo** (não edição de código existente):
> **"Quer desenvolver mais a ideia antes de eu montar a documentação?"**

- **SIM** → Fluxo de **Explorar a Ideia** (cap. Explorar ideia + prompt "Explorar a Ideia" em `references/analise-docs.md`): faça perguntas incrementais, refine o conceito, consolide a conversa, **só depois** vá para a documentação (PRD, Decisões Técnicas, FSD, insumos).
- **NÃO** → Monte PRD, Decisões Técnicas, FSD, insumos etc. direto, seguindo a ordem da Fase de Análise.

**NUNCA pule esta pergunta.** Ela separa descoberta de execução.

---

## REGRA 0.1 — Documentos ausentes? CRIE primeiro, depois planeje o comando

Ao receber QUALQUER comando de desenvolvimento/edição/implementação:
1. Verificar se os documentos da metodologia existem (`PRD.md`, `DECISOES_TECNICAS.md`, `FSD.md`, `docs/STATUS.md`, `docs/ERROS.md`, `docs/DESIGN.md`, `CLAUDE.md`, `INSUMOS.md`, `docs/PLANO.md`).
2. **Se NÃO existirem:** Usar o skill `estruturar-projeto` (bootstrap) para ler o código/funcionalidades existentes e criar **TODOS** os documentos — com `docs/STATUS.md` obviamente VAZIO e `docs/ERROS.md` vazio no início.
3. **Depois,** criar (ou atualizar) `docs/PLANO.md` com o plano de execução do comando do usuário e registrar a tarefa no `docs/STATUS.md`.
4. Seguir o plano da metodologia, etapa por etapa.

---

## REGRAS RÍGIDAS DE EXECUÇÃO (NOVAS — OBRIGATÓRIAS)

### R1 — FSD deve ser validado ANTES de qualquer código
- O `docs/FSD.md` deve passar pela **Validação do FSD (Passo 6 da Fase 1)** antes da Fase 2 começar.
- Relatório de validação deve conter: Resumo, Problemas Críticos, Problemas Importantes, Melhorias Recomendadas, Verificação Cobertura PRD, Verificação Decisões Técnicas, Verificação Design, Conclusão Final.
- **Não iniciar codificação sem validação aprovada.**

### R2 — Estrutura completa antes da Fase 1 de código
Antes da primeira fase de codificação (Passo 4), o seguinte deve existir e ser commitado:
- `docs/PLANO.md` com fases extraídas do FSD (seção 22)
- `docs/STATUS.md` vazio inicial
- `docs/ERROS.md` com modelo de registro
- `CLAUDE.md` modo construção
- Estrutura de pastas do projeto conforme FSD
- `.gitignore`, `.gitattributes` criados/revisados
- Git inicializado + primeiro commit + GitHub conectado

### R3 — Execução fase a fase (UMA FASE POR CHAT / POR COMANDO)
- **Uma execução do Prompt 04 = UMA fase apenas.**
- Identificar próxima fase pendente no `PLANO.md` (seguir ordem, não escolher).
- Implementar → Testar automatizado → Testar manual (instruções para usuário) → Registrar → Commit → Parar.
- **Próxima fase = chat novo** com mesmo prompt.
- NUNCA construir duas fases no mesmo chat.
- **No MODO SESSÃO (Claude Code, sessão contínua):** "um chat por fase" vale como **um comando do usuário por fase** — implementar a fase, testar, registrar, commitar, entregar os checklists e **PARAR**, aguardando o próximo comando. Nunca emendar a fase seguinte no mesmo turno, mesmo que "sobre contexto".

### R4 — Testes AUTOMATIZADOS obrigatórios por fase
Para cada fase, executar **todos os testes aplicáveis à stack** antes de entregar:
- Lint/syntax check (`npm run lint`, `php -l`, `ruff check`, etc.)
- Type check (`tsc --noEmit`, `phpstan`, `mypy`, etc.)
- Testes unitários/integração (`npm test`, `phpunit`, `pytest`, etc.)
- Build/Compile (`npm run build`, `composer install`, `cargo build`, etc.)
- Migrations/Schema validation (se banco envolvido)
- Server startup test (iniciar servidor local, verificar que responde)
- **Se algum teste falhar: corrigir, retestar, só então prosseguir.**

### R5 — Validação VISUAL obrigatória (frontend)
Para fases com interface (telas, componentes, páginas):
- IA deve **iniciar servidor local** e fornecer URL.
- IA deve **tirar screenshot** da página/funcionalidade implementada (via Playwright/Puppeteer/Chrome DevTools MCP).
- IA deve **verificar visualmente** se segue `docs/DESIGN.md` (cores, tipografia, espaçamento, componentes).
- IA deve testar **responsividade** (mobile, tablet, desktop) via emulação.
- Screenshot salvo em `docs/screenshots/fase-X-<nome>.png` para rastreabilidade.
- **Não marcar fase concluída sem validação visual.**

### R6 — Checklist HUMANO obrigatório (entregue ao usuário)
Ao final de cada fase, entregar **dois checklists em linguagem leiga**:

**Checklist 1 — O que foi implementado (para o cliente/usuário leigo)**
- [ ] Descrição simples do que agora é possível fazer
- [ ] Conquistas visíveis (ex.: "Página inicial carrega com hero, serviços, contato")

**Checklist 2 — O que testar e como testar (passo a passo: ação → resultado esperado)**
- [ ] **Teste:** Ação específica (ex.: "Abrir http://localhost:3000") → Resultado esperado (ex.: "Ver hero com logo, título, botão WhatsApp")
- [ ] **Teste:** Ação de erro (ex.: "Clicar botão sem preencher formulário") → Resultado esperado (ex.: "Mensagem amigável 'Preencha todos os campos'")
- [ ] **Comando automatizado:** `npm test` → Resultado esperado (ex.: "Todos os 12 testes passam")
- [ ] **Comando build:** `npm run build` → Resultado esperado (ex.: "Build succeeds sem erros")

**Checklist 3 — Regressão (o que NÃO pode quebrar)**
- [ ] Login continua funcionando
- [ ] Navegação entre páginas funciona
- [ ] APIs anteriores respondem corretamente

### R7 — Atualização STATUS.md + ERROS.md obrigatória
Após cada fase:
- `docs/STATUS.md`: fase construída, tarefas concluídas/pendentes, arquivos alterados, testes executados/resultado, data, próxima fase.
- `docs/ERROS.md`: qualquer erro (mesmo corrigido) no formato padrão.
- Commit com mensagem clara: `Fase X: <resumo da fase>`.

### R8 — Segurança FINAL obrigatória
Ao concluir **todas** as fases do `PLANO.md`:
- Executar **Revisão de Segurança (Passo 5)** em chat novo com raciocínio.
- Checklist completo (SQL Injection, XSS, CSRF, Auth/Authz, Isolamento, Secrets, Logs, Uploads, APIs, Erros).
- Classificar achados: Crítico/Alto/Médio/Baixo.
- Corrigir o seguro, perguntar antes de mudar regra/fluxo/dados/arquitetura.
- Atualizar `STATUS.md`, `ERROS.md`, commit, push.
- Só então: Documentação (Passo 6) → Deploy (Passo 7) se solicitado.

### R9 — Documentação Final Obrigatória (Passo 6)
Após revisão de segurança aprovada, em chat novo com raciocínio:
- Criar `docs/MANUTENCAO.md` com 12 seções obrigatórias (Visão geral, Stack/ambientes, Como rodar localmente, Mapa de pastas, Banco/persistência, Auth/autorização, Como adicionar tela, Como adicionar campo, Como alterar regra, Como testar, Cuidados segurança, Como registrar progresso, O que não fazer).
- Criar `docs/COMO-PEDIR-MUDANCAS.md` com 8 exemplos de prompts adaptados ao sistema (campo, tela, erro, regra, visual, relatório, segurança, commit).
- Atualizar `CLAUDE.md` para **modo manutenção** com protocolo antes/depois de alteração.
- Atualizar `docs/STATUS.md` registrando documentação criada, pendências, próximo passo.
- Commit: `Documentação final de manutenção` + `git push`.

### R10 — Deploy só se solicitado (Passo 7)
Deploy apenas quando o usuário pedir, em chat novo com raciocínio, depois da revisão de segurança e da documentação final. Procedimento completo (arquivos, segredos do GitHub, primeiro deploy sem `--delete`): `references/detalhes-skill.md` → "R10 — Deploy Obrigatório se Solicitado".

## FASE 1 — ANÁLISE (sem programar)

Documentos em ordem, cada um lido/validado antes do próximo. Para cada passo, LEIA o prompt correspondente em `references/` e execute-o fielmente, transcrevendo as respostas nos arquivos.

### Passo 0 — Chat de Dúvidas
**Objetivo:** Tirar dúvidas de conceito separadas das decisões, em chat isolado.
**Prompt verbatim:** `references/analise-fundamentos.md` → seção "PROMPT — Chat de dúvidas"
**Saída:** Dúvidas respondidas, decisões NÃO tomadas aqui.
**Modelo:** Sem raciocínio (suficiente para explicações simples).
**Regras:**
- Dúvidas = conceitos (ex.: "O que é CRUD?")
- Decisões = escolhas do projeto (ex.: "O sistema deve ter pagamento parcial?") → NÃO responder aqui, encaminhar para passos corretos.

### Passo 1 — Design System → `docs/DESIGN.md`
**Objetivo:** Definir identidade visual do sistema (cores, tipografia, espaçamento, componentes, responsividade, acessibilidade).
**Prompts verbatim (escolha conforme origem):**
- Do zero: `references/analise-fundamentos.md` → "PROMPT — Criar um DESIGN.md do zero"
- De imagem: `references/analise-fundamentos.md` → "PROMPT — Criar um DESIGN.md a partir de imagem"
- De HTML/CSS: `references/analise-fundamentos.md` → "PROMPT — Criar um DESIGN.md a partir de HTML e CSS"
- Via Stitch: `https://stitch.withgoogle.com` → exportar .zip → salvar em `docs/`
- Refinar: "Prompt para refinar o design antes de gerar o DESIGN.md"
**Template base:** `templates/DESIGN.md`
**Checklist de revisão (seção 3.16):** Não genérico ("cores modernas"), contrastes OK, fontes usáveis, componentes claros, estilo combina com sistema.
**Usar skills:** `componentes-modernos` / `design-sem-cara-de-ia` quando aplicável.
**Skill `apple-design` — obrigatória em DOIS casos:**

1. **Plataformas Apple** (iOS, iPadOS, macOS, watchOS, tvOS, visionOS, Apple Watch, Vision Pro, SwiftUI, UIKit, AppKit, Catalyst): usar a skill ANTES de escrever o `docs/DESIGN.md`. Nessas plataformas o design system não é livre: ele começa nas Human Interface Guidelines e no sistema Liquid Glass. O `docs/DESIGN.md` deve declarar quais componentes são do sistema (não redesenhar), qual é a tipografia do sistema (SF Pro / SF Compact / New York) e a escala de Dynamic Type, os SF Symbols escolhidos, o comportamento em claro/escuro, e as regras de acessibilidade (Dynamic Type, contraste, Reduce Motion, Reduce Transparency, VoiceOver, alvo mínimo de toque).

2. **Qualquer projeto WEB com interface** (site, landing page, web app, painel, componente): usar a skill junto com `design-sem-cara-de-ia` e `componentes-modernos`. A `apple-design` cobre a parte que as outras não cobrem — a escada de decisão de componente (elemento HTML nativo antes de componente customizado), os padrões de experiência do usuário com as regras de quando **não** usar cada um (modal, spinner, permissão, onboarding), e a acessibilidade com os números do WCAG. O `docs/DESIGN.md` de projeto web deve declarar: quais componentes usam elemento nativo e quais são customizados (com o padrão ARIA de cada um), os estados obrigatórios de cada componente interativo, o comportamento em `prefers-color-scheme` e `prefers-reduced-motion`, os alvos de toque, e o contraste mínimo adotado.

**De onde tirar os valores do `docs/DESIGN.md` web (não invente escala nova):** a skill já traz a escala tipográfica, a escala de espaçamento, os tokens de cor claro/escuro com o contraste de cada par calculado, os tokens de sombra e de movimento e o sistema de ícones prontos em `~/.claude/skills/apple-design/references/web-sistema-visual.md`. Se o projeto usa Radix, shadcn/ui, React, Next.js ou Tailwind, a conciliação está em `references/web-ponte-stack.md`. Para começar do zero com um artefato pronto, `references/web-exemplo-referencia.md` tem uma página completa e comentada.
**Aprovação:** Usuário aprova `docs/DESIGN.md` antes de avançar.
**Obrigatório no FSD/Codificação:** IA deve ler `docs/DESIGN.md` antes de criar/alterar qualquer tela.

### Passo 2 — Explorar a Ideia
**Objetivo:** Entrevista incremental para fechar escopo, transformar ideia vaga em visão clara.
**Prompt verbatim:** `references/analise-docs.md` → "PROMPT — Explorar a Ideia (Passo 2)"
**Fluxo:** IA faz perguntas → usuário responde → IA consolida → repete até saturação → entrega **resumo consolidado da conversa** (não documento final obrigatório).
**Regras de ouro:**
- Nenhuma decisão técnica aqui (nada de linguagem, banco, framework, hospedagem, arquitetura, tabelas)
- Modelo com raciocínio obrigatório
- Não inventar conteúdo: só usar o que o usuário disse
- Perguntas uma a uma ou em pequenos grupos
- Aguardar resposta, consolidar, repetir até usuário dizer "chega"

### Passo 3 — PRD → `PRD.md`
**Objetivo:** Criar Product Requirements Document puramente funcional, sem tecnologia.
**Prompt verbatim:** `references/analise-docs.md` → "PROMPT — PRD (Passo 3)"
**Entrada:** Resumo consolidado do Passo 2 + `docs/DESIGN.md`
**Template base:** `templates/PRD.md`
**Estrutura:** Objetivo, Problema, Público, Perfis, Funcionalidades v1, Fora da v1, Regras de negócio, Informações controladas, Fluxos principais, Critérios de aceitação, Dúvidas pendentes.
**Aprovação:** Usuário aprova `PRD.md` antes de avançar.

### Passo 4 — Decisões Técnicas → `DECISOES_TECNICAS.md`
**Objetivo:** Definir stack, banco, hospedagem, login, perfis, auditoria, soft delete, logs, uploads, exportações, APIs, configs globais.
**Prompt verbatim:** `references/analise-docs.md` → "PROMPT — Decisões Técnicas (Passo 4)"
**16 seções obrigatórias:** Linguagem/framework, Banco, Desenvolvimento local, Deploy, Organização pastas, Login/auth, Perfis, Auditoria, Soft delete, Logs/erros em banco, Contingência arquivo, Uploads, Exportações, APIs/integrações, Configs globais, Outras.
**Perguntar ao usuário** o que não estiver definido. Usar defaults do vocabulário apenas quando usuário não souber.
**Template base:** `templates/DECISOES_TECNICAS.md`

### Passo 5 — FSD → `docs/FSD.md`
**Objetivo:** Juntar PRD + DESIGN + DECISOES_TECNICAS em especificação funcional completa.
**Prompt verbatim:** `references/analise-docs.md` → "PROMPT — FSD (Passo 5)"
**Template base:** `templates/FSD.md` (estrutura completa de 28 seções — ver template)
**Estrutura obrigatória (28 seções):**
1. Visão Geral
2. Documentos do Projeto para Implementação (apenas FSD.md + DESIGN.md)
3. Stack Definida
4. Ambientes do Projeto
5. Arquitetura do Sistema (padrão MVC se definido)
6. Regras de Segurança no Contexto
7. Estrutura Base do Projeto - Fase 1
8. Banco de Dados e Migrations - Fase 2
9. Autenticação e Controle de Acesso - Fase 3
10. Recursos Estruturais - Fase 4
11. Entidades Principais - Fase 5
12. CRUDs - Fase 6
13. Fluxos Principais - Fase 7
14. Relatórios e Consultas - Fase 8
15. Uploads - Fase 9 (se existirem)
16. Exportações - Fase 10 (se existirem)
17. APIs e Integrações - Fase 11 (se existirem)
18. Logs e Contingência - Fase 12
19. Revisão de Segurança - Fase 13
20. Revisão de Qualidade - Fase 14
21. Preparação da Entrega - Fase 15
22. Checklist de Prontidão Técnica por Fase
23. Checklist de Qualidade por Fase
24. Checklist de Entrega
25. Regras de Segurança
26. Critérios de Aceitação Técnica e Funcional
27. Pontos Pendentes e Decisões Futuras
28. Conclusão
**Validação interna:** FSD deve atender PRD, decisões completas, sem lacunas para IA "inventar".

### Passo 6 — Validar FSD
**Objetivo:** Revisão independente (simulada ou real) do FSD antes de codificar.
**Prompt verbatim:** `references/analise-docs.md` → "PROMPT — Validação do FSD (Passo 6)"
**Critérios:** Coerência FSD↔PRD, decisões técnicas completas, lacunas identificadas, refinamento se necessário.
**Saída:** Relatório com: Resumo, Problemas Críticos, Problemas Importantes, Melhorias Recomendadas, Verificação de Cobertura PRD, Verificação Decisões Técnicas, Verificação Design, Conclusão Final.

---

## FASE 2 — CODIFICAÇÃO (em etapas)

### Passo 0 — Chat de Ajuda
**Objetivo:** Dúvidas técnicas em chat separado do chat de execução.
**Prompt verbatim:** `references/codificacao-estrutura.md` → "PROMPT — Chat de ajuda (Passo 0)"
**Modelo:** Sem raciocínio.

### Passo 1 — Validar Insumos → `docs/INSUMOS.md`
**Objetivo:** Ler TODOS os docs, conferir coerência e completude, corrigir lacunas ANTES de codificar.
**Prompt verbatim:** `references/codificacao-estrutura.md` → "PROMPT — Validar insumos (Passo 1)"
**Documentos a ler:** `docs/PLANO.md`, `docs/STATUS.md`, `docs/ERROS.md`, `docs/DESIGN.md`, `docs/FSD.md`, `PRD.md`, `DECISOES_TECNICAS.md`, `CLAUDE.md`
**Checklist obrigatório:**
- [ ] Ler todos os documentos por completo
- [ ] Verificar FSD ↔ PRD (o que está especificado atende o que foi pedido)
- [ ] Verificar se decisões técnicas estão todas definidas (sem lacunas para IA "inventar")
- [ ] Listar conflitos/lacunas e corrigir ANTES de codificar
- [ ] Confirmar primeiro ponto de partida: por qual etapa do PLANO começar

### Passo 2 — Preparar Estrutura Inicial
**Objetivo:** Criar pastas/arquivos-base e docs da metodologia na pasta `docs/`.
**Prompt verbatim:** `references/codificacao-estrutura.md` → "PROMPT — Preparar estrutura (Passo 2)"
**Criar/atualizar:**
1. `docs/PLANO.md` — fases extraídas do FSD (seção 22)
2. `docs/STATUS.md` — acompanhamento vazio inicial
3. `docs/ERROS.md` — com modelo de registro
4. `CLAUDE.md` — instruções para IAs agênticas:
   - Stack/estrutura resumida
   - Metodologia obrigatória
   - Regras de registro (ERROS.md, STATUS.md)
   - Regras de segurança por stack
   - Como adicionar tela/campo
   - Modo construção → manutenção
5. Estrutura de pastas do projeto conforme FSD

### Passo 3 — Git e GitHub
**Objetivo:** `git init`, `.gitignore`, `.gitattributes`, primeiro commit com estrutura, conectar ao GitHub.
**Prompt verbatim:** `references/codificacao-etapas.md` → "PROMPT — Git e GitHub (Passo 3)"
**Inclui:**
- Tutorial SSH manual (Linux/macOS/Git Bash + PowerShell Windows)
- Prompt de apoio para problemas SSH
- `.gitignore`: nunca versionar segredos, `.env`, logs, dumps, certificados, chaves privadas
- `.gitattributes`: padronizar tratamento de arquivos
- Primeiro commit: estrutura + docs metodologia
- Conectar remoto GitHub (não forçar `origin` existente)
**Arquivos vivos:** Atualizar `docs/STATUS.md` e `docs/ERROS.md` após commit.

### Passo 4 — Codificar EM ETAPAS (coração da construção)
**Objetivo:** Construir **apenas a próxima fase pendente**, uma fase por vez, **um chat novo por fase**.
**Prompt verbatim:** `references/codificacao-etapas.md` → "PROMPT — Codificar em etapas (Passo 4)"
**Fluxo por fase:**
1. IA lê contexto (`docs/PLANO.md`, `docs/STATUS.md`, `docs/ERROS.md`, `docs/FSD.md`, `CLAUDE.md`)
2. Identifica próxima etapa pendente no `PLANO.md` (seguir ordem, não escolher)
3. Implementa a etapa conforme FSD/PLANO — o Opus escreve a ordem de serviço e o executor `jornada-executor` (Sonnet) implementa; o Opus revisa (ver ROTEAMENTO DE MODELOS)
4. **Testa** (manual + automatizado) — ver seção "Testar a fase"
5. Atualiza `docs/STATUS.md` (status da etapa) e `docs/ERROS.md` (erros encontrados)
6. Commit Git com mensagem clara
7. Entrega os **2 checklists obrigatórios**:
   - Checklist 1: O que foi implementado (linguagem leiga)
   - Checklist 2: O que testar e como testar (passo a passo: ação → resultado; comando se houver)
8. **Próxima fase = chat novo** com mesmo prompt

**Regras críticas:**
- NUNCA construir tudo de uma vez
- Prompt 04 NÃO pode construir mais de uma fase
- Sem raciocínio nesta etapa
- Usar `CLAUDE.md` (Claude Code)
- Antes de resolver erro novo, consultar `docs/ERROS.md`
- Não marcar fase concluída se critérios de pronto não atendidos
- Não instalar libs/frameworks fora do FSD sem perguntar
- Não presumir tecnologia se não estiver no FSD
- Segurança obrigatória mesmo durante construção (ver lista completa no prompt)

**Seção "O que fazer quando algo falhar":**
1. Ler `docs/ERROS.md` — já ocorreu antes?
2. Reproduzir erro
3. Pedir correção descrevendo: o que fez, esperava, aconteceu
4. Aplicar correção → retestar → registrar em `docs/ERROS.md`
5. Se travar: novo chat, mesmo prompt, ler contexto atualizado

### Testando as Etapas (embutido no Passo 4)
**Seção do prompt:** "Testar a fase" + "O que fazer quando algo falhar"
**Regra:** Sistema criado ≠ sistema testado. Nunca avançar sem teste real.

### Passo 5 — Revisão de Segurança
**Objetivo:** Verificar auth/authz, dados sensíveis, inputs, injeção, exposição de mensagens técnicas.
**Prompt verbatim:** `references/codificacao-etapas.md` → "PROMPT — Revisão de segurança (Passo 5)"
**Quando:** Ao concluir todas as etapas de construção, **antes** da documentação final.
**Checklist:**
- Proteção contra injeção SQL
- Proteção contra XSS
- Proteção contra CSRF
- Armazenamento seguro de senhas (hash)
- Autenticação e controle de sessão
- Controle de acesso por perfil/permissão
- Isolamento de dados (usuário, conta, empresa, organização)
- Proteção de arquivos sensíveis
- Uso seguro de variáveis de ambiente/configuração
- Mensagens de erro seguras (não expor stack traces)
- Logs protegidos
- Validação de entradas
- Sanitização de saídas
- Proteção em uploads (se houver)
- Segurança no consumo de APIs externas (se houver)
- Cuidados com chaves, tokens, credenciais
- Proteção das rotas/endpoints/páginas internas
- Regras do FSD/`CLAUDE.md` têm prioridade

### Passo 6 — Documentação Final
**Objetivo:** Atualizar `docs/` com estado final, colocar `CLAUDE.md` em **modo manutenção**.
**Prompt verbatim:** `references/codificacao-final.md` → "PROMPT — Documentação (Passo 6)"
**Quando:** Após revisão de segurança (Passo 5) aprovada. **Chat novo com raciocínio.** Não cria funcionalidades, não faz deploy.
**Antes de executar:** ler as regras completas em `references/detalhes-skill.md` → "Passo 6 — Documentação Final".

### Passo 7 — Deploy
**Objetivo:** Publicar na Hostnet via `GitHub → GitHub Actions → SSH/rsync → Hostnet`.
**Prompt verbatim:** `references/codificacao-final.md` → "PROMPT — Deploy (Passo 7)"
**Quando:** Sistema pronto, validado localmente, revisão de segurança feita, documentação final criada. **Chat novo com raciocínio.**
**Antes de executar:** ler `references/detalhes-skill.md` → "Passo 7 — Deploy" (arquivos criados, comandos Linux/macOS e PowerShell, checklist).

## FLUXOS ESPECIAIS

### Edição Simples (bug pequeno, ajuste)
- Aplicar direto no código
- Atualizar `docs/STATUS.md` e `docs/ERROS.md`
- Entregar os 2 checklists (leigo + como testar)
- **NÃO** atualizar PRD/FSD/insumos

### Alteração/Recurso Maior
1. Atualizar `PRD.md`/`FSD.md`/insumos se necessário
2. Iniciar novo plano no `docs/STATUS.md` (nova etapa)
3. Ir etapa por etapa, seguindo metodologia
4. Gerar nova documentação se necessário
5. Começar lendo `docs/` + código relevante

### Implementar Funcionalidade Nova
1. Ler `docs/` (STATUS, ERROS, FSD, PLANO) e código relevante
2. Atualizar `PRD.md`/`FSD.md`/insumos quando necessário
3. Atualizar `docs/STATUS.md` (nova etapa) e iniciar novo plano
4. Ir fase a fase, seguindo metodologia e registrando em `docs/ERROS.md`

### Pedido de Alteração (chat separado)
**Checklist antes de pedir:**
- [ ] Expliquei o objetivo
- [ ] Defini tipo: visual, funcional, técnica, regra
- [ ] Avisei o que NÃO deve ser alterado
- [ ] Pedi plano antes de executar (se necessário)
- [ ] Pedi para preservar regras do FSD
- [ ] Pedi para manter documentação atualizada
- [ ] Pedi para verificar necessidade de commit
- [ ] Testei depois da alteração

### Rollback
**Regra:** Código volta com Git. Banco só volta com análise, backup e cuidado.
**Antes de rollback (9 perguntas):** Problema no código? Interface? Regra? Banco alterado? Enviado GitHub? Publicado produção? Usuários criaram dados depois? Existe backup? Existe tag versão anterior?
**Prompt análise:** `git log --oneline --decorate --graph --all` → analisar commit atual, recentes, tags, qual introduziu alteração, versão boa anterior, comando rollback seguro, riscos.
**Prompt rollback código:** `git revert <commit>` ou `git reset --hard <commit/tag>` + `git push --force-with-lease` (se necessário).

### STATUS.md Concluído (todas as etapas)
1. Executar **Revisão de Segurança** (Passo 5) — chat novo com raciocínio
2. Executar **Documentação** final (Passo 6) — chat novo com raciocínio
3. Executar **Deploy** (Passo 7) se solicitado — chat novo com raciocínio

### Cold Start — Sistema SEM arquivos da metodologia

Primeira vez num projeto que já tem código: os documentos vão descrever o sistema inteiro, então a leitura cobre o sistema inteiro. **Amostra não serve** — PRD e FSD escritos a partir de "alguns arquivos representativos" ficam errados, e o erro só aparece depois, quando alguém já confiou neles.

Ordem obrigatória (skill `estruturar-projeto`):

1. **Inventário** — `bash scripts/inventario-projeto.sh` na raiz. Devolve arquivos por extensão, pastas com contagem, manifestos, migrations, rotas, autenticação, testes, variáveis de ambiente, integrações e `TODO`/`FIXME`. É a lista de verificação.
2. **Grafo** — `tokensave` (`_entities`, `_files`, `_module_api`, `_dependencies`, `_rank`) + `code-review-graph` (`get_architecture_overview_tool`, `list_communities_tool`, `list_flows_tool`, `get_hub_nodes_tool`), em paralelo.
3. **Leitura direta obrigatória** onde o grafo não alcança: manifestos, `.env.example`, **todas** as migrations e schemas, todas as rotas e telas, middleware/policies/permissões, README e docs soltos, configuração de deploy.
4. **Módulo por módulo**, na ordem de importância, respondendo seis perguntas: o que faz (em linguagem de negócio), que entidades toca, que telas/endpoints expõe, que regras aplica, de quem depende e quem depende dele, e se tem teste. Módulo grande → subagente.
5. **Tabela de cobertura**, entregue **antes** dos documentos: pasta/módulo → como foi coberto → o que faz → entidades → pendências. Toda pasta do inventário aparece, inclusive as descartadas com o motivo. Tabela que não fecha com o inventário = varredura incompleta.
6. **Só então** escrever PRD, DECISOES_TECNICAS, FSD, DESIGN, INSUMOS e `CLAUDE.md` — cada afirmação apontando a origem no código. `STATUS.md` e `ERROS.md` nascem vazios.
7. Reler o comando original do usuário, registrar em `PLANO.md` + `STATUS.md`, e seguir a metodologia.

**Cobertura total, custo mínimo:** cobrir 100% dos módulos é obrigatório; fazer isso lendo arquivo inteiro quando o grafo resolvia, não. As duas coisas valem ao mesmo tempo.

## VOCABULÁRIO ESPECIALIZADO (uso obrigatório para precisão)

**Análise:** CRUD, RBAC, Auditoria, Soft delete, Logs, MVC, API, Integração externa, Configurações globais, Deploy, Hospedagem, Domínio, Ambiente local/testes/homologação/produção.
**Dados:** Entidade, Campo, Relacionamento (1:1, 1:N, N:M), Migration, Seed, Índice, Constraint, Soft delete, Timestamp.
**Telas/Interface:** Dashboard, Layout, Responsividade, Acessibilidade, Componente, Estado (vazio, carregando, erro, sucesso), Navegação (menu, breadcrumb), Modal, Tabela, Formulário, Validação.
**Usuários/Segurança:** Autenticação, Autorização, Perfil, Permissão, Sessão, Token, Hash, Salt, CSRF, XSS, SQL Injection, Isolamento de dados (multi-tenancy).
**Construção:** Fase, Construção incremental, Critério de pronto, Persistência, Commit, Branch, Push, Pull, Merge, Conflict, Rollback, Tag, Hotfix, Refatoração, Technical debt.
**Uploads/Exportações:** Upload, Anexo, Exportação, CSV, PDF, Excel, Importação, MIME type, Validação extensão/tipo real.
**Documentos do fluxo:** Chat de dúvidas, DESIGN.md, Explorar ideia, PRD.md, DECISOES_TECNICAS.md, FSD.md, Validação FSD, Chat de ajuda, INSUMOS.md, PLANO.md, STATUS.md, ERROS.md, CLAUDE.md, CHECKLIST.md.

---

## REGRAS OBRIGATÓRIAS DO USUÁRIO

1. **Sistema criado ≠ sistema testado.** Nunca declarar etapa concluída sem teste real.
2. **Ao final de cada etapa/edição**, entregar:
   - **Checklist 1:** O que foi implementado, em **linguagem leiga** (sem termos técnicos)
   - **Checklist 2:** O que testar e como testar (passo a passo: ação → resultado esperado; comando de teste se houver)
3. **Ao completar uma etapa do STATUS.md**, anexar:
   - (a) O checklist por etapa (leigo)
   - (b) O **checklist completo com todas as etapas** de tudo que já foi feito no projeto
4. **Erros:** Registrar em `docs/ERROS.md` (o que aconteceu em leigo, erro técnico, causa, correção, status). Reusar histórico para não repetir erros.
5. **Status:** Manter `docs/STATUS.md` sempre atualizado a cada avanço.

---

## MATRIZ DE IMPACTO — que documento atualizar (OBRIGATÓRIA)

Toda alteração de código passa por esta tabela **antes** de a tarefa ser considerada pronta. Não é "se der tempo": é parte da entrega.

| O que você mexeu | Documento que precisa ser atualizado |
|---|---|
| Funcionalidade nova, alterada ou removida | `PRD.md` (e `docs/FSD.md`) |
| Regra de negócio, validação, cálculo, estado | `PRD.md` + `docs/FSD.md` |
| Entidade, tabela, campo, migration | `docs/FSD.md` (modelo de dados) |
| Rota, endpoint, tela nova | `docs/FSD.md` |
| Fluxo do usuário mudou | `PRD.md` + `docs/FSD.md` |
| Stack, banco, hospedagem, biblioteca nova | `DECISOES_TECNICAS.md` + `INSUMOS.md` |
| Autenticação, perfil, permissão, sessão | `DECISOES_TECNICAS.md` + `docs/FSD.md` |
| Variável de ambiente, config, integração externa | `INSUMOS.md` + `DECISOES_TECNICAS.md` |
| Cor, fonte, espaçamento, componente, padrão visual | `docs/DESIGN.md` |
| Tela, componente ou ícone em plataforma Apple (iOS, iPadOS, macOS, watchOS, tvOS, visionOS) | `docs/DESIGN.md` + skill `apple-design` (conferir HIG antes de fechar) |
| Etapa nova descoberta no caminho | `docs/PLANO.md` |
| Jeito de rodar, testar ou contribuir mudou | `CLAUDE.md` |
| Qualquer alteração de código, sempre | `docs/STATUS.md` |
| Qualquer erro encontrado, mesmo já corrigido | `docs/ERROS.md` |

**Regra de fechamento:** ao terminar a tarefa, diga em uma linha quais documentos foram atualizados e, para os que **não** foram, qual foi conferido e por que não precisou mexer. Silêncio sobre um documento conta como esquecimento, não como "não precisava".

**Trava:** o hook `Stop` não deixa a sessão encerrar se houve alteração de código e o `docs/STATUS.md` não foi atualizado — ele devolve esta matriz e o trabalho continua.

**Não vale o contrário:** não inche o PRD com detalhe de implementação nem o FSD com decisão que não foi tomada. Atualizar é refletir o que mudou, não escrever mais.

---

## FERRAMENTAS DE ECONOMIA DE TOKENS (OBRIGATÓRIAS)
Nove ferramentas, parte da metodologia: `tokensave` e `code-review-graph` (grafos de código, MCP), `rtk` (filtra o terminal), `graphify` (grafo de insumos longos), `tokenoptim` (compressão), `caveman` (resposta enxuta), `context-mode` (saída grande fora do contexto), `token-optimizer` (só auditoria), `claude-hud` (contexto ocupado); `ccusage` para medir. Instalam-se sozinhas em segundo plano (hook `SessionStart`, no máximo 1x por dia).
- **Trava P1:** leitura direta de código (`Read`/`Grep`/`Glob` e `cat`/`sed`/`grep` no terminal) fica bloqueada até a primeira consulta ao `tokensave` ou ao `code-review-graph` na sessão.
- **Por passo:** mapear → `tokensave` + `code-review-graph` juntos; impacto → `_impact`/`_callers` + `get_impact_radius_tool`; codificar → `_body`/`_signature` no lugar de `Read`; revisar → `detect_changes_tool` + `get_review_context_tool`; saída grande → `context-mode`; insumo longo → `graphify` (+ `tokenoptim`). Chamadas independentes na mesma mensagem.
- **caveman:** conversa enxuta; documentos, checklists e commits por extenso. **rtk:** nunca contornar com `rtk proxy`.
- Tabela completa, instalação e regras: `references/ferramentas-token.md` e `references/detalhes-skill.md` → "FERRAMENTAS DE ECONOMIA DE TOKENS (OBRIGATÓRIAS)".

### Ordem padrão de leitura do sistema (P1)

1. `mcp__tokensave__tokensave_status` → tem índice? Se não, `tokensave init .` no projeto (Bash).
2. `mcp__tokensave__tokensave_context` com a descrição da tarefa (+ `keywords`) → símbolos, relações, trechos relevantes.
3. `mcp__tokensave__tokensave_search` / `_entities` / `_files` → localizar entidades, rotas, telas.
4. `mcp__tokensave__tokensave_callers` / `_callees` / `_impact` / `_affected` → o que a mudança quebra.
5. `code-review-graph`: `build_or_update_graph_tool` → `get_architecture_overview_tool`, `list_flows_tool`, `list_communities_tool`, `get_impact_radius_tool`, `get_minimal_context_tool` (arquitetura, fluxos, raio de impacto).
6. Se existir `graphify-out/` no projeto, consultar o grafo antes de reler código.
7. Só então `Read` **parcial** dos arquivos que sobraram (nunca dump de arquivo inteiro).
8. Varredura ampla (muitos arquivos/pastas) → **subagente** (`Explore` / `cavecrew-investigator`), para não inchar o contexto principal.

## COMO EXECUTAR (Workflow Obrigatório)

0. **Ativar o modo sessão** (`scripts/jornada-session.sh on`) e rodar `status` para saber quais documentos existem. Enquanto o modo estiver ativo, o protocolo P1–P8 é injetado em cada comando e o guard bloqueia código sem documentos.
1. **Identificar a fase/passo** em que a tarefa se encaixa e **LER o prompt correspondente em `references/`** (ex.: passo PRD → `analise-docs.md`; codificar etapa → `codificacao-etapas.md`; alteração → `codificacao-final.md`). Executar o prompt fielmente.
2. **Seguir as fases acima, na ordem**, consultando o prompt correto de cada passo.
3. **Usar os templates de `templates/`** como base dos documentos.
4. **Ao terminar cada passo/etapa**, entregar os checklists exigidos.
5. **Usar as ferramentas de economia de tokens** (tokensave, code-review-graph, rtk) ao ler código.

---

## PROMPTS VERBATIM (onde estão)
| Passo | Arquivo |
|---|---|
| Fase 1 — Passo 2 Explorar a ideia, 3 PRD, 4 Decisões técnicas, 5 FSD, 6 Validar FSD | `references/analise-docs.md` |
| Fase 2 — Passo 1 Validar insumos, 2 Preparar estrutura | `references/codificacao-estrutura.md` |
| Fase 2 — Passo 3 Git e GitHub, 4 Codificar em etapas, 5 Revisão de segurança | `references/codificacao-etapas.md` |
| Fase 2 — Passo 6 Documentação, 7 Deploy | `references/codificacao-final.md` |

Ler o prompt inteiro no arquivo antes de executar a fase. Resumo de cada prompt (a antiga referência rápida): `references/detalhes-skill.md` → "PROMPTS VERBATIM CHAVE".

## TEMPLATES E ESTRUTURA DE PASTAS
Modelos dos 10 documentos em `templates/` (PRD, DESIGN, DECISOES_TECNICAS, FSD, INSUMOS, PLANO, STATUS, ERROS, CLAUDE.md, CHECKLIST). Tabela de cada template e árvore de pastas padrão do Passo 2: `references/detalhes-skill.md` → "TEMPLATES DE DOCUMENTOS" e "ESTRUTURA DE PASTAS PADRÃO".

## EXTRAS AVANÇADOS (Capítulos 15-18)
Criar skills, outras stacks, erros comuns e IA agêntica: `references/detalhes-skill.md` → "EXTRAS AVANÇADOS" e `references/avancado-extras.md`.
