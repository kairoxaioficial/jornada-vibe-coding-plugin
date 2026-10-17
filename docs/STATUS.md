# STATUS — Acompanhamento do Desenvolvimento

> Projeto: plugin Jornada IA Vibe Coding (`jornada-vibe-coding-plugin`)
> Atualizado a cada avanço. O hook Stop bloqueia o encerramento se houve código alterado sem este arquivo atualizado.

## Visão geral do progresso

| # | Etapa | Status | Data | Commit |
|---|-------|--------|------|--------|
| 1 | Documentos do repositório | concluída | 16/10/2026 | ver git log |
| 2 | Tirar o ponytail | concluída | 16/10/2026 | ver git log |
| 3 | Opus planeja, Sonnet executa | concluída | 16/10/2026 | ver git log |
| 4 | Menos texto repetido a cada mensagem | pendente | — | — |
| 5 | SKILL.md mais leve | pendente | — | — |
| 6 | Instalar, publicar e conferir | pendente | — | — |

## Detalhamento das etapas

### Etapa 1 — Documentos do repositório (16/10/2026)
- Tarefa aberta: versão 1.2.0 (ver `docs/PLANO.md`).
- Arquivos: `PRD.md` (trazido da cópia instalada e atualizado para v1.2), `DECISOES_TECNICAS.md`, `INSUMOS.md`, `docs/FSD.md` (com a tabela de cobertura do cold start), `docs/DESIGN.md`, `docs/PLANO.md`, `docs/STATUS.md`, `docs/ERROS.md`, `CLAUDE.md` (seção de como trabalhar), `.gitignore` (`.tokensave/`, `tests/.tmp-*`).
- Teste: `jornada-session.sh status .` → "docs: completos" (a trava de edição de código deixa de bloquear o repositório).
- Próxima etapa: 2 — tirar o ponytail.

### Etapa 2 — Tirar o ponytail (16/10/2026)
- Arquivos: `SKILL.md`, `references/ferramentas-token.md`, `scripts/instalar-ferramentas.sh`, `scripts/jornada-context.sh`, `scripts/jornada-lib.sh`, `scripts/verificar-ferramentas.sh` (trazidos da cópia instalada, que já estava sem ponytail desde 05/10/2026 sem ter sido publicada); `jornada-lib.sh` ganhou a regra "PONYTAIL DESLIGADO" no bloco injetado; `README.md`, `INSTALAR.md`, `METODOLOGIA.md`, `skills/estruturar-projeto/SKILL.md` sem ponytail; `~/.claude/CLAUDE.md` (fora do repositório) com a exceção "com a Jornada ativa, ponytail desligado"; `tests/testar-hooks.sh` criado.
- Testes: `bash tests/testar-hooks.sh` → 22 testes, 0 falhas (sintaxe de todos os scripts, bloco injetado, nenhuma instrução de usar o ponytail, trava de edição).
- Erros: ERRO-001 (corrigido).
- Próxima etapa: 3 — Opus planeja, Sonnet executa.

### Etapa 3 — Opus planeja, Sonnet executa (16/10/2026)
- Arquivos: `agents/jornada-executor.md` (novo, `model: sonnet`), `skills/jornada-vibe-coding/references/roteamento-modelos.md` (novo: quem faz o quê, quando não delegar, modelo da ordem de serviço, revisão, medição), `SKILL.md` (P5/P6, seções "ROTEAMENTO DE MODELOS" e "PONYTAIL DESLIGADO", Passo 4), `scripts/jornada-context.sh` (P5/P6 do bloco injetado), `instalar.sh` (copia `agents/*.md` para `~/.claude/agents`; matcher da trava de leitura com `Bash`), `tests/testar-hooks.sh` (5 testes novos).
- Testes: `bash tests/testar-hooks.sh` → 27 testes, 0 falhas.
- Erros: ERRO-002 e ERRO-003 (corrigidos).
- Próxima etapa: 4 — menos texto repetido a cada mensagem.

## Checklist completo — todas as etapas

(vazio)

## Próximos passos

(vazio)
