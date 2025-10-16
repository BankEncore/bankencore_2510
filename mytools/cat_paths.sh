#!/usr/bin/env bash

# chmod +x scripts/cat_paths.sh
# scripts/cat_paths.sh app/models/**/*.rb db/migrate/*.rb config/**/*.yml


set -euo pipefail
[[ $# -gt 0 ]] || { echo "usage: $0 <path-or-glob> [more ...]"; exit 2; }

STAMP="$(date +%Y%m%d_%H%M%S)"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT_DIR="${OUT_DIR:-${ROOT}/non-git}"
OUT_FILE="${OUT_DIR}/cat_paths_${STAMP}.txt"
MAX_BYTES="${MAX_BYTES:-1048576}"
MAX_LINES="${MAX_LINES:-5000}"
mkdir -p "$OUT_DIR"

mime_ok() { local m; m="$(file -b --mime-type "$1" || true)"; [[ "$m" == text/* || "$m" == application/json || "$m" == application/xml || "$m" == application/x-sh || "$m" == application/javascript ]]; }

emit() {
  local f="$1"; local size; size=$(stat -c%s "$f" 2>/dev/null || echo 0)
  local rel; rel="$(realpath --relative-to="." "$f" 2>/dev/null || echo "$f")"
  [[ -f "$f" ]] || { printf '===== SKIP (missing) %s =====\n\n' "$rel"; return; }
  [[ "$size" -le "$MAX_BYTES" ]] || { printf '===== SKIP (size) %s (%s bytes) =====\n\n' "$rel" "$size"; return; }
  mime_ok "$f" || { printf '===== SKIP (binary) %s =====\n\n' "$rel"; return; }

  printf '===== BEGIN %s =====\n' "$rel"
  if [[ "${MAX_LINES}" -gt 0 ]]; then
    head -n "${MAX_LINES}" "$f"
    local lc; lc=$(wc -l <"$f"); [[ "$lc" -le "$MAX_LINES" ]] || printf '\n----- TRUNCATED after %d lines -----\n' "$MAX_LINES"
  else
    cat "$f"
  fi
  printf '\n===== END %s =====\n\n' "$rel"
}

echo "# Concatenated selection $(date -Is)" > "$OUT_FILE"
for arg in "$@"; do
  for f in $arg; do emit "$f" >> "$OUT_FILE"; done
done
echo "Wrote ${OUT_FILE}"
