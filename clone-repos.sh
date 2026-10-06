#!/usr/bin/env bash
# ==============================================================================
# clone-repos.sh — Clonación e idempotencia del ecosistema pj-omarchy
# ==============================================================================
# Clona y alinea los 6 repositorios del fork personal de Omarchy sin interactuar
# con el upstream omacom. Seguro e idempotente.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Definición de repositorios: <directorio_local>:<repo_github>:<rama_base>
declare -a REPOS=(
  "fo-omarchy:robert-flo/omarchy:personal"
  "fo-omarchy-pkgs:robert-flo/omarchy-pkgs:personal"
  "rf-omarchy-personal-repo:robert-flo/omarchy-personal-repo:gh-pages"
  "rf-fork-docs:robert-flo/fork-docs:main"
  "rf-scratchpad:robert-flo/scratchpad:main"
  "rf-omarchy-personal-archive-2026-09:robert-flo/omarchy-personal-archive-2026-09:personal"
)

echo "==> Verificando ecosistema de repositorios en pj-omarchy..."

for entry in "${REPOS[@]}"; do
  IFS=":" read -r local_dir gh_repo base_branch <<< "$entry"

  echo ""
  echo "--- [$local_dir] ($gh_repo -> $base_branch) ---"

  if [ ! -d "$local_dir/.git" ]; then
    echo "Clonando $gh_repo en $local_dir usando gh repo clone..."
    gh repo clone "$gh_repo" "$local_dir"

    # Alinear rama base
    echo "Alineando rama base $base_branch en $local_dir..."
    if git -C "$local_dir" show-ref --verify --quiet "refs/heads/$base_branch"; then
      git -C "$local_dir" checkout "$base_branch"
    elif git -C "$local_dir" show-ref --verify --quiet "refs/remotes/origin/$base_branch"; then
      git -C "$local_dir" checkout -b "$base_branch" "origin/$base_branch"
    fi
  else
    echo "Directorio $local_dir ya existe. Verificando estado e idempotencia..."

    # Proteger contra interacción involuntaria con upstream (omacom)
    if git -C "$local_dir" remote | grep -q "^upstream$"; then
      git -C "$local_dir" config remote.upstream.skipFetchAll true
    fi

    # Traer todas las ramas remotas
    echo "Actualizando referencias remotas (git fetch --all)..."
    git -C "$local_dir" fetch --all --prune

    # Verificar / asegurar tracking de la rama base sin destruir cambios locales
    if ! git -C "$local_dir" show-ref --verify --quiet "refs/heads/$base_branch"; then
      if git -C "$local_dir" show-ref --verify --quiet "refs/remotes/origin/$base_branch"; then
        echo "Creando rama local $base_branch rastreando origin/$base_branch..."
        git -C "$local_dir" branch --track "$base_branch" "origin/$base_branch"
      fi
    fi

    current_branch="$(git -C "$local_dir" branch --show-current || true)"
    if [ "$current_branch" != "$base_branch" ]; then
      echo "Aviso: $local_dir está en la rama '$current_branch' (rama base esperada: '$base_branch')."
      if git -C "$local_dir" diff --quiet && git -C "$local_dir" diff --cached --quiet; then
        echo "Árbol limpio. Cambiando a rama base $base_branch..."
        git -C "$local_dir" checkout "$base_branch"
      else
        echo "Árbol con cambios locales. Se conserva la rama actual '$current_branch' para no destruir trabajo."
      fi
    else
      echo "Rama actual alineada con la base: $base_branch"
    fi
  fi
done

echo ""
echo "==> Todos los repositorios del ecosistema verificados exitosamente."
