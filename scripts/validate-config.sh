#!/bin/bash
# validate-config.sh — Validate .shiplog/config.json format and fix common issues
# Run from project root: bash <shiplog-path>/scripts/validate-config.sh

CONFIG=".shiplog/config.json"

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: $CONFIG not found. Run /shiplog init first."
  exit 1
fi

# Use python3 for reliable JSON validation (handles both config formats)
python3 -c "
import json, sys

try:
    c = json.load(open('$CONFIG'))
except json.JSONDecodeError as e:
    print(f'ERROR: Invalid JSON in $CONFIG: {e}')
    sys.exit(1)

errors = []
warnings = []

# Check project name (nested or flat)
name = c.get('project', {}).get('name') or c.get('projectName')
if not name:
    errors.append('Missing project name (project.name or projectName)')
else:
    print(f'Project: {name}')

# Check agents
agents = c.get('agents', {})
if not agents:
    errors.append('Missing agents config')
else:
    model = agents.get('model') or c.get('agentModel', 'haiku')
    print(f'Agent model: {model}')

    for agent in ['specs', 'prd', 'security', 'memory']:
        val = agents.get(agent)
        if isinstance(val, bool):
            status = 'enabled' if val else 'disabled'
            warnings.append(f'Agent \"{agent}\" uses flat format (bool). Template uses {{ \"enabled\": true }}')
        elif isinstance(val, dict):
            status = 'enabled' if val.get('enabled') else 'disabled'
        elif val is None:
            status = 'not configured'
        else:
            status = f'unexpected type: {type(val).__name__}'
            errors.append(f'Agent \"{agent}\" has unexpected value: {val}')
        print(f'  {agent}: {status}')

# Check orchestration
orch = c.get('orchestration', {})
launch = orch.get('launchAgentsAfterTask')
if launch is None:
    warnings.append('Missing orchestration.launchAgentsAfterTask — agents default to launching')
else:
    print(f'Launch agents after task: {launch}')

if warnings:
    print()
    for w in warnings:
        print(f'WARNING: {w}')

if errors:
    print()
    for e in errors:
        print(f'ERROR: {e}')
    sys.exit(1)

print()
print('Config is valid.')
" 2>&1
