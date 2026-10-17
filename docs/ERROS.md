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
