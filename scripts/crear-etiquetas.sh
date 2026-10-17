#!/usr/bin/env bash
# ==============================================================================
# crear-etiquetas.sh — Etiquetas de triage y colas del trío (idempotente)
# ==============================================================================
# Colas:  ready-for-agent (WK) · listo-para-review (RV) · ready-to-merge (Roberto)
# Triage: needs-triage · needs-info   (wontfix ya viene con GitHub)
#
# Uso:
#   scripts/crear-etiquetas.sh                 # meta-repo + repos hijos de clone-repos.sh
#   scripts/crear-etiquetas.sh robert-flo/x …  # solo esos repos
#   DRY_RUN=1 scripts/crear-etiquetas.sh       # muestra qué haría, sin tocar nada
#
# Solo crea las que faltan; una etiqueta que ya existe no se toca (ni color ni
# descripción). Requiere gh autenticado.
# ==============================================================================
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN="${DRY_RUN:-0}"

# nombre|color|descripción
ETIQUETAS=(
  "needs-triage|fbca04|Idea o issue sin revisar"
  "needs-info|d93f0b|Falta información o esperando respuesta"
  "ready-for-agent|0e8a16|Cola del WK: listo para que el worker lo tome"
  "listo-para-review|1d76db|Cola del RV: PR listo para revisión"
  "ready-to-merge|5319e7|Cola de Roberto: PR aprobado, espera su orden de merge"
)

if [ "$#" -gt 0 ]; then
  REPOS=("$@")
else
  REPOS=()
  meta="$(cd "$RAIZ" && gh repo view --json nameWithOwner -q .nameWithOwner)"
  REPOS+=("$meta")
  # Repos hijos: las entradas "<dir>:<owner/repo>:<rama>" de clone-repos.sh
  while IFS= read -r repo; do
    REPOS+=("$repo")
  done < <(sed -nE 's/^[[:space:]]*"[^:"]+:([^:"]+\/[^:"]+):[^:"]+".*/\1/p' "$RAIZ/clone-repos.sh")
fi

for repo in "${REPOS[@]}"; do
  echo "--- $repo"
  existentes="$(gh label list -R "$repo" --limit 500 --json name -q '.[].name')"
  for entrada in "${ETIQUETAS[@]}"; do
    IFS="|" read -r nombre color descripcion <<< "$entrada"
    if grep -qxF "$nombre" <<< "$existentes"; then
      echo "  ya existe: $nombre"
    elif [ "$DRY_RUN" = "1" ]; then
      echo "  crearía:   $nombre"
    else
      gh label create "$nombre" -R "$repo" --color "$color" --description "$descripcion" >/dev/null
      echo "  creada:    $nombre"
    fi
  done
done
