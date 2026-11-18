#!/usr/bin/env bash
# ai_arsenal bootstrap: set up the whole environment on a fresh machine.
#
# Run it as your user, never with sudo. It calls sudo itself, only for pacman,
# and only when packages are actually missing. Every step checks before it
# changes anything, so it is safe to re-run.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR: run install.sh as your user, not as root or with sudo." >&2
  exit 1
fi

ARSENAL="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
cd "$ARSENAL"
say() { printf '\n==> %s\n' "$1"; }
warn() { printf 'WARN: %s\n' "$1"; }

say "ai_arsenal setup, repo at $ARSENAL"

# Ollama is the base package plus a GPU backend add-on picked from the GPU vendor.
gpu_vendors="$(cat /sys/class/drm/card*/device/vendor 2>/dev/null || true)"
if grep -qx 0x10de <<<"$gpu_vendors"; then
  ollama_backend=ollama-cuda        # NVIDIA
elif grep -qx 0x1002 <<<"$gpu_vendors"; then
  ollama_backend=ollama-rocm        # AMD
else
  ollama_backend=""                 # CPU only
fi

say "Installing base packages (pacman)"
base_pkgs=(direnv ripgrep openvpn git base-devel nodejs npm uv ollama)
[ -n "$ollama_backend" ] && base_pkgs+=("$ollama_backend")
missing="$(pacman -T "${base_pkgs[@]}" || true)"
if [ -z "$missing" ]; then
  echo "ok: all base packages present"
else
  echo "missing: $(tr '\n' ' ' <<<"$missing")"
  # shellcheck disable=SC2086  # word splitting of the package list is intended
  sudo pacman -S --needed --noconfirm $missing || {
    echo "ERROR: pacman failed. Run this yourself, then re-run install.sh:" >&2
    echo "  sudo pacman -S --needed $(tr '\n' ' ' <<<"$missing")" >&2
    exit 1
  }
fi

say "Installing AUR packages (yay)"
missing="$(pacman -T gentle-ai engram-bin || true)"
if [ -z "$missing" ]; then
  echo "ok: all AUR packages present"
elif command -v yay >/dev/null; then
  # shellcheck disable=SC2086
  yay -S --needed --noconfirm $missing
else
  warn "yay not found. Install manually: $(tr '\n' ' ' <<<"$missing")"
fi

# Global npm installs default to /usr (root-owned). Keep them per user instead:
# if the npm prefix is outside $HOME, point it at ~/.local (written to ~/.npmrc).
say "Installing promptfoo (npm, per user, no sudo)"
npm_prefix="$(npm config get prefix)"
case "$npm_prefix" in
  "$HOME"/*) echo "ok: npm prefix is per user ($npm_prefix)" ;;
  *)
    npm config set prefix "$HOME/.local"
    npm_prefix="$HOME/.local"
    echo "set: npm prefix -> $npm_prefix (in ~/.npmrc)"
    ;;
esac
npm_bin="$npm_prefix/bin"
mkdir -p "$npm_bin"
export PATH="$npm_bin:$PATH"
if [ -x "$npm_bin/promptfoo" ]; then
  echo "ok: promptfoo present ($npm_bin/promptfoo). Update with: npm update -g promptfoo"
else
  npm install -g --allow-scripts=esbuild promptfoo
fi

say "Checking tools installed separately"
if command -v herdr >/dev/null; then echo "ok: herdr present"
else warn "herdr missing. Install from https://github.com/ogulcancelik/herdr"; fi
if command -v claude >/dev/null; then echo "ok: claude present"
else warn "Claude Code missing. Install with: yay -S claude-code"; fi

# Each line is added only if it is not already there, so re-runs change nothing.
say "Wiring ~/.bashrc (idempotent)"
bashrc="$HOME/.bashrc"
touch "$bashrc"
add_line() {
  if grep -qxF "$1" "$bashrc"; then
    echo "ok: $1"
  else
    printf '%s\n' "$1" >>"$bashrc"
    echo "added: $1"
  fi
}
grep -qxF '# ai_arsenal' "$bashrc" || printf '\n# ai_arsenal\n' >>"$bashrc"
npm_bin_rc="${npm_bin/#$HOME/\$HOME}"    # write $HOME, not the literal path
if grep -qF -e "$npm_bin_rc" -e "$npm_bin" "$bashrc"; then
  echo "ok: $npm_bin_rc already on PATH in ~/.bashrc"
else
  add_line "export PATH=\"$npm_bin_rc:\$PATH\""
fi
add_line "export PATH=\"$ARSENAL/bin:\$PATH\""
# shellcheck disable=SC2016  # written literally, expanded by bash at startup
add_line 'eval "$(direnv hook bash)"'
add_line "export AI_ARSENAL=\"$ARSENAL\""

say "Recreating workspace/ tree"
mkdir -p workspace/{certifications,specialization_ai,university}

say "Linking global agent rules into ~/.claude"
mkdir -p ~/.claude
if [ -e ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ]; then
  warn "$HOME/.claude/CLAUDE.md exists and is a real file, leaving it alone."
else
  ln -sfn "$ARSENAL/global/AGENTS.md" ~/.claude/CLAUDE.md
  echo "ok: global rules linked"
fi

say "Allowing committed direnv configs"
for dir in obsidian-vault .; do
  if [ -f "$dir/.envrc" ]; then
    direnv allow "$dir"
    echo "ok: allowed $dir/.envrc"
  fi
done

say "Done. Run 'exec bash' to load PATH, AI_ARSENAL and direnv."
