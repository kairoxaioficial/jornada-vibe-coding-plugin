# DECISOES_TECNICAS — Decisões técnicas do plugin

> Projeto: plugin Jornada IA Vibe Coding (`jornada-vibe-coding-plugin`)
> Última atualização: 16/10/2026 (versão 1.2.0)

| # | Decisão | Escolha | Justificativa / origem |
|---|---|---|---|
| 1 | Plataforma | Claude Code: skills, hooks e subagentes | O sistema é a metodologia rodando dentro do Claude Code (`hooks/hooks.json`, `skills/`) |
| 2 | Distribuição | Plugin (`.claude-plugin/`) e instalação direta (`instalar.sh` copia as skills para `~/.claude/skills` e registra os hooks no `~/.claude/settings.json`) | A máquina do usuário usa a instalação direta; o plugin serve para outras pessoas |
| 3 | Linguagem dos hooks | `bash` + `jq` | Sem Node nem Python; roda em macOS e Linux (`scripts/*.sh`) |
| 4 | Estado | Arquivos-marca em `~/.claude/jornada/` (`global-on`, `sessions/`, `projects/`, `p1/`, `edits/` e, a partir da 1.2.0, `injecao/`) | Simples, sem banco, fácil de inspecionar e apagar (`jornada-lib.sh`) |
| 5 | Ativação | Só por comando explícito; três alcances: sessão, projeto e global | Decisão do PRD (seção 6): nada liga sozinho |
| 6 | Travas | PreToolUse (edição sem documentos, AGENTS.md, leitura antes do grafo), Stop (STATUS desatualizado) | Regra garantida por hook, não pela memória do modelo |
| 7 | Ferramentas de economia de tokens | tokensave, rtk, code-review-graph, graphify, tokenoptim, caveman, context-mode, token-optimizer, claude-hud, ccusage | Cada uma cobre um tipo de gasto (`references/ferramentas-token.md`) |
| 8 | ponytail | **Removido** na 1.2.0 (16/10/2026, pedido do usuário) | A régua "o mínimo que funciona" puxa para baixo beleza, intuitividade e completude. O excesso já é contido pelo FSD (nada fora dele) e pela execução em etapas. Com a Jornada ativa, a regra injetada desliga o ponytail mesmo que outro hook ou o CLAUDE.md global o peça |
| 9 | Roteamento de modelos | Opus na sessão principal (ler pelo grafo, planejar, escrever a ordem de serviço, revisar, segurança, documentos); Sonnet no subagente `jornada-executor` (implementar e testar a etapa) | Escrever código é o trabalho que mais gera tokens de saída e mais chamadas de ferramenta; no Sonnet e num contexto pequeno ele custa menos, e a sessão principal fica enxuta (menos compactação, menos perda de detalhe). A revisão do Opus em cima do trabalho do Sonnet é uma segunda opinião independente |
| 9a | Alternativa descartada: `opusplan` | — | Troca o modelo da conversa inteira: testes, revisão e documentação também cairiam no Sonnet; cada troca de modelo perde o cache da conversa; depende do modo de plano com aprovação a cada etapa |
| 9b | Alternativa descartada: tudo no Opus | — | Custa mais por token e incha o contexto principal com leituras, diffs e logs de cada etapa |
| 9c | Exceções que ficam no Opus | Mudança pequena (até ~30 linhas em até 2 arquivos), código sensível de segurança (autenticação, sessão, permissões/RLS, criptografia, pagamento, segredos, upload), documentos da metodologia, correção depois de 2 rodadas sem sucesso do executor | Nesses casos delegar custa mais do que economiza ou o risco não compensa |
| 10 | Injeção do protocolo | Bloco completo na 1ª mensagem da sessão, ao ativar, depois de compactar/limpar e a cada `JORNADA_REFORCO` (padrão 10) mensagens; bloco curto nas demais | O texto injetado fica no histórico: repetir ~1.400 tokens a cada mensagem só ocupava contexto e era relido em toda chamada |
| 11 | Regras do caveman | Texto completo só quando o plugin caveman não está instalado; com o plugin, só a regra própria da metodologia (o que fica gravado sai em prosa normal) | O plugin já injeta as próprias regras; repetir era desperdício |
| 12 | SessionStart | Só injeta texto quando a Jornada está ativa, e só a lista de ferramentas (o protocolo vem no bloco completo da 1ª mensagem) | Antes injetava as regras em toda sessão, ativa ou não, duplicando o P0 |
| 13 | SKILL.md | Núcleo no `SKILL.md`; detalhes de fases raras (documentação final, deploy, extras, prompts de referência, ferramentas) movidos sem alteração para `references/detalhes-skill.md` | O SKILL.md inteiro entra no contexto quando a skill é lida; o detalhe raro é lido só quando a fase chega |
| 14 | Testes | `tests/testar-hooks.sh` (bash), com `HOME` isolado numa pasta temporária dentro do repositório | Testa os hooks como o Claude Code os chama (JSON na entrada padrão), sem tocar no estado real |
| 15 | Versionamento e publicação | Semver em `.claude-plugin/plugin.json`; GitHub público `kairoxaioficial/jornada-vibe-coding-plugin`, branch `main` | Histórico por etapa (um commit por etapa) |
| 16 | Segurança dos hooks | O texto do prompt só é comparado em `case`, nunca executado; nomes de arquivo de estado vêm do `session_id` com `/` trocado por `-` | Evita execução de conteúdo e caminhos fora de `~/.claude/jornada` |

## Perguntas em aberto

- PENDENTE - confirmar com o usuário: aplicar as mesmas mudanças (sem ponytail, roteamento de modelos, injeção enxuta) na skill irmã `ia5k` (APES IA5K), que hoje também injeta o protocolo e o ponytail em todo prompt.
