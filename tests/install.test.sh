#!/usr/bin/env bash
# Literal $ in strings and vars read inside check() eval strings are intended.
# shellcheck disable=SC2016,SC2034,SC2329
# Regression tests for install.sh. Usage: tests/install.test.sh
# Runs the real install.sh in a sandbox: a throwaway HOME, XDG_* unset, and
# stubs for npm, pacman, yay and sudo, so it never touches the host system.
# The sudo stub fails loudly: any test that reaches sudo is a bug.
set -u
REPO="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
fails=0
tmp=()
trap 'rm -rf "${tmp[@]}"' EXIT
check() { if eval "$2"; then echo "PASS: $1"; else echo "FAIL: $1"; fails=$((fails+1)); fi; }
stub() { printf '#!/bin/sh\n%s\n' "$2" >"$STUB/$1"; chmod +x "$STUB/$1"; }
setup() {
  H=$(mktemp -d); STUB=$(mktemp -d); tmp+=("$H" "$STUB")
  mkdir -p "$H/.local/bin"
  printf '#!/bin/sh\necho 0.0\n' >"$H/.local/bin/promptfoo"; chmod +x "$H/.local/bin/promptfoo"
  stub npm '[ "$1 $2 $3" = "config get prefix" ] && echo "$HOME/.local"; exit 0'
  stub pacman 'exit 0'                     # -T: every package present
  stub yay 'echo "yay stub called" >&2; exit 1'
  stub sudo 'echo "sudo stub called" >&2; exit 1'
}
run() {
  env -u XDG_DATA_HOME -u XDG_CONFIG_HOME -u XDG_CACHE_HOME \
    HOME="$H" PATH="$STUB:$PATH" "$REPO/install.sh" >"$H/out" 2>&1
}
path_lines() { grep -c '^export PATH="\$HOME/.local/bin:\$PATH"$' "$H/.bashrc"; }

# A comment mentioning ~/.local/bin, and no trailing newline
setup
printf '# todo: add $HOME/.local/bin someday\nalias ll="ls -l"' >"$H/.bashrc"
run; rc=$?
check "run succeeds" '[ $rc -eq 0 ]'
check "sandbox: no sudo or yay call" '! grep -q "stub called" "$H/out"'
check "PATH export added despite comment" '[ "$(path_lines)" -eq 1 ]'
check "last user line not glued" 'grep -qx "alias ll=\"ls -l\"" "$H/.bashrc"'
sum=$(sha256sum <"$H/.bashrc"); run
check "idempotent re-run" '[ "$sum" = "$(sha256sum <"$H/.bashrc")" ]'

# Wired by the old script (header present), no trailing newline
setup
printf '\n# ai_arsenal\nexport PATH="/opt/arsenal/bin:$PATH"\neval "$(direnv hook bash)"\nexport AI_ARSENAL="/opt/arsenal"\nalias x=y' >"$H/.bashrc"
run
check "last line not glued when header exists" 'grep -qx "alias x=y" "$H/.bashrc"'

# Existing PATH lines in common shapes are honored: no second export
for line in \
  'export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"' \
  'export PATH=$PATH:$HOME/.local/bin' \
  'PATH="$HOME/.local/bin"' \
  "export PATH='\$HOME/.local/bin:\$PATH'" \
  'PATH+=:$HOME/.local/bin' \
  'export PATH="${HOME}/.local/bin:$PATH"' \
  'export PATH=~/.local/bin:$PATH' \
  'export PATH=$PATH:$HOME/.local/bin # user bin'; do
  setup
  printf '%s\n' "$line" >"$H/.bashrc"
  run
  check "honored: $line" '[ "$(path_lines)" -eq 0 ]'
done

# Lines that only look similar do not count as on PATH
for line in \
  '# export PATH="$HOME/.local/bin:$PATH"' \
  'export PATH="$HOME/.local/bin/extra:$PATH"' \
  'alias lb="ls $HOME/.local/bin"'; do
  setup
  printf '%s\n' "$line" >"$H/.bashrc"
  run
  check "not counted: $line" '[ "$(path_lines)" -eq 1 ]'
done

# pacman -T broken (exit 1, empty stdout) must abort, not report ok
setup
stub pacman '[ "$1" = "-T" ] && exit 1; exit 0'
: >"$H/.bashrc"; run; rc=$?
check "pacman -T error aborts" '[ $rc -ne 0 ] && ! grep -q "ok: all base packages present" "$H/out"'

echo "failures: $fails"; exit "$fails"
