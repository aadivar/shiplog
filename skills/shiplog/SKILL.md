---
name: Shiplog Orchestrator
description: Session orchestration, progress tracking, and background agent management
version: "1.0.1"
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

## CRITICAL: Post-Commit Agent Launching

**After every `git commit` you perform**, you MUST check for `.shiplog/config.json`. If it exists, launch background agents immediately. Do NOT wait for hook output. Do NOT skip this step.

### How to launch agents after a commit

1. **Read config**: Read `.shiplog/config.json` to get agent model and which agents are enabled.
   - Handle both config formats:
     - Nested: `{ "agents": { "model": "sonnet", "specs": { "enabled": true } } }`
     - Flat: `{ "agentModel": "sonnet", "agents": { "specs": true } }`

2. **Read agent prompts**: For each enabled agent, read its prompt file from the plugin's `agents/` directory:
   - `agents/specs-agent.md`
   - `agents/prd-agent.md`
   - `agents/security-agent.md`
   - `agents/memory-agent.md`

3. **Launch agents** using the `Agent` tool with `run_in_background: true` and `subagent_type: "shiplog:{agent}-agent"`:
   - **Specs Agent** → updates `docs/SPECS.md`
   - **PRD Agent** → updates `docs/PRD.md` and `docs/PROGRESS.md`
   - **Security Agent** → updates `docs/SECURITY.md`
   - **Memory Agent** → updates memory files

4. **Launch in parallel**: Launch specs, PRD, and security agents together. Memory agent can also run in parallel.

5. **Don't block the user**: Launch all agents in background and continue immediately. Never wait for agents to complete before responding.

### Fallback: Hook trigger
If you see `SHIPLOG_AGENTS_TRIGGER` output from a PostToolUse hook, treat it the same way — launch agents. But do NOT rely on this; always proactively launch after commits.

### Custom Agents
If `.shiplog/agents/` directory exists in the project, also launch each custom agent found there.

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
- Agent prompts: `agents/` (in plugin root)
- Templates: `templates/` (in plugin root)
