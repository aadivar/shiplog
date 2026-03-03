#!/bin/bash
# validate-config.sh — Validate .shiplog/config.json exists and has required fields

CONFIG=".shiplog/config.json"

if [ ! -f "$CONFIG" ]; then
  echo "ERROR: $CONFIG not found. Run /shiplog init first."
  exit 1
fi

# Check for required fields
required_fields=("version" "project.name" "agents.model" "docs.path")

for field in "${required_fields[@]}"; do
  # Use jq-style dot notation check with grep
  key=$(echo "$field" | tr '.' '\n' | tail -1)
  if ! grep -q "\"$key\"" "$CONFIG"; then
    echo "ERROR: Missing required field '$field' in $CONFIG"
    exit 1
  fi
done

echo "OK: Config is valid"
exit 0
