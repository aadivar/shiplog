# /shiplog status

Display project status dashboard.

## Trigger
User runs `/shiplog status`

## Behavior

### Step 1: Validate setup
Check that `.shiplog/config.json` exists. If not:
> "Shiplog is not initialized. Run `/shiplog init` first."

### Step 2: Read project files
Read these files:
- `docs/PROGRESS.md` — Current sprint, active feature, session log
- `docs/PRD.md` — Feature table with statuses
- `docs/SECURITY.md` — Last security review entry

### Step 3: Read config
Read `.shiplog/config.json` and handle both config formats:
- **Nested (template)**: `{ "project": { "name": "..." }, "agents": { "model": "haiku", "specs": { "enabled": true } }, "orchestration": { ... } }`
- **Flat (legacy)**: `{ "projectName": "...", "agentModel": "haiku", "agents": { "specs": true } }`

Extract: project name, agent model, which agents are enabled.

### Step 4: Calculate metrics
From the PRD feature table:
- Count total features (rows matching `| F\d+ |`)
- Count features by status (not-started, in-progress, done, blocked)
- Calculate completion percentage
- **If the table has no Status column** (no `not-started`, `in-progress`, `done`, or `blocked` values found), report: "Status tracking not set up — features will be tracked after the next commit triggers the PRD agent."

From PROGRESS.md:
- Current sprint number
- Active feature ID and name
- Last session date

From SECURITY.md:
- Last review date and severity

### Step 5: Display dashboard

```
Shiplog Status — {Project Name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sprint: {N}
Active Feature: {ID} — {name} ({status})
Last Session: {date}

Features: {done}/{total} done ({percentage}%)
  Phase 1 (Foundation): {progress_bar} {phase_pct}%
  Phase 2 (Core):       {progress_bar} {phase_pct}%
  Phase 3 (Advanced):   {progress_bar} {phase_pct}%

  not-started: {count}  |  in-progress: {count}  |  done: {count}  |  blocked: {count}

Security: Last review {date} — {severity}

Config: .shiplog/config.json
  Agent model: {model}
  Agents: {enabled_list}
```

Use `█` for filled progress and `░` for empty (12 chars total).

### Rules
- If PRD has no features yet, show "No features defined yet. Run `/shiplog feature` to add one."
- If PRD has features but no Status column, show the feature count and note that status tracking will activate after the next commit
- If phases aren't defined in PRD, show a single overall progress bar
- Handle both config formats (nested and flat) gracefully
- Keep output compact — this should fit on one screen
