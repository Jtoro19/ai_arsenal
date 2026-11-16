#!/usr/bin/env bash
set -euo pipefail
# find the arsenal root from this script's own location (portable, clone anywhere)
ARSENAL="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
MODES="$ARSENAL/modes"

name="${1:-}"
target="${2:-.}"

if [[ -z "$name" || ! -d "$MODES/$name" ]]; then
  echo "usage: mode <name> [target_dir]"
  echo "available modes:"
  ls -1 "$MODES"
  exit 1
fi

mkdir -p "$target"
cp -rn "$MODES/$name/." "$target/"          # copy template, never overwrite

if [[ -f "$target/.envrc" ]]; then
  ( cd "$target" && direnv allow )
fi

echo "mode '$name' applied to: $target"
echo "cd into it to activate."
