# Shiplog

## Shiplog — Project Orchestration

This project uses [Shiplog](https://github.com/sumedha/shiplog) for automatic progress tracking and background quality agents.

### Session Start
At the start of every session:
1. Read `docs/PROGRESS.md` to understand current project state
2. Display a one-line status: `Shiplog: Sprint X | Feature FXXX (status) | N/M features done`
3. Use the context from PROGRESS.md to pick up where the last session left off

### During Work
- When creating a new feature, use `/shiplog feature "<name>"` to scaffold it
- Reference `docs/SPECS.md` for architecture decisions and code conventions
- Reference `docs/PRD.md` for the feature roadmap and status

### After Task Completion
Background agents will run automatically via hooks to:
- Update `docs/SPECS.md` with any architecture decisions made
- Update `docs/PRD.md` feature statuses based on file changes
- Append security review findings to `docs/SECURITY.md`
- Update memory files with new patterns and conventions

### Configuration
- Config: `.shiplog/config.json`
- Agent model: `haiku`
- Enabled agents: specs, prd, security, memory
