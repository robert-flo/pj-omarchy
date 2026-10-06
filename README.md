# pj-omarchy

> **Meta-repositorio y orquestador del workspace para el ecosistema del fork personal de Omarchy.**  
> Centraliza la configuración del entorno multi-repo, reglas de agentes de IA, tooling de IDE y scripts de bootstrapping desatendido para la flota de Roberto.

---

## 1. Visión General

El proyecto `pj-omarchy` orquesta el ecosistema de distribución y mantenimiento del fork personal de [Omarchy](https://github.com/omacom/omarchy). A diferencia de un monorepo convencional o el uso de submódulos de Git, este meta-repositorio gestiona seis repositorios independientes bajo un esquema desacoplado y versiona exclusivamente los metadatos globales, reglas operativas de agentes y scripts de bootstrapping.

### Mapa del Ecosistema (Los 6 Repositorios Hijos)

| Directorio local | Repositorio GitHub | Rama base | Rol en el ecosistema |
| :--- | :--- | :--- | :--- |
| `fo-omarchy/` | [`robert-flo/omarchy`](https://github.com/robert-flo/omarchy) | `personal` | **Código fuente de la distribución:** Personalizaciones (`config/`, `applications/`, `bin/`, `install/`, `migrations/`). |
| `fo-omarchy-pkgs/` | [`robert-flo/omarchy-pkgs`](https://github.com/robert-flo/omarchy-pkgs) | `personal` | **Motor de packaging & CI:** PKGBUILDs del par sombreado (`omarchy`, `omarchy-settings`), builds en contenedor Arch Linux, firma GPG y cron detector 04:00 AM (`sync-check.yml`). |
| `rf-omarchy-personal-repo/` | [`robert-flo/omarchy-personal-repo`](https://github.com/robert-flo/omarchy-personal-repo) | `gh-pages` | **Repositorio pacman binario:** Servido en GitHub Pages (`https://robert-flo.github.io/omarchy-personal-repo/stable/$arch`). Contiene bases de datos `.db.tar.zst` y paquetes `.pkg.tar.zst` firmados. |
| `rf-fork-docs/` | [`robert-flo/fork-docs`](https://github.com/robert-flo/fork-docs) | `main` | **Documentación canónica viva («Estándar de Oro»):** Fuente única de verdad del proyecto. Portal Jekyll con User Guide, Matriz de Decisión, Operaciones (W1–W10) y todos los ADRs. |
| `rf-scratchpad/` | [`robert-flo/scratchpad`](https://github.com/robert-flo/scratchpad) | `main` | **Histórico y deprecado (solo lectura):** Memoria de las etapas 0 a 4 del proyecto. |
| `rf-omarchy-personal-archive-2026-09/` | [`robert-flo/omarchy-personal-archive-2026-09`](https://github.com/robert-flo/omarchy-personal-archive-2026-09) | `personal` | **Histórico pre-2026-09:** Snapshot de auditoría de la distribución previo a la modularización de octubre 2026. |

---

## 2. Requisitos y Herramientas

Antes de inicializar el workspace en una nueva máquina, asegurate de contar con:

1. **Git:** Configurado con tus credenciales y llaves SSH habilitadas en GitHub.
2. **GitHub CLI (`gh`):** Autenticado y con permisos para clonar repositorios del usuario `robert-flo`:
   ```bash
   gh auth status
   # Si no está autenticado:
   gh auth login
   ```
3. **Sistema Base:** Arch Linux / Omarchy (con `tanjiro` en `gracie` como entorno primario de desarrollo).

---

## 3. Guía de Inicio Rápido (Setup)

### Paso 1: Clonar el Meta-Repositorio

```bash
git clone git@github.com:robert-flo/pj-omarchy.git ~/Work/tries/pj-omarchy
cd ~/Work/tries/pj-omarchy
```

### Paso 2: Ejecutar el Script de Clonación Idempotente

El script `./clone-repos.sh` clona los seis repositorios usando `gh repo clone`, alinea sus ramas base y trae todas las referencias remotas disponibles para facilitar checkout y worktrees:

```bash
./clone-repos.sh
```

> **Propiedad de Idempotencia:** Podés ejecutar `./clone-repos.sh` en cualquier momento. Si los directorios ya existen, actualizará las referencias remotas (`git fetch --all --prune`) sin destruir cambios locales ni desconfigurar ramas en curso.

### Paso 3: Abrir el Workspace en el Editor

El archivo `pj-omarchy.code-workspace` define un espacio multi-raíz para VS Code y Cursor:

```bash
# En VS Code:
code pj-omarchy.code-workspace

# En Cursor:
cursor pj-omarchy.code-workspace
```

---

## 4. Estructura del Meta-Repositorio

```
pj-omarchy/
├── .agents/                      # Definiciones del trío de agentes Antigravity
│   └── agents/
│       ├── PM-pj-omarchy.md      # Project Manager (Matt Pocock Flow)
│       ├── WK-pj-omarchy.md      # Worker (implementación con pruebas reales)
│       └── RV-pj-omarchy.md      # Reviewer (auditoría previa al merge)
├── .cursor/                      # Reglas, prompts y skills para Cursor IDE
│   ├── agents/                   # Prompts especializados para agentes
│   ├── rules/                    # Reglas automáticas para Cursor
│   └── skills/                   # Skills del flujo (code-review, diagnosing-bugs, etc.)
├── .gitignore                    # Exclusión estricta de sub-repos, worktrees y temporales
├── AGENTS.md                     # Guía maestra y memoria persistente del workspace
├── clone-repos.sh                # Script ejecutable de clonación e idempotencia
├── pj-omarchy.code-workspace     # Configuración del espacio multi-raíz para IDE
└── README.md                     # Documentación principal del workspace (este archivo)
```

---

## 5. Reglas Duras de Arquitectura

1. **La Matriz de Decisión Manda:** Cualquier cambio en la distribución debe alinearse con [`rf-fork-docs/architecture/02-matriz-de-decision.md`](./rf-fork-docs/architecture/02-matriz-de-decision.md).
2. **Cero Interacción Directa con `omacom`:** Queda prohibido abrir issues, PRs o pushear a `omacom/*`. Todo trabajo se canaliza exclusivamente a través de los forks personales (`robert-flo/*`).
3. **`omarchy update` es el Único Gatillo de Distribución:** Todas las máquinas de la flota convergen únicamente mediante `omarchy update`.
4. **Sombreado pacman & `pkgrel >= 99`:** Los paquetes conservan los mismos nombres que upstream (`omarchy`, `omarchy-settings`) y usan `pkgrel >= 99` para prevalecer en `pacman -Syu`.
5. **Lockstep:** Los paquetes `omarchy` y `omarchy-settings` se compilan y versionan sincronizados desde el mismo commit.
6. **Cadencia Desatendida de las 04:00 AM:** El cron en `fo-omarchy-pkgs` (`sync-check.yml`) detecta nuevos tags upstream y corre el rebase de forma desatendida.
7. **Worktrees Aislados:** Cada tarea o ticket se implementa en worktrees dedicados (`.wt-*`), manteniendo el clon raíz siempre limpio.

---

## 6. Flujo de Trabajo de los Agentes

El desarrollo en este workspace opera bajo el modelo del Trío Antigravity (`PM`, `WK`, `RV`):
- **Roberto** interactúa únicamente con el **PM** (`PM-pj-omarchy`).
- El **PM** formaliza especificaciones y genera tickets `ready-for-agent`.
- El **WK** (`WK-pj-omarchy`) implementa cada sub-issue en un worktree aislado, verifica criterios con pruebas reales y actualiza el issue del spec.
- El **RV** (`RV-pj-omarchy`) audita el PR final antes de someterlo a la aprobación de Roberto.
- Solo Roberto autoriza el merge definitivo a la rama principal.
