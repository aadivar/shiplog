# /shiplog config

Show and edit Shiplog configuration.

## Trigger
User runs `/shiplog config`

## Behavior

### Step 1: Validate setup
Check that `.shiplog/config.json` exists. If not:
> "Shiplog is not initialized. Run `/shiplog init` first."

### Step 2: Read and display config
Read `.shiplog/config.json` and display current settings:

```
Shiplog Configuration
━━━━━━━━━━━━━━━━━━━━

Project: {name}
Description: {description}
Stack: {stack list}

Agent Model: {model}
Agents:
  Specs:    {enabled/disabled}
  PRD:      {enabled/disabled}
  Security: {enabled/disabled}
  Memory:   {enabled/disabled}

Orchestration:
  Read progress on start: {yes/no}
  Launch agents after task: {yes/no}
  Trigger method: {triggerMethod}
  Max parallel agents: {n}

Config file: .shiplog/config.json
```

### Step 3: Ask what to change
Use `AskUserQuestion`:
- "What would you like to change?"
- Options:
  - Agent model (currently: {model})
  - Toggle agents on/off
  - Update project info
  - Nothing, looks good

### Step 4: Apply changes
Based on user selection, use the `Edit` tool to update `.shiplog/config.json`.

If the agent model is changed, also update the CLAUDE.md Shiplog section to reflect the new model.

### Step 5: Confirm
```
Configuration updated!
  Changed: {what changed}
```

## Rules
- Always show current config before asking for changes
- Validate model is one of: haiku, sonnet, opus
- Don't allow invalid JSON in the config file
- If user changes agent model, update CLAUDE.md too
