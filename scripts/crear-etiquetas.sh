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
# descripción). Requiere gh autenticado. Sin argumentos salta los repos
# archivados. Si un repo falla, sigue con los demás y al final lista los fallos
# (código de salida 1). GH_TIMEOUT (segundos, 30 por defecto) limita cada gh.
# ==============================================================================
set -uo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN="${DRY_RUN:-0}"
GH_TIMEOUT="${GH_TIMEOUT:-30}"

gh_t() { timeout "$GH_TIMEOUT" gh "$@"; }

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
  if ! meta="$(cd "$RAIZ" && gh_t repo view --json nameWithOwner -q .nameWithOwner)"; then
    echo "error: no pude resolver el meta-repo con gh" >&2
    exit 1
  fi
  REPOS+=("$meta")
  # Repos hijos: las entradas "<dir>:<owner/repo>:<rama>" de clone-repos.sh
  # Salta los archivados: los de AGENTS.md §3 («Archivado e Inmutable») y los
  # que GitHub marca como archivados.
  ARCHIVADOS=(robert-flo/scratchpad robert-flo/omarchy-personal-archive-2026-09)
  while IFS= read -r repo; do
    if printf '%s\n' "${ARCHIVADOS[@]}" | grep -qixF "$repo"; then
      echo "--- $repo (archivado, se salta)"
      continue
    fi
    if [ "$(gh_t repo view "$repo" --json isArchived -q .isArchived 2>/dev/null)" = "true" ]; then
      echo "--- $repo (archivado, se salta)"
      continue
    fi
    REPOS+=("$repo")
  done < <(sed -nE 's/^[[:space:]]*"[^:"]+:([^:"]+\/[^:"]+):[^:"]+".*/\1/p' "$RAIZ/clone-repos.sh")
fi

FALLOS=()
for repo in "${REPOS[@]}"; do
  echo "--- $repo"
  if ! existentes="$(gh_t label list -R "$repo" --limit 500 --json name -q '.[].name')"; then
    echo "  error: no pude listar etiquetas" >&2
    FALLOS+=("$repo (listar)")
    continue
  fi
  for entrada in "${ETIQUETAS[@]}"; do
    IFS="|" read -r nombre color descripcion <<< "$entrada"
    if grep -qixF "$nombre" <<< "$existentes"; then
      echo "  ya existe: $nombre"
    elif [ "$DRY_RUN" = "1" ]; then
      echo "  crearía:   $nombre"
    else
      if gh_t label create "$nombre" -R "$repo" --color "$color" --description "$descripcion" >/dev/null; then
        echo "  creada:    $nombre"
      else
        echo "  error:     $nombre" >&2
        FALLOS+=("$repo ($nombre)")
      fi
    fi
  done
done

if [ "${#FALLOS[@]}" -gt 0 ]; then
  echo "--- Fallos (${#FALLOS[@]}):" >&2
  printf '  %s\n' "${FALLOS[@]}" >&2
  exit 1
fi
