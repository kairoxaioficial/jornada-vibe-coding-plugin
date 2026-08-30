# Referência — codificacao-final (extração completa do ebook Jornada IA Vibe Coding)

> **REGRA DESTE AMBIENTE (Claude Code):** onde este texto disser `AGENTS.md`, leia e escreva **`CLAUDE.md`**. NUNCA criar `AGENTS.md` (bloqueado pelo hook `jornada-guard.sh`). Se já existir um `AGENTS.md` no projeto, migrar (`git mv AGENTS.md CLAUDE.md`), ajustar as referências e registrar no `STATUS.md`.

# Grupo 10 — Jornada IA Vibe Coding (Hostnet): Passo 6 (Documentação) e Passo 7 (Deploy)

Extração metodológica minuciosa dos capítulos `codificacao-11.txt` (Passo 6 — Documentação) e `codificacao-12.txt` (Passo 7 — Deploy).

---

## 1. Visão geral do grupo

Este grupo cobre o **fechamento do projeto**: a preparação do sistema construído para **manutenção futura** (Passo 6) e a sua **publicação em produção na Hostnet** (Passo 7).

- **Passo 6 — Documentação** (`codificacao-11.txt`): cria a documentação final de manutenção e coloca o arquivo de contexto da IA (AGENTS.md / CLAUDE.md) em **"modo manutenção"**. O sistema já foi construído em fases, testado e passou pela revisão de segurança (Passo 5). Esta etapa NÃO cria novas funcionalidades e NÃO faz deploy. Ela responde à pergunta central: "Como alguém vai alterar este sistema depois?" (essa pessoa pode ser você, outro membro da equipe ou outra IA em um novo chat).
- **Passo 7 — Deploy** (`codificacao-12.txt`): publica o sistema no servidor real da Hostnet usando o fluxo `GitHub -> GitHub Actions -> SSH/rsync -> Hostnet`. Enfatiza que **deploy não é copiar tudo para o servidor**: é publicar apenas o que o sistema precisa para funcionar. O deploy é **manual** (disparado pelo usuário), não automático por push. Primeiro deploy usa `rsync` SEM `--delete` (medida de segurança).

Posição no fluxo geral (segundo os capítulos): o Passo 6 é usado **depois da revisão de segurança** (Passo 5); o Passo 7 é usado quando o sistema **está pronto para publicação** e já validado localmente. O Passo 6 termina indicando o Passo 7 como próximo passo; o Passo 7 assume que a revisão de segurança e a documentação final já foram feitas (aparecem no "checklist do usuário" antes do deploy).

**Atenção específica do ebook sobre modelos:** os prompts dos passos são "generalistas, sem stack fixa" e usam `AGENTS.md` como padrão para Codex e Antigravity. **Quem usa Claude Code deve substituir `AGENTS.md` por `CLAUDE.md`** antes de enviar — e essa substituição pode ser necessária mais de uma vez dentro do mesmo prompt. Ambos os passos devem ser executados **em um chat novo com raciocínio**.

---

## 2. Capítulo: `codificacao-11.txt` — Passo 6: Documentação

### 2.1. Objetivo do capítulo

Preparar o projeto para o futuro, criando documentação de manutenção que reduza o esforço de alterações futuras. Sem documentação, cada mudança vira uma investigação (a IA precisa reler arquivos, entender estrutura, descobrir onde cada coisa está, identificar padrões e evitar quebrar o que funciona). A documentação final funciona como **um manual do sistema pronto**.

### 2.2. Motivação e problema resolvido

- Sistemas continuam mudando depois de prontos: adicionar um campo; corrigir uma regra; mudar um texto; criar um relatório; alterar uma permissão; ajustar uma tela; trocar uma integração; corrigir um erro encontrado por um usuário.
- Sem documentação, a próxima alteração começa com perguntas como: Onde fica a tela de cadastro? Como o banco foi criado? Como rodo o projeto localmente? Qual arquivo controla as permissões? Como adiciono um campo novo? Como testo antes de publicar? Quais arquivos não devo mexer? Quais cuidados de segurança preciso manter?
- O prompt do passo resolve isso criando **documentos para manutenção**.

### 2.3. Conceito: Documentação de manutenção

Documentação de manutenção é um **conjunto de instruções que explica como o sistema foi organizado e como ele deve ser alterado no futuro**. Não é feita para o usuário final — é feita para quem vai **cuidar do sistema por dentro**. Analogia do carro: o motorista precisa saber dirigir, mas o mecânico precisa saber onde ficam as peças, qual óleo usar, quais cuidados tomar, como desmontar sem quebrar.

### 2.4. Quando usar

- Usar **depois da revisão de segurança** (Passo 5).
- NÃO serve para criar novas funcionalidades. Serve para documentar o que já foi construído e preparar o projeto para mudanças futuras.

### 2.5. O que será criado nesta etapa

A IA deve criar ou atualizar estes documentos (bloco "Copiar" do ebook):

```
docs/MANUTENCAO.md
docs/COMO-PEDIR-MUDANCAS.md
AGENTS.md
docs/STATUS.md
```

### 2.6. Descrição dos arquivos principais

**`docs/MANUTENCAO.md`** — principal documento técnico para mudanças futuras. Deve explicar:
- o que o sistema faz;
- qual stack foi usada;
- como rodar localmente;
- como o projeto está organizado;
- como o banco de dados funciona;
- como adicionar telas, campos ou regras;
- como testar alterações;
- quais cuidados de segurança manter.

Deve ser **objetivo**: não precisa explicar cada linha de código, mas precisa orientar bem o suficiente para que uma pessoa ou uma IA consiga mexer no projeto sem começar do zero.

**`docs/COMO-PEDIR-MUDANCAS.md`** — voltado para o **usuário leigo**. Deve mostrar exemplos prontos de pedidos para fazer alterações futuras com IA. Exemplo de pedido-modelo dado pelo ebook (bloco "Copiar"):

```
Leia `docs/MANUTENCAO.md`, `docs/FSD.md` e `docs/STATUS.md`.

Quero adicionar o campo "telefone" ao cadastro de clientes.

Faça a alteração com cuidado:
- atualize o banco ou migration, se necessário;
- atualize o formulário;
- atualize a listagem;
- valide o campo;
- teste localmente;
- atualize `docs/STATUS.md`;
- registre erros em `docs/ERROS.md`, se houver.

No final, me diga como testar.
```

Contraste mostrado pelo ebook: em vez de dizer apenas "Coloque telefone no cadastro.", o usuário aprende a fazer um pedido melhor que orienta a IA a mexer nas partes certas.

**`AGENTS.md` (arquivo de contexto)** — atualizado para **modo manutenção**. Durante a construção orientou a IA a criar o sistema; agora é ajustado para manutenção. Não significa apagar as regras anteriores; significa **reforçar o novo modo de trabalho**. A partir daqui o sistema não está mais começando do zero, então o arquivo de contexto deve orientar a IA a:
- ler a documentação antes de alterar;
- não refazer o sistema;
- não mudar arquitetura sem necessidade;
- preservar funcionalidades existentes;
- testar antes de concluir;
- atualizar STATUS.md;
- registrar erros em ERROS.md;
- manter cuidados de segurança.

Motivo: uma IA em um chat futuro pode tentar "melhorar" demais o projeto e reescrever partes que não precisava. **O modo manutenção evita esse comportamento.**

### 2.7. Vocabulário técnico (tabela do capítulo)

| Termo | Explicação simples |
|---|---|
| Manutenção | Alterações feitas em um sistema depois que ele já foi construído. |
| Evolução | Melhorias ou novas funcionalidades adicionadas ao sistema com o tempo. |
| Documentação técnica | Explicação organizada sobre como o sistema funciona por dentro. |
| Modo manutenção | Forma de orientar a IA quando o sistema já está pronto e precisa apenas ser alterado. |
| Mapa de pastas | Explicação sobre o que fica em cada pasta do projeto. |
| Migration | Arquivo ou mecanismo usado para criar ou alterar a estrutura do banco de dados. |
| Arquivo de contexto | Arquivo que orienta a IA sobre como trabalhar naquele projeto. |
| Regressão | Quando uma alteração nova quebra algo que já funcionava antes. |

### 2.8. PROMPT DO PASSO 6 (bloco "Copiar" — transcrição VERBATIM)

**Título no ebook: "Prompt do passo 6"** — precedido pelas notas: "Abaixo está uma versão generalista do prompt, sem stack fixa. Ela usa AGENTS.md como padrão para Codex e Antigravity. IMPORTANTE: Quem usa Claude Code deve substituir AGENTS.md por CLAUDE.md antes de enviar. O AGENTS.md pode aparecer mais de uma vez no prompt. ATENÇÃO: Execute este prompt em um chat novo com raciocínio."

Texto integral do prompt:

---

Responda sempre em **português do Brasil**.

Você é responsável por deixar o projeto **fácil de manter, corrigir e evoluir** no futuro.

Sua missão é criar a documentação final de manutenção do sistema e atualizar o arquivo de contexto para que uma IA em chats futuros consiga trabalhar com segurança.

Não crie novas funcionalidades nesta etapa.

Não faça deploy nesta etapa.

## 1. Reconstruir o contexto

Leia integralmente, nesta ordem:

- `AGENTS.md`
- `docs/FSD.md`
- `docs/DESIGN.md`
- `docs/INSUMOS.md`
- `docs/PLANO.md`
- `docs/STATUS.md`
- `docs/ERROS.md`

Depois, revise a estrutura atual do projeto e os arquivos principais do código.

Identifique:

- stack do projeto;
- arquitetura;
- ambiente de desenvolvimento;
- ambiente de produção;
- estrutura de pastas;
- comandos para instalar, rodar, testar, migrar banco, validar ou fazer build;
- banco de dados ou mecanismo de persistência, se houver;
- estratégia de autenticação, se houver;
- estratégia de autorização, se houver;
- principais módulos construídos;
- arquivos de configuração;
- dependências principais;
- pontos de segurança que precisam ser preservados;
- erros importantes registrados em `docs/ERROS.md`.

Não presuma PHP, MySQL, XAMPP, Hostnet, Laravel, Node.js, Python, Supabase, Firebase, Next.js ou qualquer outra tecnologia se isso não estiver definido no FSD, no arquivo de contexto ou no código do projeto.

## 2. Conferir se o projeto está pronto para documentação final

Antes de documentar, confira `docs/STATUS.md`.

Se ainda houver fases funcionais pendentes, avise o usuário que a documentação final idealmente deve ser feita depois da conclusão das fases.

Se a revisão de segurança ainda não foi executada, avise que esta documentação pode ficar incompleta e recomende executar primeiro o prompt do passo 5.

Se o usuário decidir continuar mesmo assim, registre no `docs/STATUS.md` que a documentação foi criada com pendências.

## 3. Criar `docs/MANUTENCAO.md`

Crie o arquivo `docs/MANUTENCAO.md`.

Ele deve ser claro, objetivo e útil para uma pessoa ou IA que precise alterar o sistema no futuro.

Inclua, no mínimo, estas seções:

### Visão geral

Explique:

- o que o sistema faz;
- para quem ele foi criado;
- quais problemas resolve;
- quais módulos principais existem.

### Stack e ambientes

Explique:

- linguagem;
- framework, se houver;
- banco de dados ou persistência;
- bibliotecas importantes;
- ambiente local;
- ambiente de produção;
- comandos principais.

### Como rodar localmente

Explique o passo a passo para iniciar o sistema no ambiente de desenvolvimento definido no FSD.

Inclua comandos quando existirem.

Não invente comandos. Use apenas os comandos reais da stack ou os definidos no projeto.

### Mapa de pastas

Explique as principais pastas e arquivos do projeto.

Para cada pasta importante, diga:

- o que ela guarda;
- quando mexer nela;
- cuidados importantes.

### Banco de dados e persistência

Se o projeto usar banco de dados ou outro mecanismo de persistência, explique:

- onde ficam migrations, schemas, models ou arquivos equivalentes;
- como criar ou aplicar alterações;
- como rodar migrations ou comandos equivalentes;
- onde ficam dados iniciais, seeders ou scripts;
- cuidados antes de alterar estrutura de dados.

Se o projeto não usar banco de dados, informe isso claramente.

### Autenticação, autorização e usuários

Se o sistema tiver login, perfis ou permissões, explique:

- como o login funciona de forma geral;
- quais perfis existem;
- onde as permissões são verificadas;
- cuidados ao criar novas telas ou rotas protegidas.

### Como adicionar uma nova tela

Explique, em passos curtos, como uma pessoa ou IA deve adicionar uma nova tela respeitando a arquitetura do projeto.

Inclua quais arquivos ou pastas normalmente precisam ser alterados.

### Como adicionar um novo campo

Explique, em passos curtos, como adicionar um campo a um cadastro existente.

Quando aplicável, mencione:

- alteração de banco ou schema;
- atualização de model ou equivalente;
- atualização de formulário;
- atualização de validação;
- atualização de listagem;
- atualização de testes;
- atualização da documentação.

### Como adicionar uma nova regra de negócio

Explique como alterar uma regra sem quebrar o sistema.

Oriente a IA a sempre conferir o FSD, localizar onde a regra é aplicada, alterar com cuidado e testar cenários principais e de erro.

### Como testar alterações

Explique:

- quais comandos de teste existem;
- como fazer testes manuais;
- quais fluxos principais devem ser testados;
- como verificar erros ou logs;
- quando atualizar `docs/ERROS.md`.

### Cuidados de segurança

Liste os cuidados de segurança que devem ser mantidos em qualquer alteração, conforme a stack do projeto.

Considere, quando aplicável:

- autenticação;
- autorização;
- controle de sessão;
- validação de entradas;
- proteção contra injeção;
- proteção contra XSS;
- proteção contra CSRF;
- isolamento de dados;
- proteção de arquivos sensíveis;
- logs;
- uploads;
- APIs externas;
- segredos e variáveis de ambiente.

### Como registrar progresso

Explique que toda alteração futura deve atualizar:

- `docs/STATUS.md`;
- `docs/ERROS.md`, se houver erro.

### O que não fazer

Inclua alertas como:

- não reescrever o sistema sem necessidade;
- não alterar stack sem decisão explícita;
- não remover segurança para "resolver rápido";
- não versionar segredos;
- não ignorar testes;
- não mexer em várias áreas sem explicar o impacto.

## 4. Criar `docs/COMO-PEDIR-MUDANCAS.md`

Crie o arquivo `docs/COMO-PEDIR-MUDANCAS.md`.

Esse arquivo deve ajudar uma pessoa leiga a pedir alterações futuras para uma IA.

Inclua:

- explicação simples sobre como pedir mudanças;
- orientação para sempre pedir que a IA leia `docs/MANUTENCAO.md`, `docs/FSD.md`, `docs/DESIGN.md`, `docs/STATUS.md` e `docs/ERROS.md`;
- modelos de prompts prontos;
- checklist antes de aceitar uma alteração.

Inclua exemplos de prompts para:

1. Adicionar um campo em um cadastro.
2. Criar uma nova tela.
3. Corrigir um erro.
4. Alterar uma regra de negócio.
5. Ajustar visual conforme o `docs/DESIGN.md`.
6. Criar um relatório ou filtro, se fizer sentido para o projeto.
7. Revisar segurança depois de uma mudança.
8. Preparar uma alteração para commit.

Use exemplos adaptados à stack e ao tipo de sistema construído.

Não use exemplos genéricos demais se o projeto permitir exemplos mais concretos.

## 5. Atualizar o arquivo de contexto para modo manutenção

Atualize `AGENTS.md` para o **modo manutenção**.

O arquivo de contexto deve orientar a IA em futuras mudanças.

Inclua:

- idioma: responder sempre em português do Brasil;
- stack e arquitetura do projeto;
- resumo da estrutura;
- documentos obrigatórios para ler antes de alterar;
- protocolo para mudanças futuras;
- regras de segurança;
- cuidados para não quebrar funcionalidades existentes;
- orientação para testar antes de concluir;
- orientação para atualizar `docs/STATUS.md`;
- orientação para registrar erros em `docs/ERROS.md`;
- orientação para fazer commit depois de alterações relevantes.

Inclua este protocolo:

Antes de qualquer alteração:
1. Ler docs/MANUTENCAO.md.
2. Ler docs/FSD.md.
3. Ler docs/DESIGN.md, se a alteração envolver interface.
4. Ler docs/STATUS.md.
5. Ler docs/ERROS.md.
6. Entender o pedido do usuário.
7. Explicar o plano antes de alterar arquivos.

Depois de qualquer alteração:
1. Testar o que foi alterado.
2. Atualizar docs/STATUS.md.
3. Registrar erro e solução em docs/ERROS.md, se houver.
4. Fazer commit ou entregar os comandos.
5. Explicar ao usuário como validar.

## 6. Atualizar `docs/STATUS.md`

Atualize `docs/STATUS.md` registrando:

- documentação final criada;
- `docs/MANUTENCAO.md` criado;
- `docs/COMO-PEDIR-MUDANCAS.md` criado;
- arquivo de contexto atualizado para modo manutenção;
- pendências, se houver;
- próximo passo recomendado.

## 7. Registrar erros, se houver

Se algum problema aparecer durante esta etapa, registre em `docs/ERROS.md`:

## <data> - <título curto do erro>

- Sintoma:
- Causa:
- Solução aplicada:
- Como evitar no futuro:

## 8. Versionar a documentação

Depois de criar e atualizar os documentos, verifique o Git:

`git status`

Confirme que nenhum segredo será versionado.

Depois faça commit com uma mensagem clara, por exemplo:

`git add .`
`git commit -m "Documentação final de manutenção"`

Se não puder executar o commit, entregue os comandos para o usuário copiar.

Lembre o usuário de fazer:

`git push`

## 9. Entregar ao usuário

Ao final, entregue:

1. Resumo do que foi criado.
2. Principais pontos do `docs/MANUTENCAO.md`.
3. Principais exemplos criados em `docs/COMO-PEDIR-MUDANCAS.md`.
4. Confirmação de atualização do `AGENTS.md` ou `CLAUDE.md`.
5. Confirmação de atualização do `docs/STATUS.md`.
6. Confirmação de atualização do `docs/ERROS.md`, se houve erro.
7. Confirmação de commit ou comandos para o usuário executar.
8. Próximo passo.

Use esta frase final:

Documentação pronta. Próximo passo: chat novo + prompt do passo 7, se você quiser publicar o sistema na Hostnet.

Lembre-se: esta etapa documenta o sistema para manutenção futura. Não crie novas funcionalidades e não faça deploy agora.

---

### 2.9. Prompts auxiliares do Passo 6 (transcrição VERBATIM)

**Título: "Prompt para pedir documentação mais simples"** — "Se a IA criar uma documentação técnica demais, use:"

---

Reescreva a documentação com linguagem mais simples.

O público é uma pessoa que pode não saber programar profundamente, mas vai usar uma IA para pedir alterações futuras.

Mantenha os termos técnicos necessários, mas explique cada um de forma breve.
Não remova informações importantes.

---

**Título: "Prompt para completar documentação incompleta"** — "Se a IA esquecer alguma seção importante, use:"

---

Revise `docs/MANUTENCAO.md`.

Confira se ele explica:
- visão geral do sistema;
- stack e ambientes;
- como rodar localmente;
- mapa de pastas;
- banco de dados ou persistência;
- autenticação e permissões, se houver;
- como adicionar tela;
- como adicionar campo;
- como alterar regra;
- como testar;
- cuidados de segurança;
- como atualizar STATUS.md e ERROS.md.

Complete o que estiver faltando.

---

**Título: "Prompt para revisar exemplos de mudanças futuras"** — "Se o arquivo COMO-PEDIR-MUDANCAS.md ficar genérico demais, use:"

---

Revise `docs/COMO-PEDIR-MUDANCAS.md`.

Os exemplos estão genéricos demais.

Adapte os exemplos ao sistema real descrito em `docs/FSD.md`.

Crie exemplos de pedidos para mudanças que façam sentido neste projeto.

---

### 2.10. Regras, avisos e boas práticas do Passo 6

- Etapa não cria novas funcionalidades e não faz deploy.
- Usar depois da revisão de segurança (Passo 5); se a revisão não foi feita, avisar e recomendar executar o prompt do passo 5 antes.
- Se houver fases funcionais pendentes, avisar que a documentação final idealmente deve vir depois da conclusão das fases.
- Se o usuário continuar mesmo assim, registrar em `docs/STATUS.md` que a documentação foi criada com pendências.
- MANUTENCAO.md deve ser objetivo e NÃO inventar comandos (usar apenas comandos reais da stack ou definidos no projeto).
- Modo manutenção evita que uma IA futura "melhore" demais e reescreva partes que não precisava.
- Sempre confirmar com `git status` que nenhum segredo será versionado antes do commit.
- Quem usa Claude Code substitui AGENTS.md por CLAUDE.md no prompt (pode aparecer mais de uma vez).

### 2.11. Erros comuns e como resolver (Passo 6)

- **Documentação técnica demais** → usar o prompt "Prompt para pedir documentação mais simples".
- **Seção importante faltando no MANUTENCAO.md** → usar o prompt "Prompt para completar documentação incompleta" (a lista de 12 seções funciona como checklist).
- **COMO-PEDIR-MUDANCAS.md genérico demais** → usar o prompt "Prompt para revisar exemplos de mudanças futuras" para adaptar os exemplos ao sistema real do FSD.

---

## 3. Capítulo: `codificacao-12.txt` — Passo 7: Deploy

### 3.1. Objetivo do capítulo

Publicar o sistema em produção na Hostnet. "Chegamos à etapa de publicação. Agora vamos tratar do momento em que o sistema sai do ambiente local e vai para um servidor real." O deploy é feito **na Hostnet, usando GitHub Actions, SSH e rsync**.

Ideia central: **Deploy não é copiar tudo para o servidor. Deploy é publicar apenas o que o sistema precisa para funcionar.** A pasta do projeto contém arquivos que ajudam no desenvolvimento mas não devem ficar públicos no servidor (documentação interna, instruções para IA, histórico do projeto, logs, detalhes técnicos). Em produção, o servidor deve receber apenas o necessário para rodar o sistema — isso reduz riscos e deixa a publicação mais limpa.

### 3.2. Conceito de deploy (analogia do restaurante)

- Deploy é o processo de publicar um sistema em um ambiente onde ele poderá ser usado.
- Ambiente local = cozinha de testes; produção = restaurante aberto. Você não leva para o salão todas as anotações internas, rascunhos e caixas de material — leva apenas o que precisa para atender bem.

### 3.3. Vocabulário técnico (tabela do capítulo)

| Termo | Explicação simples |
|---|---|
| Deploy | Processo de publicar o sistema em um servidor para uso real. |
| Produção | Ambiente onde o sistema fica disponível para usuários reais. |
| Ambiente local | Ambiente usado no computador para desenvolver e testar. |
| Servidor | Computador remoto que hospeda o sistema. |
| SSH | Forma segura de acessar o servidor por comandos. |
| rsync | Ferramenta usada para enviar arquivos de uma máquina para outra. |
| GitHub Actions | Recurso do GitHub que executa tarefas automaticamente ou manualmente. |
| Workflow | Arquivo que define uma automação dentro do GitHub Actions. |
| Secret | Informação sensível guardada no GitHub de forma protegida, como chave SSH ou usuário do servidor. |
| Backup | Cópia de segurança feita antes de substituir arquivos em produção. |

### 3.4. Quando usar

- O prompt de deploy deve ser usado **apenas quando o sistema estiver pronto para publicação**.
- Deploy NÃO deve ser usado para "ver se funciona". O ideal é publicar depois que o sistema já foi validado localmente.

### 3.5. Atenção: capítulo específico para Hostnet

- Os capítulos anteriores deixaram os prompts generalistas (stack/arquitetura vêm do `docs/FSD.md`). Este capítulo é **diferente**: trata de uma estratégia específica de publicação:

```
GitHub -> GitHub Actions -> SSH/rsync -> Hostnet
```

- Se o projeto usa outra hospedagem (Vercel, Render, Railway, VPS própria, Cloudflare Pages, Netlify, Supabase Hosting ou outro provedor), **este prompt precisará ser adaptado** — pode-se pedir para uma IA ajudar a adaptar.
- Mesmo assim, os conceitos continuam úteis para qualquer hospedagem: publicar apenas arquivos necessários; proteger segredos; fazer backup; usar variáveis seguras; validar o sistema depois do deploy.

### 3.6. O que vai para produção e o que não vai

**Arquivos que normalmente vão para produção** (dependendo da stack definida no FSD):
- código-fonte necessário para rodar o sistema;
- pastas da aplicação;
- assets públicos, como CSS, JS, imagens e logos;
- arquivos de entrada da aplicação;
- arquivos de configuração de exemplo, se forem necessários sem segredos;
- dependências necessárias em produção, se a estratégia do projeto exigir;
- scripts de banco ou migrations, se forem usados para preparar produção;
- `.htaccess` ou configuração equivalente, se a stack usar.

Observação: se o sistema exibir imagens ou logos, elas precisam estar na **pasta pública ou de assets definida pela stack** — não apenas em `docs/`.

**Arquivos que NÃO devem ir para produção** (bloco "Copiar"):

```
.git/
.github/
docs/
prompts/
AGENTS.md
CLAUDE.md
README.md
arquivos de exemplo desnecessários em produção
configurações reais locais
.env local
logs/
backups
dumps de banco
arquivos temporários
arquivos de editor
```

"A ideia é simples: a produção deve receber o sistema, não o material de construção do sistema."

### 3.7. A diferença entre GitHub e produção

- **GitHub guarda o projeto completo de desenvolvimento**, incluindo documentos de manutenção:

```
docs/
AGENTS.md ou CLAUDE.md
PLANO.md
STATUS.md
ERROS.md
MANUTENCAO.md
COMO-PEDIR-MUDANCAS.md
```

- Esses arquivos são úteis no repositório, mas isso **não significa que devem ir para a Hostnet**.
- **GitHub é o backup e histórico do projeto. Hostnet é o ambiente onde o sistema vai rodar.**

### 3.8. O papel do `deploy-exclude.txt`

Arquivo que **lista o que o rsync deve ignorar durante o envio**. Exemplo dado pelo ebook:

```
.git/
.github/
docs/
prompts/
AGENTS.md
CLAUDE.md
README.md
logs/
.env
.env.*
```

Assim, o deploy envia o sistema sem publicar arquivos internos.

### 3.9. O papel do GitHub Actions

- GitHub Actions é um recurso do GitHub que executa tarefas. Neste caso, é usado para publicar o sistema na Hostnet.
- Ideia: o projeto está no GitHub → você abre a aba Actions → executa manualmente o workflow de deploy → o GitHub conecta na Hostnet por SSH → o GitHub envia os arquivos corretos com rsync.
- Isso evita o envio manual por FTP e cria um processo mais organizado e repetível.

### 3.10. O papel dos Secrets

Secrets são informações sensíveis guardadas no GitHub, usadas pelo workflow sem ficarem expostas no código. Neste deploy, os secrets importantes são:

```
HOSTNET_HOST
HOSTNET_USER
HOSTNET_PORT
HOSTNET_PATH
HOSTNET_SSH_KEY
```

Esses valores permitem que o GitHub se conecte à Hostnet. **Eles não devem aparecer no código do projeto.**

### 3.11. O papel da chave SSH

- SSH é uma forma segura de acessar um servidor. Para o GitHub Actions enviar arquivos para a Hostnet, ele precisa de uma chave SSH, que tem duas partes:

```
chave pública;
chave privada.
```

- **A chave pública vai para a Hostnet. A chave privada vai para o Secret do GitHub.**
- Analogia: fechadura e chave. A parte pública prepara a fechadura no servidor; a parte privada permite abrir a conexão. **A chave privada precisa ser protegida.**

### 3.12. O primeiro deploy deve ser mais cuidadoso

- No primeiro deploy, o prompt orienta usar `rsync` **sem `--delete`** — medida de segurança.
- `--delete` faz o servidor apagar arquivos que não existem mais no projeto local. É útil depois, mas no primeiro deploy é arriscado: se o caminho estiver errado, pode remover arquivos que não deveria.
- No primeiro envio, a prioridade é validar:
  - o caminho do servidor está correto;
  - os arquivos chegaram ao lugar certo;
  - o sistema abriu;
  - a configuração de produção funciona;
  - o banco conecta;
  - arquivos internos não ficaram públicos.
- Depois de tudo validado, pode-se avaliar ajustes no deploy.

### 3.13. Preparando o ambiente de produção (Hostnet)

Antes de publicar, preparar recursos no painel da Hostnet, principalmente:
- banco de dados;
- usuário do banco;
- senha do banco;
- endereço de conexão;
- conta de e-mail para envio automático, se o sistema usar e-mail.

**Atenção:** NÃO colocar senhas, usuários de banco ou dados de e-mail dentro do GitHub. Essas informações devem ser configuradas diretamente no ambiente de produção ou em secrets seguros, conforme a estratégia de deploy do projeto.

#### 3.13.1. Banco de dados de produção (MySQL)

Se o sistema usa MySQL, criar o banco de produção no painel da Hostnet **antes do deploy**. Passos:
1. Acesse o painel de controle da Hostnet: `https://painel.hostnet.com.br/`
2. Na barra lateral, acesse: `Banco de dados / Banco de dados MySQL`
3. Clique no botão: `Novo banco`
4. O sistema escolherá automaticamente o nome do banco de dados e o usuário.
5. Anote com cuidado: nome do banco; usuário do banco.
6. Preencha os campos: `Senha`; `Confirmar senha`; `Descrição`.
7. Anote a senha em um local seguro.
8. Clique no botão: `Enviar`.

#### 3.13.2. Endereço de conexão do banco de dados

- O sistema também precisa saber o endereço do servidor MySQL (onde o banco está hospedado).
- Passos: painel `https://painel.hostnet.com.br/` → `Banco de dados / Banco de dados MySQL` → selecione o banco desejado → clique em `Endereços de conexão` → **anote o SEGUNDO endereço exibido**.
- Geralmente parecido com:

```
mysql.seudominio.com
```

- Usar exatamente o endereço informado no painel da conta.

#### 3.13.3. Dados que você deve guardar (banco)

Guarde: nome do banco de dados; usuário do banco; senha do banco; endereço de conexão do banco. **Não salve esses dados dentro dos arquivos versionados do projeto.**

#### 3.13.4. E-mail de envio do sistema

- Alguns sistemas precisam enviar e-mails automáticos: recuperação de senha; confirmação de cadastro; aviso de nova solicitação; notificação de alteração; mensagens enviadas por formulário.
- **Recomendação: não usar o e-mail comum de atendimento da empresa.** Criar um e-mail separado apenas para o sistema:

```
sistema@seudominio.com
formulario@seudominio.com
naoresponda@seudominio.com
```

- Motivo: se alguém trocar a senha do e-mail de atendimento, o sistema pode parar de enviar mensagens. Com conta exclusiva para envio automático, o risco diminui.

#### 3.13.5. Criando a conta de e-mail de envio (painel Hostnet)

1. Acesse o painel: `https://painel.hostnet.com.br/`
2. Na barra lateral, acesse: `Email / Contas de email`
3. Ative o `Ultramail`, caso ainda não esteja ativo.
4. Clique no botão: `Nova conta`
5. Se houver mais de um domínio na conta, selecione o domínio correto ao lado do campo `Conta`.
6. No campo `Conta`, informe o nome do e-mail desejado. Exemplo: `sistema`
7. No campo `Tamanho`, informe o espaço da conta de e-mail. Para conta usada apenas como enviadora do sistema, pode manter: `1024`
8. Preencha os campos: `Senha`; `Confirmar senha`; `Descrição`.
9. Anote a senha em um local seguro.
10. Clique no botão: `Enviar`.

#### 3.13.6. Dados de envio do e-mail

Normalmente parecidos com:

```
Envio SMTP: smtp.seudominio.com
Porta: 465
Segurança de conexão: SSL/TLS
Nome de usuário: sistema=seudominio.com
Senha: senha criada para esta conta
```

- Usar exatamente o formato informado pelo painel da Hostnet ou pela documentação da conta de e-mail.
- Guardar em local seguro; serão necessários na configuração do deploy ou do ambiente de produção.
- **Atenção:** não salvar a senha do e-mail dentro do GitHub; não colocar em arquivos de documentação do projeto; não enviar em prints ou mensagens públicas. Ao pedir ajuda à IA, informar apenas o necessário e evitar expor a senha real sempre que possível.

#### 3.13.7. Cuidado com senhas e credenciais

As senhas do banco de dados e do e-mail de envio são sensíveis. **Não colocar em:**

```
docs/;
AGENTS.md;
CLAUDE.md;
README.md;
arquivos enviados ao GitHub;
prints compartilhados com terceiros;
prompts públicos;
mensagens em grupos.
```

Essas credenciais devem ser usadas apenas na configuração segura do ambiente. Ao informar para a IA codificadora, fazer com cuidado e apenas no contexto necessário.

### 3.14. Executando PHP na Hostnet por linha de comando

- Durante o deploy pode ser necessário executar comandos PHP no servidor via SSH — por exemplo, quando o sistema precisa rodar migrations.
- **Migration** (definição do capítulo): "arquivo ou comando usado para aplicar mudanças no banco, como criar tabelas, adicionar campos ou preparar dados iniciais."
- Em servidores com várias versões de PHP, é importante chamar a **versão correta** para evitar problemas com extensões, configurações ou recursos que mudam entre versões.

**Formato do comando (bloco "Copiar"):**

```
php-8.1 nome_do_arquivo.php
```

**Exemplo:**

```
php-8.1 migrations.php
```

**Atenção:** trocar `php-8.1` pela versão usada no projeto. Exemplos possíveis:

```
php-7.4 nome_do_arquivo.php
php-8.0 nome_do_arquivo.php
php-8.1 nome_do_arquivo.php
php-8.2 nome_do_arquivo.php
php-8.4 nome_do_arquivo.php
```

- Usar o comando com cuidado, principalmente se alterar o banco de dados. **Antes de rodar qualquer migration em produção, confirmar que existe backup e que o comando foi testado no ambiente local.**

**Identificando a versão do PHP do projeto (painel Hostnet):**
1. Acesse `https://painel.hostnet.com.br/`
2. Na barra lateral, acesse: `Servidor Cloud / Configurações dos sites`
3. Selecione o domínio desejado.
4. Clique no botão: `Editar`
5. Marque `Sim` na opção `Configurações avançadas`.
6. Procure pela opção: `Versão do PHP`
7. Se a versão configurada for 8.4, o comando no SSH deve usar `php-8.4 nome_do_arquivo.php`.

**Exemplo prático:** projeto com arquivo `database/migrate.php` e site configurado com PHP 8.4 → comando:

```
php-8.4 database/migrate.php
```

Se o sistema usar outro comando de migration, seguir exatamente a orientação documentada no projeto.

#### 3.14.1. Prompt de apoio para a IA (antes de comandos PHP em produção) — VERBATIM

"Antes de executar comandos PHP em produção, você pode pedir para a IA conferir o que deve ser feito."

---

Leia a documentação do projeto e me ajude a preparar a execução de comandos PHP no servidor Hostnet.

Verifique:

1. qual versão de PHP o projeto usa;
2. qual comando precisa ser executado;
3. se o comando altera o banco de dados;
4. se existe backup antes da execução;
5. se o comando já foi testado localmente;
6. em qual pasta do servidor o comando deve ser rodado;
7. quais riscos existem;
8. como validar se funcionou.

Não execute comandos destrutivos sem minha confirmação explícita.

---

#### 3.14.2. Cuidados importantes antes de rodar comandos PHP no servidor (checklist do capítulo)

```
[ ] Estou conectado ao servidor correto.
[ ] Estou na pasta correta do projeto.
[ ] Sei qual versão de PHP o projeto usa.
[ ] O comando foi testado localmente.
[ ] Existe backup, se o comando alterar o banco.
[ ] Entendi o que o comando faz.
[ ] A IA explicou os riscos antes da execução.
```

Regra: "Comando em produção deve ser executado com atenção. Um comando errado pode alterar dados reais, quebrar tabelas ou deixar o sistema indisponível."

### 3.15. Como saber a versão do PHP no XAMPP

- O ideal é que o ambiente de produção use a **mesma versão do PHP** testada no ambiente local. Se testou no XAMPP com PHP 8.2, configurar o site na Hostnet também com PHP 8.2, quando disponível.
- Problemas possíveis com versões diferentes: funções disponíveis em uma versão e ausentes em outra; extensões carregadas em um ambiente e ausentes no outro; comportamentos diferentes em bibliotecas; avisos ou erros que aparecem apenas em produção; incompatibilidade com dependências do projeto.

**Verificando a versão pelo painel do XAMPP:**
1. Abra o painel do XAMPP.
2. Clique em `Start` ao lado de `Apache`.
3. Abra o navegador.
4. Acesse: `http://localhost/dashboard/`
5. No menu superior direito, clique em `PHPInfo` ou acesse diretamente: `http://localhost/dashboard/phpinfo.php`
6. A versão do PHP aparecerá em destaque no topo da página, algo parecido com:

```
PHP Version 8.2.x
```

**Exemplo prático:** se o PHPInfo mostrar `PHP Version 8.4.1`, na Hostnet procure configurar o site com PHP 8.4 e, se precisar executar arquivo PHP por linha de comando no servidor, o comando provavelmente usará `php-8.4 nome_do_arquivo.php`.

**Observação importante:** a versão local e a de produção devem ser compatíveis. Quando não for possível usar exatamente a mesma, escolher a versão mais próxima e pedir para a IA revisar possíveis incompatibilidades antes do deploy.

**Prompt de compatibilidade de versão PHP (bloco "Copiar" — VERBATIM):**

---

No XAMPP, meu projeto foi testado com PHP [informe a versão].

Na Hostnet, a versão disponível/configurada é PHP [informe a versão].

Analise se pode haver risco de incompatibilidade para este projeto.

Considere:
- recursos da linguagem PHP;
- dependências do projeto;
- extensões necessárias;
- comandos de migration;
- conexão com banco de dados;
- possíveis erros em produção.

Explique em linguagem simples e me diga o que devo verificar antes do deploy.

---

### 3.16. Criando a pasta do sistema na Hostnet

Antes de configurar o deploy automático, garantir que a pasta de destino exista no servidor. Pode ser criada acessando o servidor por SSH (no Windows, usar o PowerShell).

**Acessando o servidor por SSH (bloco "Copiar"):**

```
ssh usuario@endereco_ftp
```

Trocar `usuario` e `endereco_ftp` pelos dados da conta na Hostnet. Geralmente o endereço SSH é o mesmo usado para FTP. Exemplo:

```
ssh cevclinica@ftp.cevclinica.x-br.com
```

**Primeiro acesso ao servidor:** pode aparecer mensagem parecida com:

```
The authenticity of host 'ftp.cevclinica.x-br.com (187.73.33.21)' can't be established.
ED25519 key fingerprint is SHA256:LyKTaLdSYARSgwXYZOrhthadJLuN7YIXpaeYc0yLV2Q.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Essa mensagem aparece porque o computador ainda não conhece o servidor. Se conferiu que o endereço está correto, responda `yes`. Depois, o servidor pode pedir a senha do usuário — digite e pressione Enter. **Atenção: ao digitar a senha no terminal, é normal que nada apareça na tela.**

**Confirmando a pasta do usuário:** use `pwd` para mostrar o caminho da pasta atual. Exemplo de resultado:

```
/home/cevclinica
```

Neste exemplo, `cevclinica` é a pasta do usuário da conta. **Esse caminho será importante para configurar a variável HOSTNET_PATH no GitHub.**

**Entendendo a pasta `www`:** na Hostnet, `www` é a pasta pública do site — arquivos publicados dentro dela podem ficar acessíveis pela internet, dependendo da configuração do domínio.
- Se o sistema for publicado diretamente no domínio principal, a pasta de destino pode ser: `/home/SEU_USUARIO/www`
- Se for em uma subpasta: `/home/SEU_USUARIO/www/nome_da_pasta`
- Exemplo: `/home/cevclinica/www/financas_simples`

**Criando uma subpasta para o sistema:**
```
cd ~/www
mkdir financas_simples
```
Ou criar o caminho completo de uma vez:
```
mkdir -p ~/www/financas_simples
```
(`mkdir` cria uma pasta; `-p` ajuda a criar o caminho completo caso alguma pasta intermediária ainda não exista.)

**Conferindo se a pasta foi criada:**
```
ls ~/www
cd ~/www/financas_simples
pwd
```
Exemplo de resultado: `/home/cevclinica/www/financas_simples` — **esse é o caminho que poderá ser usado na secret HOSTNET_PATH.**

### 3.17. Configurando o GitHub para o deploy

O prompt desta etapa vai gerar o passo a passo do deploy. Durante o processo, o usuário será orientado a criar Secrets no repositório do GitHub.

**Secrets necessárias** (descrição de cada uma):

```
HOSTNET_HOST
```
Endereço do servidor SSH da Hostnet. Geralmente o mesmo endereço de FTP. Exemplo: `ftp.seudominio.com`

```
HOSTNET_USER
```
Usuário SSH da Hostnet. Geralmente o mesmo usuário de FTP. Exemplo: `cevclinica`

```
HOSTNET_PORT
```
Porta SSH. Geralmente: `22`

```
HOSTNET_PATH
```
Caminho absoluto da pasta de destino na Hostnet. Se for publicar direto na pasta www, use algo como:
```
/home/SEU_USUARIO/www
```
Se for publicar em uma subpasta, use algo como:
```
/home/SEU_USUARIO/www/financas_simples
```
Exemplo: `/home/cevclinica/www/financas_simples`

```
HOSTNET_SSH_KEY
```
Chave privada SSH usada pelo GitHub Actions para acessar o servidor da Hostnet. Será criada no computador e cadastrada no servidor e no GitHub.

### 3.18. Como gerar a chave SSH para o deploy

Gerar um par de chaves específico para o deploy, no terminal local (PowerShell, Git Bash ou terminal da ferramenta de desenvolvimento). Se usar PowerShell no Windows, preferir `$HOME` no caminho da chave.

**PowerShell (Windows):**
```
ssh-keygen -t ed25519 -C "deploy-hostnet" -f "$HOME\.ssh\hostnet_deploy"
```
Cria dois arquivos:
```
$HOME\.ssh\hostnet_deploy
$HOME\.ssh\hostnet_deploy.pub
```
O arquivo sem `.pub` é a chave privada; o com `.pub` é a chave pública.

**Git Bash, Linux ou macOS:**
```
ssh-keygen -t ed25519 -C "deploy-hostnet" -f ~/.ssh/hostnet_deploy
```
Arquivos criados:
```
~/.ssh/hostnet_deploy
~/.ssh/hostnet_deploy.pub
```

**Atenção:** a chave privada vai para o GitHub Secret `HOSTNET_SSH_KEY`; a chave pública vai para o servidor da Hostnet, no arquivo `authorized_keys`. **Nunca compartilhar a chave privada em chats públicos, prints ou documentação.**

**Observação para Windows e PowerShell:** se aparecer erro parecido com:
```
Saving key "~/.ssh/hostnet_deploy" failed: No such file or directory
```
e a pasta `.ssh` já existir, o problema provavelmente foi o uso do `~` no caminho. No PowerShell usar o formato com `$HOME`:
```
ssh-keygen -t ed25519 -C "deploy-hostnet" -f "$HOME\.ssh\hostnet_deploy"
```
`$HOME` representa a pasta do usuário no Windows. Exemplo: `C:\Users\SeuUsuario`. Caminho final: `C:\Users\SeuUsuario\.ssh\hostnet_deploy`.

**Copiando a chave pública:**
- PowerShell: `Get-Content "$HOME\.ssh\hostnet_deploy.pub"`
- Git Bash/Linux/macOS: `cat ~/.ssh/hostnet_deploy.pub`
- Copiar o conteúdo inteiro. Deve começar parecido com:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...
```

### 3.19. Adicionando a chave pública no servidor da Hostnet

1. Acesse o servidor por SSH:
```
ssh usuario@endereco_ftp
```
Exemplo: `ssh cevclinica@ftp.cevclinica.x-br.com`

2. Garanta que a pasta `.ssh` exista:
```
mkdir -p ~/.ssh
```

3. Abra o arquivo `authorized_keys` com o editor nano:
```
nano ~/.ssh/authorized_keys
```
(nano é um editor de texto simples que funciona dentro do terminal.)

4. Cole a chave pública em uma nova linha.

5. Para salvar: pressione `Ctrl + O` para salvar; `Enter` para confirmar o nome do arquivo; `Ctrl + X` para sair do editor.

6. Ajuste as permissões da pasta e do arquivo:
```
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```
Esses comandos ajudam o SSH a aceitar o arquivo com segurança.

**Testando a chave de deploy (no computador local):**
- PowerShell: `ssh -i "$HOME\.ssh\hostnet_deploy" usuario@endereco_ftp`
- Git Bash/Linux/macOS: `ssh -i ~/.ssh/hostnet_deploy usuario@endereco_ftp`
- Exemplo: `ssh -i ~/.ssh/hostnet_deploy cevclinica@ftp.cevclinica.x-br.com`
- Se o acesso funcionar **sem pedir a senha do usuário**, a chave foi configurada corretamente. Se pedir senha, a chave pode não ter sido cadastrada corretamente ou pode haver detalhe de permissão.

**Copiando a chave privada para o GitHub:**
- PowerShell: `Get-Content "$HOME\.ssh\hostnet_deploy"`
- Git Bash/Linux/macOS: `cat ~/.ssh/hostnet_deploy`
- Copiar o conteúdo inteiro. Começa e termina com linhas parecidas com:
```
-----BEGIN OPENSSH PRIVATE KEY-----
...
-----END OPENSSH PRIVATE KEY-----
```
- Cadastrar no GitHub Secret: `HOSTNET_SSH_KEY`.

**Cuidados importantes (chave privada):**
- Deve ser cadastrada apenas no Secret do GitHub.
- Não colocar em arquivo do projeto; não salvar em `docs/`, `README.md`, `AGENTS.md` ou `CLAUDE.md`.
- Não enviar para outras pessoas; não colar em chats públicos, prints, e-mails ou mensagens de grupo.
- **Se a chave for exposta por engano, remova a chave pública correspondente do servidor e gere um novo par de chaves.**

### 3.20. Como cadastrar as Secrets no GitHub

Passos:
1. Acesse o GitHub.
2. Clique em `Repositories`.
3. Abra o repositório do projeto.
4. Clique em `Settings` no menu superior.
5. No menu lateral, acesse: `Secrets and variables / Actions`
6. Clique em: `New repository secret`
7. Cadastre uma secret por vez. Para cada secret:

```
Name: nome da secret, por exemplo HOSTNET_HOST
Secret: valor correspondente
```

8. Cadastre todas:

```
HOSTNET_HOST
HOSTNET_USER
HOSTNET_PORT
HOSTNET_PATH
HOSTNET_SSH_KEY
```

**Conferindo as Secrets:** depois de cadastrar, o GitHub mostra apenas os nomes das secrets — **não mostra os valores novamente**. Por isso, conferir com atenção antes de salvar. Se errar algum valor, pode editar ou recriar a secret.

**Cuidados importantes (antes do deploy) — checklist:**
```
[ ] A pasta de destino existe na Hostnet.
[ ] O caminho absoluto da pasta foi confirmado com `pwd`.
[ ] A chave pública foi adicionada ao `authorized_keys`.
[ ] A chave privada foi cadastrada apenas no GitHub Secret.
[ ] As permissões da pasta `.ssh` foram ajustadas.
[ ] O teste SSH com a chave funcionou.
[ ] Todas as secrets foram cadastradas no GitHub.
[ ] Nenhuma chave foi salva dentro do projeto.
[ ] Nenhuma senha foi enviada para o GitHub como arquivo.
```

**Regra principal:**
> Chave pública vai para o servidor.
> Chave privada vai para o GitHub Secret.
> Código vai para o repositório.
> Segredos não vão para os arquivos do projeto.

### 3.21. Posso usar a mesma chave SSH de deploy em outros projetos?

- Tecnicamente sim: pode ser usada em outro projeto/repositório/outra GitHub Action, desde que a chave pública esteja no servidor e a privada como secret no GitHub. **Mas não é a prática mais recomendada.**
- O ideal é criar uma chave específica para cada projeto importante, facilitando controle e segurança. Exemplos:
```
Projeto Finanças Simples:
~/.ssh/hostnet_financas_simples_deploy

Projeto Sistema de Agendamento:
~/.ssh/hostnet_agendamento_deploy

Projeto Site Institucional:
~/.ssh/hostnet_site_institucional_deploy
```
- Vantagem: para bloquear o deploy de um projeto, basta remover a chave pública correspondente do `authorized_keys` e apagar a secret daquele repositório. Se todos usarem a mesma chave, removê-la quebra o deploy de todos ao mesmo tempo.

**Regra prática (bloco "Copiar"):**
```
mesmo projeto = pode reutilizar a mesma chave na mesma Action;
mesmo projeto com mais de uma Action = pode reutilizar, se fizer sentido;
projetos diferentes = prefira criar chaves diferentes;
clientes diferentes = crie chaves diferentes;
servidores diferentes = crie chaves diferentes.
```
Regra principal: quanto mais específica a chave, mais fácil controlar e revogar o acesso. **Para iniciantes, criar uma chave de deploy por projeto.**

### 3.22. Ajustes na configuração do servidor (PHP e cache)

- Conferir a configuração do servidor na Hostnet: o ideal é que o site use a mesma versão de PHP testada localmente, ou a versão mais próxima disponível.
- Além do PHP, ajustar o **cache**. Cache guarda uma versão temporária de páginas/arquivos para entregar conteúdo mais rápido — útil em sites institucionais, blogs e páginas estáticas. **Mas em sistemas web totalmente dinâmicos, o cache pode atrapalhar**: depois de um deploy, o navegador ou servidor pode continuar exibindo uma versão antiga de uma tela mesmo com arquivos novos enviados.
- **Para sistemas web dinâmicos, a recomendação é desabilitar o cache do site no painel da Hostnet, a menos que o projeto tenha estratégia específica para lidar com cache.**

**Ajustando PHP e cache na Hostnet:**
1. Acesse o painel: `https://painel.hostnet.com.br/`
2. Na barra lateral, acesse: `Servidor Cloud / Configurações dos sites`
3. Selecione o domínio desejado.
4. Clique no botão: `Editar`
5. Marque `Sim` na opção `Configurações avançadas`.
6. Procure pela opção: `Versão do PHP` → ajuste para a mesma versão encontrada no XAMPP ou para a mais próxima disponível.
7. Procure pela opção: `Cache` → marque `Não`
8. Clique no botão: `Enviar`

**Atenção ao cache:** depois de desabilitar, fazer novo teste no navegador após o deploy. Se algo parecer desatualizado, testar: recarregar com `Ctrl + F5`; abrir em janela anônima; limpar o cache do navegador; confirmar se o deploy enviou os arquivos para a pasta correta.

Regra: durante o desenvolvimento e nos primeiros deploys de um sistema dinâmico, prefira evitar cache. Depois que o sistema estiver maduro, pode-se estudar estratégias específicas de cache, com cuidado para não prejudicar telas, login, formulários e dados atualizados.

### 3.23. PROMPT DO PASSO 7 (bloco "Copiar" — transcrição VERBATIM)

**Título no ebook: "Prompt do passo 7"** — precedido pelas notas: "Abaixo está uma versão generalista do prompt, sem stack fixa. Ela usa AGENTS.md como padrão para Codex e Antigravity. IMPORTANTE: Quem usa Claude Code deve substituir AGENTS.md por CLAUDE.md antes de enviar. O AGENTS.md pode aparecer mais de uma vez no prompt. ATENÇÃO: Execute este prompt em um chat novo com raciocínio."

Texto integral do prompt:

---

Responda sempre em **português do Brasil**.

Você é especialista em GitHub Actions, SSH, rsync e deploy seguro na **Hostnet**, ajudando um usuário leigo a publicar um sistema web.

Sua missão é preparar o deploy manual do projeto para produção na Hostnet.

Fluxo desta etapa:

GitHub -> GitHub Actions -> SSH/rsync -> Hostnet

A Hostnet deve receber apenas o necessário para rodar o sistema.

Tudo que for documentação, prompts, arquivos de contexto da IA, histórico Git, arquivos locais, logs, backups e segredos deve ficar fora da produção.

O deploy deve ser manual, ou seja, o usuário dispara quando quiser.

Não faça deploy automático por push neste primeiro momento.

## 1. Reconstruir o contexto

Leia integralmente, nesta ordem:

- `AGENTS.md`
- `docs/FSD.md`
- `docs/DESIGN.md`
- `docs/INSUMOS.md`
- `docs/PLANO.md`
- `docs/STATUS.md`
- `docs/ERROS.md`
- `docs/MANUTENCAO.md`

Identifique:

- stack do projeto;
- arquitetura;
- pasta pública ou ponto de entrada da aplicação;
- arquivos necessários para produção;
- arquivos que não devem ir para produção;
- dependências necessárias em produção;
- estratégia de configuração em produção;
- banco de dados ou persistência;
- assets públicos;
- arquivos de insumos usados pela interface;
- comandos necessários após deploy, se houver;
- cuidados de segurança definidos no FSD e na documentação;
- arquivos reais ou exemplos de configuração usados pelo sistema;
- nomes exatos das variáveis de ambiente ou constantes usadas pelo código;
- onde o sistema lê as configurações de produção, como `.env`, `config/config.php`, `config.example.php`, `app/config`, `includes/config`, chamadas `getenv()`, `$_ENV`, `$_SERVER`, `env()` ou equivalentes da stack.

Se alguma informação essencial para deploy na Hostnet estiver faltando, pergunte ao usuário antes de configurar.

## 2. Regras inquebráveis do deploy

Siga estas regras:

- Nunca exiba, versione ou registre senhas, tokens ou chaves reais em arquivos do projeto.
- Não envie `.git/` para produção.
- Não envie `.github/` para produção.
- Não envie `docs/` para produção.
- Não envie `AGENTS.md` ou `CLAUDE.md` para produção.
- Não envie `README.md` para produção, salvo se o FSD exigir por algum motivo específico.
- Não envie arquivos reais de ambiente local.
- Não envie logs, dumps, backups ou arquivos temporários.
- Não envie arquivos de documentação usados apenas pela IA.
- Não envie arquivos de configuração de exemplo, salvo se forem realmente necessários em produção e não contiverem segredos.
- Envie assets públicos necessários, como CSS, JS, imagens, logos e ícones usados pelo sistema.
- Envie dependências necessárias em produção conforme a estratégia definida no FSD.
- Envie scripts de banco, migrations ou schemas apenas se forem necessários para preparar ou atualizar o banco em produção.
- Crie o arquivo real de configuração de produção diretamente na Hostnet, sem versionar segredos.
- No primeiro deploy, use `rsync` sem `--delete`.
- Antes de publicar, faça backup da versão atual na Hostnet, se já houver arquivos no destino.

## 3. Criar `deploy-exclude.txt`

Crie o arquivo `deploy-exclude.txt` na raiz do projeto.

Ele deve listar tudo que o `rsync` não deve enviar para produção.

Comece com esta base e ajuste conforme a stack do projeto:

.git/
.github/
docs/
prompts/
AGENTS.md
CLAUDE.md
README.md
README*.md
*.example
*.example.*
.env
.env.*
deploy-exclude.txt
.gitignore
.gitattributes
logs/
*.log
error_log
*.sql.gz
*.bak
*.backup
tmp/
temp/
.DS_Store
Thumbs.db
desktop.ini
.vscode/
.idea/

Depois, ajuste conforme a stack:

- Se a stack gerar pastas de cache que não devem ir para produção, adicione.
- Se a stack tiver dependências que devem ser reconstruídas no servidor, exclua essas dependências.
- Se a stack exigir dependências versionadas ou enviadas para produção, não exclua essas pastas.
- Se houver pasta de uploads persistentes em produção, cuidado para não sobrescrever nem apagar.
- Se houver pasta pública específica, garanta que ela será enviada corretamente.

Não exclua automaticamente `vendor/`, `dist/`, `build/`, `public/`, `assets/` ou pastas similares sem verificar o FSD e a estratégia de produção.

## 4. Criar workflow do GitHub Actions

Crie o arquivo:

`.github/workflows/deploy-hostnet.yml`

O deploy deve ser manual, usando `workflow_dispatch`.

Use este modelo como base e ajuste conforme a stack do projeto:

```yaml
name: Deploy Hostnet

on:
 workflow_dispatch:

jobs:
 deploy:
 name: Enviar arquivos para a Hostnet
 runs-on: ubuntu-latest

 steps:
 - name: Baixar repositório
 uses: actions/checkout@v4

 - name: Preparar chave SSH
 run: |
 mkdir -p ~/.ssh
 echo "${{ secrets.HOSTNET_SSH_KEY }}" > ~/.ssh/hostnet_deploy
 chmod 600 ~/.ssh/hostnet_deploy
 ssh-keyscan -p ${{ secrets.HOSTNET_PORT }} -H ${{ secrets.HOSTNET_HOST }} >> ~/.ssh/known_hosts

 - name: Testar conexão SSH
 run: |
 ssh -i ~/.ssh/hostnet_deploy -p ${{ secrets.HOSTNET_PORT }} \
 ${{ secrets.HOSTNET_USER }}@${{ secrets.HOSTNET_HOST }} \
 "echo 'Conexão SSH com a Hostnet funcionando.'"

 - name: Backup da versão atual na Hostnet
 run: |
 ssh -i ~/.ssh/hostnet_deploy -p ${{ secrets.HOSTNET_PORT }} \
 ${{ secrets.HOSTNET_USER }}@${{ secrets.HOSTNET_HOST }} \
 "mkdir -p ~/deploy-backups && \
 if [ -d '${{ secrets.HOSTNET_PATH }}' ] && [ \"\$(ls -A '${{ secrets.HOSTNET_PATH }}')\" ]; then \
 tar -czf ~/deploy-backups/backup-\$(date +%Y%m%d-%H%M%S).tar.gz -C '${{ secrets.HOSTNET_PATH }}' . ; \
 else echo 'Primeiro deploy: sem backup.'; fi"

 - name: Deploy com rsync
 run: |
 rsync -avz \
 --exclude-from=deploy-exclude.txt \
 -e "ssh -i ~/.ssh/hostnet_deploy -p ${{ secrets.HOSTNET_PORT }}" \
 ./ ${{ secrets.HOSTNET_USER }}@${{ secrets.HOSTNET_HOST }}:${{ secrets.HOSTNET_PATH }}
```

Se a stack exigir build antes do envio, como instalar dependências ou gerar arquivos de produção, proponha os passos necessários com base no FSD antes do `rsync`.

Não invente comandos de build. Use apenas os comandos definidos no FSD, em `docs/MANUTENCAO.md` ou nos arquivos do projeto.

## 5. Explicar os GitHub Secrets

Oriente o usuário a cadastrar em:

`Settings -> Secrets and variables -> Actions`

Os seguintes Secrets:

HOSTNET_HOST
HOSTNET_USER
HOSTNET_PORT
HOSTNET_PATH
HOSTNET_SSH_KEY

Explique cada um em linguagem simples:

- `HOSTNET_HOST`: endereço do servidor SSH da Hostnet.
- `HOSTNET_USER`: usuário SSH da Hostnet.
- `HOSTNET_PORT`: porta SSH.
- `HOSTNET_PATH`: caminho da pasta onde o sistema será publicado.
- `HOSTNET_SSH_KEY`: chave privada usada pelo GitHub Actions para conectar na Hostnet.

Explique que esses valores não devem ser colocados no código.

## 6. Orientar criação da chave SSH

Entregue os comandos para gerar uma chave SSH, quando necessário:

`ssh-keygen -t ed25519 -C "deploy-hostnet" -f ~/.ssh/hostnet_deploy`

Depois explique:

`cat ~/.ssh/hostnet_deploy.pub`

A chave pública deve ser cadastrada na Hostnet, no arquivo `~/.ssh/authorized_keys`.

E:

`cat ~/.ssh/hostnet_deploy`

A chave privada deve ser cadastrada no GitHub Secret `HOSTNET_SSH_KEY`.

Deixe claro:

- chave pública pode ir para a Hostnet;
- chave privada vai para o GitHub Secret;
- chave privada não deve ser enviada no chat, nem versionada, nem salva no projeto.

## 7. Orientar configuração na Hostnet

Oriente o usuário a preparar a pasta de destino.

Exemplo:

`mkdir -p ~/www/<nome-do-projeto>`

O caminho real deve ser o definido no Secret `HOSTNET_PATH`.

Explique que a Hostnet pode usar `www/` como pasta pública e que o projeto pode ficar em uma subpasta, por exemplo:

`/home/USUARIO/www/<nome-do-projeto>`

Se o FSD definir outra estrutura, siga o FSD.

## 8. Configuração real de produção

Oriente o usuário a criar diretamente na Hostnet o arquivo real de configuração de produção, conforme a stack do projeto.

Antes de fornecer qualquer exemplo de configuração, procure nos fontes do sistema qual arquivo de configuração é usado e quais nomes exatos de variáveis, constantes ou chaves o código espera receber.

Verifique, conforme a stack do projeto, arquivos e padrões como:

- `.env`;
- `.env.example`;
- `config/config.php`;
- `config.example.php`;
- arquivos dentro de `config/`;
- arquivos dentro de `app/config/`;
- arquivos dentro de `includes/`;
- chamadas `getenv()`;
- uso de `$_ENV`;
- uso de `$_SERVER`;
- função `env()`;
- constantes de conexão;
- documentação em `docs/MANUTENCAO.md`;
- instruções específicas no `docs/FSD.md`.

Não invente nomes de variáveis de ambiente.

Não troque nomes usados pelo sistema por nomes genéricos.

Não forneça exemplo de configuração sem antes confirmar qual arquivo ou padrão o projeto utiliza.

O exemplo fornecido ao usuário deve usar exatamente os mesmos nomes esperados pelo código.

Exemplos possíveis, dependendo da stack:

- `.env`;
- `config/config.php`;
- arquivo de configuração de produção definido pelo FSD;
- arquivo de configuração de produção já previsto no projeto.

Esse arquivo pode conter credenciais reais de produção, como banco, SMTP, tokens ou chaves, se forem necessários.

Mas essas credenciais não devem ir para o GitHub.

Use valores fictícios ou placeholders no exemplo, como:

NOME_DO_BANCO_AQUI
USUARIO_DO_BANCO_AQUI
SENHA_DO_BANCO_AQUI
SMTP_DO_DOMINIO_AQUI

Ao orientar o usuário, explique:

1. qual arquivo de configuração foi encontrado ou deve ser criado;
2. onde esse arquivo deve ficar na Hostnet;
3. quais nomes exatos de variáveis ou constantes o sistema espera;
4. quais valores o usuário deve substituir;
5. quais dados não devem ser versionados;
6. se existe algum arquivo de exemplo local que pode ser usado como base.

Se não encontrar com segurança o arquivo ou padrão de configuração usado pelo sistema, pare e pergunte ao usuário antes de sugerir nomes de variáveis.

## 9. Banco de dados em produção

Se o sistema usar banco de dados, oriente a preparação em produção conforme o FSD.

Isso pode envolver:

- criar banco no painel da Hostnet;
- forneça o link (https://ajuda.hostnet.com.br/mysql/) de orientação para criar o banco de dados na Hostnet
- configurar usuário e senha;
- criar arquivo de configuração em produção;
- rodar migrations;
- importar schema;
- executar seeders;
- criar usuário inicial;
- validar conexão.

Não rode comandos destrutivos sem confirmação.

Não sobrescreva banco de produção sem autorização explícita.

## 10. Commit das configurações de deploy

Depois de criar ou alterar `deploy-exclude.txt` e `.github/workflows/deploy-hostnet.yml`, verifique o estado do Git:

`git status`

Confira com atenção quais arquivos serão versionados.

Confirme que nenhum segredo será enviado para o GitHub.

Não devem aparecer no commit:

- senhas reais;
- tokens;
- chaves privadas;
- arquivos `.env` reais;
- arquivos de configuração real de produção;
- dumps de banco;
- backups;
- logs;
- arquivos temporários;
- credenciais de SMTP;
- credenciais de banco de dados.

Se aparecer algum arquivo sensível, pare e ajuste o `.gitignore` ou o `deploy-exclude.txt` antes de continuar.

Depois, prepare os arquivos do deploy para commit:

`git add deploy-exclude.txt .github/workflows/deploy-hostnet.yml`

Se outros arquivos de documentação viva tiverem sido atualizados nesta etapa, como `docs/STATUS.md` ou `docs/ERROS.md`, inclua também esses arquivos no commit, desde que não contenham segredos:

`git add docs/STATUS.md docs/ERROS.md`

Em seguida, crie o commit:

`git commit -m "Configura deploy manual na Hostnet"`

Depois do commit, oriente o usuário a enviar as alterações para o GitHub antes de tentar executar a Action.

Use o comando adequado à branch principal do projeto.

Na maioria dos casos:

`git push origin main`

Se a branch principal do projeto for `master`, use:

`git push origin master`

Se houver dúvida sobre o nome da branch principal, verifique com:

`git branch`

O workflow `.github/workflows/deploy-hostnet.yml` só estará disponível na aba Actions do GitHub depois que esse push for feito.

Não oriente o usuário a executar a Action antes de confirmar que o arquivo do workflow já foi enviado ao GitHub.

## 11. Como executar o deploy

Antes de orientar o usuário a executar a Action, confirme que as alterações de deploy foram enviadas ao GitHub. O arquivo abaixo precisa existir no repositório remoto:

`.github/workflows/deploy-hostnet.yml`

Se o arquivo foi criado apenas localmente, oriente primeiro: `git push origin main`

Ou, se a branch principal for `master`: `git push origin master`

Somente depois disso oriente o usuário a abrir a aba Actions.

Explique ao usuário:

1. Acesse o repositório no GitHub.
2. Vá até a aba **Actions**.
3. Escolha o workflow **Deploy Hostnet**.
4. Clique em **Run workflow**.
5. Acompanhe os logs.
6. Se falhar, leia a mensagem e peça correção para a IA.
7. Se concluir, abra o sistema no navegador e valide.

Reforce que o deploy é manual.

Ele não acontece automaticamente a cada `git push`.

## 12. Checklist pós-deploy

Depois do deploy, oriente o usuário a conferir:

[ ] Site abriu.
[ ] Assets públicos carregaram, como CSS, JS, imagens e logos.
[ ] Login funciona, se houver login.
[ ] Banco conecta, se houver banco.
[ ] Páginas principais abrem.
[ ] Formulários principais funcionam.
[ ] Arquivos de configuração sensíveis não abrem pela URL.
[ ] `docs/` não está publicado.
[ ] `prompts/` não está publicado.
[ ] `AGENTS.md` ou `CLAUDE.md` não está publicado.
[ ] `.git/` não está publicado.
[ ] Logs e backups não estão públicos.
[ ] Backup foi gerado em `~/deploy-backups`, se já havia versão anterior.

## 13. Atualizar arquivos vivos

Atualize `docs/STATUS.md` registrando:

- deploy configurado;
- workflow criado;
- arquivo `deploy-exclude.txt` criado;
- secrets necessários listados;
- pendências do usuário, se houver;
- se o primeiro deploy foi executado ou ficou pendente;
- resultado do deploy, se executado.

Se algum erro ocorrer, registre em `docs/ERROS.md`:

## <data> - <título curto do erro>

- Sintoma:
- Causa:
- Solução aplicada:
- Como evitar no futuro:

## 14. Entrega final

Ao final, entregue:

1. O que foi criado ou alterado.
2. Conteúdo resumido do `deploy-exclude.txt`.
3. Nome do workflow criado.
4. Lista dos 5 Secrets necessários.
5. Como gerar e cadastrar a chave SSH.
6. Como preparar a pasta na Hostnet.
7. Como criar a configuração real de produção, informando:
 - qual arquivo de configuração foi localizado ou definido;
 - quais nomes exatos de variáveis, constantes ou chaves o sistema usa;
 - quais valores devem ser preenchidos pelo usuário;
 - onde esse arquivo deve ficar na Hostnet;
 - confirmação de que o exemplo foi baseado nos fontes reais do sistema, e não em nomes genéricos.
8. Como preparar o banco de dados, se houver.
9. Como executar o deploy manual.
10. Confirmação de que o usuário deve executar `git push origin main` ou o comando equivalente da branch principal antes de tentar rodar a Action no GitHub.
11. Checklist pós-deploy.
12. Confirmação de atualização do `docs/STATUS.md`.
13. Confirmação de registro em `docs/ERROS.md`, se houve erro.
14. Confirmação de commit ou comandos para o usuário executar.

Lembre-se: nunca exiba ou versione senhas, tokens ou chaves reais.

---

### 3.24. Antes de rodar o deploy: checklist do usuário

```
[ ] O projeto está funcionando localmente.
[ ] A revisão de segurança foi feita.
[ ] A documentação final foi criada.
[ ] O GitHub está atualizado.
[ ] Os Secrets foram cadastrados.
[ ] A chave pública foi colocada na Hostnet.
[ ] A chave privada foi colocada apenas no GitHub Secret.
[ ] A pasta de destino na Hostnet existe.
[ ] O arquivo de configuração real foi criado na Hostnet.
[ ] O banco de produção foi criado, se necessário.
```

Se algum item estiver faltando, resolva antes de publicar.

### 3.25. O que fazer se o deploy falhar

Deploy pode falhar — não significa que o projeto foi perdido; significa que alguma parte da configuração precisa de ajuste.

**Problemas comuns:**
- Secret escrito errado;
- porta SSH incorreta;
- chave SSH inválida;
- pasta de destino inexistente;
- permissão negada;
- arquivo de configuração de produção ausente;
- banco de produção não criado;
- comando de build faltando;
- assets não enviados;
- caminho errado na Hostnet.

**Procedimento:** quando falhar, copiar o trecho do erro do log do GitHub Actions e enviar para a IA, usando este modelo (bloco "Copiar" — VERBATIM):

---

O deploy falhou no GitHub Actions.

Trecho do erro:

[cole aqui o erro]

O que eu já conferi:
- Secrets cadastrados:
- Pasta na Hostnet:
- Chave SSH:
- Branch usada:

Leia `docs/MANUTENCAO.md`, `docs/STATUS.md` e o workflow de deploy. Identifique a causa provável, corrija o que for seguro corrigir e me diga o que eu preciso conferir manualmente.

---

### 3.26. Prompt para revisar segurança do deploy (bloco "Copiar" — VERBATIM)

"Antes de executar o deploy, você pode pedir uma revisão:"

---

Revise a configuração de deploy antes da primeira publicação.

Verifique:
- se `deploy-exclude.txt` impede envio de docs/, AGENTS.md ou CLAUDE.md, .git/, .github/ e arquivos sensíveis;
- se nenhum segredo está no código;
- se o workflow usa GitHub Secrets;
- se o primeiro deploy está sem `--delete`;
- se o backup remoto está previsto;
- se assets públicos necessários serão enviados;
- se dependências necessárias em produção serão tratadas corretamente.

Não execute deploy agora. Apenas revise e aponte riscos.

---

### 3.27. Cuidado com uploads e arquivos persistentes

- Alguns sistemas permitem upload de arquivos: fotos; documentos; anexos; comprovantes; imagens enviadas por usuários.
- Esses arquivos podem existir em produção e não no repositório.
- **Muito cuidado com `rsync --delete`**: se o deploy apagar arquivos que não estão no GitHub, você pode perder uploads reais.
- Por isso o primeiro deploy não usa `--delete`.
- Antes de ativar `--delete` no futuro, ter certeza de que uploads, logs, backups e configurações reais estão fora da sincronização ou protegidos.

### 3.28. Depois do primeiro deploy (possibilidades futuras)

Depois que o primeiro deploy estiver funcionando, pode-se melhorar o processo aos poucos:
- ativar deploy automático ao fazer push na branch main;
- adicionar `--delete` com segurança;
- separar pasta de uploads persistentes;
- criar etapa de build;
- rodar testes antes do deploy;
- criar ambiente de homologação;
- automatizar migrations com mais controle.

**Não fazer tudo no primeiro momento.** Primeiro, publicar com segurança; depois, melhorar o processo (pode-se pedir ajuda de uma IA para melhorar esse fluxo).

### 3.29. Checklist da etapa de deploy

```
[ ] A IA leu AGENTS.md ou CLAUDE.md.
[ ] A IA leu FSD.md, MANUTENCAO.md, STATUS.md e ERROS.md.
[ ] deploy-exclude.txt foi criado.
[ ] O workflow deploy-hostnet.yml foi criado.
[ ] O deploy é manual.
[ ] Os Secrets necessários foram listados.
[ ] A chave SSH foi explicada.
[ ] A pasta da Hostnet foi explicada.
[ ] A configuração de produção foi explicada.
[ ] O banco de produção foi orientado, se houver.
[ ] Nenhum segredo foi versionado.
[ ] Foi feito commit da configuração de deploy.
[ ] Foi feito push para o GitHub.
[ ] O workflow foi executado ou ficou claro como executar.
[ ] O checklist pós-deploy foi entregue.
```

---

## 4. Itens acionáveis — documentos, pastas, comandos e prompts que um desenvolvedor precisa executar

### 4.1. Arquivos/pastas a criar ou atualizar (Passo 6)

- `docs/MANUTENCAO.md` (novo — seções mínimas listadas no prompt do passo 6).
- `docs/COMO-PEDIR-MUDANCAS.md` (novo — 8 tipos de exemplos de prompt).
- `AGENTS.md` (ou `CLAUDE.md` para usuários de Claude Code) — atualizar para "modo manutenção", incluindo o protocolo antes/depois de qualquer alteração.
- `docs/STATUS.md` — atualizar com o que foi criado e pendências.
- `docs/ERROS.md` — registrar erros no formato `## <data> - <título curto do erro>` com Sintoma/Causa/Solução aplicada/Como evitar no futuro.

### 4.2. Arquivos/pastas a criar ou atualizar (Passo 7)

- `deploy-exclude.txt` (na raiz do projeto) — base completa no prompt do passo 7.
- `.github/workflows/deploy-hostnet.yml` — workflow manual (`workflow_dispatch`), modelo YAML completo no prompt do passo 7.
- GitHub Secrets a cadastrar (5): `HOSTNET_HOST`, `HOSTNET_USER`, `HOSTNET_PORT`, `HOSTNET_PATH`, `HOSTNET_SSH_KEY`.
- Pasta de destino na Hostnet (ex.: `/home/cevclinica/www/financas_simples`) — criada via SSH.
- Arquivo real de configuração de produção — criado diretamente na Hostnet, com placeholders (NOME_DO_BANCO_AQUI, USUARIO_DO_BANCO_AQUI, SENHA_DO_BANCO_AQUI, SMTP_DO_DOMINIO_AQUI), sem versionar segredos.
- Banco de produção MySQL no painel Hostnet (link de ajuda: https://ajuda.hostnet.com.br/mysql/).
- Conta de e-mail de envio no painel Hostnet (Ultramail, se preciso), caso o sistema envie e-mails.
- `~/.ssh/authorized_keys` no servidor Hostnet (chave pública) + permissões `chmod 700 ~/.ssh` e `chmod 600 ~/.ssh/authorized_keys`.
- `docs/STATUS.md` e `docs/ERROS.md` — atualizar como arquivos vivos.

### 4.3. Comandos principais citados

- Gerar chave (Linux/macOS/Git Bash): `ssh-keygen -t ed25519 -C "deploy-hostnet" -f ~/.ssh/hostnet_deploy`
- Gerar chave (PowerShell Windows): `ssh-keygen -t ed25519 -C "deploy-hostnet" -f "$HOME\.ssh\hostnet_deploy"`
- Ler chave pública: `cat ~/.ssh/hostnet_deploy.pub` (ou `Get-Content "$HOME\.ssh\hostnet_deploy.pub"` no PowerShell)
- Ler chave privada: `cat ~/.ssh/hostnet_deploy` (ou `Get-Content "$HOME\.ssh\hostnet_deploy"` no PowerShell)
- Acessar servidor: `ssh usuario@endereco_ftp` (ex.: `ssh cevclinica@ftp.cevclinica.x-br.com`)
- Testar chave: `ssh -i ~/.ssh/hostnet_deploy usuario@endereco_ftp`
- Preparar servidor: `mkdir -p ~/.ssh`; `nano ~/.ssh/authorized_keys`; `chmod 700 ~/.ssh`; `chmod 600 ~/.ssh/authorized_keys`
- Criar pasta de destino: `cd ~/www`; `mkdir financas_simples`; ou `mkdir -p ~/www/financas_simples`; conferir com `ls ~/www`, `cd ~/www/financas_simples`, `pwd`
- PHP no servidor: `php-8.1 nome_do_arquivo.php` (versão conforme projeto; ex.: `php-8.4 database/migrate.php`)
- Git: `git status`; `git add deploy-exclude.txt .github/workflows/deploy-hostnet.yml`; `git add docs/STATUS.md docs/ERROS.md`; `git commit -m "Configura deploy manual na Hostnet"`; `git push origin main` (ou `master`); verificar branch com `git branch`.
- Ver PHP local: abrir `http://localhost/dashboard/phpinfo.php` no XAMPP.

### 4.4. Prompts prontos para dar à IA (resumo)

1. **Prompt do passo 6** — criar documentação final de manutenção + modo manutenção no arquivo de contexto.
2. **Prompt para pedir documentação mais simples** — reescrever documentação com linguagem simples.
3. **Prompt para completar documentação incompleta** — conferir as 12 seções de MANUTENCAO.md e completar o que falta.
4. **Prompt para revisar exemplos de mudanças futuras** — adaptar exemplos de COMO-PEDIR-MUDANCAS.md ao sistema real do FSD.
5. **Prompt de apoio para a IA (comandos PHP em produção)** — conferir versão de PHP, comando, backup, riscos antes de executar.
6. **Prompt de compatibilidade de versão PHP (XAMPP vs Hostnet)** — analisar risco de incompatibilidade.
7. **Prompt do passo 7** — preparar deploy manual na Hostnet (workflow, deploy-exclude, secrets, chave SSH, configuração de produção, banco).
8. **Prompt "O deploy falhou"** — modelo de relato de erro do GitHub Actions para a IA diagnosticar.
9. **Prompt para revisar segurança do deploy** — revisar configuração de deploy antes da primeira publicação.

### 4.5. Pontos-chave de segurança a reter

- Chave pública → servidor (authorized_keys); chave privada → GitHub Secret; segredos nunca nos arquivos do projeto.
- Se a chave for exposta por engano, remover a chave pública do servidor e gerar novo par.
- Primeiro deploy sem `--delete`; backup automático remoto em `~/deploy-backups`.
- Credenciais de banco/e-mail: nunca em docs, AGENTS/CLAUDE.md, README, GitHub, prints, prompts públicos ou mensagens de grupo.
- Antes de rodar migrations em produção: backup + teste local + versão correta do PHP.
- Deploy é manual (não automático por push) neste primeiro momento.

---

## 5. Avisos sobre conteúdo ausente

- O Passo 6 (`codificacao-11.txt`) não contém: workflows/código YAML, tabela de erros comuns estruturada (apenas prompts corretivos), nem comandos de deploy. Não menciona deploy — por design (proibido nesta etapa).
- O Passo 7 (`codificacao-12.txt`) não contém: instruções para outras hospedagens além da Hostnet (apenas aviso de que o prompt precisaria ser adaptado), nem passos de build específicos (são delegados ao FSD/MANUTENCAO.md). O modelo YAML do workflow está transcrito integralmente, preservando a indentação do original (que usa espaços; a formatação do ebook pode não preservar indentação exata — o conteúdo e os `uses:`/`run:`/`name:` são fiéis).
- Nenhum dos dois capítulos define uma tabela de "erros comuns" tabular própria (o ebook usou tabelas apenas para o Vocabulário técnico); os erros comuns do Passo 7 estão listados em prosa na seção "O que fazer se o deploy falhar".

# Grupo 11 — Manutenção: Pedindo Alterações e Rollback

## 1. Visão geral do grupo

Este grupo cobre a **manutenção de sistemas já prontos** — a fase seguinte à construção, validação, segurança, documentação e publicação. O ebook afirma: "um sistema não termina quando fica pronto". Depois que o sistema começa a ser usado, surgem novas necessidades (melhoria visual, ajuste de texto, nova regra, alteração em relatório, correção de permissão, melhoria de usabilidade).

O grupo é dividido em duas etapas:

1. **Pedindo alterações** (codificacao-13.txt): como pedir uma mudança para a IA sem bagunçar o projeto, sem pular documentação e sem transformar uma melhoria simples em uma reescrita desnecessária.
2. **Rollback: como voltar uma versão do sistema com segurança** (codificacao-14.txt): como desfazer uma alteração e retornar o sistema para um estado anterior, usando Git, GitHub, produção e banco de dados, com um caminho seguro para iniciantes.

O fio condutor é: **conduzir a IA com cuidado** (leitura de documentação, limite de escopo, plano antes de agir, atualização de documentação, commit) e **nunca improvisar** rollback (investigar antes, planejar, testar, documentar e versionar).

---

# Capítulo: codificacao-13.txt — "Pedindo uma alteração depois do sistema pronto"

## 2.1 Objetivo do capítulo

Mostrar, por meio de um exemplo real, como pedir uma alteração à IA após a conclusão do sistema — de forma controlada, sem bagunçar o projeto, sem pular documentação e sem transformar uma melhoria simples em uma reescrita desnecessária. O exemplo usa um sistema financeiro concluído cujo Dashboard (tela principal de visão geral) deve ficar "mais elegante, moderno e bonito, sem alterar regras de negócio".

**Cenário do exemplo:** o sistema financeiro já estava concluído. A alteração envolve principalmente: layout, Bootstrap, ícones, menu, nome do sistema e organização visual. **Não** é mudança de banco de dados, **não** é nova funcionalidade financeira, **não** é alteração de regra de negócio — é uma **melhoria de interface** (front-end).

## 2.2 Passos EXATOS na ordem (ciclo completo da alteração)

O capítulo apresenta o ciclo completo de manutenção com IA:

1. **Pedir alteração com contexto** (ler documentação + objetivo + escopo).
2. **Limitar o escopo** (dizer o que pode e o que não pode ser alterado).
3. **Pedir plano antes de alterar.**
4. **Revisar proposta visual** (imagem/modelo do layout).
5. **Ajustar com base em imagens ou preferências** (segundo prompt).
6. **Aplicar alteração** (após aprovação).
7. **Conferir documentação** (alinhamento de documentação).
8. **Verificar necessidade de commit.**

## 2.3 PROMPTS COMPLETOS (transcrição verbatim)

### Prompt do índice — Exemplo de pedido vago que deve ser evitado

> Copiar
>
> Deixe o dashboard mais bonito.

O livro explica que esse pedido é compreensível, mas vago demais: a IA pode tentar mudar muitas coisas ao mesmo tempo, alterar arquivos desnecessários, mexer no back-end, trocar bibliotecas, mudar regras de negócio ou ignorar a documentação do projeto.

### Primeiro prompt: pedido principal de alteração

> ATENÇÃO: Execute este prompt em um chat novo. Não é necessário raciocínio.
>
> Leia os seguintes arquivos de documentação do projeto para entender o contexto atual:
> - `AGENTS.md`
> - `docs/MANUTENCAO.md`
> - `docs/FSD.md`
> - `docs/STATUS.md`
> - `docs/ERROS.md`
>
> Objetivo:
> Quero deixar a interface do Dashboard mais elegante, moderna e bonita. Atue como um designer especialista em UI/UX (interfaces de sistemas web) e desenvolvedor front-end.
>
> Instruções específicas de design:
> 1. Melhore o layout visual do Dashboard usando as classes do Bootstrap já existentes no projeto (ajuste espaçamentos, cores de cartões, tipografia, se necessário).
> 2. Adicione ícones contextuais nos blocos de informação (KPIs) e menus. Use a biblioteca Font Awesome (verifique no FSD esta biblioteca já está inclusa ou se precisa ser instalada).
> 3. Corrija a exibição do nome do sistema no topo/menu para incluir um espaço, ficando exatamente assim: "Finanças Simples".
>
> Atenção:
> Esta é uma alteração puramente visual e de interface (Front-end). Não há necessidade de alterar tabelas do banco de dados ou regras de negócio nos controladores (Back-end), a menos que seja estritamente necessário para passar as variáveis de contagem para a View.
>
> Próximo passo:
> Antes de alterar qualquer arquivo, crie e me apresente um plano de implementação detalhado listando quais arquivos de visualização (views/css/layouts) serão modificados e o que será feito em cada um. Aguarde minha aprovação para avançar.
>
> Se possível me apresente uma imagem com o modelo do layout para aprovação.

**Por que esse prompt é bom** (o que ele informa à IA): quais arquivos consultar; qual o objetivo da alteração; qual papel a IA deve assumir; quais recursos visuais usar; qual texto precisa ser corrigido; que a mudança é de front-end; que banco de dados não deve ser alterado; que regras de negócio não devem ser alteradas; que a IA deve apresentar um plano antes de agir.

### Frase de proteção de escopo (bloco "Copiar" dentro da seção "A importância de limitar o escopo")

> Copiar
>
> Esta é uma alteração puramente visual e de interface (Front-end).

"Escopo é o limite do que será feito." Esta frase protege o projeto, orientando a IA a não mexer em tabelas, regras financeiras, controladores ou banco de dados sem necessidade.

### Segundo prompt: ajuste com base nas imagens

> Nota do livro: "Observe que para este exemplo é necessário anexar o print da tela."
>
> Copiar
>
> Veja as imagens anexas. Acho que estas opções poderiam ficar em uma NavBar conforme estava descrito no plano apresentado.

**Por que funciona:** não abre novo escopo; não diz "Refaça tudo" (pedido que deve ser evitado — citado como bloco "Copiar" negativo); aponta um ajuste específico ("colocar as opções em uma NavBar") e conecta o pedido ao plano já apresentado, ajudando a IA a manter continuidade.

### Terceiro prompt: alinhamento de documentação

> Copiar
>
> ## Alinhamento de documentação
> Com essas alterações aplicadas, talvez seja necessário alterar alguns arquivos de configuração e contexto.
>
> Verifique se é necessário alterar os arquivos MANUTENCAO.md, INSUMOS.md, FSD.md, AGENTS.md, DESIGN.md ou outros arquivos da pasta `docs/` para deixar tudo pronto para alterações futuras.

**Explicação do livro:** a palavra importante é **"Verifique"** — a IA deve analisar a necessidade, não alterar automaticamente tudo sem critério. Exemplos de impacto a considerar: se Font Awesome foi adicionado, isso pode entrar na documentação; se o layout do Dashboard mudou, registrar no STATUS; se o padrão visual mudou, afeta o DESIGN; se a manutenção futura precisa saber da nova estrutura, entra no MANUTENCAO; se o AGENTS.md orienta a IA sobre padrões visuais, talvez precise ser atualizado.

### Quarto prompt: verificar commit

> Copiar
>
> Verifique se é necessário fazer um commit.

"Esse pedido fecha o ciclo da alteração." Commit é o registro da mudança no Git; depois de uma alteração real, normalmente é recomendado registrar a mudança com mensagem clara.

### Exemplo de pedido ruim (evitar)

> Copiar
>
> Melhore o dashboard e pronto.

Esse tipo de pedido é muito menos seguro que o ciclo completo descrito acima.

### Prompt de apoio para testar a alteração

> Copiar
>
> Crie um roteiro de teste manual para validar esta alteração.
>
> Considere:
> - o que mudou na interface;
> - o que não deveria ter mudado;
> - quais telas preciso abrir;
> - quais ações preciso executar;
> - qual resultado esperado;
> - como identificar se algo quebrou.
>
> Explique em linguagem simples.

Esse prompt ajuda a validar a alteração **antes do commit ou antes do próximo deploy**.

## 2.4 Modelos/estruturas de documentos citados

Arquivos de documentação que o pedido de alteração deve mandar a IA ler:

- `AGENTS.md` (no primeiro prompt; também citado na documentação do terceiro prompt)
- `docs/MANUTENCAO.md` — explica como o sistema foi organizado e como deve ser mantido
- `docs/FSD.md` — mostra as regras e decisões do sistema
- `docs/STATUS.md` — mostra o estado atual do projeto
- `docs/ERROS.md` — mostra problemas anteriores e soluções aplicadas
- `docs/INSUMOS.md` — citado no terceiro prompt (alinhamento de documentação)
- `docs/DESIGN.md` — citado no terceiro prompt (alinhamento de documentação)

Função de cada arquivo, segundo o livro:
- `docs/MANUTENCAO.md` explica como o sistema foi organizado e como deve ser mantido.
- `docs/FSD.md` mostra as regras e decisões do sistema.
- `docs/STATUS.md` mostra o estado atual do projeto.
- `docs/ERROS.md` mostra problemas anteriores e soluções aplicadas.

## 2.5 Modelo geral para pedidos de alteração (estrutura reutilizável)

Com base no exemplo, um bom pedido de alteração deve dizer:

- **qual documentação a IA deve ler;**
- **qual é o objetivo da mudança;**
- **o que pode ser alterado;**
- **o que não deve ser alterado;**
- **quando a IA deve pedir aprovação;**
- **se a documentação precisa ser atualizada;**
- **se deve haver commit.**

Estrutura passo a passo do modelo geral:
1. Leia a documentação.
2. Explique o objetivo.
3. Diga o tipo de alteração.
4. Liste instruções específicas.
5. Diga o que não deve ser alterado.
6. Peça plano antes da execução, se necessário.
7. Peça atualização de documentação.
8. Peça verificação de commit.

## 2.6 Quando pedir plano antes de alterar

Peça plano antes de alterar quando:
- a mudança mexe em várias telas;
- a mudança pode afetar back-end;
- a mudança envolve banco de dados;
- a mudança altera permissões;
- a mudança altera fluxo do usuário;
- a mudança envolve deploy;
- a mudança pode quebrar algo existente;
- você ainda não tem certeza do melhor caminho.

Para alterações pequenas (ex.: corrigir um texto simples), talvez não seja necessário um plano detalhado. Mas, quando houver dúvida, peça o plano. Em alterações de sistemas prontos, o ideal é: **primeiro a IA propõe, depois o usuário aprova, só então ela implementa.**

## 2.7 Checklist para pedidos de alteração (transcrito)

> Copiar
>
> [ ] Informei quais documentos a IA deve ler.
> [ ] Expliquei o objetivo da alteração.
> [ ] Defini se é alteração visual, funcional, técnica ou de regra.
> [ ] Avisei o que não deve ser alterado.
> [ ] Pedi plano antes de executar, se necessário.
> [ ] Pedi para preservar regras do FSD.
> [ ] Pedi para manter documentação atualizada.
> [ ] Pedi para verificar necessidade de commit.
> [ ] Testei depois da alteração.

## 2.8 Vocabulário especializado (tabela Termo/Explicação)

| Termo | Explicação simples |
|---|---|
| Manutenção | Alteração feita em um sistema depois que ele já foi construído. |
| Dashboard | Tela principal que mostra informações importantes do sistema. |
| KPI | Indicador visual que resume uma informação importante, como saldo, total ou quantidade. |
| Front-end | Parte visual do sistema, que o usuário vê e usa. |
| Back-end | Parte interna do sistema, onde ficam regras, processamento e acesso ao banco. |
| View | Arquivo responsável por exibir uma tela ou parte visual do sistema. |
| Layout | Organização visual dos elementos na tela. |
| Navbar | Barra de navegação, geralmente usada no topo do sistema. |
| Bootstrap | Biblioteca CSS que ajuda a criar telas responsivas e organizadas. |
| Font Awesome | Biblioteca de ícones usada em sites e sistemas. |
| Commit | Registro de uma alteração no Git. |

## 2.9 Regras, avisos, boas práticas e armadilhas

- **Regra:** mesmo para alteração visual, conduzir a IA com cuidado — um pedido bom diz: documentação a ler, objetivo, o que pode ser alterado, o que não deve ser alterado, quando pedir aprovação, se a documentação precisa ser atualizada e se deve haver commit.
- **Regra:** a IA deve ler a documentação antes de alterar, mesmo em sistema pronto ("não alterar arquivos no escuro"); isso evita repetir erros, ignorar regras ou alterar partes erradas.
- **Regra:** limitar o escopo no prompt (ex.: "Esta é uma alteração puramente visual e de interface (Front-end)").
- **Regra:** a IA deve apresentar um plano antes de agir quando a alteração puder afetar várias partes. "Primeiro ela deve propor. Depois o usuário aprova. Só então ela implementa."
- **Regra:** documentação e Git fazem parte da manutenção — alterou o sistema, confira documentação e commit.
- **Aviso/armadilha:** pedidos vagos ("Deixe o dashboard mais bonito") fazem a IA mudar muitas coisas ao mesmo tempo, alterar arquivos desnecessários, mexer no back-end, trocar bibliotecas, mudar regras de negócio ou ignorar a documentação.
- **Boas práticas do segundo prompt:** não abrir novo escopo; apontar ajuste específico; conectar ao plano já apresentado para manter continuidade.
- **Boas práticas do terceiro prompt:** usar a palavra "Verifique" — a IA deve analisar a necessidade, não alterar documentos automaticamente sem critério.

## 2.10 Erros comuns e como resolver

| Erro comum | Como resolver |
|---|---|
| Pedido vago ("Deixe o dashboard mais bonito") | Seguir o modelo geral: documentação, objetivo, tipo de alteração, instruções específicas, o que NÃO alterar, plano antes, atualização de documentação, commit. |
| IA altera arquivos imediatamente sem proposta | Pedir plano de implementação antes de qualquer alteração e aguardar aprovação. |
| IA mexe em banco/regras de negócio em mudança visual | Incluir a frase de proteção de escopo ("alteração puramente visual e de interface (Front-end)"). |
| IA ignora decisões já tomadas | Obrigar a leitura prévia de `AGENTS.md`, `docs/MANUTENCAO.md`, `docs/FSD.md`, `docs/STATUS.md`, `docs/ERROS.md`. |
| Documentação fica desatualizada após a mudança | Usar o prompt de alinhamento de documentação (verificar MANUTENCAO, INSUMOS, FSD, AGENTS, DESIGN e demais `docs/`). |
| Alteração aplicada sem registro | Prompt "Verifique se é necessário fazer um commit." |
| Alteração publicada sem validação | Pedir roteiro de teste manual antes do commit ou deploy. |

---

# Capítulo: codificacao-14.txt — "Rollback: como voltar uma versão do sistema com segurança"

## 3.1 Objetivo do capítulo

Ensinar a pensar em rollback usando Git, GitHub, produção e banco de dados — sem ensinar todos os comandos avançados do Git, mas mostrando um **caminho seguro para iniciantes pedirem ajuda à IA e evitarem decisões perigosas**. Ideia central: **"Voltar código é uma coisa. Voltar banco de dados é outra."** Código, telas, arquivos e documentação normalmente podem ser revertidos com Git; banco de dados exige muito mais cuidado, porque pode conter dados reais criados por usuários.

**Cenário:** o sistema financeiro estava pronto e publicado. Foi pedida uma melhoria no Dashboard; a IA fez a alteração, o usuário testou, publicou e tudo parecia certo. Dias depois, os usuários finais disseram "A versão anterior era melhor" / "A nova tela ficou bonita, mas dificultou o uso" / "Depois da alteração, alguns usuários ficaram confusos". Agora é preciso voltar à versão anterior.

## 3.2 Passos EXATOS na ordem

**Antes de tudo — não entre em pânico.** O pedido "Volte tudo como era antes." é perigoso, porque "tudo" pode incluir código, banco, dados reais, arquivos enviados por usuários e configuração de produção. O correto é investigar primeiro. Antes de qualquer rollback, responda:

- O problema está apenas no código?
- O problema está na interface?
- O problema está em regra de negócio?
- O banco de dados foi alterado?
- A alteração já foi enviada ao GitHub?
- A alteração já foi publicada em produção?
- Usuários reais criaram dados depois da alteração?
- Existe backup antes da publicação?
- Existe uma tag de versão anterior?

Essas perguntas **definem a estratégia**.

**Fluxo de rollback quando a alteração foi apenas código/documentação (sem banco):**
1. Listar commits do histórico (ex.: `git log --oneline`).
2. Conferir detalhes do commit que introduziu a alteração (`git show --stat <hash>`, `git show <hash>`).
3. Ver histórico organizado (`git log --oneline --decorate --graph --all`).
4. Pedir à IA análise do histórico e plano (prompt "listar commits").
5. Escolher o commit/tag da versão boa.
6. Executar rollback com `git revert` (cria novo commit que desfaz a alteração, preservando o histórico).
7. Se já enviado ao GitHub: `git revert <hash>` + `git push`.
8. Se já publicado em produção: reverter localmente, testar localmente, commitar, enviar ao GitHub, executar novo deploy, testar produção.
9. Documentar (STATUS.md e, se fizer sentido, ERROS.md).
10. Testar depois do rollback.

**Fluxo quando há banco de dados:**
- **Só local:** analisar; opções: reverter código com Git, desfazer migration local, recriar banco local, restaurar backup local, rodar novamente as migrations da versão anterior. Usuário deve confirmar antes de apagar/recriar banco.
- **Em produção:** análise de risco e escolha de estratégia (reverter só código; migration corretiva; restaurar backup; correção para frente). Nada de comandos destrutivos sem confirmação explícita.

## 3.3 PROMPTS COMPLETOS (transcrição verbatim)

### Prompt para pedir ajuda à IA para listar commits

> Copiar
>
> Leia `docs/STATUS.md` e me ajude a analisar o histórico do Git antes de qualquer rollback.
>
> Primeiro, liste os commits recentes usando:
>
> git log --oneline --decorate --graph --all
>
> Depois explique em linguagem simples:
>
> 1. qual é o commit atual;
> 2. quais são os commits mais recentes;
> 3. quais tags existem, se houver;
> 4. qual commit provavelmente introduziu a alteração que quero desfazer;
> 5. qual commit ou tag parece representar a versão boa anterior;
> 6. qual comando de rollback seria mais seguro;
> 7. quais riscos devo considerar antes de executar.
>
> Não faça rollback ainda.
> Apenas analise o histórico e apresente um plano.

### Prompt para pedir rollback de código por commit

> Use este prompt quando a alteração envolveu apenas código e documentação.
>
> Copiar
>
> Leia antes de agir:
>
> - `docs/MANUTENCAO.md`
> - `docs/STATUS.md`
> - `docs/ERROS.md`
>
> Preciso fazer rollback da última alteração.
>
> Cenário:
> - A alteração já foi concluída.
> - A alteração foi registrada em commit.
> - A alteração não agradou os usuários finais.
> - Quero voltar o código e a documentação para o estado anterior a essa alteração.
> - Não houve alteração de banco de dados.
>
> Antes de executar qualquer comando, analise o histórico do Git e me apresente um plano seguro.
>
> Verifique:
> 1. qual commit introduziu a alteração;
> 2. quais arquivos foram alterados;
> 3. se a alteração já foi enviada ao GitHub;
> 4. se a alteração já foi publicada em produção;
> 5. se o rollback pode ser feito com `git revert`;
> 6. quais testes devem ser feitos depois.
>
> Não use `git reset --hard` sem minha autorização explícita.
>
> Depois de aprovado, faça o rollback criando um novo commit de reversão, atualize `docs/STATUS.md`, registre o ocorrido em `docs/ERROS.md` se fizer sentido e me diga como testar.

### Prompt para rollback quando já foi para produção

> Copiar
>
> Preciso fazer rollback da última alteração que já foi publicada em produção.
>
> Leia:
>
> - `docs/MANUTENCAO.md`
> - `docs/STATUS.md`
> - `docs/ERROS.md`
> - configuração de deploy do projeto
>
> Cenário:
> - A alteração foi publicada em produção.
> - Os usuários finais não gostaram da alteração.
> - Quero voltar o código para a versão anterior.
> - Não houve alteração de banco de dados.
>
> Antes de alterar qualquer coisa, apresente um plano com:
>
> 1. commit que será revertido;
> 2. arquivos afetados;
> 3. comando Git recomendado;
> 4. testes locais necessários;
> 5. passos para enviar ao GitHub;
> 6. passos para publicar novamente em produção;
> 7. checklist pós-deploy.
>
> Use preferencialmente `git revert`, não `git reset --hard`.
>
> Depois de aprovado, faça o rollback, atualize a documentação viva e oriente o novo deploy.

### Prompt para criar tag depois de uma versão estável

> Copiar
>
> O sistema foi testado e esta versão está estável.
>
> Quero criar uma tag de versão no Git.
>
> Antes de executar, verifique:
>
> 1. se não há alterações pendentes;
> 2. qual é o último commit;
> 3. qual nome de tag faz sentido;
> 4. se a tag já existe;
> 5. se o GitHub deve receber essa tag.
>
> Sugira uma tag no formato `vX.Y.Z` e explique o significado.
>
> Depois de aprovado, crie a tag e envie para o GitHub.

### Prompt para voltar usando uma tag

> Copiar
>
> Preciso voltar o sistema para a versão marcada pela tag `v1.0.0`.
>
> Leia:
>
> - `docs/MANUTENCAO.md`
> - `docs/STATUS.md`
> - `docs/ERROS.md`
>
> Antes de executar qualquer comando, explique a estratégia mais segura para um usuário iniciante.
>
> Verifique:
>
> 1. qual é a versão atual;
> 2. qual commit está associado à tag `v1.0.0`;
> 3. quais commits existem depois dessa tag;
> 4. se é melhor usar `git revert` dos commits posteriores ou criar uma branch a partir da tag;
> 5. se a alteração já foi enviada ao GitHub;
> 6. se a alteração já foi publicada em produção;
> 7. se houve mudança de banco de dados.
>
> Não execute `git reset --hard` nem `git push --force` sem minha autorização explícita.
>
> Apresente o plano antes de alterar arquivos.

### Prompt para rollback com banco alterado apenas localmente

> Copiar
>
> Preciso fazer rollback da última alteração que mexeu no banco de dados, mas apenas no ambiente local.
>
> Leia:
>
> - `docs/MANUTENCAO.md`
> - `docs/FSD.md`
> - `docs/STATUS.md`
> - `docs/ERROS.md`
>
> Cenário:
> - A alteração não foi publicada em produção.
> - O banco de produção não foi alterado.
> - A alteração foi testada apenas na minha máquina local.
> - Quero voltar o código e o banco local para o estado anterior.
>
> Antes de executar qualquer comando, analise:
>
> 1. quais commits alteraram o código;
> 2. quais migrations, schemas, seeders ou scripts foram criados ou alterados;
> 3. se existe comando seguro de rollback da stack;
> 4. se é melhor recriar o banco local;
> 5. se há dados locais importantes que precisam de backup;
> 6. quais testes devem ser feitos depois.
>
> Não apague banco nem dados sem minha confirmação.
>
> Apresente um plano seguro primeiro.

### Prompt para rollback com banco alterado em produção

> Copiar
>
> Preciso fazer rollback da última alteração que já foi publicada em produção e alterou o banco de dados.
>
> Leia:
>
> - `docs/MANUTENCAO.md`
> - `docs/FSD.md`
> - `docs/STATUS.md`
> - `docs/ERROS.md`
> - documentação de deploy e banco do projeto
>
> Cenário:
> - A alteração foi publicada em produção.
> - O banco de produção foi alterado.
> - Usuários finais podem ter criado ou alterado dados depois da publicação.
> - A alteração não agradou e precisamos regredir com segurança.
>
> Antes de executar qualquer comando, faça uma análise de risco.
>
> Verifique:
>
> 1. quais commits fazem parte da alteração;
> 2. quais migrations, schemas, seeders, scripts ou alterações de banco foram aplicados;
> 3. se o código anterior é compatível com o banco atual;
> 4. se existem dados novos que podem ser perdidos;
> 5. se há backup de produção antes da alteração;
> 6. se é melhor reverter apenas código;
> 7. se é melhor criar uma migration corretiva;
> 8. se é necessário restaurar backup;
> 9. se é melhor aplicar uma correção para frente;
> 10. quais testes devem ser feitos antes e depois.
>
> Não apague dados.
> Não restaure backup.
> Não rode migration destrutiva.
> Não execute comandos em produção sem minha confirmação explícita.
>
> Apresente um plano seguro, com riscos, vantagens e desvantagens de cada opção.

### Prompt para documentar rollback

> Copiar
>
> Documente o rollback realizado.
>
> Atualize `docs/STATUS.md` com:
>
> - alteração revertida;
> - motivo do rollback;
> - estratégia usada;
> - impacto em código;
> - impacto em banco de dados, se houve;
> - impacto em produção, se houve;
> - testes feitos;
> - versão ativa após o rollback;
> - próximos cuidados.
>
> Se o rollback foi causado por erro, rejeição dos usuários ou problema relevante, registre também em `docs/ERROS.md` com:
>
> - Sintoma:
> - Causa:
> - Solução aplicada:
> - Como evitar no futuro:

### Prompt para sugerir próxima tag

> Copiar
>
> Quero criar uma tag para marcar a versão atual do sistema.
>
> Leia `docs/STATUS.md` e o histórico recente do Git.
>
> Verifique:
> 1. se a versão atual está estável;
> 2. qual foi a última tag;
> 3. se houve mudança grande, recurso novo ou correção pequena;
> 4. qual deveria ser o próximo número de versão;
> 5. qual mensagem descritiva usar.
>
> Não crie a tag ainda.
> Primeiro me apresente a sugestão e aguarde aprovação.

### Exemplo de pedido perigoso (evitar)

> Copiar
>
> Volte tudo como era antes.

Esse pedido é perigoso porque "tudo" pode incluir código, banco, dados reais, arquivos enviados por usuários e configuração de produção. O correto é investigar primeiro.

## 3.4 Comandos Git citados

- `git log --oneline` — lista resumida dos commits. Cada linha tem: identificador curto (hash) + mensagem. Ex.:
  ```
  h7i8j9k Ajusta documentação de manutenção
  d4e5f6g Melhora visual do Dashboard
  a1b2c3d Sistema pronto e publicado
  ```
- `git revert <hash>` — ex.: `git revert d4e5f6g`. Cria um novo commit desfazendo o commit escolhido (não apaga o histórico). Ex.: novo commit `h7i8j9k Reverte melhoria visual do Dashboard`.
- `git show --stat <hash>` — resumo dos arquivos modificados (mais fácil para iniciantes, não despeja o conteúdo).
- `git show <hash>` — alterações detalhadas.
- `git log --oneline --decorate --graph --all` — histórico resumido incluindo branches e tags. Ex.:
  ```
  * h7i8j9k (HEAD -> main) Ajusta documentação de manutenção
  * d4e5f6g (tag: v1.1.0) Melhora visual do Dashboard
  * a1b2c3d (tag: v1.0.0) Sistema pronto e publicado
  ```
  `HEAD -> main` indica onde você está agora; `tag: v1.0.0` / `tag: v1.1.0` mostram versões marcadas.
- Quando o commit já foi enviado ao GitHub: `git revert d4e5f6g` + `git push`.
- **Evitar:** `git reset --hard` e `git push --force` (podem causar confusão, principalmente quando o repositório já está no GitHub ou quando outras pessoas usam o projeto). O `git reset` é "voltar o histórico local para outro ponto. Pode ser perigoso se usado sem cuidado."
- Criar tag: `git tag -a v1.0.0 -m "Versão inicial publicada"` + `git push origin v1.0.0` (ex.: `git tag -a v1.1.0 -m "Melhoria visual do dashboard"` + `git push origin v1.1.0`).
- Olhar o projeto como estava em uma tag: `git checkout v1.0.0` — deixa o Git em estado **detached HEAD**, que confunde iniciantes; por isso, pedir ajuda à IA antes de usar.

## 3.5 Modelos/estruturas de documentos citados

- `docs/STATUS.md` — registrar: qual alteração foi revertida; por que foi revertida; qual estratégia foi usada; se afetou produção; se afetou banco; quais testes foram feitos; qual versão ficou ativa depois.
- `docs/ERROS.md` — registrar se a alteração causou problema relevante (formato: Sintoma / Causa / Solução aplicada / Como evitar no futuro).
- `docs/MANUTENCAO.md` — lido em praticamente todos os prompts de rollback.
- `docs/FSD.md` — lido nos prompts de rollback com banco (local e produção).
- Configuração de deploy do projeto e documentação de deploy e banco do projeto — citadas nos prompts de produção.

**Exemplo de registro em `docs/ERROS.md` (bloco "Copiar"):**

> ## 2026-07-03 - Rollback da melhoria visual do Dashboard
>
> - Sintoma:
> Usuários finais relataram dificuldade de navegação com a nova versão do Dashboard.
>
> - Causa:
> A nova organização visual reduziu a clareza das opções principais.
>
> - Solução aplicada:
> Foi feito rollback do commit da melhoria visual usando git revert e nova publicação em produção.
>
> - Como evitar no futuro:
> Validar mudanças visuais com usuários antes de publicar em produção.

## 3.6 Estratégias de rollback

**Regra principal do rollback:**

> Copiar
>
> Nunca faça rollback de banco de dados em produção sem backup e análise do impacto.

**Estratégia recomendada para iniciantes:**
- Para desfazer uma mudança já registrada e compartilhada, prefira `git revert`.
- Para marcar versões estáveis, use tags.
- Para voltar produção, faça novo deploy da versão revertida.
- Para banco de dados, analise separadamente.
- Isso evita apagar histórico e reduz riscos.

**Estratégias para banco local** (dependem da stack; decisão depende do projeto; usuário deve confirmar antes de apagar ou recriar banco):
- rodar rollback da última migration;
- recriar banco local;
- restaurar backup local;
- apagar apenas tabelas de teste;
- voltar código com `git revert`;
- remover migration não desejada, se ela nunca foi compartilhada;
- ajustar STATUS.md e ERROS.md.

**Possíveis estratégias em produção:**
- **Estratégia 1 — reverter apenas o código e manter o banco:** quando a nova alteração no banco não atrapalha a versão anterior (ex.: campo novo opcional que o código antigo ignora). Boa opção quando o banco novo é compatível com o código anterior.
- **Estratégia 2 — criar uma migration corretiva:** em vez de restaurar backup, criar nova migration que desfaz a mudança com segurança (ex.: marcar a coluna como descontinuada ou remover apenas se não houver dados importantes). "Remover dados em produção deve ser evitado sem análise."
- **Estratégia 3 — restaurar backup de produção:** opção mais pesada, necessária se a alteração corrompeu dados ou tornou o sistema inutilizável. Antes, avaliar: qual backup será usado; qual horário do backup; quais dados serão perdidos; se é possível exportar dados recentes antes; se usuários devem ser avisados; se existe janela de manutenção; como validar depois. Restaurar backup pode apagar dados criados depois do backup.
- **Estratégia 4 — correção para frente:** criar uma nova correção que restaure a experiência anterior sem desfazer o banco (ex.: a tela nova não agradou, o banco mudou mas não quebrou nada → voltar o layout anterior mantendo o banco). Reduz risco de perda de dados.

**O que evitar em rollback de produção:**
- rodar comandos destrutivos sem backup;
- apagar colunas com dados reais;
- restaurar backup sem avaliar perda de dados;
- usar `git reset --hard` e `push --force` sem entender impacto;
- publicar código antigo incompatível com banco novo;
- fazer deploy sem testar localmente;
- não avisar usuários quando houver risco;
- não registrar o ocorrido em STATUS.md e ERROS.md.

## 3.7 Checklists (transcritos)

### Checklist antes de escolher o commit

> Copiar
>
> [ ] Identifiquei o commit atual.
> [ ] Identifiquei o commit que introduziu a alteração ruim.
> [ ] Identifiquei o commit ou tag da versão boa anterior.
> [ ] Verifiquei quais arquivos foram alterados.
> [ ] Confirmei se houve alteração de banco de dados.
> [ ] Confirmei se a alteração já foi enviada ao GitHub.
> [ ] Confirmei se a alteração já foi publicada em produção.
> [ ] Pedi um plano antes de executar comandos.

"Essa etapa evita que você reverta o commit errado."

### Checklist antes de fazer rollback

> Copiar
>
> [ ] Sei qual alteração precisa ser revertida.
> [ ] Sei qual commit ou tag representa a versão boa.
> [ ] Sei se a alteração foi enviada ao GitHub.
> [ ] Sei se a alteração foi publicada em produção.
> [ ] Sei se houve alteração de banco de dados.
> [ ] Sei se usuários criaram dados depois da alteração.
> [ ] Existe backup, se produção estiver envolvida.
> [ ] A IA apresentou plano antes de executar.
> [ ] Não há comando destrutivo sem confirmação.
> [ ] Sei como testar depois do rollback.

### Checklist depois do rollback

> Copiar
>
> [ ] O código voltou ao comportamento esperado.
> [ ] A interface voltou ao estado desejado.
> [ ] O banco continua compatível.
> [ ] O sistema abre localmente.
> [ ] Os principais fluxos funcionam.
> [ ] O Git tem commit do rollback.
> [ ] O GitHub recebeu o rollback.
> [ ] Produção foi atualizada, se necessário.
> [ ] Produção foi testada.
> [ ] STATUS.md foi atualizado.
> [ ] ERROS.md foi atualizado, se necessário.
> [ ] Uma tag de versão foi criada, se fizer sentido.

## 3.8 Sugestão de rotina com tags

Criar tags em versões importantes facilita rollback no futuro. Exemplo de rotina:

> v1.0.0 - primeira versão publicada
> v1.1.0 - melhoria no dashboard
> v1.2.0 - novo relatório mensal
> v1.2.1 - correção pequena

**Padrão simples:** `vMAIOR.MENOR.CORRECAO`

- MAIOR: mudança grande;
- MENOR: novo recurso ou melhoria;
- CORRECAO: ajuste pequeno ou correção.

Exemplos:
- `v1.0.0` — primeira versão estável.
- `v1.1.0` — nova melhoria ou recurso.
- `v1.1.1` — correção pequena.

## 3.9 Vocabulário especializado (tabela Termo/Explicação)

| Termo | Explicação simples |
|---|---|
| Rollback | Voltar o sistema para uma versão anterior. |
| Regressão | Retorno para um estado anterior, geralmente porque uma mudança não funcionou bem. |
| Commit | Registro de uma alteração no Git. |
| Hash do commit | Código identificador de um commit. |
| Tag | Nome dado a uma versão importante do projeto, como v1.0.0. |
| Produção | Ambiente usado pelos usuários reais. |
| Banco de dados | Local onde o sistema guarda informações. |
| Migration | Arquivo ou mecanismo usado para alterar a estrutura do banco. |
| Backup | Cópia de segurança usada para recuperar dados. |
| Revert | Criar um novo commit que desfaz alterações anteriores. |
| Reset | Voltar o histórico local para outro ponto. Pode ser perigoso se usado sem cuidado. |

## 3.10 Erros comuns e como resolver

| Erro comum | Como resolver |
|---|---|
| Pedir "Volte tudo como era antes." | Investigar primeiro (responder as 9 perguntas da seção "Antes de tudo: não entre em pânico") antes de qualquer rollback. |
| Rollback de banco em produção sem backup/análise | Regra principal: nunca faça rollback de banco em produção sem backup e análise do impacto. |
| Reverter o commit errado | Usar o checklist "antes de escolher o commit"; conferir com `git show --stat <hash>` qual commit introduziu a alteração. |
| Apagar histórico (git reset --hard / push --force) | Preferir `git revert`; nunca usar `git reset --hard` sem autorização explícita; para iniciantes a orientação mais segura é `git revert` + novo commit + `git push`. |
| Achar que produção volta sozinha com rollback local | A produção não volta sozinha só porque você fez rollback no Git local — é preciso publicar novamente a versão revertida (deploy). |
| Restaurar backup antigo e perder dados criados depois | Avaliar perda de dados antes; considerar exportar dados recentes; considerar estratégias de migration corretiva ou correção para frente. |
| Banco novo incompatível com código antigo | Analisar compatibilidade código x banco; escolher entre reverter só código, migration corretiva, restaurar backup ou correção para frente. |
| Rollback sem documentar | Documentar em STATUS.md (alteração revertida, motivo, estratégia, impactos, testes, versão ativa) e em ERROS.md (Sintoma/Causa/Solução/Como evitar). |
| Tags desatualizadas ou inexistentes | Usar o prompt "sugerir próxima tag"; padrão vMAIOR.MENOR.CORRECAO; criar tag após versões estáveis. |

## 3.11 Fechamento do capítulo (mensagens-chave)

- Rollback não é sinal de fracasso; é parte normal da manutenção de sistemas.
- A regra principal: **Código pode voltar com Git. Banco de dados só volta com análise, backup e cuidado.**
- Rollback não deve ser improvisado. Rollback deve ser **planejado, testado, documentado e versionado.**

---

# 4. Itens acionáveis (documentos, pastas, comandos e prompts que o desenvolvedor precisa executar)

**Documentos/pastas que devem existir no projeto** (referenciados pelos prompts):
- `AGENTS.md` (raiz)
- `docs/MANUTENCAO.md`
- `docs/FSD.md`
- `docs/STATUS.md`
- `docs/ERROS.md`
- `docs/INSUMOS.md` (citado no alinhamento de documentação)
- `docs/DESIGN.md` (citado no alinhamento de documentação)
- Configuração de deploy do projeto e documentação de deploy/banco do projeto (usados nos prompts de rollback em produção).

**Comandos Git para o fluxo de manutenção/rollback:**
- `git log --oneline`
- `git show --stat <hash>`
- `git show <hash>`
- `git log --oneline --decorate --graph --all`
- `git revert <hash>` (com `git push` se já enviado ao GitHub)
- `git tag -a <versão> -m "<mensagem>"` + `git push origin <versão>`
- `git checkout <tag>` — cuidado: detached HEAD (pedir ajuda à IA)
- Evitar: `git reset --hard`, `git push --force` (sem autorização explícita).

**Prompts a executar (na ordem de uso):**

Para pedir alteração (cap. 13):
1. Primeiro prompt: pedido principal de alteração (chat novo, sem raciocínio; anexar print no segundo prompt).
2. Segundo prompt: ajuste com base nas imagens (com print da tela anexado).
3. Terceiro prompt: alinhamento de documentação.
4. Quarto prompt: verificar commit.
5. Prompt de apoio: roteiro de teste manual.

Para rollback (cap. 14):
1. Prompt para pedir ajuda à IA para listar commits.
2. Prompt para pedir rollback de código por commit (alteração apenas código/documentação).
3. Prompt para rollback quando já foi para produção.
4. Prompt para criar tag depois de uma versão estável.
5. Prompt para voltar usando uma tag.
6. Prompt para rollback com banco alterado apenas localmente.
7. Prompt para rollback com banco alterado em produção.
8. Prompt para documentar rollback.
9. Prompt para sugerir próxima tag.

**Rotina sugerida:** criar tag após cada versão estável (`vMAIOR.MENOR.CORRECAO`), documentar rollback em STATUS.md e ERROS.md, testar localmente antes de qualquer deploy de rollback, e avisar usuários quando houver risco em produção.

---

# 5. Notas sobre conteúdo ausente

- **Não presente neste grupo:** comandos avançados de Git (o capítulo 14 declara explicitamente que o objetivo não é ensinar todos os comandos avançados do Git); instruções de como executar deploy (apenas referencia "configuração de deploy do projeto"); nenhum capítulo traz um template de arquivo pronto para STATUS.md/ERROS.md (apenas listas de campos e um exemplo de entrada de ERROS.md); não há checklists na forma de arquivo — todos os checklists aparecem como listas no texto (transcritos acima).

