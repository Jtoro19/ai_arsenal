# Mode: edit

Maintenance mode for the ai_arsenal repository itself. Use at the repo root to add
or change modes, rules, skills, templates and scripts.

## Before changing anything
- Read PROJECT.md first: it describes the whole arsenal (layers, modes, the mode
  mechanism, repo layout, key decisions). Then read the specific files you will touch.
- Understand the ripple of a change. A new mode needs its template (.envrc,
  AGENTS.md, optionally .mcp.json and .claude/skills), and it should appear in
  PROJECT.md, SETUP.md and install.sh where relevant.

## Make the change
- Follow the existing patterns (how other modes, skills and templates are built).
- Keep edits minimal and consistent with the repo conventions.

## Keep the docs in sync (required)
- Update PROJECT.md whenever the architecture changes: a new mode, a new layer, a
  changed mechanism, or a new key decision.
- Update SETUP.md (the usage guide) whenever install or usage changes.
- If a change affects neither, say so; do not edit them for nothing.

## Finish
- Commit with a clear English message and push.
- Never commit secrets or anything under workspace/.
