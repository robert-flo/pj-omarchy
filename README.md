# pj-omarchy

Meta-repo del trío PM/WK/RV del fork personal de Omarchy: construye, firma y publica los paquetes Arch (`fo-omarchy`, `fo-omarchy-pkgs`, `rf-omarchy-personal-repo`); la única puerta a `/` es pacman. Hijo de `robert-flo/pj-template` en modo dependencia: acá viven solo `proyecto.yml`, este README, `AGENTS.md`, `.gitignore`, `./pj`, el workflow `pj-template.yml` y los extras de `proyecto.yml`.

```bash
./pj listo      # todo de una tras clonar: pull, template, genera, hooks, agy, clonar, check (--abrir arranca el PM)
./pj            # solo trae pj-template al template_ref y genera .agents/ y .cursor/
./pj check      # esquema de proyecto.yml, idempotencia y prueba de humo
./pj clonar     # clona los repos de proyecto.yml al lado
./pj agy        # una vez por máquina; después: agy --agent PM-pj-omarchy
./pj humo       # prueba de humo; con agy instalado arranca PM-pj-omarchy sin interacción
code pj-omarchy.code-workspace   # o cursor pj-omarchy.code-workspace
```

Necesitás `python3`, `gh`, `git` y `make` (`./pj` arma su propio `.pj/venv` con PyYAML y jsonschema). Mapa de repos y reglas de arquitectura: `AGENTS.md`.
