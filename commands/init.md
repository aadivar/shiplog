# /shiplog init

Initialize Shiplog project tracking on the current project.

## Trigger
User runs `/shiplog init`

## Behavior

### Step 1: Check if already initialized
Check if `.shiplog/config.json` exists. If it does, inform the user:
> "Shiplog is already initialized for this project. Run `/shiplog config` to modify settings."

### Step 2: Detect project info
Run the stack detection script to auto-detect the tech stack:
```bash
bash scripts/detect-stack.sh
```
This returns a JSON array of detected technologies.

### Step 3: Gather project info
Use the `AskUserQuestion` tool to collect project details. Ask these questions:

**Question 1 — Project name & description:**
- Ask: "What's your project name and a brief description?"
- If `package.json`, `Cargo.toml`, or similar exists, suggest the name from there

**Question 2 — Tech stack:**
- Present the auto-detected stack and ask the user to confirm or modify
- Options: Confirm detected stack / Modify

**Question 3 — Tracking mode:**
- Ask: "How do you want to track features?"
- Options:
  - `Vibe mode` (Recommended) — Just build. Shiplog auto-discovers features from your commits and builds the PRD for you as you go. No upfront planning needed.
  - `Planned mode` — Define features upfront in the PRD, then build. Shiplog tracks status as you work.

**Question 4 — Agent model:**
- Ask: "Which model should background agents use?"
- Options:
  - `haiku` (Recommended) — Fastest and cheapest, great for append-only agent work
  - `sonnet` — More capable, slightly higher cost
  - `opus` — Most capable, highest cost

**Question 5 — Background agents:**
- Ask: "Which background agents do you want to enable?"
- Multi-select options (all enabled by default):
  - Specs Agent — Logs architecture decisions automatically
  - PRD Agent — Updates feature status from code changes
  - Security Agent — Reviews for OWASP Top 10 after each task
  - Memory Agent — Maintains code patterns and project memory

### Step 4: Create directory structure
Create the following directories and files:

```
docs/
├── features/
.shiplog/
```

### Step 5: Generate files from templates
Using the collected info, populate and write these files by reading each template from `templates/` and replacing the Handlebars placeholders:

1. **`.shiplog/config.json`** — from `templates/config.json.hbs`
   - Replace `{{projectName}}`, `{{projectDescription}}`, `{{stack}}`, `{{agentModel}}`, `{{agents.*}}`, `{{trackingMode}}`

2. **`docs/PRD.md`** — from `templates/PRD.md.hbs`
   - Replace `{{projectName}}`, `{{projectDescription}}`, `{{stack}}`, `{{date}}`
   - If **vibe mode**: use the vibe mode version (no empty feature rows, no phases, includes auto-discovery note)
   - If **planned mode**: use the planned version (empty F001 row, phase placeholders)

3. **`docs/SPECS.md`** — from `templates/SPECS.md.hbs`
   - Replace `{{projectName}}`, `{{stack}}`, `{{date}}`

4. **`docs/SECURITY.md`** — from `templates/SECURITY.md.hbs`
   - Replace `{{projectName}}`, `{{date}}`

5. **`docs/PROGRESS.md`** — from `templates/PROGRESS.md.hbs`
   - Replace `{{projectName}}`, `{{date}}`

Set `{{date}}` to today's date in `YYYY-MM-DD` format.

### Step 6: Update CLAUDE.md
- If `CLAUDE.md` exists in the project root, **append** the Shiplog orchestration section from `templates/CLAUDE.md.hbs` to the end of the file
- If `CLAUDE.md` does not exist, **create** it with the Shiplog orchestration section
- **Never overwrite** existing CLAUDE.md content
- Replace template variables with the user's selections

### Step 7: Confirm setup
Display a summary of what was created:

For **vibe mode**:
```
Shiplog initialized in vibe mode!

Created:
  docs/PRD.md         — Feature roadmap (auto-populated as you build)
  docs/SPECS.md       — Architecture decisions log
  docs/SECURITY.md    — Security review trail
  docs/PROGRESS.md    — Session tracker
  docs/features/      — Per-feature details
  .shiplog/config.json — Plugin settings
  Updated CLAUDE.md   — Added orchestration section

Agent model: haiku
Enabled agents: specs, prd, security, memory

Just start building — Shiplog will discover and track your features automatically!
```

For **planned mode**:
```
Shiplog initialized!

Created:
  docs/PRD.md         — Feature roadmap
  docs/SPECS.md       — Architecture decisions log
  docs/SECURITY.md    — Security review trail
  docs/PROGRESS.md    — Session tracker
  docs/features/      — Per-feature details
  .shiplog/config.json — Plugin settings
  Updated CLAUDE.md   — Added orchestration section

Agent model: haiku
Enabled agents: specs, prd, security, memory

Next steps:
  1. Add features to docs/PRD.md
  2. Or run `/shiplog feature "feature name"` to create one
  3. Start building — Shiplog will track your progress automatically!
```

## Important Rules
- Never overwrite existing files without asking
- If `docs/` already has files, ask before overwriting
- Always append to CLAUDE.md, never replace
- Validate that we're in a git repository (warn if not, since agents need `git diff`)
