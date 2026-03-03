# Shiplog — Architecture & Specs

> Architecture decisions and technical specifications log.

**Stack**: Shell, Markdown
**Created**: 2026-03-03

---

## Architecture Decisions

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-03-03 | Config-driven agent orchestration via `.shiplog/config.json` | Enables flexible agent enablement, model selection, and orchestration settings without code changes |
| 2026-03-03 | Hook + CLAUDE.md trigger mechanism for post-commit agents | Integrates agent launch into Claude's native workflow; CLAUDE.md signals agent availability at session start |
| 2026-03-03 | Haiku model as default for background agents | Optimizes token cost for repetitive tasks (specs, PRD updates, security reviews) while maintaining quality |
| 2026-03-03 | Append-only doc pattern for PRD, SPECS, SECURITY, PROGRESS | Prevents accidental context loss; audit trail of all decisions and changes; read-at-session-start design |
| 2026-03-03 | Handlebars templates + JSON config for project scaffolding | Decouples templates from logic; enables interactive `/shiplog init` to generate project-specific docs |

---

## Technical Stack

- **Shell**
- **Markdown**

---

## Conventions

- **Agent model selection**: Haiku for cost-sensitive recurring tasks (specs, PRD, security); Sonnet/Opus for complex analysis
- **Config namespace**: All orchestration settings under `.shiplog/config.json`; docs paths must be relative to project root
- **Doc headers**: Each log file has `Date`, `Session`, `Feature`, `Severity` (or equivalent) columns for consistent audit trails
- **Session state**: PROGRESS.md always reflects current sprint, active feature, and last session date for context pickup

---

_This file is append-only. The Shiplog Specs agent adds entries after each session. Existing content is never modified or deleted._
