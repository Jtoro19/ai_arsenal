#!/usr/bin/env bash
# Literal $ in strings and vars read inside check() eval strings are intended.
# shellcheck disable=SC2016,SC2034
# Regression tests for install.sh. Usage: tests/install.test.sh
# Runs the real install.sh against a throwaway HOME with stubbed npm (and pacman).
set -u
REPO="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
fails=0
tmp=()
trap 'rm -rf "${tmp[@]}"' EXIT
check() { if eval "$2"; then echo "PASS: $1"; else echo "FAIL: $1"; fails=$((fails+1)); fi; }
setup() {
  H=$(mktemp -d); STUB=$(mktemp -d); tmp+=("$H" "$STUB")
  mkdir -p "$H/.local/bin"; printf '#!/bin/sh\necho 0.0\n' > "$H/.local/bin/promptfoo"; chmod +x "$H/.local/bin/promptfoo"
  printf '#!/bin/sh\n[ "$1 $2 $3" = "config get prefix" ] && echo "$HOME/.local"\nexit 0\n' > "$STUB/npm"; chmod +x "$STUB/npm"
}
run() { HOME="$H" PATH="$STUB:$PATH" "$REPO/install.sh" >"$H/out" 2>&1; }

# 1+2: comment mentions ~/.local/bin, file has no trailing newline
setup
printf '# todo: add $HOME/.local/bin someday\nalias ll="ls -l"' > "$H/.bashrc"
run; rc=$?
check "1: run succeeds" '[ $rc -eq 0 ]'
check "1: PATH export added despite comment" 'grep -qxF "export PATH=\"\$HOME/.local/bin:\$PATH\"" "$H/.bashrc"'
check "2: last user line not glued" 'grep -qx "alias ll=\"ls -l\"" "$H/.bashrc"'
sum=$(sha256sum < "$H/.bashrc"); run
check "idempotent re-run" '[ "$sum" = "$(sha256sum < "$H/.bashrc")" ]'

# 2b: wired by the old script (header present), no trailing newline
setup
printf '\n# ai_arsenal\nexport PATH="/opt/arsenal/bin:$PATH"\neval "$(direnv hook bash)"\nexport AI_ARSENAL="/opt/arsenal"\nalias x=y' > "$H/.bashrc"
run
check "2b: last line not glued when header exists" 'grep -qx "alias x=y" "$H/.bashrc"'

# existing real PATH line (desktop style) is honored, no duplicate
setup
printf 'export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"\n' > "$H/.bashrc"
run
check "existing PATH line honored" '[ "$(grep -c "\.local/bin" "$H/.bashrc")" -eq 1 ]'

# 3: pacman -T broken (exit 1, empty stdout) must abort, not report ok
setup
printf '#!/bin/sh\n[ "$1" = "-T" ] && exit 1\nexec /usr/bin/pacman "$@"\n' > "$STUB/pacman"; chmod +x "$STUB/pacman"
: > "$H/.bashrc"; run; rc=$?
check "3: pacman -T error aborts" '[ $rc -ne 0 ] && ! grep -q "ok: all base packages present" "$H/out"'

echo "failures: $fails"; exit $fails
