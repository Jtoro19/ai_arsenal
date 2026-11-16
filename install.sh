#!/usr/bin/env bash
# ai_arsenal bootstrap: set up the whole environment on a fresh machine.
set -euo pipefail

ARSENAL="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
cd "$ARSENAL"
say() { printf '\n==> %s\n' "$1"; }

say "ai_arsenal setup, repo at $ARSENAL"

say "Installing base packages (pacman)"
sudo pacman -S --needed --noconfirm \
  direnv ripgrep openvpn ollama-rocm git base-devel nodejs npm uv

if command -v yay >/dev/null; then
  say "Installing AUR packages (yay)"
  yay -S --needed --noconfirm gentle-ai engram-bin
else
  echo "WARN: yay not found. Install gentle-ai and engram-bin manually."
fi

say "Installing promptfoo (npm)"
npm install -g --allow-scripts=esbuild promptfoo

say "Checking tools installed separately"
command -v herdr >/dev/null && echo "ok: herdr present" \
  || echo "WARN: herdr missing. Install from https://github.com/ogulcancelik/herdr"
command -v claude >/dev/null && echo "ok: claude present" \
  || echo "WARN: Claude Code missing. Install with: yay -S claude-code"

say "Wiring ~/.bashrc (idempotent)"
if ! grep -q 'AI_ARSENAL' ~/.bashrc; then
  printf '\n%s\n%s\n%s\n%s\n' \
    '# ai_arsenal' \
    "export AI_ARSENAL=\"$ARSENAL\"" \
    "export PATH=\"$ARSENAL/bin:\$PATH\"" \
    'eval "$(direnv hook bash)"' \
    >> ~/.bashrc
else
  echo "ok: ~/.bashrc already wired"
fi

say "Recreating workspace/ tree"
mkdir -p workspace/{certifications,specialization_ai,university}

say "Linking global agent rules into ~/.claude"
mkdir -p ~/.claude
if [ -e ~/.claude/CLAUDE.md ] && [ ! -L ~/.claude/CLAUDE.md ]; then
  echo "WARN: ~/.claude/CLAUDE.md exists and is a real file, leaving it alone."
else
  ln -sf "$ARSENAL/global/AGENTS.md" ~/.claude/CLAUDE.md
  echo "ok: global rules linked"
fi

say "Allowing committed direnv configs"
[ -f obsidian-vault/.envrc ] && ( cd obsidian-vault && direnv allow )
[ -f .envrc ] && direnv allow

say "Done. Run 'exec bash' to load PATH, AI_ARSENAL and direnv."
