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
