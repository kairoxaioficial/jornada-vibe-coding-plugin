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

## Passo 1 — Identificar o alvo
- Se recebeu um caminho, use-o; senão use o diretório atual.
- Verificar se já existe `docs/` ou os arquivos da metodologia (`PRD.md`, `FSD.md`, `docs/STATUS.md`, etc.).

## Passo 2 — Mapear o sistema (usando os repos de tokens)
- **tokensave (MCP):** se não houver índice, rodar `tokensave init` no projeto; depois usar `mcp__tokensave__tokensave_context`/`tokensave_entities`/`tokensave_dependencies` para mapear símbolos, entidades, rotas, estrutura.
- **code-review-graph (MCP):** usar `build_or_update_graph_tool`, `get_architecture_overview_tool`, `list_flows_tool`, `list_communities_tool` para entender arquitetura, fluxos e módulos.
- **Leitura direta (com rtk filtrando saída):** manifestos (`package.json`, `composer.json`, `pyproject.toml`, `Cargo.toml`, `Gemfile`, `pubspec.yaml`…), `.env.example`, pastas de telas/rotas/entidades, README existente.
- **Greenfield (sem código):** pular o scan; os documentos nascem do conceito informado ou como esqueleto.
- **caveman:** relatório de progresso em formato comprimido.
- **ponytail:** não criar documentos além do necessário — só os da metodologia.
- **graphify:** opcional, quando um mapa mental do domínio ajudar.

## Passo 3 — Gerar os documentos
Usar os templates como base. Regras:
- **STATUS.md → obviamente VAZIO nesse primeiro momento** (etapas listadas, todas não iniciadas). Nenhuma etapa marcada como feita.
- **ERROS.md → vazio** (log sem entradas).
- **PLANO.md → esqueleto de etapas a partir do que o sistema faz** (ou vazio em greenfield até o PRD fechar).
- **PRD.md / DECISOES_TECNICAS.md / FSD.md / DESIGN.md / INSUMOS.md / CLAUDE.md → preenchidos a partir do que foi mapeado.** O que não der para inferir fica como pergunta pendente, NÃO inventar.
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
- NUNCA criar `AGENTS.md` — sempre `CLAUDE.md`; se houver `AGENTS.md`, migrar.
- NUNCA escrever código neste bootstrap: aqui só nascem documentos.
- Depois do bootstrap, seguir o fluxo normal da metodologia (`jornada-vibe-coding`), retomando o comando original do usuário: registrar a tarefa em `docs/PLANO.md` + `docs/STATUS.md` e só então codificar.
