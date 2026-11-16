# ai_arsenal: Setup Guide

How to stand this environment up on a fresh EndeavourOS machine, and how the
mode system works. Conversation language is Spanish; everything in this repo is
documented in English on purpose. For the whole-project description, see PROJECT.md.

## Concept

Three layers:

- Base, always installed and on: git, direnv, herdr, Claude Code.
- Arsenal, installed but off by default: Ollama, gentle-ai, Engram, promptfoo.
  Turned on per task, never globally.
- Modes, per-folder config (.envrc, AGENTS.md, sometimes .mcp.json) that
  activates only what a task needs. Entering the folder turns the mode on;
  leaving turns it off.

## Quick setup (recommended)

On a fresh machine, clone and run the bootstrap:

    git clone https://github.com/Jtoro19/ai_arsenal.git ~/Documents/ai_arsenal
    cd ~/Documents/ai_arsenal
    ./install.sh
    exec bash

install.sh installs dependencies, wires ~/.bashrc (PATH, AI_ARSENAL, direnv),
recreates the workspace/ tree, links the global rules into ~/.claude, and allows
the committed direnv configs. herdr and Claude Code are checked, not installed;
set those up separately if the script reports them missing.

## Manual setup (reference)

1. Prerequisites: EndeavourOS, bash, kitty, git, yay, GitHub access.
2. Clone as above.
3. Install dependencies:

       sudo pacman -S --needed direnv ripgrep openvpn ollama-rocm nodejs npm uv
       yay -S --needed gentle-ai engram-bin
       npm install -g --allow-scripts=esbuild promptfoo

4. Wire the shell (adds PATH, AI_ARSENAL and direnv; computes the real path):

       cd ~/Documents/ai_arsenal
       ARSENAL="$(pwd)"
       printf '\n%s\n%s\n%s\n%s\n' \
         '# ai_arsenal' \
         "export AI_ARSENAL=\"$ARSENAL\"" \
         "export PATH=\"$ARSENAL/bin:\$PATH\"" \
         'eval "$(direnv hook bash)"' \
         >> ~/.bashrc
       exec bash

5. Allow direnv per folder the first time: cd into it, then run direnv allow.

## How the mode system works

- modes/<name>/ holds a template: .envrc, AGENTS.md, sometimes .mcp.json and
  .claude/skills/<skill>/SKILL.md.
- mode <name> [target_dir] copies the template into a folder, runs direnv allow,
  and symlinks CLAUDE.md and GEMINI.md to AGENTS.md so both agents read the same
  rules. Default target is the current directory.
- cd into the folder loads the mode (exports AI_MODE and mode-specific vars);
  cd out unloads it.
- Global rules live in global/AGENTS.md, linked to ~/.claude/CLAUDE.md, so every
  project inherits them. The mode folder adds task-specific rules on top.

## The modes

- notes: Obsidian vault work. Markdown notes and writeups.
- project: full projects (ML, analytics). SDD workflow, Engram memory via MCP.
- scripts: quick automation, plain Claude Code, no methodology.
- lab: authorized course labs over VPN, writeups to the vault.
- ai-sec: AI and LLM security testing against local Ollama models, with promptfoo.
- general: open-ended, human-guided work; no brief, conversation-led.
- research: GAIA seedbed work, the IDS project and teaching material; Engram memory.
- edit: maintenance of this repo itself (the repo root runs in this mode).

Each code mode carries a skill under .claude/skills/ that activates with it.

## Apply a mode

    mode project workspace/specialization_ai/my-project
    cd workspace/specialization_ai/my-project

## Project brief

- templates/BRIEF.md is the starting template for a task. Fill it (by hand or by
  asking Claude on the web), drop a BRIEF.md in the project root, and the agent
  reads it first. The general mode does not use a brief.

## Editing the arsenal

- The repo root runs in edit mode. Open Claude Code there, describe the change
  (a new mode, a changed rule), and it reads PROJECT.md, makes the change, keeps
  PROJECT.md and this guide in sync, and commits.

## Add a new mode

    mkdir modes/<name>
    # create modes/<name>/.envrc      (at least: export AI_MODE=<name>)
    # create modes/<name>/AGENTS.md   (the rules for that kind of work)

## Repo layout

    ai_arsenal/
    install.sh          # bootstrap for a fresh machine
    PROJECT.md          # the whole-project description
    SETUP.md            # this file (usage and setup guide)
    README.md
    global/AGENTS.md    # global rules, linked to ~/.claude/CLAUDE.md
    bin/mode(.sh)       # the mode command
    modes/<name>/       # one template per mode
    templates/BRIEF.md  # project-brief template
    obsidian-vault/     # the notes vault
    workspace/          # your real work (gitignored, recreated by install.sh)

## Gotchas

- workspace/ is gitignored: real work never lands in this repo.
- git does not track empty folders; .gitkeep files keep the skeleton alive.
- On a fresh clone, committed .envrc files start blocked until direnv allow
  (install.sh does this for the vault and the repo root).
- Claude Pro and Max subscriptions only work in Claude Code, not in third-party
  tools, so OpenCode would need its own paid plan or local models.
