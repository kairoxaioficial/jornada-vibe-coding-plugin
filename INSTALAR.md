# Como instalar (passo a passo, sem enrolação)

## Opção A — pelo GitHub (mais fácil)

1. Abra o Claude Code no terminal.
2. Cole isto e aperte Enter:

   ```
   /plugin marketplace add kairoxaioficial/jornada-vibe-coding-plugin
   ```

3. Cole isto e aperte Enter:

   ```
   /plugin install jornada-vibe-coding@jornada
   ```

4. Feche e abra o Claude Code de novo.
5. Digite `/jornada-vibe-coding` para ligar a metodologia.

## Opção B — recebi uma pasta ou um arquivo .zip

1. Descompacte o arquivo (se for `.zip`), clicando duas vezes nele.
2. Abra o Terminal e arraste para dentro dele o arquivo `instalar.sh` que está na pasta. Aperte Enter.
3. Feche e abra o Claude Code.
4. Digite `/jornada-vibe-coding` para ligar a metodologia.

A Opção B copia as skills para dentro de `~/.claude/skills/` e adiciona os dois hooks no seu `~/.claude/settings.json`. O script faz uma cópia de segurança do `settings.json` antes de mexer nele.

## Como saber se funcionou

Digite `/jornada-vibe-coding` no Claude Code. Se a metodologia ligar e ele responder sobre o protocolo de fases, está tudo certo.

## Como desligar

- Só na conversa atual: `/jornada-vibe-coding off`.
- Remover de vez (Opção A): `/plugin uninstall jornada-vibe-coding@jornada`.
- Remover de vez (Opção B): apague as pastas `~/.claude/skills/jornada-vibe-coding` e `~/.claude/skills/estruturar-projeto` e restaure o backup do `settings.json`.
