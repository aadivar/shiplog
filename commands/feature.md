# /shiplog feature

Create a new feature file and add it to the PRD.

## Trigger
User runs `/shiplog feature "<name>"` or `/shiplog feature`

## Behavior

### Step 1: Validate setup
Check that `.shiplog/config.json` exists and `docs/PRD.md` exists. If not:
> "Shiplog is not initialized. Run `/shiplog init` first."

### Step 2: Get feature name
- If the user provided a name as an argument (e.g., `/shiplog feature "user auth"`), use that
- If no name was provided, ask: "What's the feature name?"

### Step 3: Assign feature ID
Read `docs/PRD.md` and find the highest existing feature ID (e.g., F003).
Assign the next sequential ID (e.g., F004).

### Step 4: Get current sprint
Read `docs/PROGRESS.md` to determine the current sprint number.

### Step 5: Create feature file
Read the template from `templates/feature.md.hbs` and create the feature file:
- Path: `docs/features/{featureId}-{kebab-case-name}.md`
- Replace template variables:
  - `{{featureId}}` — e.g., F004
  - `{{featureName}}` — The feature name provided by user
  - `{{sprint}}` — Current sprint number
  - `{{date}}` — Today's date (YYYY-MM-DD)

### Step 6: Add to PRD
Append a new row to the feature table in `docs/PRD.md`:
```
| {ID} | {name} | not-started | {sprint} | |
```

### Step 7: Confirm
```
Created feature {ID} — {name}
  File: docs/features/{ID}-{kebab-name}.md
  Sprint: {N}
  Status: not-started

  Edit the feature file to add description and acceptance criteria.
```

## Rules
- Feature IDs are always sequential (F001, F002, F003...)
- Feature file names use kebab-case (F004-user-authentication.md)
- Never overwrite an existing feature file
- If a feature with the same name already exists, warn the user
