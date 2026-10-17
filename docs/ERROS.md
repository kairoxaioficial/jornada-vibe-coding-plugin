# ERROS — Registro de Erros e Correções

> Projeto: plugin Jornada IA Vibe Coding (`jornada-vibe-coding-plugin`)
> Regra: todo erro entra aqui, mesmo já corrigido, com causa e correção. Consultar este arquivo ANTES de corrigir um erro novo.

## Modelo de registro (copie para um erro novo)

### ERRO-NNN: título curto
- **Data:** DD/MM/AAAA
- **Etapa:** número e nome da etapa do `docs/PLANO.md`
- **Erro exato:** mensagem ou comportamento observado, copiado como apareceu
- **Causa:** por que aconteceu
- **Correção:** o que foi feito
- **Como evitar:** regra prática para não repetir
- **Status:** corrigido | em aberto

## Log de erros

| # | ID | Data | Etapa | Título | Status |
|---|----|------|-------|--------|--------|
| 1 | ERRO-001 | 16/10/2026 | 2 | Teste "sem ponytail" acusou o nome da função da regra | corrigido |
| 2 | ERRO-002 | 16/10/2026 | 3 | `instalar.sh` registrava a trava de leitura sem o `Bash` | corrigido |
| 3 | ERRO-003 | 16/10/2026 | 3 | Teste "sem ponytail" acusou a nova seção do SKILL.md | corrigido |
| 4 | ERRO-004 | 16/10/2026 | 6 | Comando `timeout` não existe no macOS (teste real do executor) | corrigido |
| 5 | ERRO-005 | 17/10/2026 | 9 | Detector de esforço levava 3,5 s num histórico de 20 MB | corrigido |
| 6 | ERRO-006 | 17/10/2026 | 9 | Notificação de tarefa com caminho "jornada-vibe-coding" ligou a Jornada | corrigido |

### ERRO-006: notificação de tarefa ligou a Jornada (caminho com jornada-vibe-coding)
- **Data:** 17/10/2026
- **Etapa:** 9 (achado na revisão do Opus)
- **Erro exato:** quando chegou a notificação do executor, cujo texto citava `skills/jornada-vibe-coding/scripts/...`, o hook respondeu `[jornada-vibe-coding] MODO METODOLOGIA ATIVADO (sessao + projeto /Users/adriel/jornada-vibe-coding-plugin).`
- **Causa:** o `jornada-context.sh` procurava `/jornada-vibe-coding` em qualquer lugar do texto, e as notificações de tarefas em segundo plano também passam pelo UserPromptSubmit. Pelo mesmo caminho, um relatório de agente que citasse `/jornada-vibe-coding off` desligaria as travas da sessão.
- **Correção:** notificação (`<task-notification>`) não liga nem desliga; caminhos de arquivo com `jornada-vibe-coding` são retirados do texto antes da comparação; 4 testes novos (os 3 primeiros reprovam sem a correção).
- **Como evitar:** ligar e desligar só por texto do usuário; nunca casar o nome da skill dentro de caminhos.
- **Status:** corrigido

### ERRO-005: detector de esforço lento em histórico grande (grep depois de pipe no macOS)
- **Data:** 17/10/2026
- **Etapa:** 9
- **Erro exato:** `FALHA esforco: transcript de 20 MB em 3518 ms` (limite do teste: 1000 ms)
- **Causa:** a primeira versão fazia `tail -c +N arquivo | grep -a -F ...`; o grep do macOS lê muito mais devagar de pipe (1,2 s em 20 MB) do que de arquivo redirecionado (0,06 s).
- **Correção:** `grep -a -b -F '<local-command-stdout>' < arquivo` (o `-b` dá o byte inicial de cada linha) e um `awk` filtra as linhas a partir do ponto gravado; a busca do modelo usa só os últimos 2 MB. Medido: 168 a 206 ms em 20 MB.
- **Como evitar:** em arquivo grande, ler direto com `< arquivo`, não por pipe; medir com histórico sintético de 20 MB.
- **Status:** corrigido

### ERRO-004: comando `timeout` não existe no macOS
- **Data:** 16/10/2026
- **Etapa:** 6 — teste real do executor numa sessão `claude -p`
- **Erro exato:** `(eval):1: command not found: timeout` (saída 127)
- **Causa:** `timeout` é do GNU coreutils; o macOS não traz.
- **Correção:** o teste rodou sem `timeout`, em segundo plano, com o limite de tempo da própria ferramenta.
- **Como evitar:** em scripts para macOS, não depender de `timeout`; usar `gtimeout` só se o coreutils estiver instalado.
- **Status:** corrigido

### ERRO-002: `instalar.sh` registrava a trava de leitura sem o `Bash`
- **Data:** 16/10/2026
- **Etapa:** 3 (achado ao ler o instalador no cold start)
- **Erro exato:** `instalar.sh` registrava `PreToolUse` com matcher `Read|Grep|Glob`, enquanto `hooks/hooks.json` (plugin) usa `Read|Grep|Glob|Bash` desde a versão 1.1.0.
- **Causa:** a versão 1.1.0 ("trava cobre o terminal") atualizou só o `hooks.json`.
- **Correção:** matcher do `instalar.sh` passou a `Read|Grep|Glob|Bash`. Instalações antigas já registradas não são alteradas pelo instalador (ele só acrescenta hook que falta); na máquina do usuário o `settings.json` já estava com `Bash`.
- **Como evitar:** toda mudança de hook vale nos dois lugares — `hooks/hooks.json` e a lista `HOOKS` do `instalar.sh`.
- **Status:** corrigido

### ERRO-003: teste "sem ponytail" acusou a nova seção do SKILL.md
- **Data:** 16/10/2026
- **Etapa:** 3
- **Erro exato:** `FALHA skills e scripts sem ponytail: .../SKILL.md:89:Com a Jornada ativa, o ponytail não é usado — ...`
- **Causa:** a frase não continha "desligado", que é o que o teste exige em toda menção.
- **Correção:** frase reescrita como "o ponytail fica desligado".
- **Como evitar:** mesmo do ERRO-001.
- **Status:** corrigido

### ERRO-001: teste "sem ponytail" acusou o nome da função da regra
- **Data:** 16/10/2026
- **Etapa:** 2 — Tirar o ponytail
- **Erro exato:** `FALHA skills e scripts sem ponytail: .../jornada-lib.sh:156:  jornada_regra_ponytail`
- **Causa:** o teste aceita a palavra "ponytail" só em linha que também diga "desligado"; a função se chamava `jornada_regra_ponytail`.
- **Correção:** função renomeada para `jornada_regra_ponytail_desligado`.
- **Como evitar:** qualquer menção ao ponytail em skills e scripts deve deixar claro que ele está desligado.
- **Status:** corrigido

## Erros conhecidos — padrões para evitar

(vazio)
