# Roteamento de modelos — o Opus planeja e revisa, o Sonnet executa

> Versão 1.2.0 · 16/10/2026. Vale sempre que a Jornada estiver ativa.

## Por que dividir

- Escrever código é a parte que mais gera tokens de saída (os mais caros) e a que mais faz chamadas de ferramenta — e cada chamada relê o contexto inteiro da conversa.
- No executor, esse trabalho roda no Sonnet e num contexto pequeno: só a ordem de serviço e o código da etapa. Na sessão principal entra apenas o relatório curto que ele devolve.
- A sessão principal (Opus) fica enxuta: compacta menos, perde menos detalhe e gasta o raciocínio onde ele faz diferença — entender o sistema, decidir, especificar e revisar.
- Segunda opinião de verdade: quem revisa não é quem escreveu.

## Quem faz o quê

| Passo | Quem |
|---|---|
| P1 Ler o código pelo grafo | Opus |
| P2–P4 Documentos, matriz de impacto, plano | Opus |
| Ordem de serviço da etapa | Opus (modelo abaixo) |
| P5 Implementar a etapa | Executor Sonnet (`jornada-executor`) |
| P6 Testes automatizados | Executor escreve e roda; o Opus roda de novo na revisão |
| P6 Validação visual (screenshot desktop e 375 px) | Opus — é julgamento de beleza e de facilidade de uso |
| Revisão do diff | Opus (checklist abaixo) |
| P7 `STATUS.md` e matriz de impacto | Opus; o executor registra os erros dele no `ERROS.md` e o Opus confere |
| P8 Commit e checklists em linguagem leiga | Opus |
| Revisão de segurança final (Passo 5) | Opus |

## Quando NÃO delegar (o Opus faz direto)

- Mudança pequena: até ~30 linhas em até 2 arquivos — delegar custaria mais do que fazer.
- Código sensível de segurança: autenticação, sessão, permissões/RLS, criptografia, pagamento, segredos, upload de arquivo.
- Documentos da metodologia (PRD, FSD, DECISOES_TECNICAS, DESIGN, PLANO, STATUS).
- Depois de 2 rodadas de correção sem sucesso do executor.
- Quando a etapa depende de uma decisão do usuário: perguntar ao usuário primeiro, delegar depois.

## Ordem de serviço (copiar e preencher)

```
ORDEM DE SERVIÇO — Etapa N: <nome>   (projeto: <raiz>)
1. Objetivo: <o que o usuário vai ver funcionando, em 1-2 frases>
2. Ler antes (só isto): <FSD §x, DESIGN §y, PRD regra z, ERROS ERRO-nnn, arquivos e símbolos>
3. Arquivos: criar <caminho> — <conteúdo>; alterar <caminho>:<símbolo> — <mudança>
4. Contratos: <assinaturas e tipos; rotas (método, caminho, entrada, saídas e códigos); schema/migration>
5. Regras de negócio e validações: <regra — origem no PRD/FSD>
6. Interface: <componentes e tokens do DESIGN; estados carregando/vazio/erro/sucesso; textos exatos; responsivo; acessibilidade; animação>
7. Segurança: <entradas a validar; autorização exigida; segredos por variável de ambiente; riscos desta etapa>
8. Testes obrigatórios: <casos: feliz, borda, erro, permissão>; comandos: <lint, typecheck, testes, build>
9. Fora do escopo: <o que não fazer>
10. Pronto quando: <critérios que dá para conferir>
```

Quanto mais exata a ordem de serviço, melhor o resultado: o executor não adivinha — o que faltar, ele para e relata como `BLOQUEIO`.

## Como chamar

- Ferramenta Agent com `subagent_type: "jornada-executor"` (instalado como plugin: `jornada-vibe-coding:jornada-executor`) e a ordem de serviço inteira no `prompt`.
- Um executor por etapa. Para ajustes, `SendMessage` ao mesmo executor (ele mantém o contexto da etapa) com a lista objetiva do que corrigir.
- Etapas independentes podem ir para executores em paralelo, na mesma mensagem, desde que não mexam nos mesmos arquivos.

## Revisão do Opus (antes do commit)

1. `git diff --stat` e o diff só dos arquivos da etapa (ou `detect_changes_tool` + `get_review_context_tool`).
2. Ordem de serviço item a item: o "pronto quando" foi cumprido?
3. Segurança: validação de entrada, autorização, segredos, injeção, XSS/CSRF quando houver web.
4. Interface: screenshot desktop e 375 px; estados; textos; acessibilidade; aderência ao DESIGN.
5. Rodar os testes de novo — sistema criado não é sistema testado.
6. Ajustes: até 2 rodadas com o executor; depois disso, o Opus assume.
7. Fechar: `STATUS.md`, matriz de impacto, commit, checklists 1-2-3.

## Modelo da sessão principal

A sessão principal precisa estar no Opus (`/model opus`; nesta máquina, `"model": "opus"` no `~/.claude/settings.json`). Se o modelo atual não for o Opus, avisar o usuário antes de planejar.

## Medir

`npx -y ccusage@latest daily --breakdown` mostra o gasto por dia separado por modelo; compare uma etapa antes e depois da divisão.
