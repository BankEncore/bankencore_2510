#!/usr/bin/env bash
# scripts/cat_paths.sh
# Usage:
#   # A) Pass dirs/files (recurses with find)
#   scripts/cat_paths.sh app db/migrate config Gemfile Gemfile.lock
#   # B) Pipe an explicit file list
#   find app db/migrate config -type f \( -name '*.rb' -o -name '*.erb' -o -name '*.yml' -o -name '*.rb' -o -name '*.rake' \) -print0 \
#     | scripts/cat_paths.sh --stdin

set -euo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
OUT_DIR="${OUT_DIR:-${ROOT}/non-git}"
OUT_FILE="${OUT_DIR}/cat_paths_${STAMP}.txt"
MAX_BYTES="${MAX_BYTES:-1048576}"
MAX_LINES="${MAX_LINES:-5000}"
: "${SKIP_MIME:=0}"

mkdir -p "$OUT_DIR"

# portable file size
fsize() {
  if stat -f%z "$1" >/dev/null 2>&1; then stat -f%z "$1"; else stat -c%s "$1"; fi
}

# portable "relative path"
relpath() {
  case "$1" in
    "$ROOT"/*) printf '%s\n' "${1#"$ROOT/"}" ;;
    *)         printf '%s\n' "$1" ;;
  esac
}

mime_ok() {
  [[ "$SKIP_MIME" == "1" ]] && return 0
  local f="$1" ext="${f##*.}"
  case "$ext" in
    rb|erb|haml|slim|yml|yaml|json|js|ts|css|scss|mjs|rake|ru|txt|md|html|htm|xml|sql|sh|zsh|gemspec|rbs) return 0;;
  esac
  local m; m="$(/usr/bin/file -I -b "$f" 2>/dev/null || true)"
  [[ "$m" == text/* ]] || [[ "$m" == application/json* ]] || [[ "$m" == application/xml* ]] || \
  [[ "$m" == application/javascript* ]] || [[ "$m" == application/x-empty* ]]
}

emit() {
  local f="$1"
  [[ -f "$f" ]] || { printf '===== SKIP (missing) %s =====\n\n' "$(relpath "$f")"; return; }
  local size; size="$(fsize "$f" 2>/dev/null || echo 0)"
  [[ "$size" -le "$MAX_BYTES" ]] || { printf '===== SKIP (size) %s (%s bytes) =====\n\n' "$(relpath "$f")" "$size"; return; }
  mime_ok "$f" || { printf '===== SKIP (binary) %s =====\n\n' "$(relpath "$f")"; return; }

  printf '===== BEGIN %s =====\n' "$(relpath "$f")"
  if [[ "${MAX_LINES}" -gt 0 ]]; then
    head -n "${MAX_LINES}" "$f"
    local lc; lc=$(wc -l <"$f"); [[ "$lc" -le "$MAX_LINES" ]] || printf '\n----- TRUNCATED after %d lines -----\n' "$MAX_LINES"
  else
    cat "$f"
  fi
  printf '\n===== END %s =====\n\n' "$(relpath "$f")"
}

echo "# Concatenated project snapshot" > "$OUT_FILE"
echo "# Generated: $(date -Is)" >> "$OUT_FILE"
echo "# Git: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown) @ $(git rev-parse --short HEAD 2>/dev/null || echo unknown)" >> "$OUT_FILE"
echo >> "$OUT_FILE"

if [[ "${1:-}" == "--stdin" ]]; then
  shift
  # read NUL-delimited list from stdin
  while IFS= read -r -d '' path; do emit "$path" >> "$OUT_FILE"; done
else
  [[ $# -gt 0 ]] || { echo "usage: $0 [--stdin] <file-or-dir> [more ...]"; exit 2; }
  for arg in "$@"; do
    if [[ -d "$arg" ]]; then
      # recurse and handle spaces safely
      while IFS= read -r -d '' f; do emit "$f" >> "$OUT_FILE"; done < <(find "$arg" -type f -print0)
    else
      emit "$arg" >> "$OUT_FILE"
    fi
  done
fi

echo "Wrote ${OUT_FILE}"
