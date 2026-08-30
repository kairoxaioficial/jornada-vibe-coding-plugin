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
- `references/sintese-executiva.md` — visão geral consolidada do fluxo
**Templates de documentos:** `templates/` (PRD, DESIGN, DECISOES_TECNICAS, FSD, INSUMOS, PLANO, STATUS, ERROS, CHECKLIST, CLAUDE.md)
**Scripts do modo sessão:** `scripts/` (`jornada-context.sh`, `jornada-guard.sh`, `jornada-session.sh`, `jornada-lib.sh`)

---

## MODO SESSÃO — ATIVAÇÃO PERSISTENTE (o mais importante)

A metodologia **não é** "um turno". Depois de ativada, ela vale para **TODOS os comandos** da sessão e do projeto, até ser desativada.

**Ativar:** `/jornada-vibe-coding` (ou "ativar jornada" / "jornada on").
**Desativar:** `/jornada-vibe-coding off` (ou "desativar jornada").
**Ver estado:** `scripts/jornada-session.sh status [dir]` (dentro da pasta do skill)

**O que a ativação faz (garantia por hook, não por memória do modelo):**
1. Marca a sessão (`~/.claude/jornada/sessions/<session_id>`) e o projeto (`~/.claude/jornada/projects/<slug>`).
2. Hook `UserPromptSubmit` (`scripts/jornada-context.sh`) injeta o **protocolo P1–P8** em **todo prompt seguinte**, com o estado real dos documentos daquele projeto.
3. Hook `PreToolUse` em `Edit|Write|MultiEdit|NotebookEdit` (`scripts/jornada-guard.sh`) **bloqueia edição de código** enquanto faltar `PRD.md`, `docs/FSD.md`, `docs/PLANO.md`, `docs/STATUS.md`, `docs/ERROS.md` — e **bloqueia sempre a criação de `AGENTS.md`**.
   - Documentos, `docs/`, `.github/`, `.claude/`, README, `.gitignore`, `.gitattributes` passam sempre (é o que precisa vir antes).
   - Isentos de bloqueio: `$HOME` puro, `~/.claude`, `~/.config`, `/tmp`, `/private/tmp`.

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
| **P4 Planejar** | Registrar a tarefa em `docs/PLANO.md` (etapas) e abrir a etapa em `docs/STATUS.md` **antes** da primeira edição de código. |
| **P5 Executar** | **Uma etapa por comando.** Seguir PLANO/FSD/DESIGN. Nada de tecnologia fora do FSD. |
| **P6 Testar** | Lint, typecheck, testes, build, migrations, servidor; UI → screenshot + responsividade em `docs/screenshots/`. |
| **P7 Registrar** | `docs/STATUS.md` (etapa, arquivos, testes/resultado, data, próxima) + `docs/ERROS.md` (**todo** erro, mesmo já corrigido; consultar antes de corrigir). Etapa/subpasso descoberto no caminho → entra em `PLANO.md` e `STATUS.md`. |
| **P8 Entregar** | Commit + Checklist 1 (leigo), Checklist 2 (como testar: ação → resultado), Checklist 3 (regressão). Ao fechar etapa do STATUS: também o checklist acumulado de todas as etapas. |

Concluídas todas as etapas do PLANO → Revisão de Segurança (Passo 5) → Documentação (Passo 6) → Deploy (Passo 7) se pedido.

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

### R10 — Deploy Obrigatório se Solicitado (Passo 7)
Se usuário pedir deploy, em chat novo com raciocínio:
- Criar `deploy-exclude.txt` na raiz (lista padrão + ajustes stack).
- Criar `.github/workflows/deploy-hostnet.yml` (workflow_dispatch, rsync sem `--delete` no primeiro deploy).
- Orientar 5 GitHub Secrets: `HOSTNET_HOST`, `HOSTNET_USER`, `HOSTNET_PORT`, `HOSTNET_PATH`, `HOSTNET_SSH_KEY`.
- Orientar chave SSH ed25519 específica por projeto (privada → Secret, pública → servidor `authorized_keys` + `chmod 700 ~/.ssh` + `chmod 600 ~/.ssh/authorized_keys`).
- Orientar pasta destino Hostnet (ex.: `/home/usuario/www/projeto`) via SSH.
- Orientar config produção no servidor (placeholders: NOME_DO_BANCO_AQUI, USUARIO_DO_BANCO_AQUI, SENHA_DO_BANCO_AQUI, SMTP_DO_DOMINIO_AQUI) — **sem versionar segredos**.
- Orientar banco produção MySQL no painel Hostnet + conta e-mail Ultramail.
- Commit config deploy + `git push origin main` ANTES de executar Action.
- Checklist pós-deploy obrigatório (site abre, assets carregam, login funciona, banco conecta, docs/ não público, CLAUDE.md não público, .git/ não público, backup gerado).
- Atualizar `docs/STATUS.md` + `docs/ERROS.md` se houver erro.

**Para usuários de Claude Code: use apenas `CLAUDE.md` (não crie `AGENTS.md` — o hook `jornada-guard.sh` bloqueia). Todos os prompts usam `AGENTS.md` como padrão para Codex/Antigravity — substitua por `CLAUDE.md` antes de executar. Esta substituição pode aparecer mais de uma vez no mesmo prompt. Se o projeto já tiver `AGENTS.md`, migrar para `CLAUDE.md` (ver "REGRA CLAUDE.md vs AGENTS.md").**

---

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
3. Implementa a etapa conforme FSD/PLANO
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
**Quando:** Após revisão de segurança (Passo 5) aprovada. **Chat novo com raciocínio.**
**Não cria** funcionalidades, **não faz deploy**.
**Criar/atualizar:**
1. `docs/MANUTENCAO.md` — 12 seções mínimas:
   - Visão geral (o que faz, para quem, problemas, módulos)
   - Stack e ambientes (linguagem, framework, banco, libs, local, produção, comandos)
   - Como rodar localmente (passo a passo com comandos reais)
   - Mapa de pastas (o que guarda, quando mexer, cuidados)
   - Banco de dados e persistência (migrations, seeds, como alterar, cuidados)
   - Autenticação, autorização e usuários (login, perfis, onde permissões verificadas)
   - Como adicionar nova tela (passos, arquivos a alterar)
   - Como adicionar novo campo (banco, model, formulário, validação, listagem, testes, docs)
   - Como adicionar nova regra de negócio (conferir FSD, localizar, alterar com cuidado, testar)
   - Como testar alterações (comandos, manuais, fluxos principais, logs, ERROS.md)
   - Cuidados de segurança (auth, authz, sessão, validação, injeção, XSS, CSRF, isolamento, arquivos sensíveis, logs, uploads, APIs, segredos)
   - Como registrar progresso (STATUS.md, ERROS.md)
   - O que não fazer (não reescrever sem necessidade, não alterar stack sem decisão, não remover segurança, não versionar segredos, não ignorar testes, não mexer várias áreas sem explicar)
2. `docs/COMO-PEDIR-MUDANCAS.md` — para usuário leigo:
   - Explicação simples + orientação ler docs antes
   - 8 modelos de prompts adaptados ao sistema: adicionar campo, criar tela, corrigir erro, alterar regra, ajustar visual (DESIGN.md), criar relatório/filtro, revisar segurança, preparar commit
3. Atualizar `CLAUDE.md` para **modo manutenção** com protocolo:
   - Antes: ler MANUTENCAO.md, FSD.md, DESIGN.md (se UI), STATUS.md, ERROS.md, entender pedido, explicar plano
   - Depois: testar, atualizar STATUS.md, registrar ERROS.md, commit, explicar validação
4. Atualizar `docs/STATUS.md`: documentação criada, pendências, próximo passo.
5. Commit: `Documentação final de manutenção` + `git push`.
**Entregar ao usuário:** Resumo, pontos principais MANUTENCAO.md, exemplos COMO-PEDIR-MUDANCAS.md, confirmações.
**Frase final:** "Documentação pronta. Próximo passo: chat novo + prompt do passo 7, se você quiser publicar o sistema na Hostnet."

### Passo 7 — Deploy
**Objetivo:** Publicar na Hostnet via `GitHub → GitHub Actions → SSH/rsync → Hostnet`.
**Prompt verbatim:** `references/codificacao-final.md` → "PROMPT — Deploy (Passo 7)"
**Quando:** Sistema pronto, validado localmente, revisão de segurança feita, documentação final criada. **Chat novo com raciocínio.**
**Arquivos criados:**
- `deploy-exclude.txt` (raiz) — o que NÃO enviar (lista padrão + ajustes stack)
- `.github/workflows/deploy-hostnet.yml` — workflow manual (`workflow_dispatch`), rsync sem `--delete` no primeiro deploy
- GitHub Secrets (5): `HOSTNET_HOST`, `HOSTNET_USER`, `HOSTNET_PORT`, `HOSTNET_PATH`, `HOSTNET_SSH_KEY`
- Pasta destino na Hostnet (ex.: `/home/usuario/www/projeto`) — criada via SSH
- Arquivo config produção no servidor (placeholders: NOME_DO_BANCO_AQUI, USUARIO_DO_BANCO_AQUI, SENHA_DO_BANCO_AQUI, SMTP_DO_DOMINIO_AQUI) — **sem versionar segredos**
- Banco produção MySQL no painel Hostnet
- Conta e-mail envio (Ultramail se precisar)
- `~/.ssh/authorized_keys` no servidor + permissões `chmod 700 ~/.ssh` e `chmod 600 ~/.ssh/authorized_keys`
**Deploy manual** (workflow_dispatch), não automático por push. Primeiro deploy usa `rsync` SEM `--delete`.
**Chave SSH deploy (ed25519, específica por projeto):**
```bash
# Linux/macOS/Git Bash
ssh-keygen -t ed25519 -C "deploy-hostnet" -f ~/.ssh/hostnet_deploy
# PowerShell Windows
ssh-keygen -t ed25519 -C "deploy-hostnet" -f "$HOME\.ssh\hostnet_deploy"
```
Privada → GitHub Secret `HOSTNET_SSH_KEY`; Pública → servidor `authorized_keys`.
**Passos obrigatórios do deploy:**
1. Ler contexto completo (CLAUDE.md, FSD.md, DESIGN.md, INSUMOS.md, PLANO.md, STATUS.md, ERROS.md, MANUTENCAO.md)
2. Identificar stack, arquitetura, pasta pública, arquivos necessários/proibidos, dependências, config produção, banco, assets, comandos pós-deploy, variáveis exatas do código
3. Criar `deploy-exclude.txt` (base padrão + ajustes stack — não excluir `vendor/`, `dist/`, `build/`, `public/`, `assets/` sem verificar FSD)
4. Criar workflow `.github/workflows/deploy-hostnet.yml` (modelo base + ajustes stack)
5. Orientar 5 Secrets no GitHub (Settings → Secrets and variables → Actions)
6. Orientar geração chave SSH + cadastro pública no servidor + privada no Secret
7. Orientar pasta destino Hostnet (`mkdir -p ~/www/projeto`)
8. Orientar config produção real no servidor (baseada nos fontes do sistema — não inventar nomes)
9. Orientar banco produção (painel Hostnet → MySQL → criar banco, usuário, senha, endereço conexão)
10. Orientar e-mail envio (Ultramail → conta separada → SMTP dados)
11. `git status` → confirmar sem segredos → `git add deploy-exclude.txt .github/workflows/deploy-hostnet.yml` (+ STATUS/ERROS se atualizados) → `git commit -m "Configura deploy manual na Hostnet"` → `git push origin main` (ou master)
12. Orientar execução Action: GitHub → Actions → Deploy Hostnet → Run workflow → acompanhar logs
13. Checklist pós-deploy obrigatório (site abre, assets carregam, login, banco, páginas, formulários, configs sensíveis não abrem, docs/prompts/CLAUDE.md/.git/logs não públicos, backup gerado)
14. Atualizar `docs/STATUS.md` + `docs/ERROS.md` se erro

---

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
Se o projeto NÃO tem PRD/FSD/insumos/etc.:
1. **Ler TODO o código e funcionalidades existentes** (mapear rotas, entidades, telas, fluxos)
2. **Criar toda a estrutura e arquivos:** `PRD.md`, `DECISOES_TECNICAS.md`, `FSD.md`, `INSUMOS.md`, `docs/PLANO.md`, `docs/STATUS.md` (**obviamente VAZIO nesse primeiro momento**), `docs/ERROS.md`, `CLAUDE.md` — preenchidos a partir do código lido
3. **Reler o comando do usuário**, atualizar STATUS e demais arquivos com a tarefa atual
4. Seguir o plano com a metodologia, etapa por etapa

---

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

## FERRAMENTAS DE ECONOMIA DE TOKENS (OBRIGATÓRIAS)

Usar SEMPRE neste projeto (já ativas globalmente). **Ler o código é obrigatório antes de planejar/editar — mas SEM torrar contexto.**

**Ordem padrão de leitura do sistema (P1):**
1. `mcp__tokensave__tokensave_status` → tem índice? Se não, `tokensave init` no projeto (Bash).
2. `mcp__tokensave__tokensave_context` com a descrição da tarefa (+ `keywords`) → símbolos, relações, trechos relevantes.
3. `mcp__tokensave__tokensave_search` / `_entities` / `_files` → localizar entidades, rotas, telas.
4. `mcp__tokensave__tokensave_callers` / `_callees` / `_impact` / `_affected` → o que a mudança quebra.
5. `code-review-graph`: `build_or_update_graph_tool` → `get_architecture_overview_tool`, `list_flows_tool`, `list_communities_tool`, `get_impact_radius_tool`, `get_minimal_context_tool` (arquitetura, fluxos, raio de impacto).
6. Só então `Read` **parcial** dos arquivos que sobraram (nunca dump de arquivo inteiro).
7. Varredura ampla (muitos arquivos/pastas) → **subagente** (`Explore` / `cavecrew-investigator`), para não inchar o contexto principal.

**Demais ferramentas:**
- `rtk` — saída de Bash já filtrada (hook). Nunca bypassar.
- `caveman` — saída comprimida ao revisar/relatar.
- `ponytail` — solução mais simples (evitar over-engineering).
- `graphify` — transformar inputs em knowledge graph quando útil (`graphify-out/` existente → consultar antes de reler código).
- `tokenoptim` / `headroom` — compressão de contexto/diff quando necessário.

**Proibido:** planejar, prometer ou editar código sem ter feito P1. "Não achei o arquivo" não justifica pular o mapeamento.

---

## COMO EXECUTAR (Workflow Obrigatório)

0. **Ativar o modo sessão** (`scripts/jornada-session.sh on`) e rodar `status` para saber quais documentos existem. Enquanto o modo estiver ativo, o protocolo P1–P8 é injetado em cada comando e o guard bloqueia código sem documentos.
1. **Identificar a fase/passo** em que a tarefa se encaixa e **LER o prompt correspondente em `references/`** (ex.: passo PRD → `analise-docs.md`; codificar etapa → `codificacao-etapas.md`; alteração → `codificacao-final.md`). Executar o prompt fielmente.
2. **Seguir as fases acima, na ordem**, consultando o prompt correto de cada passo.
3. **Usar os templates de `templates/`** como base dos documentos.
4. **Ao terminar cada passo/etapa**, entregar os checklists exigidos.
5. **Usar as ferramentas de economia de tokens** (tokensave, code-review-graph, rtk) ao ler código.

---

## PROMPTS VERBATIM CHAVE (referência rápida)

### Prompt "Explorar a Ideia" (Passo 2) — `references/analise-docs.md`
> Você vai conduzir uma **entrevista incremental** para transformar uma ideia inicial em uma visão clara do sistema.
> - Faça perguntas uma a uma ou em pequenos grupos.
> - Aguarde a resposta do usuário.
> - Consolide o que foi dito.
> - Repita até saturação (usuário diz "chega" ou não há mais dúvidas).
> - **NÃO tome decisões técnicas.** Nada de linguagem, banco, framework, hospedagem, arquitetura, tabelas.
> - **NÃO crie documentos finais** (PRD, FSD, etc.). O entregável é o **resumo consolidado da conversa**.
> - Use modelo com raciocínio.
> - Não invente: só use o que o usuário disse.

### Prompt "PRD" (Passo 3) — `references/analise-docs.md`
> Transforme o resumo consolidado do Passo 2 em um **PRD.md** (Product Requirements Document).
> - Puramente funcional, para pessoas (leigo). Sem detalhes técnicos.
> - Use o template `templates/PRD.md`.
> - O DESIGN.md (Passo 1) será usado "com mais força" no FSD, não aqui.
> - Aprovar com o usuário antes de avançar.

### Prompt "Decisões Técnicas" (Passo 4) — `references/analise-docs.md`
> Defina as decisões técnicas do projeto em `DECISOES_TECNICAS.md`.
> - Stack, banco, hospedagem, login, perfis, auditoria, soft delete, logs, uploads, exportações, APIs, configs globais.
> - Pergunte ao usuário o que não estiver definido.
> - Use defaults do vocabulário apenas quando usuário não souber.
> - Template: `templates/DECISOES_TECNICAS.md`.

### Prompt "FSD" (Passo 5) — `references/analise-docs.md`
> Junte PRD + DESIGN + DECISOES_TECNICAS em `docs/FSD.md` (Especificação Funcional do Sistema).
> - Template: `templates/FSD.md` (28 seções obrigatórias).
> - Deve ser completo para orientar a codificação sem a IA "inventar".

### Prompt "Validar FSD" (Passo 6) — `references/analise-docs.md`
> Valide o FSD contra PRD, DECISOES_TECNICAS.md, DESIGN.md.
> - Saída: relatório com Resumo, Problemas Críticos, Importantes, Melhorias, Cobertura PRD, Decisões Técnicas, Design, Conclusão.

### Prompt "Validar Insumos" (Passo 1 Codificação) — `references/codificacao-estrutura.md`
> Leia TODOS os documentos do projeto e confira coerência/completude ANTES de codificar.
> - `docs/PLANO.md`, `docs/STATUS.md`, `docs/ERROS.md`, `docs/DESIGN.md`, `docs/FSD.md`, `PRD.md`, `DECISOES_TECNICAS.md`, `CLAUDE.md`
> - Corrija lacunas ANTES de escrever código.

### Prompt "Preparar Estrutura" (Passo 2 Codificação) — `references/codificacao-estrutura.md`
> Crie docs/PLANO.md, docs/STATUS.md, docs/ERROS.md, CLAUDE.md, estrutura pastas projeto.

### Prompt "Git e GitHub" (Passo 3 Codificação) — `references/codificacao-etapas.md`
> git init, .gitignore, .gitattributes, primeiro commit, conectar GitHub. SSH tutorial incluso.

### Prompt "Codificar em Etapas" (Passo 4 Codificação) — `references/codificacao-etapas.md`
> **UM CHAT NOVO POR FASE.** Leia contexto, identifique próxima etapa pendente no PLANO.md, implemente, teste, atualize STATUS.md e ERROS.md, commit, entregue checklists.

### Prompt "Revisão de Segurança" (Passo 5 Codificação) — `references/codificacao-etapas.md`
> Revise: auth/authz, dados sensíveis, inputs/sanitização, injeção (SQL/XSS/CSRF), exposição de erros técnicos, secrets no código.

### Prompt "Documentação" (Passo 6 Codificação) — `references/codificacao-final.md`
> Atualize docs/ com estado final. Coloque CLAUDE.md em modo manutenção. Não crie funcionalidades, não faça deploy.

### Prompt "Deploy" (Passo 7 Codificação) — `references/codificacao-final.md`
> Deploy manual via GitHub Actions → SSH/rsync → Hostnet. Crie deploy-exclude.txt, workflow YAML, 5 GitHub Secrets, config produção no servidor.

---

## TEMPLATES DE DOCUMENTOS (em `templates/`)

| Arquivo | Descrição |
|---------|-----------|
| `PRD.md` | Product Requirements Document — o QUE o sistema faz (leigo) |
| `DESIGN.md` | Design System — COMO a interface deve parecer |
| `DECISOES_TECNICAS.md` | Decisões técnicas — stack, banco, auth, auditoria, etc. (16 seções) |
| `FSD.md` | Especificação Funcional — PRD + DESIGN + DECISÕES = spec completa (28 seções) |
| `INSUMOS.md` | Checklist de validação dos docs antes de codificar |
| `PLANO.md` | Plano de desenvolvimento em etapas (fases extraídas do FSD) |
| `STATUS.md` | Acompanhamento: progresso, checklist etapa atual, checklist completo, próximos passos |
| `ERROS.md` | Log de erros com causa/correção + checklist ao encontrar erro |
| `CLAUDE.md` | Instruções para IAs agênticas (modo construção → modo manutenção) |
| `CHECKLIST.md` | Modelo de checklist por entrega (leigo + como testar + regressão) |

---

## ESTRUTURA DE PASTAS PADRÃO (criada no Passo 2 Codificação)

```
projeto/
├── PRD.md
├── DECISOES_TECNICAS.md
├── CLAUDE.md
├── docs/
│   ├── DESIGN.md
│   ├── FSD.md
│   ├── INSUMOS.md
│   ├── PLANO.md
│   ├── STATUS.md
│   └── ERROS.md
├── .gitignore
├── .gitattributes
├── deploy-exclude.txt
├── .github/workflows/deploy-hostnet.yml
└── [código do projeto conforme stack definida no FSD]
```

---

## EXTRAS AVANÇADOS (Capítulos 15-18)

### Criando Skills (Cap. 15)
- Transformar Prompt 04 ("Codificar em etapas") em skill reutilizável
- **Uso manual (acionamento explícito)**, nunca automático
- Preservar integralmente a função do prompt original
- Estrutura: `construir-proxima-fase/SKILL.md` + `references/prompt-04-construir-fase.md`
- Comandos válidos: "Executar skill: construir próxima fase", "Use a skill de construção da próxima fase", "/construir-proxima-fase"
- Comandos inválidos: "Continue o sistema", "Faça a próxima parte", "Pode seguir", "Termine o projeto"

### Outras Stacks (Cap. 16)
- Adaptar fluxo (prompts 01-07) para qualquer stack: PHP/Laravel, Node/Express, Next.js, Python/Django, Supabase, Firebase, etc.
- Qualquer hospedagem: Hostnet, VPS, Vercel, Render, Railway, Netlify, Cloudflare Pages
- **Regra central:** "Quem define a tecnologia do projeto é o FSD, não o improviso da IA"
- Prompts são generalistas e devem seguir `docs/FSD.md`, `CLAUDE.md`, demais documentos

### Erros Comuns (Cap. 17)
- Pular validação de insumos
- Construir tudo de uma vez
- Não testar antes de avançar
- Não registrar erros
- Inventar tecnologia fora do FSD
- Versionar segredos
- Não fazer revisão de segurança
- Não documentar para manutenção

### IA Agêntica (Extras)
- Passo 5 FSD (IA Agêntica): prompt adaptado para agentes
- Passo 6 Validação FSD (IA Agêntica): prompt adaptado para agentes

---

**Lembre-se:** A metodologia existe para transformar conversa em código confiável, passo a passo, com rastreabilidade. Pular etapas ou não fazer as perguntas obrigatórias quebra o fluxo.