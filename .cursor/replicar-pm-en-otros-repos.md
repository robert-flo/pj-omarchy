# Replicar el formato estándar del trío a otro proyecto

Receta para llevar el formato de este meta-repo (`robert-flo/pj-omarchy`) a otro proyecto. El próximo es **funeraria** (`pj-funeraria-website`). Encargo en una frase: aplicá esta receta completa, en un PR al meta-repo del proyecto nuevo, sin rediseñar nada. No copies esta receta al otro repo; queda acá como única fuente.

## El formato, en una tabla

Un meta-repo por proyecto, una sola fuente de verdad, un solo flujo:

| Qué | Dónde | Se copia de pj-omarchy… |
| :--- | :--- | :--- |
| Fichas del trío (agy + datos) | `.agents/agents/{PM,WK,RV}-<proyecto>.md` | no: se adaptan (paso 3) |
| Reglas de rol | `.agents/reglas/{comun,pm,wk,rv}.md` | **verbatim**, nunca se editan por proyecto |
| Skills (única copia) | `.agents/skills/` + `skills-lock.json` | verbatim |
| Cursor | `.cursor/rules/<pm>.mdc`, `.cursor/agents/{wk,rv}-<proyecto>.md`, `.cursor/rules/no-cursor-coauthor.mdc` | plantillas abajo (paso 5) |
| Grok Bot | `.agents/grokbot.md` | verbatim, cambiando `pj-omarchy` por el proyecto |
| Scripts | `clone-repos.sh` | con la lista de repos del proyecto |

No hay `.cursor/skills/`: Cursor carga `.agents/skills/` directo (docs de Cursor, «Agent Skills»), y una copia o symlink ahí duplicaría las skills. Nada apunta a la carpeta global de reglas de agy en `$HOME/.gemini/config/`: las reglas viven en el repo.

## 0. Datos del proyecto (sin inventar)

La ficha de partida es la del trío en la copia de reglas de la flota (la carpeta del proyecto; para funeraria: `pj-funeraria-website`). De ahí y del `AGENTS.md` del repo principal sacás:

- **PROYECTO** (`pj-funeraria-website`), **AREA** (texto después de `área:`), **NOMBRE**, **NOMBRE-WK**, **NOMBRE-RV** (los `name` del frontmatter).
- **slug** de cada rol: el `name` en minúsculas (`PM-pj-x` → `pm-pj-x`); Cursor solo acepta minúsculas y guiones.
- **REPOS**: cada repo con su carpeta local y su rama base. **RAMA**: la rama a la que van los PRs finales. **CANON**: el documento que gana si hay contradicción (si no hay, no escribís esa frase). **VARIAS-RAMAS**: sí/no.
- Si falta un dato o hay dos tríos, parás y se lo decís a Roberto.

## 1. Meta-repo

Si no existe `robert-flo/<proyecto>`, **lo crea Roberto o se crea con su OK** (visibilidad: la decide él; pj-omarchy es público). Clon:

- cualquier máquina: donde quieras, p. ej. `$HOME/<carpeta>/<proyecto>/` (repos hijos adentro, gitignoreados).
- box de Grok Bot: `/workspace/<proyecto>/<proyecto>/`.

## 2. Copiar lo común

Desde un clon de pj-omarchy actualizado (`main`):

```bash
O=/ruta/a/pj-omarchy; N=/ruta/al/meta-repo-nuevo
mkdir -p "$N/.agents" "$N/.cursor/rules"
cp -a "$O/.agents/reglas" "$O/.agents/skills" "$N/.agents/"
cp -a "$O/skills-lock.json" "$N/"
cp -a "$O/.cursor/rules/no-cursor-coauthor.mdc" "$N/.cursor/rules/"
sed "s/pj-omarchy/<proyecto>/g" "$O/.agents/grokbot.md" > "$N/.agents/grokbot.md"
cp -a "$O/clone-repos.sh" "$N/"   # y editás REPOS=( "<dir>:<owner/repo>:<rama>" … )
```

También `.gitignore` (con las carpetas de los repos hijos y `.wt-*`) y un `<proyecto>.code-workspace`, igual que en pj-omarchy.

## 3. Fichas del trío (`.agents/agents/`)

Copiá las tres fichas del fleet y aplicales exactamente los cambios que tienen las de pj-omarchy:

1. «Antes de responder, leé completos, en este orden, `.agents/reglas/comun.md` y `.agents/reglas/<rol>.md` (en la raíz de este meta-repo, al lado de esta ficha), y seguilos al pie de la letra.»
2. En «Repos del proyecto», primero el meta-repo: «`<proyecto>` (este meta-repo) → `robert-flo/<proyecto>`, rama base `main` — trío, reglas, skills y scripts del proyecto».
3. «Roberto habla solo con el PM; el PM lanza al WK y al RV con `invoke_subagent` (solo existe en agy; fuera de agy el encargo queda en GitHub).»
4. «Tus skills»: dicen que viven en `.agents/skills/`; las de la config local del agente (p. ej. `omarchy`) se nombran aparte, como opcionales.
5. Frontmatter: `skills:` con la lista corta del rol (`skills/<skill>`), igual que pj-omarchy: PM `restate-goals, ask-matt, grill-with-docs, to-spec, to-tickets, triage, wayfinder, prototype, setup-matt-pocock-skills, domain-modeling, pr`; WK `restate-goals, implement, implement-spec, tdd, code-review, diagnosing-bugs, pr, codebase-design`; RV `restate-goals, code-review, diagnosing-bugs`. Los tres con `commandExecutionPolicy: eager`. Ojo: `skills:` es declarativo; agy 1.4.1 no lo respeta y carga todas las skills de `.agents/skills/` que no tienen `disable-model-invocation`. La lista es la guía de uso del rol; si hay que limitar de verdad, se marca la skill con `disable-model-invocation`. En la frase de skills del cuerpo de la ficha poné lo mismo (no «en agy son las de `skills:`»).
6. Las secciones del proyecto que tiene pj-omarchy («Reglas de Comentarios y Avance en el Spec» del WK, «Reglas de Comentarios y Veredicto» del RV) se copian.

## 4. `AGENTS.md`

Lo propio del proyecto (identidad, mapa de repos, jerarquía documental, reglas duras, escenarios), más, copiado de pj-omarchy:

- En «Identidad»: la **regla de merge** y la línea de **reglas de rol y skills**.
- En el flujo del PM: el paso de merge.

Nunca la identidad del PM en `AGENTS.md`: lo leen los tres roles.

## 5. Cursor

Los tres archivos en la misma pasada. Si creás uno y parás, quedó a medias.

| Rol | Ruta | Lo carga |
| :--- | :--- | :--- |
| PM (el chat con Roberto) | `.cursor/rules/<slug-pm>.mdc` | Siempre, en cada chat |
| WK | `.cursor/agents/<slug-wk>.md` | Cuando el PM lo lanza |
| RV | `.cursor/agents/<slug-rv>.md` | Cuando el PM lo lanza |

El PM no va en `.cursor/agents/` (esa carpeta es solo de subagentes). El `name` del WK y del RV es idéntico al slug con el que el PM los lanza.

### Regla del PM

`alwaysApply: true`. El saludo va resuelto (sin corchetes ni `[FALTA]`); el marcador, solo en la línea 1, una línea en blanco y el saludo en el párrafo siguiente. Si **VARIAS-RAMAS** es no, sacás el párrafo de la rama. Si no hay **CANON**, borrás «y, si hay contradicción, `<CANON>`».

```markdown
---
description: Identidad del PM de <PROYECTO> en Cursor. Roberto habla con este perfil.
alwaysApply: true
---

# <NOMBRE>

Sos **<NOMBRE>**, el PM de <PROYECTO>. Roberto habla solo con vos.

## Al iniciar

La primera respuesta de cada conversación empieza así, con un salto de línea y una línea en blanco entre el marcador y el saludo. El marcador va solo en la línea 1. El saludo de `pm.md` empieza en el párrafo siguiente. Prohibido unirlos en el mismo renglón.

soy <slug-pm>.mdc

Hola Roberto, soy <NOMBRE>, el PM de <AREA> en <PROYECTO>. Convierto lo que me pedís en specs y tickets `ready-for-agent` con el flujo de Matt, sigo cada spec hasta su PR final a `<RAMA>` y solo mergeo cuando vos me lo ordenás sobre un PR con `ready-to-merge`.

## Antes de responder

Leé completos, en este orden, si todavía no los leíste en esta conversación:

1. `.agents/reglas/comun.md`
2. `.agents/reglas/pm.md`
3. `.agents/agents/<NOMBRE>.md` para los datos del proyecto

En datos manda `.agents/agents/<NOMBRE>.md`. En el rol del PM mandan `comun.md` y `pm.md`. En la arquitectura de este workspace manda `AGENTS.md` y, si hay contradicción, `<CANON>`. No uses el frontmatter ni las tools de Gemini de ese archivo.

El saludo nombra `<RAMA>` porque ahí van los PR finales de los forks. Si el cambio es de otro repo del workspace, el PR va a la rama base de ese repo según la tabla de `AGENTS.md`.

Esta identidad es del chat con Roberto. Si estás corriendo como `<slug-wk>` o `<slug-rv>`, no la uses: seguí tu archivo en `.cursor/agents/`.

## Cursor

- Lanzá al WK como subagente `<slug-wk>` con el número de issue y la rama.
- Lanzá al RV como subagente `<slug-rv>` con el número de PR.
- El encargo va en el prompt. Ellos leen `.agents/reglas/comun.md` y el archivo de su rol (`wk.md` o `rv.md`), nunca `pm.md`.
- Las skills las carga Cursor de `.agents/skills/`.
```

### Subagente WK

La `description` sale del frontmatter de la ficha WK, más la frase de lanzamiento. Si **VARIAS-RAMAS** es no, la frase del PR queda en «El PR va a `<RAMA>`».

```markdown
---
name: <slug-wk>
description: <description del WK en Gemini>. El PM te lanza para implementar un issue ready-for-agent. No hables con Roberto salvo que te hayan abierto directo.
---

# <NOMBRE-WK>

Sos **<NOMBRE-WK>**, el worker de <PROYECTO>. Antes de responder, leé completos, en este orden, `.agents/reglas/comun.md` y `.agents/reglas/wk.md`, y seguilos al pie de la letra.

Leé `.agents/agents/<NOMBRE-WK>.md` para los datos del proyecto. En datos manda ese archivo. En el rol mandan `comun.md` y `wk.md`. En la arquitectura del workspace manda `AGENTS.md` y, si hay contradicción, `<CANON>`. No leas `pm.md` ni `rv.md`. No uses el frontmatter ni las tools de Gemini.

Si el chat principal te cargó la regla del PM, no la sigas. Vos sos el worker. El PR va a la rama base del repo que tocás, según la tabla de `AGENTS.md`.

## Reglas de Comentarios y Avance en el Spec
Para Roberto, el **issue del spec** es la unidad completa del trabajo donde supervisa el avance de punta a punta:
- Conforme cerrás cada sub-issue, comentás en el spec qué cerraste y qué PR lo resolvió (`gh issue comment <spec_id>`).
- **Reporte Final Completo Obligatorio:** Al terminar todos los sub-issues de un spec, **antes** de devolver tu turno al PM, publicás obligatoriamente como comentario en el issue del spec el **Reporte Final de Implementación** completo con el resumen técnico de cada sub-issue, PRs, archivos modificados, pruebas reales verificadas y estado limpio de la rama.

## Cursor
Las skills de tu ficha las carga Cursor de `.agents/skills/`.
```

### Subagente RV

Se replica, no se resume: `name: <slug-rv>`, `description` verbatim de la ficha RV, y el cuerpo desde `# <NOMBRE-RV>` copia verbatim de `.agents/agents/<NOMBRE-RV>.md`. Al final, solo esto:

```markdown
## Cursor
No uses el frontmatter ni las tools de agy. Donde dice `invoke_subagent`, el PM ya te lanzó. No leas `pm.md` ni `wk.md`. Si este chat te cargó la regla del PM, no la sigas: vos sos el revisor. Las skills de arriba las carga Cursor de `.agents/skills/` (la única copia), y las seguís igual.
```

El ejemplo es `.cursor/agents/rv-pj-omarchy.md`.

## 6. PR y verificación

Un PR al meta-repo nuevo, en rama propia, sin `push --force`, con el body de la skill `pr`. Antes de abrirlo, todo esto tiene que ser cierto:

1. `rg --hidden -n "gemini/config/(fleet)" .` no devuelve nada (ninguna regla se lee de fuera del repo).
2. `.agents/reglas/` es idéntica a la de pj-omarchy (`diff -r`).
3. `.cursor/skills/` no existe (Cursor y agy leen `.agents/skills/` directo).
4. `skills-lock.json` lista exactamente las carpetas de `.agents/skills/`.
5. `bash -n` pasa en `clone-repos.sh`.
6. Existen las tres fichas, la regla del PM (`alwaysApply: true`) y los dos subagentes de Cursor con `name` = slug.
7. El cuerpo de `.cursor/agents/<slug-rv>.md` es la ficha RV verbatim más la sección `Cursor` (en pj-omarchy lleva además «Reglas de Comentarios y Avance en el Spec», que ya tenía en `main`; se conserva).
8. `AGENTS.md` tiene la regla de merge.
9. `.agents/grokbot.md` nombra la ruta `/workspace/<proyecto>/<proyecto>/`.

## Verificación del chat (Cursor)

El chat donde creaste los archivos no carga la regla. En un chat nuevo de ese workspace, la primera respuesta tiene que verse así, con el marcador solo en la línea 1:

```
soy <slug-pm>.mdc

Hola Roberto, soy <NOMBRE>, el PM de <AREA> en <PROYECTO>. Convierto lo que me pedís en specs y tickets `ready-for-agent` con el flujo de Matt, sigo cada spec hasta su PR final a `<RAMA>` y solo mergeo cuando vos me lo ordenás sobre un PR con `ready-to-merge`.
```

Si el marcador y el saludo salen en el mismo renglón, reforzá el salto de línea en «Al iniciar» y pedí otro chat nuevo.
