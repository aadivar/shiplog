# Shiplog — Claude Code Plugin PRD

**Product Requirements Document**
**Version**: 0.1 (Draft)
**Author**: Sumedha
**Date**: 2026-03-03

---

## 1. Vision

**Shiplog** is a Claude Code plugin that gives every project a persistent memory, automatic progress tracking, and background quality agents — so no session starts cold and no decision is forgotten.

> "A ship's log tracks every voyage. Shiplog tracks every dev session."

### Problem
Claude Code sessions are stateless by default. On large projects (50+ sessions), developers lose context: what was built, what decisions were made, what's left, and what security issues exist. They re-explain the project every time, waste tokens on context, and forget past decisions.

### Solution
Shiplog automatically:
1. **Initializes** a structured docs system on any project (PRD, specs, security log, progress tracker)
2. **Reads** progress at session start so Claude picks up where you left off
3. **Launches background agents** after each task to update specs, PRD status, security reviews, and memory
4. **Maintains** code pattern docs so Claude writes consistent code across sessions

### Target User
Developers using Claude Code for projects that span multiple sessions (5+ sessions). Especially valuable for:
- Solo developers building full-stack apps
- Teams using Claude Code for feature development
- Long-running migrations, refactors, or greenfield builds

---

## 2. User Stories

| ID | As a... | I want to... | So that... |
|----|---------|-------------|------------|
| US1 | Developer | Run `/shiplog init` on any project | A docs structure is scaffolded automatically |
| US2 | Developer | Start a new session and have Claude know what I was doing | I don't re-explain context every time |
| US3 | Developer | Have architecture decisions logged automatically | I have an audit trail of why things were built a certain way |
| US4 | Developer | Get automatic security reviews after each task | Vulnerabilities are caught early, not in production |
| US5 | Developer | Track feature progress without a separate tool | My PRD stays current without manual updates |
| US6 | Developer | Have code patterns documented as I build | Claude writes consistent code across sessions |
| US7 | Developer | Customize which agents run | I only pay for what I need |
| US8 | Developer | See a dashboard of project status | I get a quick overview without reading multiple files |

---

## 3. Core Features

### 3.1 Project Initialization (`/shiplog init`)

Interactive setup that scaffolds the project:

```
$ /shiplog init

? Project name: My App
? Project description: E-commerce platform with multi-tenant support
? Tech stack: Next.js, Supabase, Tailwind
? Agent model for background tasks: haiku (Recommended) / sonnet / opus
? Enable background agents? [specs, prd, security, memory] (all selected)
? Create initial feature roadmap? (Y/n)
```

**Creates:**
```
docs/
├── PRD.md              # Feature roadmap with status tracking
├── SPECS.md            # Architecture decisions log
├── SECURITY.md         # Security review audit trail
├── PROGRESS.md         # Session log + current focus
└── features/           # Per-feature detail files

CLAUDE.md               # Project instructions (appends Shiplog section)
.claude/
└── skills/
    └── shiplog/
        └── SKILL.md    # Project-aware code patterns
```

**Behavior:**
- Detects existing project structure (package.json, Cargo.toml, etc.) and adapts templates
- If CLAUDE.md already exists, appends Shiplog orchestration section (does not overwrite)
- Creates `.shiplog/config.json` for plugin settings
- Generates initial PRD from project description with empty feature table

### 3.2 Session Orchestration (Automatic)

**On every session start** (via CLAUDE.md instructions):
1. Read `docs/PROGRESS.md` to load current state
2. Display a one-line status: `Shiplog: Sprint 2 | Feature F006 (in-progress) | 8/20 features done`
3. Identify what the user is likely working on based on PROGRESS.md context

**After main work completes** (background, non-blocking):
- Launch configured agents with `run_in_background: true`
- Agents write to their respective docs files
- If any agent fails, it fails silently — no impact on main work

### 3.3 Background Agents

#### Specs Agent
- **Trigger**: After main task completes
- **Input**: `git diff`, `docs/SPECS.md`
- **Action**: Appends new architecture decisions (date, decision, rationale)
- **Output**: Updated `docs/SPECS.md`
- **Rules**: Append-only, 1-2 lines per entry, never rewrites existing content

#### PRD Agent
- **Trigger**: After main task completes
- **Input**: `git diff`, `docs/PRD.md`, `docs/PROGRESS.md`
- **Action**: Updates feature status (not-started → in-progress → done) based on file changes
- **Output**: Updated `docs/PRD.md`
- **Rules**: Only changes status with evidence from file changes, never adds new features

#### Security Agent
- **Trigger**: After main task completes
- **Input**: `git diff --name-only`, changed file contents
- **Action**: Reviews for OWASP Top 10, hardcoded secrets, missing auth, injection risks
- **Output**: Appends session entry to `docs/SECURITY.md`
- **Rules**: One line per finding with severity (CRIT/HIGH/MED/LOW), logs "clean" if no issues

#### Memory Agent
- **Trigger**: After main task completes
- **Input**: Session changes, existing memory files
- **Action**: Updates Claude memory files with new patterns, decisions, gotchas
- **Output**: Updated memory files (MEMORY.md, patterns.md, etc.)
- **Rules**: Max 15 lines added per session, never deletes existing content

### 3.4 Slash Commands

| Command | Description |
|---------|-------------|
| `/shiplog init` | Initialize Shiplog on current project |
| `/shiplog status` | Show project status (sprint, active feature, completion %) |
| `/shiplog feature <name>` | Create a new feature file from template |
| `/shiplog sprint <n>` | Start a new sprint, archive previous session log |
| `/shiplog review` | Trigger all background agents manually |
| `/shiplog config` | Show/edit Shiplog configuration |

### 3.5 Configuration

**File:** `.shiplog/config.json`

```json
{
  "version": "1.0.0",
  "project": {
    "name": "My App",
    "description": "E-commerce platform",
    "stack": ["Next.js", "Supabase", "Tailwind"]
  },
  "agents": {
    "model": "haiku",
    "specs": { "enabled": true },
    "prd": { "enabled": true },
    "security": { "enabled": true },
    "memory": { "enabled": true }
  },
  "docs": {
    "path": "docs",
    "progressFile": "PROGRESS.md",
    "prdFile": "PRD.md",
    "specsFile": "SPECS.md",
    "securityFile": "SECURITY.md",
    "featuresDir": "features"
  },
  "orchestration": {
    "readProgressOnStart": true,
    "launchAgentsAfterTask": true,
    "triggerMethod": "hooks+claude.md",
    "maxParallelAgents": 3
  }
}
```

---

## 4. Plugin Architecture

### 4.1 Plugin Structure (Claude Code Marketplace Format)

```
shiplog/
├── package.json            # Plugin metadata, version, dependencies
├── SKILL.md                # Main skill (loaded when plugin activates)
├── skills/
│   └── shiplog/
│       └── SKILL.md        # Project-aware orchestration skill
├── commands/
│   ├── init.md             # /shiplog init command
│   ├── status.md           # /shiplog status command
│   ├── feature.md          # /shiplog feature command
│   ├── sprint.md           # /shiplog sprint command
│   ├── review.md           # /shiplog review command
│   └── config.md           # /shiplog config command
├── hooks/
│   └── hooks.json          # PostToolUse hooks for agent triggers
├── templates/
│   ├── PRD.md.hbs          # PRD template (Handlebars)
│   ├── SPECS.md.hbs        # Specs template
│   ├── SECURITY.md.hbs     # Security log template
│   ├── PROGRESS.md.hbs     # Progress tracker template
│   ├── feature.md.hbs      # Per-feature template
│   ├── CLAUDE.md.hbs       # CLAUDE.md append section
│   └── config.json.hbs     # Default config
├── scripts/
│   ├── detect-stack.sh     # Auto-detect project tech stack
│   └── validate-config.sh  # Validate .shiplog/config.json
├── README.md
└── LICENSE
```

### 4.2 How It Integrates

1. **Install**: `claude plugin install shiplog` (from marketplace)
2. **Enable**: Plugin auto-enables after install
3. **Init**: User runs `/shiplog init` on their project
4. **Operate**: CLAUDE.md instructions + skill handle session orchestration automatically
5. **Commands**: Slash commands for manual operations

### 4.3 Agent Execution Model (Hybrid: Hooks + CLAUDE.md)

**Triggering (Hooks — reliable backbone):**
```
User completes main task → git commit / file writes
        ↓
PostToolUse hook fires (hooks/hooks.json)
        ↓
Hook script checks .shiplog/config.json for enabled agents
        ↓
Launches enabled agents in parallel via Agent tool
```

**Session Start (CLAUDE.md — flexible layer):**
```
New session starts
        ↓
CLAUDE.md instructs Claude to read docs/PROGRESS.md
        ↓
Displays one-line status summary
        ↓
Claude has full project context for the session
```

**Agent Execution:**
```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ Specs Agent  │  │ PRD Agent   │  │Security Agent│  (parallel, background)
│ reads diff   │  │ reads diff  │  │ reads diff   │
│ updates SPECS│  │ updates PRD │  │ updates SEC  │
└─────────────┘  └─────────────┘  └─────────────┘
        ↓
┌─────────────┐
│Memory Agent  │  (after others, to capture learnings)
│ updates mem  │
└─────────────┘
```

Agents use the `Agent` tool with `run_in_background: true` and the configured `agents.model` (default: `haiku`). They are standard Claude Code subagents — no custom runtime needed.

---

## 5. User Experience Flow

### First Time Setup
```
User: /shiplog init
Shiplog: Setting up project tracking...

? Project name: Acme SaaS
? Brief description: B2B invoicing platform
? Tech stack (detected: Next.js, Prisma, Tailwind): [confirmed]
? Enable agents: [x] Specs  [x] PRD  [x] Security  [x] Memory

Created:
  docs/PRD.md         — Feature roadmap (add your features)
  docs/SPECS.md       — Architecture decisions log
  docs/SECURITY.md    — Security review trail
  docs/PROGRESS.md    — Session tracker
  docs/features/      — Per-feature details
  .shiplog/config.json — Plugin settings
  Updated CLAUDE.md   — Added orchestration section

Run `/shiplog feature "user auth"` to create your first feature.
```

### Typical Session
```
User: Let's add the invoice PDF generation feature

Claude: [reads PROGRESS.md automatically]
I see we're on Sprint 2, working on the billing module.
Last session we finished the invoice list view (F008).

Let me create the feature file and start building...
[creates docs/features/F009-invoice-pdf.md]
[builds the feature]
[after completion, background agents run silently]

User: /shiplog status

Shiplog: Sprint 2 | 12/24 features done | Active: F009 (in-progress)
  Phase 1 (Foundation): ████████████ 100%
  Phase 2 (Core):       ████████░░░░  67%
  Phase 3 (Advanced):   ░░░░░░░░░░░░   0%
  Last security review: clean (2026-03-03)
```

### Sprint Transition
```
User: /shiplog sprint 3

Shiplog: Starting Sprint 3
  Archived 8 session entries from Sprint 2 → docs/archive/sprint-2.md
  Updated PROGRESS.md: Sprint 3, focus TBD
  Sprint 2 summary: 6 features completed, 2 in-progress

  What's the focus for Sprint 3?
```

---

## 6. Technical Specifications

### 6.1 Plugin Manifest (package.json)
```json
{
  "name": "shiplog",
  "version": "1.0.0",
  "description": "Automatic project tracking, progress management, and background quality agents for Claude Code",
  "author": "Sumedha",
  "license": "MIT (open source, free forever)",
  "keywords": ["project-management", "progress-tracking", "security-review", "memory"],
  "claude": {
    "minVersion": "1.0.0",
    "permissions": ["read", "write", "bash"],
    "skills": ["skills/shiplog/SKILL.md"],
    "commands": ["commands/*.md"],
    "hooks": ["hooks/hooks.json"]
  }
}
```

### 6.2 Compatibility
- Claude Code v1.0+
- Any programming language / framework (stack-agnostic templates)
- Git repositories (uses git diff for change detection)
- Works with existing CLAUDE.md files (appends, never overwrites)

### 6.3 Performance Budget
- `/shiplog init`: < 5 seconds
- Session start (read PROGRESS.md): < 1 second
- Each background agent: < 30 seconds
- Total background overhead per session: < 2 minutes
- Memory file additions: < 15 lines per session

### 6.4 Privacy & Security
- All data stays local (docs/ directory in repo, memory in ~/.claude/)
- No external API calls, no telemetry
- .shiplog/config.json does not contain secrets
- Security agent reviews for leaked secrets but never logs the actual secret values
- Users can .gitignore docs/ if they don't want it committed

---

## 7. Competitive Landscape

| Solution | What it does | Gap Shiplog fills |
|----------|-------------|-------------------|
| CLAUDE.md | Static project instructions | No automatic updates, no agent orchestration |
| Claude Memory | Remembers facts across sessions | No structure, no progress tracking, no security reviews |
| GitHub Issues/Projects | Feature tracking | External tool, not integrated with Claude sessions |
| Cursor Rules | Project conventions | No progress tracking, no background agents |
| Linear/Jira | Full project management | Overkill for solo/small teams, not Claude-native |

**Shiplog's unique value**: It's the only solution that combines structured project tracking with automatic background agents, purpose-built for Claude Code's multi-session workflow.

---

## 8. Milestones & Phases

### Phase 1: Core (MVP)
- [x] `/shiplog init` — project scaffolding
- [x] CLAUDE.md orchestration section generation
- [x] Background agents (specs, PRD, security, memory)
- [x] `/shiplog status` command
- [x] `/shiplog feature` command
- [x] Plugin marketplace packaging (.claude-plugin/plugin.json, settings.json, proper hook format)

### Phase 2: Enhanced
- [x] `/shiplog sprint` — sprint management with archival
- [x] `/shiplog review` — manual agent trigger
- [x] `/shiplog config` — interactive config editor
- [x] Stack detection (auto-detect framework, DB, styling)
- [x] Custom agent support (`/shiplog agent`, .shiplog/agents/, config.json custom array)

### Phase 3: Social
- [ ] Shareable project templates (e.g., "Next.js + Supabase" starter)
- [ ] Team collaboration (shared docs/ via git)
- [ ] Agent marketplace (community-built agents like "a11y reviewer", "perf auditor")
- [ ] Session analytics (tokens spent, features/sprint velocity)

---

## 9. Success Metrics

| Metric | Target (6 months post-launch) |
|--------|-------------------------------|
| GitHub stars | 500+ |
| Community agents published | 10+ |

---

## 10. Open Questions (Resolved & Remaining)

### Resolved
1. **Agent model**: ~~Should background agents use `haiku` by default or inherit the user's model?~~ → **Configurable.** Users select their agent model during `/shiplog init` (options: `haiku`, `sonnet`, `opus`). Default: `haiku` (cheapest, sufficient for append-only agent work). Stored in `.shiplog/config.json` under `agents.model`.
2. **Hook vs CLAUDE.md**: ~~PostToolUse hooks or CLAUDE.md instructions?~~ → **Both (hybrid).** Hooks handle reliable agent triggering (PostToolUse fires after git commits/file writes). CLAUDE.md handles session-start orchestration (reading PROGRESS.md, displaying status). Hooks = reliability backbone, CLAUDE.md = flexibility layer.
3. **Pricing**: ~~Free forever? Freemium? Open source?~~ → **Open source, MIT license, free forever.**

### Remaining
4. **Template marketplace**: Should users be able to share/sell project templates?
5. **Multi-repo**: How should Shiplog work in monorepos or multi-repo projects?
6. **Conflict resolution**: If two sessions run simultaneously, how do we handle doc conflicts?

---

## 11. Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Claude Code plugin API changes | Medium | High | Pin to stable API version, maintain compat layer |
| Background agents consume too many tokens | Medium | Medium | Use haiku for agents, cap at 15 lines output |
| Users find docs/ noisy in their repo | Low | Medium | Offer .gitignore option, configurable paths |
| Security agent produces false positives | Medium | Low | Conservative rules, severity levels, easy dismiss |
| Marketplace competition | Low | Medium | First-mover advantage, community agents moat |
