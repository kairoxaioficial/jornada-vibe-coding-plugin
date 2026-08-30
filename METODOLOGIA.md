# Como a metodologia funciona — passo a passo

Este documento explica, em linguagem simples, o que acontece do começo ao fim quando você trabalha com a metodologia Jornada IA Vibe Coding ligada. Não é preciso saber programar para acompanhar.

## Índice

- [A ideia em uma frase](#a-ideia-em-uma-frase)
- [Os documentos que a metodologia cria](#os-documentos-que-a-metodologia-cria)
- [Ligando e desligando](#ligando-e-desligando)
- [O que acontece a cada mensagem sua (P0 a P8)](#o-que-acontece-a-cada-mensagem-sua-p0-a-p8)
- [Fase 1 — Análise: entender antes de construir](#fase-1--análise-entender-antes-de-construir)
- [Fase 2 — Codificação: construir em etapas](#fase-2--codificação-construir-em-etapas)
- [As travas: o que o plugin impede na prática](#as-travas-o-que-o-plugin-impede-na-prática)
- [Situações do dia a dia](#situações-do-dia-a-dia)
- [Projeto que já existe (cold start)](#projeto-que-já-existe-cold-start)
- [Economia de tokens em cada passo](#economia-de-tokens-em-cada-passo)
- [Perguntas frequentes](#perguntas-frequentes)

---

## A ideia em uma frase

Primeiro se escreve o que o sistema precisa ser; depois se constrói, uma etapa por vez, testando cada uma antes de seguir.

O problema que isso resolve: pedir "faz um sistema de agendamento" para uma IA costuma gerar mil linhas de código em um chute só, sem ninguém saber o que foi decidido, o que foi testado e o que falta. Duas semanas depois ninguém entende o próprio sistema. A metodologia troca isso por documentos curtos e etapas pequenas, cada uma testada e registrada.

---

## Os documentos que a metodologia cria

| Documento | O que é, em português claro |
|---|---|
| `PRD.md` | O que o sistema faz e para quem. Sem nada de tecnologia. |
| `DECISOES_TECNICAS.md` | As escolhas técnicas: linguagem, banco de dados, hospedagem, login, permissões. |
| `docs/DESIGN.md` | A cara do sistema: cores, fontes, espaçamentos, componentes. |
| `docs/FSD.md` | A especificação completa: junta os três de cima e detalha fase por fase o que construir. |
| `docs/INSUMOS.md` | A conferência de que tudo acima está coerente e sem buracos. |
| `docs/PLANO.md` | A lista de etapas de construção, na ordem. |
| `docs/STATUS.md` | O diário: em que etapa está, o que já foi testado, qual a próxima. Nasce vazio. |
| `docs/ERROS.md` | Todo erro que aparecer, com a causa e a correção. Nasce vazio. |
| `CLAUDE.md` | As instruções que a IA lê toda vez que abre o projeto. |

Duas regras que valem sempre:

- `STATUS.md` e `ERROS.md` **nascem vazios**. Eles se enchem enquanto o trabalho acontece. Um `STATUS.md` cheio no primeiro dia é sinal de que a IA inventou.
- O arquivo de contexto é **sempre `CLAUDE.md`**, nunca `AGENTS.md` — há uma trava que bloqueia a criação de `AGENTS.md`.

---

## Ligando e desligando

| Você digita | Acontece |
|---|---|
| `/jornada-vibe-coding` | Liga a metodologia para toda a conversa **e** para o projeto. |
| `/jornada-vibe-coding off` | Desliga. |
| `/estruturar-projeto` | Cria todos os documentos acima no projeto atual. |

Ligar não é uma sugestão que a IA pode esquecer no meio da conversa: enquanto estiver ligada, o protocolo é reinjetado a cada mensagem sua e as travas continuam valendo, mesmo daqui a cinquenta mensagens.

---

## O que acontece a cada mensagem sua (P0 a P8)

Toda vez que você escreve qualquer coisa — de "cria um sistema de pedidos" até "muda essa cor para azul" — o mesmo protocolo roda:

**P0 — Ferramentas.** Confere as sete ferramentas de economia de tokens e baixa em segundo plano as que faltarem. Você não faz nada.

**P1 — Ler com economia.** Antes de opinar ou editar, a IA mapeia o projeto pelo grafo de código (`tokensave`, `code-review-graph`) em vez de abrir arquivo por arquivo. Enquanto isso não acontece, ler código direto fica bloqueado.

**P2 — Documentos.** Se faltar algum documento da metodologia, ele é criado **antes** de qualquer código, a partir do que já existe no projeto.

**P3 — Classificar o pedido.** É um ajuste simples (vai direto para o código) ou um recurso novo / mudança grande (exige atualizar PRD, FSD, decisões técnicas antes)?

**P4 — Planejar.** A tarefa entra em `docs/PLANO.md` dividida em etapas, e a etapa atual é aberta em `docs/STATUS.md`.

**P5 — Executar UMA etapa.** Uma por comando. Nada de construir cinco coisas de uma vez, nada de usar tecnologia que não está no FSD.

**P6 — Testar de verdade.** Lint, tipos, testes, build, migrations, subir o servidor. Se tem tela, screenshot e conferência no celular. *Sistema criado não é sistema testado.*

**P7 — Registrar.** `STATUS.md` recebe a etapa, os arquivos alterados, os testes e o resultado. `ERROS.md` recebe todo erro que apareceu, mesmo os já corrigidos — e é consultado **antes** de tentar corrigir um erro novo.

**P8 — Entregar.** Commit + três checklists: o que foi feito (linguagem leiga), o que testar e como (ação → resultado esperado), e o que conferir para ter certeza de que nada quebrou.

---

## Fase 1 — Análise: entender antes de construir

Nenhuma linha de código é escrita nesta fase. Cada passo produz um documento que você aprova antes do próximo.

### Passo 0 — Chat de dúvidas
Um chat separado só para tirar dúvidas de conceito ("o que é um CRUD?", "o que é migration?"). Decisões sobre **o seu** sistema não se tomam aqui — elas têm o passo certo mais adiante.

### Passo 1 — Design System → `docs/DESIGN.md`
Define a identidade visual: cores, tipografia, espaçamento, componentes, comportamento no celular, acessibilidade. Pode nascer do zero, de uma imagem de referência, de um HTML/CSS existente ou do Google Stitch.
**Critério para aprovar:** nada de "cores modernas" — tem que ser específico. Contraste conferido, fontes legíveis, componentes descritos.
**Vale para sempre:** a IA é obrigada a ler este arquivo antes de criar ou mudar qualquer tela.

### Passo 2 — Explorar a ideia
Uma entrevista. A IA pergunta, você responde, ela consolida, repete — até você dizer "chega". O objetivo é transformar "quero um sistema de agendamento" em uma visão clara do que entra e do que fica de fora.
**Regra de ouro:** nenhuma decisão técnica aqui. Nada de linguagem, banco, framework ou tabela. Só o que o sistema faz.
**Saída:** um resumo consolidado da conversa.

### Passo 3 — PRD → `PRD.md`
O documento do produto: objetivo, problema, público, perfis de usuário, funcionalidades da versão 1, o que fica **fora** da versão 1, regras de negócio, fluxos principais, critérios de aceitação, dúvidas em aberto.
Continua sem tecnologia. Você aprova antes de seguir.

### Passo 4 — Decisões Técnicas → `DECISOES_TECNICAS.md`
Agora sim a tecnologia, em 16 seções: linguagem e framework, banco, ambiente local, deploy, organização de pastas, login, perfis, auditoria, exclusão lógica, logs, uploads, exportações, APIs, configurações globais.
O que não estiver definido, a IA **pergunta** — não inventa.

### Passo 5 — FSD → `docs/FSD.md`
A especificação funcional completa, em 28 seções, que junta PRD + Design + Decisões Técnicas e quebra a construção em fases numeradas (estrutura base, banco, autenticação, entidades, CRUDs, fluxos, relatórios, uploads, exportações, APIs, logs, segurança, qualidade, entrega).
É deste documento que sai o `PLANO.md`. Se o FSD tem buraco, a IA vai preencher inventando — daí o passo seguinte.

### Passo 6 — Validar o FSD
Uma revisão independente antes de qualquer código: o FSD atende tudo que o PRD pediu? As decisões técnicas estão completas? Sobrou lacuna?
**Saída:** um relatório com problemas críticos, problemas importantes, melhorias recomendadas e conclusão. Corrija o que apareceu antes de programar.

---

## Fase 2 — Codificação: construir em etapas

### Passo 0 — Chat de ajuda
Dúvidas técnicas ficam em um chat separado do chat que constrói. O chat de execução não se mistura com dúvida.

### Passo 1 — Validar insumos → `docs/INSUMOS.md`
A IA lê **todos** os documentos por completo e confere: o FSD atende o PRD? As decisões estão completas? Há conflito entre documentos? Por qual etapa do plano começar?
Conflitos e lacunas se resolvem aqui, não no meio do código.

### Passo 2 — Preparar a estrutura
Cria `docs/PLANO.md` (as fases extraídas do FSD), `docs/STATUS.md` (vazio), `docs/ERROS.md` (com o modelo de registro), `CLAUDE.md` (as instruções permanentes do projeto) e as pastas do projeto conforme o FSD.

### Passo 3 — Git e GitHub
`git init`, `.gitignore` (nunca versionar `.env`, segredos, logs, dumps, chaves), `.gitattributes`, primeiro commit e conexão com o GitHub. Inclui o tutorial de chave SSH para Windows, macOS e Linux.

### Passo 4 — Codificar em etapas (o coração)
**Uma fase por vez, um chat novo por fase.** O ciclo de cada fase:

1. A IA lê o contexto: `PLANO.md`, `STATUS.md`, `ERROS.md`, `FSD.md`, `CLAUDE.md`.
2. Identifica a **próxima etapa pendente** no plano — seguindo a ordem, sem escolher a mais fácil.
3. Implementa **só aquela etapa**.
4. Testa de verdade (comandos reais, tela aberta, fluxo percorrido).
5. Atualiza `STATUS.md` e `ERROS.md`.
6. Faz o commit.
7. Entrega os checklists: o que foi feito, em linguagem leiga; e o que você deve testar, passo a passo, com o resultado esperado de cada ação.
8. Próxima fase: chat novo, mesmo prompt.

**O que não pode acontecer:** construir várias fases de uma vez; instalar biblioteca que não está no FSD sem perguntar; presumir tecnologia; marcar fase como concluída sem os critérios atendidos.

**Quando algo quebra:** consultar `ERROS.md` primeiro (já aconteceu antes?), reproduzir o erro, descrever o que fez / o que esperava / o que aconteceu, corrigir, testar de novo, registrar. Se travar de vez: chat novo, mesmo prompt, contexto atualizado.

### Passo 5 — Revisão de segurança
Ao terminar todas as etapas, antes da documentação. Confere injeção de SQL, XSS, CSRF, hash de senha, sessão, controle de acesso por perfil, isolamento de dados entre usuários/empresas, arquivos sensíveis, variáveis de ambiente, mensagens de erro que vazam detalhe técnico, logs, validação de entrada, uploads, APIs externas e credenciais.

### Passo 6 — Documentação final
Cria `docs/MANUTENCAO.md` (como rodar, mapa de pastas, como adicionar tela, como adicionar campo, como testar, cuidados de segurança) e `docs/COMO-PEDIR-MUDANCAS.md` (modelos prontos de pedido, para quem não é técnico). O `CLAUDE.md` passa de "modo construção" para "modo manutenção".

### Passo 7 — Deploy
Publicação via GitHub Actions com rsync por SSH. Deploy **manual** (você aperta o botão), nunca automático a cada push, e o primeiro deploy roda sem `--delete`. Segredos ficam no servidor e no GitHub Secrets — **nunca** dentro do repositório.

---

## Os documentos são atualizados junto com o código

Documentação que envelhece é pior que documentação nenhuma — todo mundo confia nela e ela mente. Por isso, toda alteração de código passa por esta tabela antes de a tarefa ser dada como pronta:

| O que você mexeu | O que precisa ser atualizado |
|---|---|
| Funcionalidade nova, alterada ou removida | `PRD.md` e `docs/FSD.md` |
| Regra de negócio, validação, cálculo | `PRD.md` e `docs/FSD.md` |
| Tabela, campo, migration, entidade | `docs/FSD.md` |
| Rota, endpoint, tela nova | `docs/FSD.md` |
| Stack, banco, biblioteca, hospedagem | `DECISOES_TECNICAS.md` e `INSUMOS.md` |
| Login, perfil, permissão | `DECISOES_TECNICAS.md` e `docs/FSD.md` |
| Variável de ambiente, integração externa | `INSUMOS.md` e `DECISOES_TECNICAS.md` |
| Cor, fonte, espaçamento, componente | `docs/DESIGN.md` |
| Etapa nova descoberta no caminho | `docs/PLANO.md` |
| Mudou como rodar ou testar | `CLAUDE.md` |
| Qualquer alteração de código | `docs/STATUS.md` — sempre |
| Qualquer erro, mesmo já corrigido | `docs/ERROS.md` — sempre |

Ao terminar, a IA diz em uma linha quais documentos atualizou e, para os que não atualizou, qual conferiu e por que não precisou mexer. Ficar calado sobre um documento conta como esquecimento.

**E tem trava:** se houve alteração de código e o `STATUS.md` não foi atualizado, o encerramento é bloqueado — a tabela acima volta como pendência e o trabalho continua até estar registrado.

## As travas: o que o plugin impede na prática

Isto não depende de a IA lembrar das regras. São hooks que rodam por fora e podem dizer "não".

| Trava | O que ela faz |
|---|---|
| **Código sem documento** | Bloqueia editar/criar arquivo de código enquanto faltar `PRD.md`, `docs/FSD.md`, `docs/PLANO.md`, `docs/STATUS.md` ou `docs/ERROS.md`. Documentos, `docs/`, README e configs passam sempre — são justamente o que precisa vir antes. |
| **`AGENTS.md`** | Bloqueado sempre. O padrão é `CLAUDE.md`. |
| **Leitura cara** | Bloqueia `Read`, `Grep` e `Glob` em arquivos de código enquanto o mapeamento por grafo não for feito na sessão. Cai na primeira consulta ao `tokensave` ou ao `code-review-graph`. |
| **Ferramentas ausentes** | Instala em segundo plano o que faltar, no máximo uma vez por dia. |
| **ponytail e caveman** | Regras reinjetadas em toda mensagem: solução mais simples que funciona, resposta sem enrolação. |
| **Documento desatualizado** | Bloqueia encerrar a sessão se o código mudou e o `docs/STATUS.md` não foi atualizado; devolve a matriz de impacto com os demais documentos a revisar. |

**Limite honesto:** as travas cobrem as ferramentas de edição e leitura. Quem escrever código por comando de terminal (`cat > arquivo`, `sed -i`, geradores) passa por fora. Isso é violação da metodologia, não brecha para usar.

---

## Situações do dia a dia

**Ajuste pequeno** (trocar um texto, corrigir um bug simples): aplica direto, atualiza `STATUS.md` e `ERROS.md`, entrega os checklists. Não mexe no PRD.

**Recurso novo ou mudança grande**: atualiza PRD, FSD, decisões técnicas e design antes; abre um novo plano no `STATUS.md`; vai etapa por etapa.

**Pedido de alteração depois de pronto**: chat novo, a IA lê `MANUTENCAO.md` e `ERROS.md` antes de mexer, explica o plano, executa, testa, registra.

**Deu errado e você quer voltar**: o histórico do Git tem o commit de cada etapa — é por isso que cada etapa termina em commit.

**Todas as etapas concluídas**: revisão de segurança → documentação final → deploy, se você quiser publicar.

---

## Projeto que já existe (cold start)

É a situação mais comum: você já tem um sistema rodando e quer colocá-lo na metodologia. Nesse primeiro momento, a IA **lê o projeto inteiro** para escrever os documentos — porque os documentos vão descrever o sistema todo, e um PRD escrito a partir de meia dúzia de arquivos fica errado.

Ordem do que acontece:

**1. Inventário.** Um script lista tudo que existe: quantos arquivos, quais pastas, quais manifestos, todas as migrations, todas as rotas e telas, os arquivos de autenticação e permissão, os testes, as variáveis de ambiente, as integrações externas e os `TODO` já marcados no código. Essa lista vira a **verificação**: nada é escrito antes de tudo nela estar coberto.

**2. Mapa pelo grafo.** As entidades, os módulos, os fluxos ponta a ponta e o que é central no sistema saem do grafo de código — barato e cobre muita coisa.

**3. Leitura direta do que o grafo não enxerga.** Grafo entende código, mas não lê regra de negócio escrita em texto. São de leitura obrigatória e completa: manifestos da stack, `.env.example`, **todas** as migrations, todas as rotas e telas, middleware e permissões, README e documentos soltos, configuração de deploy.

**4. Módulo por módulo.** Para cada um, seis perguntas: o que faz (em linguagem de negócio), que dados toca, que telas expõe, que regras aplica, de quem depende e quem depende dele, e se tem teste. Módulo muito grande é delegado a um assistente auxiliar, que devolve só as respostas.

**5. Tabela de cobertura — você vê antes dos documentos.** Uma tabela com toda pasta do projeto: como foi coberta, o que faz, que entidades toca e o que ficou em aberto. As pastas descartadas aparecem também, com o motivo ("assets estáticos", "gerado automaticamente"). Se a tabela não bate com o inventário, a leitura não terminou.

**6. Só então os documentos.** PRD, decisões técnicas, FSD, design, insumos e `CLAUDE.md` — com cada afirmação apontando de onde saiu no código. O que não deu para descobrir vira `PENDENTE — confirmar com o usuário`, nunca um chute. `STATUS.md` e `ERROS.md` nascem vazios, porque nada foi feito ainda sob a metodologia.

**7. Aí sim o seu pedido.** Ele é relido, registrado no plano e executado etapa por etapa.

Duas coisas valem ao mesmo tempo aqui, e não se contradizem: **cobrir 100% do projeto é obrigatório** e **gastar token à toa não é permitido**. Cobertura total pelo caminho mais barato — grafo primeiro, leitura direta onde o grafo não alcança, subagente quando o módulo é grande.

É isso que o comando `/estruturar-projeto` faz.

## Economia de tokens em cada passo

Sete ferramentas obrigatórias, instaladas sozinhas. Não é uma por passo — quantas couberem, chamadas em paralelo:

| Passo | Ferramentas |
|---|---|
| Insumos longos do cliente (PDF, transcrição) | `graphify` + `tokenoptim` |
| Mapear o sistema | `tokensave` + `code-review-graph`, juntos |
| Arquitetura e decisões | `code-review-graph` + `tokensave` |
| Planejar a etapa / medir impacto | `tokensave` (impacto, quem chama) + `code-review-graph` (raio de impacto) |
| Escrever o código | `ponytail` sempre + `tokensave` no lugar de abrir arquivos |
| Rodar comandos e testes | `rtk` (automático) + `tokensave` (rodar só os testes afetados) |
| Revisar a etapa | `code-review-graph` (o que mudou, contexto do review) |
| Falar com você | `caveman` — comprime a conversa, **nunca** o documento, o checklist nem a mensagem de commit |

Detalhes de cada uma: [`skills/jornada-vibe-coding/references/ferramentas-token.md`](skills/jornada-vibe-coding/references/ferramentas-token.md).

---

## Perguntas frequentes

**Preciso seguir todos os passos sempre?**
Não. Ajuste pequeno vai direto ao código. Os passos completos valem para sistema novo ou mudança grande.

**A IA pode pular um passo se eu pedir?**
Os passos, sim. As travas, não — falta documento, o hook bloqueia a edição de código, independentemente do que foi pedido.

**Isso deixa tudo mais lento?**
O começo, sim: você escreve documentos antes de ver tela. O que se ganha vem depois, quando o sistema cresce e você ainda sabe o que ele faz, o que foi testado e por que cada decisão foi tomada.

**E se eu não souber responder uma pergunta técnica?**
Diga que não sabe. Os prompts preveem isso: a IA explica as opções em linguagem simples e sugere um padrão.

**Dá para usar em outra hospedagem que não a Hostnet?**
Sim. Só o Passo 7 (deploy) é específico da Hostnet. O resto é independente de hospedagem.
