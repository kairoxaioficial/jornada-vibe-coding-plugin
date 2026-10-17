# DESIGN — Padrão visual

> Projeto: plugin Jornada IA Vibe Coding (`jornada-vibe-coding-plugin`)
> Última atualização: 16/10/2026

## 1. Identidade visual

O plugin não tem interface gráfica: não há telas, cores, fontes nem componentes. Tudo o que ele "mostra" são textos no terminal do Claude Code e textos injetados no contexto do modelo. Esta seção registra o padrão desses textos.

## 2. Mensagens para o usuário (terminal)

- Prefixo entre colchetes com o nome do plugin: `[jornada-vibe-coding] ...` (origem: `scripts/jornada-context.sh`).
- Uma linha por aviso; o que fazer vem na mesma linha.
- Mensagens de bloqueio dizem o que falta e a ordem para resolver (origem: `scripts/jornada-guard.sh`).

## 3. Textos injetados no contexto do modelo

- Bloco delimitado por `<metodologia-jornada-vibe-coding ...>` e `</metodologia-jornada-vibe-coding>`.
- Sem acentos dentro dos scripts (compatibilidade de terminal); documentos `.md` usam português normal, com acentos.
- Dois tamanhos a partir da versão 1.2.0: bloco completo (protocolo P0–P8 inteiro) e bloco curto (estado dos documentos e lembretes essenciais).

## 4. Documentos

- Português do Brasil, por extenso, sem compressão (regra da metodologia).
- Checklists sempre em linguagem leiga, no formato "ação → resultado esperado".

## 5. Responsividade e acessibilidade

Não se aplica (sem interface gráfica).
