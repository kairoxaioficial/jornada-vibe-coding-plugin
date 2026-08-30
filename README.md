# Jornada IA Vibe Coding — plugin para Claude Code

Metodologia de desenvolvimento em duas fases (Análise e Codificação) empacotada como plugin do Claude Code.

Ao ativar, o Claude passa a trabalhar sempre da mesma forma: primeiro entende e documenta, depois codifica em etapas, testa cada etapa, registra erros e entrega checklists em linguagem leiga.

## O que vem dentro

- **Skill `jornada-vibe-coding`** — a metodologia completa, com os prompts de cada fase.
- **Skill `estruturar-projeto`** — cria toda a estrutura de documentos em um projeto novo ou já existente.
- **Templates** — `PRD.md`, `DECISOES_TECNICAS.md`, `FSD.md`, `INSUMOS.md`, `DESIGN.md`, `PLANO.md`, `STATUS.md`, `ERROS.md`, `CHECKLIST.md`, `CLAUDE.md`.
- **Hooks** — mantêm a metodologia ativa durante toda a sessão e impedem que o Claude comece a mexer no código antes de os documentos existirem.

## Instalação (recomendada)

Dentro do Claude Code, digite:

```
/plugin marketplace add kairoxaioficial/jornada-vibe-coding-plugin
/plugin install jornada-vibe-coding@jornada
```

Depois reinicie o Claude Code.

## Como usar

| Comando | O que faz |
| --- | --- |
| `/jornada-vibe-coding` | Liga a metodologia para toda a sessão e todo o projeto. |
| `/jornada-vibe-coding off` | Desliga. |
| `/estruturar-projeto` | Cria os documentos da metodologia no projeto atual. |

Com a metodologia ligada, é só pedir o que você quer ("crie um sistema de agendamento", "adicione login") que o Claude segue o fluxo sozinho.

## Requisitos

- Claude Code instalado.
- `jq` disponível no terminal (os hooks usam). No macOS: `brew install jq`. No Ubuntu/Debian: `sudo apt install jq`.

## Observações

- O arquivo de contexto do projeto é sempre `CLAUDE.md`. A metodologia nunca cria `AGENTS.md`.
- A skill `estruturar-projeto` cita ferramentas opcionais de economia de token (tokensave, code-review-graph, rtk, caveman, ponytail, graphify). Se você não as tiver instaladas, a metodologia funciona do mesmo jeito — o Claude simplesmente lê o código do modo normal.
- Para desinstalar: `/plugin uninstall jornada-vibe-coding@jornada`.

Licença: MIT.
