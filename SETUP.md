# ai_arsenal: Setup Guide

How to stand this environment up on a fresh EndeavourOS machine, and how the
mode system works. Conversation language is Spanish; everything in this repo
is documented in English on purpose.

## Concept

Three layers:

- **Base**: always installed, always on: git, direnv, (later) herdr, Claude Code.
- **Arsenal**: installed but off by default: Ollama, OpenCode, gentle-ai + Engram,
  promptfoo. Turned on per task, never globally.
- **Modes**: per-folder config (`.envrc` + `AGENTS.md`) that activates only what
  a given task needs. Entering the folder turns the mode on; leaving turns it off.

## Prerequisites

- EndeavourOS (Arch-based), `bash`, a terminal (kitty).
- `git`, and GitHub access (SSH key or HTTPS).

## 1. Clone

Pick where it lives (this machine used `~/Documents/ai_arsenal`):

    git clone https://github.com/Jtoro19/ai_arsenal.git ~/Documents/ai_arsenal
    cd ~/Documents/ai_arsenal

## 2. Install dependencies

Only direnv is required for the mode system itself:

    sudo pacman -S --needed direnv

Other tools (herdr, Claude Code, Ollama, gentle-ai, promptfoo) are installed as
each mode is built; see each mode's notes.

## 3. Wire the shell (bash)

This appends two lines to `~/.bashrc`: puts the repo's `bin/` on PATH (so the
`mode` command works) and activates direnv. It computes the real clone path, so
it works wherever you cloned:

    cd ~/Documents/ai_arsenal          # or wherever you cloned it
    ARSENAL="$(pwd)"
    printf '\n%s\n%s\n%s\n' \
      '# ai_arsenal' \
      "export PATH=\"$ARSENAL/bin:\$PATH\"" \
      'eval "$(direnv hook bash)"' \
      >> ~/.bashrc
    exec bash

## 4. Allow direnv per mode folder

For security, direnv ignores any `.envrc` until you approve it once:

    cd <mode-folder>
    direnv allow

On a fresh clone the committed `.envrc` files start "blocked", this is expected.

## How the mode system works

- `modes/<name>/` holds a template: an `.envrc` and an `AGENTS.md`.
- `mode <name> [target_dir]` copies that template into a folder (never overwriting)
  and runs `direnv allow` there. Default target is the current directory.
- `cd` into that folder → direnv loads the mode (exports `AI_MODE` and friends).
  `cd` out → direnv unloads it.
- The `AGENTS.md` in the folder tells the coding agent the rules for that mode;
  Claude Code reads `CLAUDE.md`, so symlink it where needed:
  `ln -s AGENTS.md CLAUDE.md`.

The `mode` script is self-locating (`bin/mode.sh`, called as `bin/mode`), so it
finds the repo from its own path regardless of where you run it.

## Apply a mode

    mode notes ~/Documents/ai_arsenal/obsidian-vault
    cd ~/Documents/ai_arsenal/obsidian-vault
    echo "$AI_MODE"        # -> notes

## Add a new mode

    mkdir modes/<name>
    # create modes/<name>/.envrc      (at least: export AI_MODE=<name>)
    # create modes/<name>/AGENTS.md   (the rules for that kind of work)

## Repo layout

    ai_arsenal/
    ├── install.sh          # bootstrap (WIP)
    ├── README.md
    ├── SETUP.md            # this file
    ├── global/AGENTS.md    # global rules
    ├── bin/mode(.sh)       # the `mode` command
    ├── modes/<name>/       # one template per mode
    ├── obsidian-vault/     # the notes vault
    └── workspace/          # YOUR real work (gitignored, recreated locally)

## Gotchas

- `workspace/` is gitignored on purpose: real work (labs, projects) lives there
  and must not land in this repo. Recreate the tree on a new machine with
  `mkdir -p workspace/{certifications,specialization_ai,university}`.
- git does not track empty folders; `.gitkeep` files keep the skeleton alive.
- The `.bashrc` PATH line must point to the real clone path, step 3 computes it.
