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

# Check if agent launching is enabled
launch_enabled=$(grep -o '"launchAgentsAfterTask": *[a-z]*' "$CONFIG" | grep -o 'true\|false')
if [ "$launch_enabled" != "true" ]; then
  exit 0
fi

# Read agent model
model=$(grep -o '"model": *"[^"]*"' "$CONFIG" | head -1 | grep -o '"[^"]*"$' | tr -d '"')
if [ -z "$model" ]; then
  model="haiku"
fi

# Check which built-in agents are enabled
specs_enabled=$(grep -A1 '"specs"' "$CONFIG" | grep -o '"enabled": *[a-z]*' | grep -o 'true\|false')
prd_enabled=$(grep -A1 '"prd"' "$CONFIG" | grep -o '"enabled": *[a-z]*' | grep -o 'true\|false')
security_enabled=$(grep -A1 '"security"' "$CONFIG" | grep -o '"enabled": *[a-z]*' | grep -o 'true\|false')
memory_enabled=$(grep -A1 '"memory"' "$CONFIG" | grep -o '"enabled": *[a-z]*' | grep -o 'true\|false')

# Discover custom agents
custom_agents=""
if [ -d ".shiplog/agents" ]; then
  for agent_file in .shiplog/agents/*.md; do
    [ -f "$agent_file" ] && custom_agents="$custom_agents,$agent_file"
  done
  custom_agents="${custom_agents#,}"
fi

# Output agent launch instructions as a message to Claude
echo "SHIPLOG_AGENTS_TRIGGER"
echo "model=$model"
echo "specs=$specs_enabled"
echo "prd=$prd_enabled"
echo "security=$security_enabled"
echo "memory=$memory_enabled"
if [ -n "$custom_agents" ]; then
  echo "custom=$custom_agents"
fi
