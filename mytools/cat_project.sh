#!/usr/bin/env bash
# mkdir -p scripts
# chmod +x scripts/cat_project.sh
# default (git-aware):
# scripts/cat_project.sh .
# change caps or output dir:
# MAX_LINES=0 MAX_BYTES=$((2*1024*1024)) OUT_DIR=/tmp scripts/cat_project.sh .

set -euo pipefail

# Config
ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
OUT_DIR="${OUT_DIR:-${ROOT}/non-git}"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT_FILE="${OUT_DIR}/cat_project_${STAMP}.txt"
MAX_BYTES="${MAX_BYTES:-1048576}"
MAX_LINES="${MAX_LINES:-5000}"
USE_GIT="${USE_GIT:-0}"   # default to non-git scan
mkdir -p "$OUT_DIR"

# Dirs and globs to include when USE_GIT=0
INCLUDE_DIRS=("app" "config" "db" "lib" "bin" "test" "spec")
INCLUDE_FILES=("Gemfile" "Gemfile.lock" "Rakefile" ".rubocop.yml" ".env.example")

# Exclusions for find mode
EXCLUDE_DIRS=("node_modules" ".git" "log" "tmp" "storage" "vendor" "public/assets")

mime_ok() {
  local m
  m="$(file -b --mime-type "$1" || true)"
  case "$m" in
    text/*|application/json|application/xml|application/x-sh|application/javascript)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

emit() {
  local f="$1"
  local rel="${f#${ROOT%/}/}"
  local size
  size=$(stat -c%s "$f" 2>/dev/null || echo 0)

  [[ "$size" -le "$MAX_BYTES" ]] || { 
    printf '===== SKIP (size) %s (%s bytes) =====\n\n' "$rel" "$size"
    return
  }
  mime_ok "$f" || { 
    printf '===== SKIP (binary) %s =====\n\n' "$rel"
    return
  }

  printf '===== BEGIN %s =====\n' "$rel"
  if [[ "${MAX_LINES}" -gt 0 ]]; then
    head -n "${MAX_LINES}" "$f"
    # Indicate truncation if longer
    local lc
    lc=$(wc -l <"$f")
    [[ "$lc" -le "$MAX_LINES" ]] || printf '\n----- TRUNCATED after %d lines -----\n' "$MAX_LINES"
  else
    cat "$f"
  fi
  printf '\n===== END %s =====\n\n' "$rel"
}

echo "# Concatenated project snapshot" > "$OUT_FILE"
echo "# Generated: $(date -Is)" >> "$OUT_FILE"
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "# Git: $(git rev-parse --abbrev-ref HEAD) @ $(git rev-parse --short HEAD)" >> "$OUT_FILE"
fi
echo >> "$OUT_FILE"

FILES=()

if [[ "$USE_GIT" == "1" ]] && command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Git tracked + staged + untracked (but not ignored)
  mapfile -t FILES < <(git ls-files --cached --others --exclude-standard \
    | grep -E '^(app|config|db|lib|bin|test|spec)/|^(Gemfile(\.lock)?|Rakefile|\.rubocop\.yml|\.env\.example)$' \
    | sed "s|^|$ROOT/|")
else
  # Fallback to find
  FIND_ARGS=()
  for d in "${EXCLUDE_DIRS[@]}"; do FIND_ARGS+=(-path "$ROOT/$d" -prune -o); done
  FIND_ARGS+=(-type f -print)
  mapfile -t CANDIDATES < <(find "$ROOT" "${FIND_ARGS[@]}")
  for f in "${CANDIDATES[@]}"; do
    for inc in "${INCLUDE_DIRS[@]}"; do
      if [[ "$f" == "$ROOT/$inc/"* ]]; then FILES+=("$f"); break; fi
    done
  done
  for f in "${INCLUDE_FILES[@]}"; do [[ -f "$ROOT/$f" ]] && FILES+=("$ROOT/$f"); done
fi

# Deduplicate and sort
mapfile -t FILES < <(printf '%s\n' "${FILES[@]}" | sort -u)

for f in "${FILES[@]}"; do
  emit "$f" >> "$OUT_FILE"
done

echo "Wrote ${OUT_FILE}"
