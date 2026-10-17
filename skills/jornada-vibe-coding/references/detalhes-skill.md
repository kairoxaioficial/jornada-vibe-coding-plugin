# Detalhes da metodologia — seções longas do SKILL.md

> Movidas do `SKILL.md` na versão 1.2.0 (16/10/2026) para a skill carregar menos texto. O conteúdo é o mesmo de antes (só a contagem de ferramentas e o matcher da trava foram atualizados). O `SKILL.md` aponta para cada seção daqui: ler a seção quando a fase chegar.

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

## FERRAMENTAS DE ECONOMIA DE TOKENS (OBRIGATÓRIAS)

Estas nove ferramentas são **parte da metodologia**, não um extra. Usar sempre; **instalar quando faltarem**.

| # | Ferramenta | Para que serve | Repositório |
|---|---|---|---|
| 1 | **tokensave** (MCP) | Grafo de código: entender o sistema sem ler arquivo inteiro | https://github.com/aovestdipaperino/tokensave |
| 2 | **rtk** | Filtra a saída dos comandos de terminal (até 90% menos tokens) | https://github.com/rtk-ai/rtk |
| 3 | **code-review-graph** (MCP) | Grafo estrutural: review, impacto, arquitetura | https://github.com/tirth8205/code-review-graph |
| 4 | **graphify** | Grafo de conhecimento de qualquer insumo (código, docs, PDFs, vídeo) | https://github.com/Graphify-Labs/graphify |
| 5 | **tokenoptim** | Compressão de prompt/contexto | https://github.com/Manas470/tokenoptim |
| 6 | **caveman** (plugin) | Saída ultracomprimida sem perder substância técnica | https://github.com/JuliusBrussee/caveman |

### P0 — Instalação automática (não depende do modelo)

Ao ativar a metodologia e a cada início de sessão, os hooks do plugin fazem sozinhos:

1. Verificam as seis ferramentas.
2. **Baixam e instalam em segundo plano** as de linha de comando que faltarem (`tokensave`, `rtk`, `code-review-graph`, `graphify`, `tokenoptim`), no máximo uma vez por dia. Log: `~/.claude/jornada/instalacao.log`.
3. Injetam no contexto quais estão disponíveis e quais faltam.

O que **você** (modelo) ainda precisa fazer:

- Se faltar o plugin `caveman`, pedir ao usuário que cole no Claude Code:
  ```
  /plugin marketplace add JuliusBrussee/caveman
  /plugin install caveman@caveman
  ```
- Se `tokensave` estiver instalado mas o projeto não tiver índice, rodar `tokensave init .`.

Detalhes de uso por ferramenta: `references/ferramentas-token.md`.

### Uso obrigatório em TODO passo — garantido por hook

O hook `PreToolUse` em `Read|Grep|Glob|Bash` **bloqueia a leitura direta de arquivos de código** enquanto o P1 não for feito na sessão. O bloqueio cai assim que qualquer ferramenta `mcp__tokensave__*` ou `mcp__code-review-graph__*` for chamada (registrado pelo hook `PostToolUse`). Documentos (`.md`), configs (`.json`, `.yml`, `.toml`, `.env`) e imagens passam sempre — são o que a metodologia precisa ler primeiro.

Ou seja: em toda sessão, em todo projeto, o mapeamento por grafo vem antes da leitura bruta. Não é uma recomendação, é uma trava.

**Não é uma ferramenta por passo — é todas as que couberem.** Chamadas independentes vão na mesma mensagem, em paralelo: duas consultas de grafo juntas custam menos que ler um arquivo.

| Passo da metodologia | Ferramentas a combinar |
|---|---|
| Explorar ideia / insumos do cliente (PDF, transcrição, documentação) | `graphify` + `tokenoptim` (comprimir o insumo antes de processar) |
| Mapear sistema existente (cold start, PRD, FSD) | `tokensave` (`_context`, `_entities`, `_files`) **+** `code-review-graph` (`get_architecture_overview_tool`, `list_flows_tool`) — em paralelo |
| Decisões técnicas / arquitetura | `code-review-graph` (arquitetura, comunidades, hubs) **+** `tokensave` (`_dependencies`, `_imports`) |
| Planejar etapa (PLANO/STATUS) | `tokensave` (`_impact`, `_affected`, `_callers`) **+** `code-review-graph` (`get_impact_radius_tool`, `get_affected_flows_tool`) **+** `graphify` se houver `graphify-out/` |
| Codificar a etapa | `tokensave` (`_body`, `_signature`, `_str_replace`) no lugar de `Read`/`Edit` de arquivo inteiro |
| Testar / rodar comandos | `rtk` (automático) **+** `tokensave` (`_run_affected_tests`, `_test_map`) para rodar só o que importa |
| Revisar a etapa | `code-review-graph` (`detect_changes_tool`, `get_review_context_tool`) **+** `tokensave` (`_diff_context`) |
| Revisão de segurança | `code-review-graph` (`get_impact_radius_tool`) **+** `tokensave` (`_callers`, `_unsafe_patterns`) |
| Busca ampla em muitos arquivos | subagente (`Explore` / `cavecrew-investigator`) — nunca no contexto principal |
| Relatar / checklists / commit | `caveman` (sempre) — comprime a conversa, **nunca** o documento nem a mensagem de commit |
| Contexto ou prompt muito longo | `tokenoptim` |

### caveman: sempre ligado

Não é opcional nem "quando der". Com o plugin caveman instalado, ele mesmo injeta as regras em todo prompt e o bloco da Jornada só acrescenta a regra própria da metodologia (documentos, checklists e commits em português normal); sem o plugin, o bloco completo da Jornada traz as regras de compressão. O hook `SessionStart` grava `~/.claude/.caveman-active` com o nível `full` se o arquivo não existir.

**caveman** — resposta comprimida: sem preâmbulo, sem resumo final, sem narrar tool call. **Nunca** comprimir código, comandos, caminhos, erros, números, versões e avisos de segurança. **Nunca** comprimir o que fica gravado: PRD, FSD, STATUS, ERROS, PLANO, checklists em linguagem leiga e mensagens de commit saem em português normal, por extenso.

### Regras de uso permanentes

- `rtk` — a saída de Bash já vem filtrada pelo hook. **Nunca** contornar com `rtk proxy` fora de depuração.
- `caveman` — relatórios, reviews e respostas comprimidos; **nunca** comprimir código, caminhos, comandos, versões ou mensagens de erro.
- `graphify` — usar para transformar insumos longos (PDF, curso, transcrição, documentação) em grafo consultável.
- `tokenoptim` — comprimir prompts e contextos longos antes de mandar para o modelo.

**Proibido:** planejar, prometer ou editar código sem ter feito P0 e P1. "Não achei o arquivo" não justifica pular o mapeamento.

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
