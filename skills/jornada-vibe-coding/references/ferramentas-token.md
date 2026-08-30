# Ferramentas obrigatórias de economia de tokens

A metodologia Jornada IA Vibe Coding assume estas sete ferramentas instaladas. Elas existem por um motivo prático: sem elas o agente lê arquivos inteiros, estoura o contexto, perde o fio da meada no meio do projeto e a conta fica cara. Com elas, ele lê grafo em vez de código bruto.

Instalação automática: `bash scripts/instalar-ferramentas.sh` (na raiz do plugin).
Só verificar: `bash scripts/instalar-ferramentas.sh --check`.

---

## 1. tokensave — grafo de código (MCP)

Repositório: https://github.com/aovestdipaperino/tokensave

Instalar:
```bash
brew install aovestdipaperino/tap/tokensave   # macOS
# ou: cargo install tokensave
tokensave install --agent claude
```

Indexar um projeto: `tokensave init .`

Usar (em vez de ler arquivos):

| Situação | Ferramenta |
| --- | --- |
| "Como funciona X neste projeto?" | `tokensave_context` (com `keywords`) |
| Achar um símbolo pelo nome | `tokensave_search` |
| Quem chama esta função | `tokensave_callers` |
| O que esta função chama | `tokensave_callees` |
| O que quebra se eu mudar isto | `tokensave_impact` / `tokensave_affected` |
| Ver o corpo de um símbolo | `tokensave_body` |

Regra: `Read` de arquivo inteiro só depois que o grafo não resolveu.

---

## 2. rtk — filtro de saída do terminal

Repositório: https://github.com/rtk-ai/rtk

Instalar:
```bash
brew install rtk
# ou: curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
rtk init -g
```

Depois de `rtk init -g`, a saída dos comandos de terminal passa a ser filtrada automaticamente por um hook — corta até 90% do texto sem perder o que importa. Não é preciso digitar `rtk` na frente dos comandos.

Ver o ganho acumulado: `rtk gain`. Oportunidades perdidas: `rtk discover`.

Regra: nunca contornar o filtro com `rtk proxy`, exceto para depurar o próprio rtk.

---

## 3. code-review-graph — grafo estrutural (MCP)

Repositório: https://github.com/tirth8205/code-review-graph

Instalar:
```bash
pip install code-review-graph      # ou: pipx install code-review-graph / uv tool install code-review-graph
code-review-graph install --platform claude-code
code-review-graph build
```

Usar:

| Situação | Ferramenta |
| --- | --- |
| O que mudou desde o último review | `detect_changes_tool` |
| Contexto mínimo para revisar a mudança | `get_review_context_tool` |
| Raio de impacto de uma alteração | `get_impact_radius_tool` |
| Visão geral da arquitetura | `get_architecture_overview_tool` |
| Buscar por significado, não por texto | `semantic_search_nodes_tool` |

Regra: usar isto no lugar de `grep` amplo no repositório inteiro.

---

## 4. graphify — grafo de conhecimento

Repositório: https://github.com/Graphify-Labs/graphify

Instalar:
```bash
uv tool install graphifyy      # ou: pipx install graphifyy
graphify install
```

Serve para transformar qualquer insumo — código, documentação, PDF, artigo, transcrição de aula, vídeo — em um grafo consultável. Muito útil na fase de Análise da metodologia, quando você joga material bruto do cliente para dentro do projeto.

Regra: se existir a pasta `graphify-out/` no projeto, consultar o grafo **antes** de reler os arquivos.

---

## 5. tokenoptim — compressão de prompt

Repositório: https://github.com/Manas470/tokenoptim

Instalar:
```bash
pip install llm-tokenoptim
# opcional, compressão por ML (40-60%): pip install "llm-tokenoptim[ml]"
```

Usar: `llm-tokenoptim compress` para encolher prompts e contextos longos antes de enviá-los ao modelo.

---

## 6. ponytail — a solução mais simples que funciona (plugin)

Repositório: https://github.com/dietrichgebert/ponytail

Instalar (dentro do Claude Code, um comando de cada vez):
```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

Obriga a escada: a tarefa precisa existir? Dá para resolver com o que já está instalado? Dá em uma linha? Só então escreva o mínimo que funciona. Nunca corta validação, tratamento de erro, segurança ou acessibilidade.

Regra: aplicar em toda decisão de código da fase de Codificação.

---

## 7. caveman — saída ultracomprimida (plugin)

Repositório: https://github.com/JuliusBrussee/caveman

Instalar (dentro do Claude Code, um comando de cada vez):
```
/plugin marketplace add JuliusBrussee/caveman
/plugin install caveman@caveman
```

Ligar: `/caveman` (níveis `lite`, `full`, `ultra`).

Regra: comprime a conversa, **nunca** o conteúdo técnico. Código, caminhos de arquivo, comandos, números de versão, avisos de segurança e mensagens de erro saem sempre por extenso. Documentos da metodologia (PRD, FSD, STATUS, checklists) e mensagens de commit continuam em português normal, escritos por extenso.

---

## ponytail e caveman ficam sempre ligados

Os hooks do plugin injetam as regras dos dois em todo prompt, mesmo antes de os plugins estarem instalados, e gravam `~/.claude/.caveman-active` com o nível `full` se o arquivo não existir. Instalar os plugins melhora (eles trazem as sub-skills), mas não é o que garante a ativação.

## Combine ferramentas no mesmo passo

Não use uma ferramenta por vez. Chamadas independentes vão juntas, na mesma mensagem: `tokensave_context` + `get_architecture_overview_tool` em paralelo custa menos que ler um único arquivo grande. A tabela de combinações por passo da metodologia está no `SKILL.md`.

## Ordem prática numa tarefa

1. `instalar-ferramentas.sh --check` — ferramentas no lugar.
2. `tokensave_context` — entender o que já existe.
3. `code-review-graph` — arquitetura e impacto da mudança.
4. `Read` parcial só do que sobrou.
5. Escrever código sob a régua do `ponytail`.
6. Relatar de forma comprimida (`caveman`), com os checklists da metodologia em linguagem leiga.
