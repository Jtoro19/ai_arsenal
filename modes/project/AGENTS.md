# Mode: project

Full project engineering (ML, analytics, apps). Follow Spec-Driven Development.

## Workflow (SDD)

- Explore read-only, then propose, spec, design, tasks, apply, verify.
- Stay in plan mode until the task list is approved; only then apply.
- For large changes, have a second model review the plan before execution.

## Agents

- Claude Code is the main agent.
- Use Gemini / Antigravity for plan review and second opinions, not as the
  primary editor.

## Memory

- Persist decisions and bug root causes to Engram with What, Why, Where, Learned.
- Keep this file concise; move history into Engram, not into instructions.

## Python projects

- Use uv for environments and dependencies.
- Validate structured or LLM outputs against a schema (PydanticAI) before use.

## Done means verified

- Run tests and linters before declaring a task complete.
