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
5. Instale as ferramentas de economia de tokens (passo obrigatório, ver abaixo).
6. Digite `/jornada-vibe-coding` para ligar a metodologia.

## Opção B — recebi uma pasta ou um arquivo .zip

1. Descompacte o arquivo (se for `.zip`), clicando duas vezes nele.
2. Abra o Terminal e arraste para dentro dele o arquivo `instalar.sh` que está na pasta. Aperte Enter.
3. Feche e abra o Claude Code.
4. Instale as ferramentas de economia de tokens (passo obrigatório, ver abaixo).
5. Digite `/jornada-vibe-coding` para ligar a metodologia.

A Opção B copia as skills para dentro de `~/.claude/skills/` e adiciona os dois hooks no seu `~/.claude/settings.json`. O script faz uma cópia de segurança do `settings.json` antes de mexer nele.

## Passo obrigatório — as ferramentas de economia de tokens

A metodologia usa sete ferramentas que fazem o Claude gastar muito menos. Sem elas ele lê arquivos inteiros e a conta fica cara.

**Cinco delas se instalam pelo Terminal.** Se você instalou pela Opção A, primeiro baixe a pasta:

```bash
git clone https://github.com/kairoxaioficial/jornada-vibe-coding-plugin
cd jornada-vibe-coding-plugin
bash scripts/instalar-ferramentas.sh
```

Se você instalou pela Opção B, é só entrar na pasta que você descompactou e rodar a última linha.

O script pergunta nada: ele instala o que falta e pula o que já existe. Para só conferir sem instalar nada:

```bash
bash scripts/instalar-ferramentas.sh --check
```

**As outras duas são plugins**, e se instalam dentro do Claude Code. Cole um comando de cada vez:

```
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
/plugin marketplace add JuliusBrussee/caveman
/plugin install caveman@caveman
```

Se algo falhar aqui, não tem problema: **o plugin baixa sozinho**. Toda vez que você abre o Claude Code, ou liga a metodologia, ele confere o que falta e instala em segundo plano (no máximo uma vez por dia). O que ele não consegue fazer sozinho são os dois plugins acima, porque só o Claude Code instala plugin.

Enquanto a metodologia estiver ligada, o Claude fica **proibido** de ler o código arquivo por arquivo antes de mapear o projeto pelo grafo — é o que faz a economia acontecer de verdade, sem depender de ele lembrar.

## Como saber se funcionou

Digite `/jornada-vibe-coding` no Claude Code. Se a metodologia ligar e ele responder sobre o protocolo de fases, está tudo certo.

## Como desligar

- Só na conversa atual: `/jornada-vibe-coding off`.
- Remover de vez (Opção A): `/plugin uninstall jornada-vibe-coding@jornada`.
- Remover de vez (Opção B): apague as pastas `~/.claude/skills/jornada-vibe-coding` e `~/.claude/skills/estruturar-projeto` e restaure o backup do `settings.json`.
