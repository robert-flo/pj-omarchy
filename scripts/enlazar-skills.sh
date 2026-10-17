#!/usr/bin/env bash
# ==============================================================================
# enlazar-skills.sh — Una sola copia de skills: .agents/skills/
# ==============================================================================
# - agy y Cursor leen .agents/skills/ directo (no hace falta .cursor/skills/).
# - Claude Code solo lee .claude/skills/<skill>/ (no .agents/skills/): acá se
#   crea un symlink relativo por skill, que es lo que Claude Code documenta.
# Idempotente: crea los que faltan, arregla los que apuntan mal y borra los
# symlinks rotos. Nunca borra carpetas reales.
# ==============================================================================
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ"

[ -d .agents/skills ] || { echo "Falta .agents/skills/" >&2; exit 1; }
mkdir -p .claude/skills

for dir in .agents/skills/*/; do
  skill="$(basename "$dir")"
  [ -f "$dir/SKILL.md" ] || continue
  destino="../../.agents/skills/$skill"
  enlace=".claude/skills/$skill"
  if [ -L "$enlace" ]; then
    [ "$(readlink "$enlace")" = "$destino" ] && continue
    rm "$enlace"
  elif [ -e "$enlace" ]; then
    echo "Aviso: $enlace es una carpeta real; no la toco (movela a .agents/skills/)." >&2
    continue
  fi
  ln -s "$destino" "$enlace"
  echo "enlazado: $enlace -> $destino"
done

# Symlinks rotos (skills que ya no están en .agents/skills/)
find .claude/skills -maxdepth 1 -type l ! -exec test -e {} \; -print | while read -r roto; do
  rm "$roto"
  echo "borrado (roto): $roto"
done

echo "Listo: $(find .claude/skills -maxdepth 1 -type l | wc -l) skills enlazadas en .claude/skills/."
