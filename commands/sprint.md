# /shiplog sprint

Start a new sprint with session log archival.

## Trigger
User runs `/shiplog sprint <n>` or `/shiplog sprint`

## Behavior

### Step 1: Validate setup
Check that `.shiplog/config.json` exists. If not:
> "Shiplog is not initialized. Run `/shiplog init` first."

### Step 2: Determine sprint number
- If user provided a number (e.g., `/shiplog sprint 3`), use that
- If no number, read `docs/PROGRESS.md` to get current sprint and increment by 1

### Step 3: Archive previous sprint
Read `docs/PROGRESS.md` and extract the session log entries for the current sprint.

Create an archive file:
- Path: `docs/archive/sprint-{N}.md` (create `docs/archive/` if it doesn't exist)
- Content: The session log entries from the completed sprint, with a header

### Step 4: Update PROGRESS.md
Edit `docs/PROGRESS.md`:
- Update "Sprint" in Current State to the new sprint number
- Clear the Session Log section and add a fresh table header for the new sprint
- Update "Last Session" date
- Keep the "What's Next" section (user will update it)

### Step 5: Generate sprint summary
Count from the archived sprint:
- Number of session entries
- Features completed (cross-reference with PRD.md)
- Features still in-progress

### Step 6: Confirm and ask for focus

```
Sprint {N} started!

Sprint {N-1} summary:
  Sessions: {count}
  Features completed: {count}
  Features in-progress: {count}
  Archived to: docs/archive/sprint-{N-1}.md

What's the focus for Sprint {N}?
```

Use `AskUserQuestion` to ask for the sprint focus, then update the "Focus" field in PROGRESS.md's Current State.

## Rules
- Always archive before clearing — never lose session history
- Sprint numbers must be positive integers
- Don't allow going backwards (sprint 2 after sprint 3)
- Create docs/archive/ directory if it doesn't exist
