# /shiplog review

Manually trigger all background agents.

## Trigger
User runs `/shiplog review`

## Behavior

### Step 1: Validate setup
Check that `.shiplog/config.json` exists. If not:
> "Shiplog is not initialized. Run `/shiplog init` first."

### Step 2: Read config
Read `.shiplog/config.json` to determine:
- Which agents are enabled
- What model to use

### Step 3: Launch agents
For each enabled agent, launch it using the `Agent` tool with `run_in_background: true`:

1. **Specs Agent** — Read prompt from `agents/specs-agent.md`, launch with configured model
2. **PRD Agent** — Read prompt from `agents/prd-agent.md`, launch with configured model
3. **Security Agent** — Read prompt from `agents/security-agent.md`, launch with configured model
4. **Memory Agent** — Read prompt from `agents/memory-agent.md`, launch with configured model

Launch specs, PRD, and security in parallel. Launch memory after the others.

### Step 4: Confirm
```
Shiplog review started!

Launching agents (model: {model}):
  - Specs Agent: updating docs/SPECS.md
  - PRD Agent: updating docs/PRD.md
  - Security Agent: updating docs/SECURITY.md
  - Memory Agent: updating memory files

Agents are running in the background. Continue working — they won't interrupt you.
```

## Rules
- If no agents are enabled, inform the user: "No agents are enabled. Run `/shiplog config` to enable them."
- This is a manual trigger — it works the same as the automatic hook-based trigger
- Don't wait for agents to complete before confirming to the user
