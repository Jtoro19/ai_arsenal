# ai_arsenal

A clone-and-go AI tooling environment for EndeavourOS, organized by modes. This file
is the whole-project description. Read it before changing the repo (see the edit mode).

## What it is

AI coding tools (Claude Code as the main agent, herdr as the terminal multiplexer,
plus local tools) wired so each kind of work is a mode that turns on by folder and off
when you leave. Nothing is global that does not need to be.

## Layers

- Base, always on: git, direnv, herdr, Claude Code, the `mode` command.
- Arsenal, installed but off by default: Ollama (ROCm), gentle-ai, Engram, promptfoo.
- Modes, per-folder config that activates only what a task needs.

## The mode mechanism

- `modes/<name>/` is a template: `.envrc`, `AGENTS.md`, optionally `.mcp.json` and
  `.claude/skills/<skill>/SKILL.md`.
- `bin/mode.sh` (called as `mode`) copies a template into a folder, runs `direnv allow`,
  and symlinks `CLAUDE.md` and `GEMINI.md` to `AGENTS.md`.
- Entering the folder loads the mode (direnv); leaving unloads it.
- Global rules live in `global/AGENTS.md`, linked to `~/.claude/CLAUDE.md`.

## Modes

- notes: Obsidian vault work (skill: study-note).
- project: full projects, SDD plus Engram memory (skill: ml-notebook).
- scripts: quick automation, plain Claude Code.
- lab: authorized course labs over VPN (skill: pentest-writeup).
- ai-sec: LLM security testing against local Ollama (skill: llm-redteam).
- general: open-ended, human-guided work; no brief, conversation-led.
- research: GAIA seedbed, the IDS project and teaching; Engram memory
  (skills: ids-experiment, teaching-material).
- edit: maintenance of this repo itself.

## Project brief

- `templates/BRIEF.md` is the starting template for a project's task. Fill it and drop
  a `BRIEF.md` in the project; agents read it first (except in general mode).

## Repo layout

    ai_arsenal/
    install.sh          # bootstrap for a fresh machine
    PROJECT.md          # this file: the whole-project description
    SETUP.md            # the usage and setup guide
    README.md
    global/AGENTS.md    # global rules, linked to ~/.claude/CLAUDE.md
    bin/mode(.sh)       # the mode command
    modes/<name>/       # one template per mode
    templates/BRIEF.md  # project-brief template
    obsidian-vault/     # the notes vault
    workspace/          # real work (gitignored, recreated by install.sh)

## Key decisions

- Claude Code over OpenCode (Anthropic blocks subscriptions in third-party tools).
- herdr over tmux (agent-aware).
- direnv per folder over global config (toggle per task).
- Engram per mode, not global (memory is a feature of project and research modes).
- gentle-ai run per project, not global (avoids a huge ~/AGENTS.md).
- Ollama-ROCm local over cloud for ai-sec (targets are your own models, offline).
- bash shell; English for everything on disk; no em dashes.

## Keeping this file current

When the architecture changes (a new mode, layer, mechanism or key decision), update
this file and SETUP.md in the same change. See modes/edit/AGENTS.md.
