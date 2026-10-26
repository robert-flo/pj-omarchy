# AGENTS.md — pj-omarchy

Meta-repo del trío PM/WK/RV del **fork personal de Omarchy** para Cursor y agy. Si sos un agente: si no existe `.agents/reglas/`, corré `./pj` antes de nada.

## Qué hay acá
- `proyecto.yml`: los datos del proyecto (repos, specs en orden, notas, extras). Lo llenás vos; lo valida el esquema de pj-template.
- Todo lo demás (reglas, fichas, plantillas, skills, scripts) lo trae `./pj` desde `robert-flo/pj-template` al SHA de `template_ref`, en `.pj/`, y genera `.agents/` y `.cursor/`. Nada de eso se versiona ni se edita a mano. Cómo funciona: `.pj/tpl/docs/pj-template.md`.
- Extras conservados a mano (`extras:` de `proyecto.yml`): un adaptador propio en `.agents/` (aparte, no se toca) y `pj-omarchy.code-workspace`.
- Regla de merge: el PM solo mergea cuando Roberto lo ordena sobre un PR con `ready-to-merge`.

## Arquitectura
| Carpeta | Repo | Rama base | Rol |
| :--- | :--- | :--- | :--- |
| `fo-omarchy` | `robert-flo/omarchy` | `personal` | Fuente del fork (`config/`, `applications/`, `bin/`, `install/`, `migrations/`); `quattro` refleja upstream. |
| `fo-omarchy-pkgs` | `robert-flo/omarchy-pkgs` | `personal` | PKGBUILDs de `omarchy` y `omarchy-settings`, build en Docker Arch, firma GPG, cron `sync-check.yml` 04:00; `master` refleja upstream. |
| `rf-omarchy-personal-repo` | `robert-flo/omarchy-personal-repo` | `gh-pages` | Repo pacman binario firmado (`https://robert-flo.github.io/omarchy-personal-repo/stable/$arch`). |
| `rf-fork-docs` | `robert-flo/fork-docs` | `main` | Documentación canónica: si hay contradicción, manda. |
| `rf-scratchpad` | `robert-flo/scratchpad` | `main` | Histórico, solo lectura. |
| `rf-omarchy-personal-archive-2026-09` | `robert-flo/omarchy-personal-archive-2026-09` | `personal` | Histórico pre-2026-09, solo lectura. |

`./pj clonar` los clona al lado (ignorados por git). Tras clonar este repo: `./pj listo` (o `./pj listo --abrir`); instala hooks para que cada `git pull` regenere solo.

## Reglas duras de arquitectura (inviolables)

1. **La Matriz de Decisión manda:** Todo cambio en `fo-omarchy` debe clasificarse estrictamente en la fila correspondiente de [`rf-fork-docs/architecture/02-matriz-de-decision.md`](./rf-fork-docs/architecture/02-matriz-de-decision.md):
   - Configs de usuario: `config/<app>/` → `$HOME/.config/<app>/` (vía `omarchy-settings`).
   - Webapps y accesos directos: `applications/*.desktop` → `$HOME/.local/share/applications/` (vía `omarchy-settings`).
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


## Los dos escenarios de trabajo

```
┌────────────────────────────────────────────────────────┐
│                   ESCENARIOS OPERATIVOS                │
└────────────────────────────────────────────────────────┘
          │                                   │
   [ Escenario DEV ]                   [ Escenario MÁQUINAS ]
 (Validación en DEV)                 (Producción para la flota)
          │                                   │
• Editar código en fo-omarchy       • git commit & push a rama personal
• omarchy dev pkg-test              • Action release-personal.yml en omarchy-pkgs
• omarchy refresh <componente>      • Compilación Arch Docker + firma GPG
• Prueba en vivo con dev.<sha>      • Publicación a gh-pages en repo pacman
                                    • Máquinas corren omarchy update
```

- **`omarchy dev pkg-test`** es exclusivo de la máquina DEV. Deja la máquina en el canal `-dev`.
- **`omarchy update`** es el canal estable para todas las máquinas de la flota (y para regresar la máquina DEV al canal oficial sombreado).


## Git
Identidad `Roberto Flores <25asab015@ujmd.edu.sv>`, `git pull --rebase --autostash` antes de empujar, nunca `--force`, todo por PR con squash y `--match-head-commit`.
