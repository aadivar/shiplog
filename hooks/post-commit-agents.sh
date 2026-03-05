#!/bin/bash
# post-commit-agents.sh — Triggered by PostToolUse hook after Bash tool use
# Only acts on git commit commands. Reads .shiplog/config.json and signals agent launch.

# The hook fires on ALL Bash tool uses — check if this was a git commit
TOOL_INPUT="${TOOL_INPUT:-}"
if ! echo "$TOOL_INPUT" | grep -q "git commit"; then
  exit 0
fi

CONFIG=".shiplog/config.json"

if [ ! -f "$CONFIG" ]; then
  exit 0
fi

# Use python3 for reliable JSON parsing (available on macOS, most Linux)
PARSED=$(python3 -c "
import json, sys
try:
    c = json.load(open('$CONFIG'))
except:
    sys.exit(1)

# Handle both flat and nested config formats
# Nested (template): { orchestration: { launchAgentsAfterTask: true }, agents: { model: 'haiku', specs: { enabled: true } } }
# Flat (legacy):     { agentModel: 'haiku', agents: { specs: true } }

# Check if agent launching is enabled
orch = c.get('orchestration', {})
launch = orch.get('launchAgentsAfterTask', True)  # Default to true if not set
if not launch:
    sys.exit(1)

# Get model
agents = c.get('agents', {})
if isinstance(agents.get('model'), str):
    model = agents['model']
else:
    model = c.get('agentModel', 'haiku')

# Get agent enabled states — handle both formats
def is_enabled(key):
    val = agents.get(key)
    if isinstance(val, bool):
        return val
    if isinstance(val, dict):
        return val.get('enabled', False)
    return False

print(f'model={model}')
print(f'specs={str(is_enabled(\"specs\")).lower()}')
print(f'prd={str(is_enabled(\"prd\")).lower()}')
print(f'security={str(is_enabled(\"security\")).lower()}')
print(f'memory={str(is_enabled(\"memory\")).lower()}')
" 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$PARSED" ]; then
  exit 0
fi

# Discover custom agents
custom_agents=""
if [ -d ".shiplog/agents" ]; then
  for agent_file in .shiplog/agents/*.md; do
    [ -f "$agent_file" ] && custom_agents="$custom_agents,$agent_file"
  done
  custom_agents="${custom_agents#,}"
fi

# Output agent launch instructions
echo "SHIPLOG_AGENTS_TRIGGER"
echo "$PARSED"
if [ -n "$custom_agents" ]; then
  echo "custom=$custom_agents"
fi
