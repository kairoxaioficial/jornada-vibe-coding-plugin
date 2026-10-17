# FSD — Especificação Funcional do Sistema

> Projeto: plugin Jornada IA Vibe Coding (`jornada-vibe-coding-plugin`)
> Versão do sistema descrita: 1.2.0 · Última atualização: 16/10/2026
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
| SessionStart | `verificar-ferramentas.sh` | `session_id`, `cwd`, `source` | Instala em segundo plano o que faltar (no máximo 1x por dia), grava o nível do caveman, zera o contador do bloco da sessão; **só se a Jornada estiver ativa** injeta a lista de ferramentas disponíveis/ausentes (e como instalar as ausentes) |
| UserPromptSubmit | `jornada-context.sh` | `session_id`, `cwd`, `prompt` | Ativa/desativa pelo texto do prompt; se ativa, injeta o bloco completo ou o curto (seção 8) |
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
| `ultima-instalacao`, `instalacao.log` | Controle e log da instalação automática |

## 8. Protocolo injetado (1.2.0)

**Bloco completo** — protocolo P0–P8 inteiro, regra de roteamento de modelos, regra "ponytail desligado", regra de compressão. Enviado quando: (a) o comando ativou a Jornada; (b) não existe `injecao/<session_id>` (1ª mensagem da sessão, ou o SessionStart apagou a marca ao iniciar, retomar, limpar ou compactar); (c) o contador chegou a `JORNADA_REFORCO` (padrão 10).

**Bloco curto** — raiz do projeto, estado dos documentos, aviso de `AGENTS.md` se houver, e uma linha com as regras que não podem falhar (grafo antes de ler, documentos antes do código, uma etapa por comando, Opus planeja/revisa e o executor Sonnet implementa, testar de verdade, STATUS/ERROS, matriz de impacto, checklists, ponytail desligado). Enviado nos demais comandos.

Regra de compressão: com o plugin caveman instalado (`caveman@` em `~/.claude/plugins/installed_plugins.json`), o bloco leva só a regra própria da metodologia (documentos, checklists e commits em prosa normal); sem o plugin, leva o texto completo das regras de compressão.

Se a marca não puder ser lida ou gravada, o hook manda o bloco completo (falha para o lado seguro).

## 9. Roteamento de modelos

Detalhe operacional em `skills/jornada-vibe-coding/references/roteamento-modelos.md`.

1. **Sessão principal (Opus):** P1 leitura pelo grafo, P2–P4 documentos e plano, e a **ordem de serviço** da etapa (objetivo, contexto a ler, arquivos, contratos, regras, interface, segurança, testes, fora do escopo, critério de pronto).
2. **Executor (`jornada-executor`, Sonnet):** recebe a ordem de serviço pela ferramenta Agent, implementa a etapa, escreve e roda os testes, registra os erros em `docs/ERROS.md` e devolve um relatório curto. Não faz commit, não muda PRD/FSD/DECISOES/DESIGN/PLANO/STATUS, não decide arquitetura, para e relata quando a ordem de serviço não basta.
3. **Revisão (Opus):** confere o diff contra a ordem de serviço, o FSD, o DESIGN e a segurança; roda os testes de novo; valida a interface por screenshot quando houver; pede correções ao mesmo executor (SendMessage) até 2 rodadas; depois assume. Fecha com STATUS, matriz de impacto, commit e os três checklists.
4. **Fica no Opus, sem delegar:** mudança pequena (até ~30 linhas em até 2 arquivos), código sensível de segurança, documentos da metodologia, correção após 2 rodadas sem sucesso.
5. Se a sessão principal não estiver no Opus, o modelo avisa o usuário (`/model opus`) antes de planejar.

Agente: `agents/jornada-executor.md` no repositório; a instalação direta copia para `~/.claude/agents/`.

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

## 14. Segurança

- O texto do prompt nunca é executado; só comparado em `case`.
- Arquivos de estado: nome derivado do `session_id`/raiz com `/` trocado por `-`, sempre dentro de `$JORNADA_HOME`.
- Nenhum segredo é lido, gravado ou enviado.
- O executor não faz commit nem push; quem publica é a sessão principal, depois da revisão.

## 15. Não se aplica

Banco de dados, migrations, autenticação de usuários, telas, uploads, exportações, APIs e logs de aplicação: o plugin não tem nenhum desses componentes.

## 16. Critérios de aceitação técnica (1.2.0)

- Nenhum arquivo do repositório nem da cópia instalada manda usar o ponytail; o bloco injetado diz que ele fica desligado.
- O bloco completo aparece na 1ª mensagem, depois de compactar/limpar e a cada 10 comandos; nos demais, o curto.
- O SessionStart não injeta nada com a Jornada desligada.
- O agente `jornada-executor` existe em `~/.claude/agents/` com `model: sonnet`.
- `bash tests/testar-hooks.sh` termina sem falhas.
- Versão `1.2.0` em `.claude-plugin/plugin.json`, publicada no GitHub.

## 17. Pendências

- PENDENTE - confirmar com o usuário: levar as mudanças da 1.2.0 para a skill `ia5k`.
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
