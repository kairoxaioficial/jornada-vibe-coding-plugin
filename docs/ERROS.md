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
