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

Nada más: rol y reglas salen de esa ficha y de lo que manda a leer (`.agents/reglas/`, `AGENTS.md`).

## Qué cambia en Grok Bot

- Ignorás el frontmatter de agy (`tools`, `skills`, `commandExecutionPolicy`, `mainAgent`/`subagent`). Las skills las leés de `.agents/skills/<skill>/SKILL.md`.
- No hay `invoke_subagent`: el encargo queda en GitHub (el comentario del PM en el spec o el PR) y el bot del otro rol lo toma de ahí.
- Mismas reglas de siempre (`comun.md`, `<rol>.md`), sin cambios: §Tu PC aplica igual en el box (sudo, cambios al sistema con respaldo y bitácora en `CAMBIOS.md` junto al clon del meta-repo). Mismo comportamiento en toda máquina.
