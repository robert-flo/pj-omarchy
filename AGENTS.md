# AGENTS.md — Workspace pj-omarchy (Ecosistema Fork Personal de Omarchy)

> **Guía maestra y memoria persistente del workspace `pj-omarchy` en la flota de Roberto.**
> Este archivo es la referencia obligatoria para cualquier agente (`PM-pj-omarchy`, `WK-pj-omarchy`, `RV-pj-omarchy`) que opere en este workspace. Define la topología de los seis repositorios, la jerarquía de documentación, las reglas duras de arquitectura y el flujo de trabajo.

---

## 1. Identidad y Operación del Workspace

- **Proyecto:** `pj-omarchy` (Área: Fork Personal de Omarchy).
- **Máquina DEV:** `gracie` (Arch Linux / Omarchy con Hyprland, usuario `tanjiro`).
- **El Trío de Agentes:**
  - `PM-pj-omarchy`: PM general. Roberto habla **únicamente con el PM**. Convierte requerimientos en specs y tickets `ready-for-agent` con el flujo de Matt Pocock.
  - `WK-pj-omarchy`: Worker. Lanzado por el PM (`invoke_subagent`) para implementar tickets en branches dedicadas con pruebas reales.
  - `RV-pj-omarchy`: Reviewer. Lanzado por el PM (`invoke_subagent`) para auditar el PR final antes de presentárselo a Roberto.
- **Regla de oro de comunicación:** Voseo salvadoreño siempre («vos tenés», «podés», «decime», «fijate», «mirá»). Respuestas concisas, primero el resultado.
- **Regla de merge:** El PM **solo mergea cuando Roberto da la orden explícita** sobre un PR con etiqueta `ready-to-merge`.

---

## 2. Mapa de Repositorios (Los 6 Repos del Workspace)

| Carpeta local | Repositorio GitHub | Rama base de trabajo | Rama upstream mirror | Rol en el ecosistema |
| :--- | :--- | :--- | :--- | :--- |
| [`fo-omarchy/`](./fo-omarchy) | `robert-flo/omarchy` | `personal` | `quattro` (o `upstream`) | **Código fuente del fork:** Distribución Omarchy con personalizaciones (`config/`, `applications/`, `bin/`, `install/`, `migrations/`). |
| [`fo-omarchy-pkgs/`](./fo-omarchy-pkgs) | `robert-flo/omarchy-pkgs` | `personal` | `master` | **Motor de packaging & CI:** PKGBUILDs del par sombreado (`omarchy`, `omarchy-settings`), compilación containerizada en Docker Arch Linux, firma GPG y cron detector 04:00 AM (`sync-check.yml`). |
| [`rf-omarchy-personal-repo/`](./rf-omarchy-personal-repo) | `robert-flo/omarchy-personal-repo` | `gh-pages` | N/A | **Repositorio pacman binario:** Servido en GitHub Pages (`https://robert-flo.github.io/omarchy-personal-repo/stable/$arch`). Contiene bases de datos `.db.tar.zst` y paquetes binarios `.pkg.tar.zst` firmados. |
| [`rf-fork-docs/`](./rf-fork-docs) | `robert-flo/fork-docs` | `main` | N/A | **Documentación canónica viva («Estándar de Oro»):** Fuente única de verdad del proyecto. Portal Jekyll en GitHub Pages con User Guide, Matriz de Decisión, Operaciones (W1–W10) y todos los ADRs. |
| [`rf-scratchpad/`](./rf-scratchpad) | `robert-flo/scratchpad` | `main` | N/A | **Histórico y deprecado (solo lectura):** Memoria de las etapas 0 a 4. No se modifica ni se le agrega nada nuevo; todo lo vigente fue migrado a `fork-docs`. |
| [`rf-omarchy-personal-archive-2026-09/`](./rf-omarchy-personal-archive-2026-09) | `robert-flo/omarchy-personal-archive-2026-09` | `personal` | N/A | **Histórico pre-2026-09:** Snapshot de auditoría de la distribución previo a la modularización de octubre 2026. |

---

## 3. Jerarquía Documental

1. **Canónico y Vivo:** [`rf-fork-docs/`](./rf-fork-docs). En caso de contradicción, lo expresado en `fork-docs` prevalece sobre cualquier otro documento o README.
2. **Archivado e Inmutable:** [`rf-scratchpad/`](./rf-scratchpad) y [`rf-omarchy-personal-archive-2026-09/`](./rf-omarchy-personal-archive-2026-09) se mantienen únicamente para auditoría y consulta de precedentes históricos.

---

## 4. Reglas Duras de Arquitectura (Inviolables)

1. **La Matriz de Decisión manda:** Todo cambio en `fo-omarchy` debe clasificarse estrictamente en la fila correspondiente de [`rf-fork-docs/architecture/02-matriz-de-decision.md`](./rf-fork-docs/architecture/02-matriz-de-decision.md):
   - Configs de usuario: `config/<app>/` → `~/.config/<app>/` (vía `omarchy-settings`).
   - Webapps y accesos directos: `applications/*.desktop` → `~/.local/share/applications/` (vía `omarchy-settings`).
   - Binarios de sistema: `bin/omarchy-*` → `/usr/bin/` (vía `omarchy`).
   - Wrappers de terceros: `install/user/*.sh` siguiendo el patrón `omarchy-mise-install`.
   - Scripts de migración / provisioning: `migrations/<timestamp>.sh` (estrictamente idempotentes).
2. **Cero mecanismos paralelos:** Prohibido inventar dotfiles managers, scripts sueltos por máquina o descargar cosas por `curl` ad-hoc.
3. **`omarchy update` es el único gatillo de distribución:** Todas las máquinas de la flota convergen únicamente mediante `omarchy update`.
4. **Sombreado pacman & `pkgrel >= 99`:** Los paquetes conservan el nombre idéntico a upstream (`omarchy`, `omarchy-settings`) para no romper dependencias, y usan `pkgrel >= 99` derivado automáticamente para prevalecer en `pacman -Syu`.
5. **Lockstep:** Los paquetes `omarchy` y `omarchy-settings` siempre se compilan, versionan y publican juntos desde el mismo commit.
6. **Cadencia desatendida de las 04:00 AM:** El cron en `fo-omarchy-pkgs` (`sync-check.yml`) detecta nuevos tags upstream y corre el rebase. **Los agentes no sincronizan upstream por su cuenta.** Los conflictos de rebase solo se tocan si Roberto abre issue pidiéndolo expresamente.
7. **Prohibido tocar `/usr/share/omarchy/` a mano:** Todo lo que vive ahí debe ser instalado limpiamente por el paquete pacman.
8. **Seguridad GPG:** Las claves privadas solo viven como secrets de GitHub Actions (`SSH_OMARCHY_SOURCE_KEY`, llaves GPG de firma). La clave pública vive en `rf-fork-docs/keys/omarchy-personal-repo.pub.asc`. Cero credenciales en repos públicos.
9. **Cero interacción directa con `omacom`:** No abrir issues, PRs ni hacer push a `omacom/omarchy`. Los PRs son contra nuestras ramas base (`personal`, etc.).

---

## 5. Los Dos Escenarios de Trabajo

```
┌────────────────────────────────────────────────────────┐
│                   ESCENARIOS OPERATIVOS                │
└────────────────────────────────────────────────────────┘
          │                                   │
   [ Escenario DEV ]                   [ Escenario MÁQUINAS ]
 (Validación en gracie)              (Producción para la flota)
          │                                   │
• Editar código en fo-omarchy       • git commit & push a rama personal
• omarchy dev pkg-test              • Action release-personal.yml en omarchy-pkgs
• omarchy refresh <componente>      • Compilación Arch Docker + firma GPG
• Prueba en vivo con dev.<sha>      • Publicación a gh-pages en repo pacman
                                    • Máquinas corren omarchy update
```

- **`omarchy dev pkg-test`** es exclusivo de desarrollo local en `gracie`. Deja la máquina en el canal `-dev`.
- **`omarchy update`** es el canal estable para todas las máquinas de la flota (y para regresar `gracie` al canal oficial sombreado).

---

## 6. Flujo de Trabajo del PM (Matt Pocock Flow)

1. **Board primero:** Todo trabajo tiene un GitHub Issue (buscar con `gh issue list --search`; si no existe, crearlo con `needs-triage`).
2. **Grill con docs (`grill-with-docs`):** Interrogar requisitos uno a uno con opciones recomendadas antes de pasar a spec.
3. **Spec (`to-spec`):** Definir criterios de aceptación verificables y crear rama del spec desde `personal` (`<número>-<slug>`).
4. **Tickets (`to-tickets`):** Partir el spec en sub-issues con etiqueta `ready-for-agent`.
5. **Worker (`WK-pj-omarchy`):** Lanzar como subagente para programar cada ticket en la rama del spec.
6. **Reviewer (`RV-pj-omarchy`):** Al completar todos los sub-issues, abrir PR de la rama del spec a `personal` y lanzar RV como subagente para auditar.
7. **Merge:** Solo cuando el RV emite `APRUEBO` y Roberto autoriza el merge, ejecutar `gh pr merge --squash --delete-branch`.
