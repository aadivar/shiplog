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

### Step 3: Calculate metrics
From the PRD feature table:
- Count total features
- Count features by status (not-started, in-progress, done, blocked)
- Calculate completion percentage

From PROGRESS.md:
- Current sprint number
- Active feature ID and name
- Last session date

From SECURITY.md:
- Last review date and severity

### Step 4: Display dashboard

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
- If phases aren't defined in PRD, show a single overall progress bar
- Keep output compact — this should fit on one screen
