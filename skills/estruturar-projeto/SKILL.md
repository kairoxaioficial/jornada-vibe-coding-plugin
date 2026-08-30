---
name: estruturar-projeto
description: >
  Cria TODA a estrutura de documentos da metodologia Jornada IA Vibe Coding em
  um projeto — mesmo que o projeto já tenha código (brownfield) ou ainda seja
  só uma ideia (greenfield). Usa os repos de economia de tokens (tokensave,
  code-review-graph, rtk, caveman, ponytail, graphify) para mapear o sistema e
  gerar PRD, DECISOES_TECNICAS, FSD, INSUMOS, DESIGN, PLANO, STATUS (vazio),
  ERROS (vazio) e CLAUDE.md (NUNCA AGENTS.md). Ativar quando o usuário pedir para "estruturar",
  "montar a estrutura de documentos", "iniciar o projeto pela metodologia",
  "bootstrap", "setup do projeto", ou quando um sistema não tiver os arquivos
  da metodologia.
argument-hint: "[caminho-do-projeto]"
license: MIT
---

# Estruturar Projeto — Jornada IA Vibe Coding (bootstrap de documentos)

Crie toda a estrutura de documentos da metodologia no projeto, usando as
ferramentas de economia de tokens. Se os documentos já existirem, NÃO sobrescreva
— leia o que existe, reporte o estado e sinalize o que falta.

**Templates:** a pasta `templates/` do skill jornada-vibe-coding
**Referência (prompts verbatim):** a pasta `references/` do skill jornada-vibe-coding — `analise-fundamentos.md`, `analise-docs.md`, `codificacao-estrutura.md`, `codificacao-etapas.md`, `codificacao-final.md`, `sintese-executiva.md`, `avancado-extras.md`
**Metodologia (fluxo completo):** skill `jornada-vibe-coding`

**Quando roda:** sob demanda (`/estruturar-projeto`) **ou automaticamente** no passo P2 do modo sessão da metodologia, sempre que faltar qualquer documento. Enquanto faltarem `PRD.md`, `docs/FSD.md`, `docs/PLANO.md`, `docs/STATUS.md`, `docs/ERROS.md`, o hook `jornada-guard.sh` **bloqueia edição de código** — este bootstrap é o que destrava.

**REGRA CLAUDE.md:** o arquivo de contexto da IA é **`CLAUDE.md`**. **NUNCA criar `AGENTS.md`** (bloqueado por hook). Achou um `AGENTS.md` no projeto → `git mv AGENTS.md CLAUDE.md` (ou mesclar no `CLAUDE.md` existente), corrigir as referências nos documentos e registrar a troca no `STATUS.md`. Não manter os dois.

## Passo 0 — Conferir as ferramentas obrigatórias

Antes de mapear qualquer coisa, rodar `bash scripts/instalar-ferramentas.sh --check` (raiz do plugin jornada-vibe-coding). Se faltar alguma ferramenta necessária à tarefa, instalar com `bash scripts/instalar-ferramentas.sh`; `ponytail` e `caveman` são plugins e se instalam dentro do Claude Code (`/plugin marketplace add ...` + `/plugin install ...`). Referência completa: `references/ferramentas-token.md` do skill jornada-vibe-coding.

## Passo 1 — Identificar o alvo
- Se recebeu um caminho, use-o; senão use o diretório atual.
- Verificar se já existe `docs/` ou os arquivos da metodologia (`PRD.md`, `FSD.md`, `docs/STATUS.md`, etc.).

## Passo 2 — VARREDURA COMPLETA do projeto (obrigatória, sem amostragem)

Os documentos vão descrever o sistema inteiro, então a leitura tem que cobrir o sistema inteiro. **Amostra não serve.** Ler "alguns arquivos representativos" produz PRD e FSD errados, e o erro só aparece semanas depois, quando alguém confia neles.

A regra é: **cobertura de 100% dos módulos, com o mínimo de tokens** — não "ler pouco".

### 2.1 Inventário — a lista do que precisa ser coberto

Rodar, na raiz do projeto:

```bash
bash <caminho-do-skill>/scripts/inventario-projeto.sh
```

Ele devolve: total de arquivos, extensões, pastas de 1º e 2º nível com contagem, manifestos, migrations/models, rotas/controllers/telas, autenticação, testes, variáveis de ambiente, integrações externas e pendências (`TODO`/`FIXME`) já marcadas no código.

Esse inventário é a **lista de verificação**. Nenhum documento é escrito antes de todos os itens dele estarem cobertos.

### 2.2 Mapear pelo grafo (barato, cobre muito)

- `tokensave`: se não houver índice, `tokensave init .`. Depois `tokensave_entities`, `tokensave_files`, `tokensave_module_api`, `tokensave_dependencies`, `tokensave_imports`, `tokensave_largest`, `tokensave_rank` — inventário de símbolos, entidades, módulos e o que é central no sistema.
- `code-review-graph`: `build_or_update_graph_tool`, depois `get_architecture_overview_tool`, `list_communities_tool` (os módulos reais), `list_flows_tool` (os fluxos ponta a ponta), `get_hub_nodes_tool` (o que o sistema tem de mais importante).
- Chamar em paralelo, na mesma mensagem. Duas consultas de grafo custam menos que um arquivo grande.

### 2.3 Leitura direta — onde o grafo não alcança

O grafo entende código. Ele **não** lê regra de negócio escrita em texto, configuração, migration ou tela. Estes são de leitura obrigatória, por completo:

- Manifestos da stack (`package.json`, `composer.json`, `pyproject.toml`, `Cargo.toml`, `Gemfile`, `go.mod`, `pom.xml`, `pubspec.yaml`…) — dependências e scripts.
- `.env.example` / `.env.sample` — toda variável é uma decisão técnica a documentar.
- **Todas** as migrations e schemas — são o modelo de dados do FSD; nenhuma pode ficar de fora.
- Rotas / `urls.py` / `web.php` / `routes/` / `app/**/page.*` — a lista completa de telas e endpoints.
- Middleware, policies, guards, permissões — viram a seção de autenticação e perfis.
- README, docs soltos, comentários longos — regra de negócio costuma estar escondida aí.
- Configuração de deploy (`Dockerfile`, `docker-compose.yml`, workflows do CI).

Para o corpo de funções específicas, usar `tokensave_body` / `tokensave_signature` em vez de abrir o arquivo inteiro.

### 2.4 Varredura por módulo, até fechar a conta

Percorrer os módulos do inventário **um por um**, na ordem de importância que o `tokensave_rank` / `get_hub_nodes_tool` apontou. Para cada módulo, responder:

1. O que ele faz, em uma frase de negócio (não técnica).
2. Que entidades e tabelas ele toca.
3. Que telas ou endpoints ele expõe.
4. Que regras de negócio ele aplica (validações, cálculos, restrições, estados).
5. De que outros módulos depende, e quem depende dele.
6. Tem teste? Cobre o quê?

Módulo grande demais para uma passada → delegar a um subagente (`Explore` / `cavecrew-investigator`) com essas seis perguntas, e trazer de volta só as respostas. O contexto principal fica limpo.

### 2.5 Tabela de cobertura (entregar antes dos documentos)

Antes de escrever qualquer documento, montar e mostrar esta tabela:

| Pasta / módulo | Como foi coberto | O que faz | Entidades | Pendências |
|---|---|---|---|---|
| `src/pedidos/` | grafo + 3 migrations lidas | fluxo de pedido do carrinho à entrega | Pedido, Item, Entrega | regra de cancelamento não está clara |

Regras da tabela:

- **Toda** pasta do inventário aparece — inclusive as que foram descartadas, com o motivo ("gerado automaticamente", "assets estáticos").
- Coluna "Pendências" vira lista de perguntas ao usuário e entra nos documentos como `PENDENTE — confirmar com o usuário`.
- Se a tabela não fecha com o inventário, a varredura não terminou. Voltar ao 2.4.

### 2.6 Greenfield (projeto sem código)

Não há o que varrer. Pular 2.1 a 2.5: os documentos nascem do conceito que o usuário descreveu, com tudo que ele não definiu marcado como pendência. Não inventar funcionalidade.

### 2.7 Insumos externos

Documentação do cliente, PDF, transcrição, planilha de regras: passar pelo `graphify` e consultar o grafo, em vez de colar o conteúdo inteiro no contexto. `tokenoptim` para comprimir o que precisar ir junto.

## Passo 3 — Gerar os documentos
Usar os templates como base. Regras:
- **STATUS.md → obviamente VAZIO nesse primeiro momento** (etapas listadas, todas não iniciadas). Nenhuma etapa marcada como feita.
- **ERROS.md → vazio** (log sem entradas).
- **PLANO.md → esqueleto de etapas a partir do que o sistema faz** (ou vazio em greenfield até o PRD fechar).
- **PRD.md / DECISOES_TECNICAS.md / FSD.md / DESIGN.md / INSUMOS.md / CLAUDE.md → preenchidos a partir da varredura completa do Passo 2.** O que não der para inferir fica como `PENDENTE — confirmar com o usuário`, NÃO inventar.
- **Rastreabilidade:** cada funcionalidade do PRD e cada seção do FSD indica de onde saiu — o módulo, a migration, a rota ou o arquivo. Afirmação sem origem no código é invenção e não entra.
- **Cobertura:** o PRD lista todas as funcionalidades que o código realmente tem; o FSD cobre todas as entidades e telas do inventário; o DECISOES_TECNICAS cobre toda variável de ambiente e toda dependência dos manifestos. Faltou item do inventário → o documento não está pronto.
- **Sem enfeite:** não descrever funcionalidade "planejada", "provável" ou "recomendada" como se existisse. O documento retrata o sistema como ele é hoje.
- **CLAUDE.md (raiz)** — modo construção, a partir de `templates/CLAUDE.md`. **Nunca `AGENTS.md`.** Se já existir `CLAUDE.md` no projeto, mesclar sem apagar o que havia.
- Marcar nos docs que foram **gerados por engenharia reversa do código existente** (não aprovados por humano ainda).

Estrutura de arquivos a criar:
```
docs/PLANO.md
docs/STATUS.md        (vazio)
docs/ERROS.md         (vazio)
docs/DESIGN.md
docs/FSD.md
PRD.md
DECISOES_TECNICAS.md
INSUMOS.md
CLAUDE.md            (NUNCA AGENTS.md)
```

## Passo 4 — Relatório final (checklist, linguagem leiga)
Entregar:
1. Checklist do que foi criado (leigo): "agora o projeto tem a documentação base para guiar o desenvolvimento".
2. Lista de decisões em aberto que precisam da resposta do usuário (stack, login, etc.).
3. Próximo passo sugerido: "quer que eu monte o plano de execução para o próximo comando?".

## Regras
- NUNCA sobrescrever documentos existentes sem confirmar com o usuário.
- NUNCA marcar etapas do STATUS como concluídas neste bootstrap.
- NUNCA inventar funcionalidades que não existem no código — o que não for inferível vira pergunta pendente.
- NUNCA escrever documento a partir de amostra do código. A varredura do Passo 2 cobre 100% dos módulos do inventário, e a tabela de cobertura é entregue antes dos documentos.
- NUNCA usar leitura cara onde o grafo resolve: cobertura total é obrigatória, desperdício de token não.
- NUNCA criar `AGENTS.md` — sempre `CLAUDE.md`; se houver `AGENTS.md`, migrar.
- NUNCA escrever código neste bootstrap: aqui só nascem documentos.
- Depois do bootstrap, seguir o fluxo normal da metodologia (`jornada-vibe-coding`), retomando o comando original do usuário: registrar a tarefa em `docs/PLANO.md` + `docs/STATUS.md` e só então codificar.
