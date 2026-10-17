# PLANO — Plano de desenvolvimento em etapas

> Projeto: plugin Jornada IA Vibe Coding (`jornada-vibe-coding-plugin`)
> Tarefa: versão 1.2.0 — sem ponytail, Opus planeja e Sonnet executa, menos tokens por comando
> Pedido do usuário (16/10/2026): "edite a skill jornada ia vibe coding e atualize no github, para não usar o ponytail; consumir menos tokens sem impactar no resultado; ler o código e planejar com o Opus 5.5 e executar com o Sonnet 5.5, sem perder qualidade, segurança, beleza e intuitividade; deixar funcionando em todas as sessões com a skill ativa"

## Regras de execução

- Cada etapa: código → teste real → `docs/STATUS.md` e `docs/ERROS.md` → commit.
- Nada fora do FSD. Documentos antes do código.
- O usuário pediu tudo pronto neste comando; as etapas são executadas em sequência, cada uma com teste e commit próprios.

## Etapas

| # | Etapa | Objetivo (leigo) | Critério de pronto | Status |
|---|---|---|---|---|
| 1 | Documentos do repositório | O repositório passa a ter PRD, decisões, FSD, insumos, design, plano, status e erros | Os 8 documentos existem; tabela de cobertura no FSD | concluída |
| 2 | Tirar o ponytail | A metodologia para de mandar "fazer o mínimo" e passa a exigir qualidade de produto | Busca por "ponytail" só encontra a regra que o desliga e o histórico; testes passam | concluída |
| 3 | Opus planeja, Sonnet executa | A sessão principal (Opus) lê, planeja e revisa; um ajudante no Sonnet escreve o código de cada etapa | Agente `jornada-executor` instalado com `model: sonnet`; guia `roteamento-modelos.md`; protocolo e SKILL.md atualizados | concluída |
| 4 | Menos texto repetido a cada mensagem | O protocolo completo vai na 1ª mensagem e a cada 10; nas outras, um lembrete curto | Testes do bloco completo/curto passam; SessionStart calado com a Jornada desligada | concluída |
| 5 | SKILL.md mais leve | A skill carrega menos texto; o detalhe raro fica num arquivo de consulta | SKILL.md menor, conteúdo movido sem perda, roteador de leitura apontando cada seção | concluída |
| 6 | Instalar, publicar e conferir | Tudo instalado na máquina, versão 1.2.0 no GitHub, documentação de uso atualizada | Cópia instalada igual ao repositório; push feito; teste final passa | concluída |

Depois da etapa 6: revisão de segurança dos scripts (Passo 5) e documentação final (Passo 6), registradas no STATUS.

## Dependências entre etapas

1 → 2 → 3 → 4 → 5 → 6. A etapa 4 depende do texto do protocolo definido nas etapas 2 e 3.

---

# Tarefa 2 — versão 1.2.1: esforço, Ultracode e planejamento por ângulos (17/10/2026)

Pedido do usuário (17/10/2026), depois da análise da noite de 16 para 17/10 no projeto ARCA, que consumiu cerca de 43% do limite semanal numa noite: a Jornada deve pesquisar e planejar por todos os ângulos com o Opus 5.5 (com Ultracode nas frentes grandes), executar com o Sonnet 5.5 e auditar com o Opus 5.5 e o Ultracode antes de publicar; e cuidar do esforço, ou pelo menos analisar e pedir ao usuário para subir ou baixar.

Escolhas do usuário na mesma data: executor em `high` por padrão e `xhigh` nas etapas difíceis; Ultracode só em frente grande ou arriscada, perguntando antes e mostrando o tamanho estimado.

## Etapas

| # | Etapa | Objetivo (leigo) | Critério de pronto | Status |
|---|---|---|---|---|
| 7 | Documentos da 1.2.1 | PRD, decisões, FSD, plano e status descrevem a nova versão antes de qualquer código | Documentos atualizados e commit | em andamento |
| 8 | Regras novas da metodologia | O executor ganha esforço próprio e a regra do teste que reprova sem a mudança; o guia de roteamento ganha a lista de ângulos, o Ultracode com pergunta antes, a auditoria antes de publicar e o paralelismo seguro; o SKILL.md resume tudo | Agente com `effort: high`; guia e SKILL.md com as seções novas; testes passam | pendente |
| 9 | Aviso de esforço no hook | O bloco injetado mostra o esforço e o Ultracode da sessão e as regras de quando pedir para mudar | Testes do detector (/effort, Ultracode, reinício, configurações) passam; bloco curto abaixo de 1.500 bytes | pendente |
| 10 | Instalar, publicar e conferir (1.2.1) | Versão 1.2.1 instalada na máquina e no GitHub, documentação de uso atualizada | Cópia instalada igual ao repositório; push feito; testes passam | pendente |

Depois da etapa 10: revisão de segurança dos scripts alterados (Passo 5) e documentação final (Passo 6), registradas no STATUS.

## Dependências

7 → 8 → 9 → 10. A etapa 9 usa o texto das regras definido na etapa 8.
