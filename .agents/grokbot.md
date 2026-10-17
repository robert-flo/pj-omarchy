# Adaptador Grok Bot

El trío de este proyecto también corre como bots de Grok Bot, sin reglas propias: leen exactamente las mismas fichas, reglas y skills que agy y Cursor.

## Dónde clonar (en el box)

```bash
mkdir -p /workspace/pj-<proyecto>
gh repo clone robert-flo/pj-<proyecto> /workspace/pj-<proyecto>/pj-<proyecto>
cd /workspace/pj-<proyecto>/pj-<proyecto> && ./clone-repos.sh   # repos hijos, adentro del meta-repo
```

Para este proyecto: `/workspace/pj-omarchy/pj-omarchy/`. El box es una sola máquina para todos los bots de Roberto: los tres roles comparten ese clon (el WK trabaja en worktrees `.wt-*`, como en cualquier máquina).

## La instrucción de cada bot

Un bot por rol. Su instrucción es solo esto, cambiando `<ROL>`:

> Tus instrucciones viven en `/workspace/pj-omarchy/pj-omarchy/.agents/agents/<ROL>-pj-omarchy.md`, leélas. Si el clon no existe, clonalo como dice `.agents/grokbot.md` de `robert-flo/pj-omarchy`.

Nada más: rol, reglas, colas y relevo salen de esa ficha y de lo que manda a leer (`.agents/reglas/`, `AGENTS.md`).

## Qué cambia en Grok Bot

- Ignorás el frontmatter de agy (`tools`, `skills`, `commandExecutionPolicy`, `mainAgent`/`subagent`). Las skills las leés de `.agents/skills/<skill>/SKILL.md`.
- No hay `invoke_subagent`. El PM no lanza a nadie: pone la etiqueta-cola y deja el relevo; el bot del otro rol lo toma al arrancar (`AGENTS.md` §7).
- `comun.md` §La máquina aplica igual: el box es una máquina más. Las pruebas que necesitan un escritorio o hardware que el box no tiene quedan como bloqueo en el relevo, para Roberto.
- En el relevo, `Plataforma: Grok Bot`.
- Mismas reglas de siempre: GitHub es la fuente de verdad, solo Roberto ordena el merge (squash), nunca `push --force`, nada de secretos en el repo.
