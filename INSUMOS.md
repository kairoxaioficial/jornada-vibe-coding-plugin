# INSUMOS — Materiais de entrada, dependências e configuração

> Projeto: plugin Jornada IA Vibe Coding (`jornada-vibe-coding-plugin`)
> Última atualização: 16/10/2026

## 1. Documentos do projeto

| Documento | Situação |
|---|---|
| `PRD.md` | Existe (v1.0 de 03/09/2026, trazido da cópia instalada da skill); atualizado para v1.2 nesta tarefa |
| `DECISOES_TECNICAS.md` | Criado no cold start de 16/10/2026 |
| `docs/FSD.md` | Criado no cold start de 16/10/2026 (inclui a tabela de cobertura) |
| `docs/DESIGN.md` | Criado: o plugin não tem interface gráfica; registra só o padrão das mensagens no terminal |
| `docs/PLANO.md`, `docs/STATUS.md`, `docs/ERROS.md` | Criados; STATUS e ERROS nasceram vazios |
| `CLAUDE.md` | Existia (instruções do code-review-graph); recebeu a seção de como testar e instalar |

## 2. Dependências obrigatórias na máquina

| Dependência | Para quê | Origem no código |
|---|---|---|
| `bash` (3.2 ou mais novo, o do macOS serve) | Todos os hooks e instaladores | `skills/jornada-vibe-coding/scripts/*.sh` |
| `jq` | Ler o JSON que o Claude Code entrega aos hooks e montar a resposta | `jornada-context.sh`, `jornada-guard.sh`, `jornada-p1-guard.sh` |
| Claude Code com suporte a hooks, skills e subagentes (testado na 2.1.302) | Executar a metodologia | `hooks/hooks.json`, `instalar.sh` |
| `git` | Commits por etapa (P8) e detecção da raiz do projeto | `jornada-lib.sh` (`jornada_root`) |

## 3. Ferramentas de economia de tokens (instaladas sozinhas se faltarem)

Linha de comando: `tokensave`, `rtk`, `code-review-graph`, `graphify`, `tokenoptim`.
Plugins do Claude Code: `caveman`, `context-mode`, `token-optimizer`, `claude-hud`.
Medição: `npx -y ccusage@latest` (sem instalação).
Origem: `skills/jornada-vibe-coding/scripts/instalar-ferramentas.sh` e `verificar-ferramentas.sh`.

O `ponytail` deixou de ser dependência na versão 1.2.0 (decisão do usuário em 16/10/2026).

## 4. Modelos de IA

| Papel | Modelo | Observação |
|---|---|---|
| Sessão principal: ler, planejar, revisar, documentar | Opus (hoje Opus 5.5) | `"model": "opus"` em `~/.claude/settings.json` |
| Executor das etapas (subagente `jornada-executor`) | Sonnet (hoje Sonnet 5.5) | Definido no próprio arquivo do agente (`model: sonnet`) |

Os dois modelos precisam estar disponíveis no plano do usuário.

## 5. Variáveis de ambiente

| Variável | Obrigatória | Padrão | Uso |
|---|---|---|---|
| `JORNADA_HOME` | Não | `~/.claude/jornada` | Pasta de estado dos hooks |
| `JORNADA_REFORCO` | Não | `10` | De quantos em quantos comandos o protocolo completo é reenviado |
| `CLAUDE_PLUGIN_ROOT` | Não (definida pelo Claude Code quando instalado como plugin) | — | Localizar os scripts do plugin |

Nenhum segredo, token ou senha é usado pelo plugin.

## 6. Integrações externas

- Repositório público `github.com/kairoxaioficial/jornada-vibe-coding-plugin` (publicação).
- Repositórios das ferramentas de economia, baixados pelo instalador (endereços em `instalar-ferramentas.sh`).

## 7. Confirmação

Insumos conferidos em 16/10/2026: documentos criados, dependências presentes na máquina do usuário (`jq`, `git`, `gh` autenticado, Claude Code 2.1.302), nenhuma pendência que impeça a codificação.
