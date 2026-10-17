# STATUS — Acompanhamento do Desenvolvimento

> Projeto: plugin Jornada IA Vibe Coding (`jornada-vibe-coding-plugin`)
> Atualizado a cada avanço. O hook Stop bloqueia o encerramento se houve código alterado sem este arquivo atualizado.
> Tarefa atual: versão 1.2.1 — esforço, Ultracode e planejamento por ângulos (`docs/PLANO.md`, Tarefa 2).

## Visão geral do progresso

| # | Etapa | Status | Data | Commit |
|---|-------|--------|------|--------|
| 1 | Documentos do repositório | concluída | 16/10/2026 | ver git log |
| 2 | Tirar o ponytail | concluída | 16/10/2026 | ver git log |
| 3 | Opus planeja, Sonnet executa | concluída | 16/10/2026 | ver git log |
| 4 | Menos texto repetido a cada mensagem | concluída | 16/10/2026 | ver git log |
| 5 | SKILL.md mais leve | concluída | 16/10/2026 | ver git log |
| 6 | Instalar, publicar e conferir | concluída | 16/10/2026 | ver git log |
| 7 | Documentos da 1.2.1 | concluída | 17/10/2026 | ver git log |
| 8 | Regras novas da metodologia | concluída | 17/10/2026 | ver git log |
| 9 | Aviso de esforço no hook | concluída | 17/10/2026 | ver git log |
| 10 | Instalar, publicar e conferir (1.2.1) | em andamento | 17/10/2026 | — |

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

### Etapa 4 — Menos texto repetido a cada mensagem (16/10/2026)
- Arquivos: `scripts/jornada-lib.sh` (detecção do plugin caveman, contador de injeção por sessão, `JORNADA_REFORCO`), `scripts/jornada-context.sh` (bloco completo × bloco curto), `scripts/verificar-ferramentas.sh` (lê o payload, zera o contador em todo SessionStart, só fala com a Jornada ativa, sem repetir as regras do P0), `SKILL.md` e `references/ferramentas-token.md` (descrição do novo comportamento), `tests/testar-hooks.sh` (9 testes novos).
- Testes: `bash tests/testar-hooks.sh` → 36 testes, 0 falhas (ciclo completo/curto a cada 3 com `JORNADA_REFORCO=3`, completo depois de compactar e ao ativar, SessionStart calado com a Jornada desligada, regras do caveman só sem o plugin).
- Medição (projeto de teste com documentos completos e plugin caveman instalado): bloco antigo 6.212 bytes em toda mensagem; novo bloco completo 7.288 bytes (1ª mensagem e a cada 10) e bloco curto 755 bytes nas demais — em 10 mensagens, de ~62 KB para ~14 KB de texto injetado (~77% menos). SessionStart: de ~2,5 KB para uma linha (~300 bytes) quando nada falta.
- Erros: nenhum.
- Próxima etapa: 5 — SKILL.md mais leve.

### Etapa 5 — SKILL.md mais leve (16/10/2026)
- Arquivos: `SKILL.md` (61.233 → 45.002 bytes, −26%), `references/detalhes-skill.md` (novo, 20 KB: R10 deploy, Passo 6 documentação final, Passo 7 deploy com comandos, ferramentas de economia em detalhe, prompts verbatim chave, templates, estrutura de pastas, extras), `tests/testar-hooks.sh` (2 testes novos).
- Como foi feito: script que corta as seções pelo título (fora de blocos de código) e cola o texto igual no arquivo de referência; no SKILL.md fica um resumo de 1 a 5 linhas com ponteiro para a seção exata.
- Testes: conferência por script → 0 linhas do SKILL.md antigo perdidas (todas estão no SKILL.md novo ou no `detalhes-skill.md`); `bash tests/testar-hooks.sh` → 38 testes, 0 falhas (os 8 ponteiros acham a seção; SKILL.md abaixo de 50 KB).
- Mantidos no SKILL.md por pesarem no resultado: Passo 1 Design System, cold start, matriz de impacto, protocolo, roteamento de modelos, regras R1–R9, fluxos especiais.
- Erros: nenhum.
- Próxima etapa: 6 — instalar, publicar e conferir.

### Etapa 6 — Instalar, publicar e conferir (16/10/2026)
- Arquivos: `.claude-plugin/plugin.json` (1.2.0), `README.md` (novidades da 1.2.0, subagente, nove ferramentas), `METODOLOGIA.md` (bloco completo/curto, executor no P5/P6), `scripts/jornada-lib.sh` (plugin caveman desligado conta como ausente), `tests/testar-hooks.sh` (1 teste novo), `docs/FSD.md`, `docs/PLANO.md`, `docs/ERROS.md`.
- Instalação: `bash instalar.sh` na máquina do usuário → `~/.claude/skills/jornada-vibe-coding`, `~/.claude/skills/estruturar-projeto` e `~/.claude/agents/jornada-executor.md` idênticos ao repositório (`diff -rq` sem diferença); backup do `settings.json` criado; nenhum hook duplicado (7 hooks da Jornada).
- Testes: `bash tests/testar-hooks.sh` → 39 testes, 0 falhas. Hooks instalados com sessão descartável: 1ª mensagem bloco completo (7.267 bytes), 2ª bloco curto (734 bytes), SessionStart de compactação com uma linha, mensagem seguinte completo de novo. Teste real `claude -p --model opus` pedindo ao `jornada-executor` uma etapa de um arquivo: `modelUsage` com `claude-opus-5-5` e `claude-sonnet-5-5`, arquivo criado, relatório no formato do agente (custo do teste: US$ 0,61).
- Erros: ERRO-004 (corrigido).

### Etapa 7 — Documentos da 1.2.1 (17/10/2026)
- Tarefa aberta: versão 1.2.1 (ver `docs/PLANO.md`, Tarefa 2), pedida depois da análise da noite do ARCA.
- Arquivos: `PRD.md` (funcionalidades, regras, informações controladas e critérios da 1.2.1), `DECISOES_TECNICAS.md` (decisões 17 a 23), `docs/FSD.md` (hooks, estado `esforco/`, linha de esforço, itens 6 a 10 do roteamento, seção 9a do detector de esforço, testes e critérios da 1.2.1), `docs/PLANO.md` (Tarefa 2, etapas 7 a 10).
- Evidência usada: análise das transcrições do ARCA (62 defeitos distintos por causa raiz, incidentes da execução em paralelo, contexto dos agentes) e documentação oficial do Claude Code sobre workflows, esforço e subagentes; formato da mensagem do `/effort` conferido no código do Claude Code instalado.
- Testes: `bash tests/testar-hooks.sh` → 39 testes, 0 falhas (nenhum código mudou nesta etapa).
- Erros: nenhum.
- Próxima etapa: 8 — regras novas da metodologia.

### Etapa 8 — Regras novas da metodologia (17/10/2026)
- Arquivos: `agents/jornada-executor.md` (`effort: high`; item Ângulos da ordem de serviço; teste que reprova sem a mudança; trabalho em paralelo; menor largura do DESIGN), `skills/jornada-vibe-coding/references/roteamento-modelos.md` (versão 1.2.1: lista de ângulos, ordem de serviço com ângulos, esforço e paralelo, seção de esforço, Ultracode com pergunta antes e papéis e modelos de cada agente, auditoria antes de publicar, ciclo do executor, paralelismo seguro), `skills/jornada-vibe-coding/SKILL.md` (P4, P5 e P6; roteamento ampliado; seção nova "ESFORÇO E ULTRACODE"), `docs/FSD.md` (conteúdo da ordem de serviço), `tests/testar-hooks.sh` (4 testes novos).
- Testes: `bash tests/testar-hooks.sh` → 43 testes, 0 falhas. SKILL.md com 47.617 bytes (limite do teste: 50 KB).
- Erros: nenhum.
- Próxima etapa: 9 — aviso de esforço no hook.

### Etapa 9 — Aviso de esforço no hook (17/10/2026)
- Quem fez: o executor Sonnet (`jornada-executor`, esforço `high`) implementou a partir da ordem de serviço; o Opus revisou o diff, rodou os testes de novo e corrigiu um defeito antigo achado na revisão (ERRO-006).
- Arquivos: `scripts/jornada-lib.sh` (`jornada_esforco_marca`, `jornada_esforco_inicio`, `jornada_esforco`), `scripts/jornada-context.sh` (lê `transcript_path`; linha de esforço nos dois blocos; P4, P5 e P6 com as regras da 1.2.1; linha "ESFORCO E ULTRACODE"; ligar e desligar só por texto do usuário), `scripts/verificar-ferramentas.sh` (ponto de partida do detector no início e na retomada do processo), `tests/testar-hooks.sh` (18 testes novos), `docs/ERROS.md` (ERRO-005 e ERRO-006), `docs/FSD.md` (seção 9a com a implementação, testes 12, segurança), `DECISOES_TECNICAS.md` (decisão 16), `PRD.md` (critério de aceitação).
- Testes: `bash tests/testar-hooks.sh` → 61 testes, 0 falhas. Bloco curto com 988 bytes. Detector em histórico sintético de 20 MB: cerca de 200 ms. Nos históricos reais desta máquina (7 e 9 MB), a linha saiu `Esforco da sessao: max (/effort) | Ultracode: ligado`, que é o estado real das duas sessões. Conferência dos testes novos sem a mudança: o executor desfez cada trecho e viu reprovar; o Opus desfez a correção do ERRO-006 e viu os 3 testes dela reprovarem, depois restaurou.
- Erros: ERRO-005 (detector lento por pipe no macOS) e ERRO-006 (notificação de tarefa ligava a Jornada), corrigidos.
- Próxima etapa: 10 — instalar, publicar e conferir.

### Revisão de segurança dos scripts (Passo 5) — 16/10/2026
- Texto do prompt só é comparado em `case`, nunca executado nem interpolado em comando.
- Arquivos de estado novos (`injecao/`) ficam dentro de `$JORNADA_HOME`; o nome vem do `session_id` com `/` trocado por `-`, então não sai da pasta.
- `JORNADA_REFORCO` é validado (só dígitos; senão 10) antes de entrar em conta aritmética.
- O contador ilegível ou impossível de gravar faz o hook mandar o bloco completo (falha para o lado seguro).
- O executor não faz commit, push nem altera histórico; quem publica é a sessão principal depois da revisão.
- Nenhum segredo lido, gravado ou enviado. Resultado: nada a corrigir.

### Documentação final (Passo 6) — 16/10/2026
- `README.md`, `INSTALAR.md`, `METODOLOGIA.md`, `CLAUDE.md` e os documentos da metodologia descrevem a versão 1.2.0.

## Checklist completo — todas as etapas

1. Documentos do repositório: abrir o repositório → existem `PRD.md`, `DECISOES_TECNICAS.md`, `INSUMOS.md` e `docs/` com FSD, DESIGN, PLANO, STATUS e ERROS.
2. Sem ponytail: pedir qualquer coisa com a Jornada ligada → a resposta não fala em "o mínimo que funciona"; o bloco da metodologia diz "PONYTAIL DESLIGADO".
3. Opus planeja, Sonnet executa: pedir uma etapa de código num projeto com documentos → o Claude escreve uma ordem de serviço e chama o `jornada-executor`; depois revisa e faz o commit.
4. Menos texto repetido: mandar duas mensagens seguidas → a primeira recebe o bloco completo e a segunda o bloco curto.
5. SKILL.md mais leve: abrir `skills/jornada-vibe-coding/SKILL.md` → seções de deploy, documentação final e extras apontam para `references/detalhes-skill.md`, onde o texto completo está.
6. Instalado e publicado: `bash tests/testar-hooks.sh` → "0 falhas"; versão 1.2.0 no GitHub.

## Próximos passos

- PENDENTE - confirmar com o usuário: levar as mesmas mudanças para a skill `ia5k` e para a versão Codex (`~/.agents/skills/jornada-ia-vibe-coding-codex`), que ainda citam o ponytail.
