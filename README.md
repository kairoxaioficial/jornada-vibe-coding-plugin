# Jornada IA Vibe Coding — plugin para Claude Code

Metodologia de desenvolvimento em duas fases (Análise e Codificação) empacotada como plugin do Claude Code.

Ao ativar, o Claude passa a trabalhar sempre da mesma forma: primeiro entende e documenta, depois codifica em etapas, testa cada etapa, registra erros e entrega checklists em linguagem leiga.

**[📖 Como a metodologia funciona — passo a passo](METODOLOGIA.md)** — o fluxo inteiro explicado em linguagem simples: cada fase, cada passo, cada documento, o que você faz e o que a IA faz.

## O que vem dentro

- **Skill `jornada-vibe-coding`** — a metodologia completa, com os prompts de cada fase.
- **Skill `estruturar-projeto`** — cria toda a estrutura de documentos em um projeto novo ou já existente.
- **Templates** — `PRD.md`, `DECISOES_TECNICAS.md`, `FSD.md`, `INSUMOS.md`, `DESIGN.md`, `PLANO.md`, `STATUS.md`, `ERROS.md`, `CHECKLIST.md`, `CLAUDE.md`.
- **Hooks** — mantêm a metodologia ativa durante toda a sessão, impedem que o Claude comece a mexer no código antes de os documentos existirem e conferem, a cada sessão, se as ferramentas de economia de tokens estão instaladas.
- **`scripts/instalar-ferramentas.sh`** — instala as sete ferramentas obrigatórias de economia de tokens.

## Ferramentas obrigatórias de economia de tokens

A metodologia **depende** destas sete ferramentas. Sem elas o agente lê arquivos inteiros, estoura o contexto no meio do projeto e a conta fica cara. Com elas, ele lê grafo em vez de código bruto.

| # | Ferramenta | Para que serve | Repositório |
|---|---|---|---|
| 1 | tokensave (MCP) | Grafo de código: entender o sistema sem ler arquivo inteiro | https://github.com/aovestdipaperino/tokensave |
| 2 | rtk | Filtra a saída dos comandos de terminal (até 90% menos tokens) | https://github.com/rtk-ai/rtk |
| 3 | code-review-graph (MCP) | Grafo estrutural: review, impacto, arquitetura | https://github.com/tirth8205/code-review-graph |
| 4 | graphify | Grafo de conhecimento de qualquer insumo (código, docs, PDF, vídeo) | https://github.com/Graphify-Labs/graphify |
| 5 | tokenoptim | Compressão de prompt e contexto | https://github.com/Manas470/tokenoptim |
| 6 | ponytail (plugin) | Força a solução mais simples que funciona | https://github.com/dietrichgebert/ponytail |
| 7 | caveman (plugin) | Saída ultracomprimida sem perder substância técnica | https://github.com/JuliusBrussee/caveman |

Instalar tudo de uma vez (as cinco de linha de comando):

```bash
git clone https://github.com/kairoxaioficial/jornada-vibe-coding-plugin
cd jornada-vibe-coding-plugin
bash scripts/instalar-ferramentas.sh
```

Só conferir o que falta: `bash scripts/instalar-ferramentas.sh --check`

As duas últimas são plugins do Claude Code. Cole dentro do Claude Code, um comando de cada vez:

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
/plugin marketplace add JuliusBrussee/caveman
/plugin install caveman@caveman
```

### Uso automático, garantido por hook

Não depende de o Claude "lembrar":

- **Baixa sozinho.** Ao ativar a metodologia e a cada início de sessão, o plugin verifica as cinco ferramentas de linha de comando e instala em segundo plano as que faltarem (no máximo uma vez por dia). Log em `~/.claude/jornada/instalacao.log`.
- **Obriga o uso em todo passo.** Enquanto a metodologia estiver ativa, ler código direto (`Read`, `Grep`, `Glob`) fica **bloqueado** até o mapeamento pelo grafo ser feito. A trava cai na primeira chamada de `tokensave` ou `code-review-graph` na sessão. Documentos, configs e imagens passam sempre.
- **ponytail e caveman ficam sempre ligados.** As regras dos dois são injetadas em todo prompt pelos hooks — funcionam mesmo antes de os plugins serem instalados. O nível do caveman (`full`) é gravado automaticamente em `~/.claude/.caveman-active` se ainda não existir.
- **Várias ferramentas por passo, não uma.** Consultas independentes vão na mesma mensagem, em paralelo — duas consultas de grafo custam menos que ler um arquivo. A tabela de combinações por passo está em `skills/jornada-vibe-coding/SKILL.md`.

As regras de uso de cada ferramenta estão em `skills/jornada-vibe-coding/references/ferramentas-token.md`.

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

O passo a passo completo de cada fase está em **[METODOLOGIA.md](METODOLOGIA.md)**.

Com a metodologia ligada, é só pedir o que você quer ("crie um sistema de agendamento", "adicione login") que o Claude segue o fluxo sozinho.

## Requisitos

- Claude Code instalado.
- `jq` disponível no terminal (os hooks usam). No macOS: `brew install jq`. No Ubuntu/Debian: `sudo apt install jq`.
- `git`, `python3` e, de preferência, `uv` ou `pipx` — usados para instalar as ferramentas de economia de tokens.

## Observações

- O arquivo de contexto do projeto é sempre `CLAUDE.md`. A metodologia nunca cria `AGENTS.md`.
- As sete ferramentas de economia de tokens são **obrigatórias**, não opcionais: o plugin confere a cada sessão e instrui o Claude a instalar o que faltar antes de trabalhar.
- Para desinstalar: `/plugin uninstall jornada-vibe-coding@jornada`.

Licença: MIT.
