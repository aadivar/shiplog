# /shiplog agent

Create or list custom background agents.

## Trigger
User runs `/shiplog agent <name>` or `/shiplog agent list`

## Behavior

### List agents: `/shiplog agent list`

1. Read `.shiplog/config.json` to get built-in agent status
2. Scan `.shiplog/agents/` for custom agent files
3. Display:

```
Shiplog Agents
━━━━━━━━━━━━━━

Built-in:
  specs    — enabled  — Logs architecture decisions
  prd      — enabled  — Updates feature status
  security — enabled  — OWASP Top 10 reviews
  memory   — enabled  — Code patterns & project memory

Custom:
  a11y     — .shiplog/agents/a11y-agent.md
  perf     — .shiplog/agents/perf-agent.md

Model: haiku
```

If no custom agents exist, show "No custom agents. Run `/shiplog agent <name>` to create one."

### Create agent: `/shiplog agent <name>`

1. Check that `.shiplog/config.json` exists. If not, prompt to run `/shiplog init`.

2. Create `.shiplog/agents/` directory if it doesn't exist.

3. Ask the user with `AskUserQuestion`:
   - "What should this agent do?" (free text)
   - "Where should it write output?" Options:
     - `docs/{name}.md` (Recommended) — New file in docs/
     - `docs/SPECS.md` — Append to specs
     - Custom path

4. Read the template from `templates/custom-agent.md.hbs` and create the agent file:
   - Path: `.shiplog/agents/{name}-agent.md`
   - Replace `{{agentName}}`, `{{agentDescription}}`, `{{outputFile}}`

5. If output file doesn't exist, create it with a basic header.

6. Update `.shiplog/config.json` — add the agent to `agents.custom` array:
   ```json
   {
     "name": "a11y",
     "file": ".shiplog/agents/a11y-agent.md",
     "output": "docs/a11y.md",
     "enabled": true
   }
   ```

7. Confirm:
   ```
   Custom agent created: {name}
     Prompt: .shiplog/agents/{name}-agent.md
     Output: docs/{name}.md
     Status: enabled

   Edit the prompt file to customize behavior.
   The agent will run automatically after each commit.
   ```

## Rules
- Agent names must be kebab-case (lowercase, hyphens)
- Never overwrite an existing agent file
- Custom agents run alongside built-in agents with the same model
- Custom agent prompt files are fully editable by the user
