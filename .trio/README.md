# .trio/ — handoffs del trío PM/WK/RV en herdr

Cada ticket que corre el trío deja acá su carpeta `.trio/<ticket>/` (plan, reporte del WK, veredicto del RV), y se commitea a git.

## Cómo lanzarlo

Desde la estación de trabajo, con `pj-trio` de `robert-flo/PJ-NIRI-rf-omarchy-workstation` (`scripts/pj-trio`):

```bash
pj-trio pj-omarchy <ticket> --repo <miembro>
```

- `<ticket>`: número del issue a trabajar.
- `<miembro>`: el `dir` del repo en `proyecto.yml` donde cae el ticket.

Abre en herdr las pestañas `pm`, `wk` y `rv`, cada una con `agy --agent PM-pj-omarchy` / `WK-pj-omarchy` / `RV-pj-omarchy` (agentes `pm-pj-omarchy`, `wk-pj-omarchy`, `rv-pj-omarchy`). El estado se ve con `trio-status`.

El PM mergea solo después del `APRUEBO <sha>` del RV: `gh pr merge <N> --squash --delete-branch --match-head-commit <sha>`.
