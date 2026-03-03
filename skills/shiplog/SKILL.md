---
name: Shiplog Orchestrator
description: Session orchestration, progress tracking, and background agent management
version: "1.0.0"
---

# Shiplog — Session Orchestration Skill

You have the Shiplog plugin active. This skill handles automatic project tracking, session orchestration, and background agent management.

## Session Start Behavior

At the start of every session, you MUST:

1. **Read progress**: Read `docs/PROGRESS.md` to understand the current project state
2. **Display status**: Show a one-line status summary:
   ```
   Shiplog: Sprint {N} | Feature {ID} ({status}) | {done}/{total} features done
   ```
3. **Load context**: Use the information from PROGRESS.md to understand:
   - What sprint we're on
   - What feature was last worked on
   - What was done in the last session
   - What's planned next

## Agent Launching

When you see `SHIPLOG_AGENTS_TRIGGER` output from a hook (after git commits), launch the configured background agents.

### Reading the trigger
The hook outputs:
```
SHIPLOG_AGENTS_TRIGGER
model=haiku
specs=true
prd=true
security=true
memory=true
```

### Launching agents
For each enabled agent, use the `Agent` tool with `run_in_background: true`:

1. **Specs Agent** (if specs=true):
   - Read the prompt from `agents/specs-agent.md`
   - Launch with model from config
   - Agent updates `docs/SPECS.md`

2. **PRD Agent** (if prd=true):
   - Read the prompt from `agents/prd-agent.md`
   - Launch with model from config
   - Agent updates `docs/PRD.md` and `docs/PROGRESS.md`

3. **Security Agent** (if security=true):
   - Read the prompt from `agents/security-agent.md`
   - Launch with model from config
   - Agent updates `docs/SECURITY.md`

4. **Memory Agent** (if memory=true):
   - Read the prompt from `agents/memory-agent.md`
   - Launch with model from config
   - Agent updates memory files

Launch specs, PRD, and security agents in parallel. Launch the memory agent after the others complete (it benefits from their output).

### Custom Agents
If the trigger includes `custom=<comma-separated-paths>`, also launch each custom agent:
- Read the agent prompt from the file path (e.g., `.agents/a11y-agent.md`)
- Launch with the configured model and `run_in_background: true`
- Custom agents run in parallel with the built-in agents (specs, PRD, security)

### Agent failure handling
- If any agent fails, it fails silently — do not interrupt the user's work
- Do not retry failed agents
- Do not report agent results unless the user asks

## Available Commands

- `/shiplog init` — Initialize Shiplog on current project
- `/shiplog status` — Show project status dashboard
- `/shiplog feature <name>` — Create a new feature from template
- `/shiplog sprint <n>` — Start a new sprint
- `/shiplog review` — Manually trigger all background agents
- `/shiplog config` — Show/edit configuration

## File Locations

- Config: `.shiplog/config.json`
- PRD: `docs/PRD.md`
- Specs: `docs/SPECS.md`
- Security: `docs/SECURITY.md`
- Progress: `docs/PROGRESS.md`
- Features: `docs/features/`
- Agent prompts: `agents/`
- Templates: `templates/`
