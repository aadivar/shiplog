# /shiplog upgrade

Upgrade Shiplog to the latest version from GitHub.

## Trigger
User runs `/shiplog upgrade`

## Behavior

### Step 1: Find plugin install path
Run:
```bash
find ~/.claude/plugins -type d -name "shiplog" 2>/dev/null | head -1
```
If not found, try:
```bash
find ~/.claude/plugins -type d -name "aadivar-shiplog*" 2>/dev/null | head -1
```
If still not found:
> "Could not find Shiplog plugin directory. Try reinstalling with `/plugin install shiplog@shiplog`."

### Step 2: Pull latest
`cd` into the plugin directory and pull:
```bash
cd <plugin_path> && git pull origin main
```

### Step 3: Confirm
Display:
```
Shiplog upgraded to latest!

To see what changed:
  https://github.com/aadivar/shiplog/commits/main

Restart Claude Code to apply changes.
```

## Rules
- Never modify the user's project files — this only updates the plugin itself
- If `git pull` fails (dirty state, merge conflict), suggest reinstalling instead
