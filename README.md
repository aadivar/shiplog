# Shiplog

> A ship's log tracks every voyage. Shiplog tracks every dev session.

**Shiplog** is a Claude Code plugin that gives every project persistent memory, automatic progress tracking, and background quality agents — so no session starts cold and no decision is forgotten.

## The Problem

Claude Code sessions are stateless. Over 50+ sessions, you lose context: what was built, what decisions were made, what's left, what security issues exist. You re-explain the project every time, waste tokens, and forget past decisions.

## The Solution

Shiplog automatically:
1. **Initializes** a structured docs system on any project (PRD, specs, security log, progress tracker)
2. **Reads** progress at session start so Claude picks up where you left off
3. **Launches background agents** after each commit to update specs, PRD status, security reviews, and memory
4. **Maintains** code pattern docs so Claude writes consistent code across sessions

## Install

Run inside a Claude Code session:

```
/plugin marketplace add aadivar/shiplog
/plugin install shiplog@shiplog
```

## Quick Start

```bash
# Initialize on your project
/shiplog init

# Create your first feature
/shiplog feature "user authentication"

# Check project status anytime
/shiplog status
```

### What a typical session looks like

```
User: Let's add the invoice PDF generation feature

Claude: [reads PROGRESS.md automatically]
I see we're on Sprint 2, working on the billing module.
Last session we finished the invoice list view (F008).

Let me create the feature file and start building...
[creates docs/features/F009-invoice-pdf.md]
[builds the feature]
[after commit, background agents run silently]

User: /shiplog status

Shiplog Status — Acme SaaS
━━━━━━━━━━━━━━━━━━━━━━━━━━
Sprint: 2 | Active: F009 (in-progress) | 12/24 features done
  Phase 1 (Foundation): ████████████ 100%
  Phase 2 (Core):       ████████░░░░  67%
  Phase 3 (Advanced):   ░░░░░░░░░░░░   0%
  Last security review: clean (2026-03-03)
```

## Background Agents

After each git commit, Shiplog silently runs 4 background agents:

| Agent | What it does | Output |
|-------|-------------|--------|
| **Specs** | Logs architecture decisions automatically | `docs/SPECS.md` |
| **PRD** | Updates feature status from code changes | `docs/PRD.md` |
| **Security** | Reviews for OWASP Top 10, hardcoded secrets, injection risks | `docs/SECURITY.md` |
| **Memory** | Maintains code patterns and project memory | Claude memory files |

Agents run in the background with `run_in_background: true` — they never interrupt your work.

## Commands

| Command | Description |
|---------|-------------|
| `/shiplog init` | Initialize Shiplog on current project |
| `/shiplog status` | Show project dashboard (sprint, features, completion %) |
| `/shiplog feature <name>` | Create a new feature from template |
| `/shiplog sprint <n>` | Start a new sprint with archival |
| `/shiplog review` | Manually trigger all background agents |
| `/shiplog config` | View/edit Shiplog configuration |
| `/shiplog agent <name>` | Create a custom background agent |
| `/shiplog agent list` | List all agents (built-in + custom) |

## Project Structure

When you run `/shiplog init`, it scaffolds:

```
docs/
├── PRD.md              # Feature roadmap with status tracking
├── SPECS.md            # Architecture decisions log
├── SECURITY.md         # Security review audit trail
├── PROGRESS.md         # Session log + current focus
├── features/           # Per-feature detail files
└── archive/            # Archived sprint logs

.shiplog/
├── config.json         # Plugin settings
└── agents/             # Custom agent definitions
```

And appends an orchestration section to your `CLAUDE.md` (never overwrites).

## Configuration

Stored in `.shiplog/config.json`:

```json
{
  "agents": {
    "model": "haiku",
    "specs": { "enabled": true },
    "prd": { "enabled": true },
    "security": { "enabled": true },
    "memory": { "enabled": true },
    "custom": []
  },
  "orchestration": {
    "readProgressOnStart": true,
    "launchAgentsAfterTask": true,
    "triggerMethod": "hooks+claude.md",
    "maxParallelAgents": 3
  }
}
```

### Agent Models
Choose during `/shiplog init` or change with `/shiplog config`:
- **haiku** (default) — Fastest and cheapest, great for background agent work
- **sonnet** — More capable analysis
- **opus** — Most capable, highest cost

## Custom Agents

Create your own background agents that run alongside the built-in ones:

```bash
/shiplog agent "a11y-reviewer"
```

This creates `.shiplog/agents/a11y-reviewer-agent.md` with an editable prompt. Your agent runs automatically after each commit, just like the built-in ones.

Examples: accessibility reviewer, performance auditor, dependency checker, test coverage tracker.

## How It Works

Shiplog uses a **hybrid triggering approach**:

1. **Hooks** (reliable backbone) — `PostToolUse` hooks fire after git commits and launch background agents automatically
2. **CLAUDE.md** (flexible layer) — Instructions in CLAUDE.md handle session-start context loading (reading PROGRESS.md, displaying status)

```
New session starts
    → CLAUDE.md instructs Claude to read docs/PROGRESS.md
    → Claude displays status and has full project context

User works and commits
    → PostToolUse hook fires
    → Hook reads .shiplog/config.json
    → Launches enabled agents in background
    → Agents update docs silently
```

## Privacy & Security

- All data stays local (`docs/` directory in your repo, memory in `~/.claude/`)
- No external API calls, no telemetry
- Security agent reviews for leaked secrets but never logs actual values
- `.gitignore` docs/ if you don't want it committed

## Plugin Structure

```
├── .claude-plugin/plugin.json   # Plugin manifest
├── skills/shiplog/SKILL.md      # Session orchestration
├── commands/                    # Slash commands
├── agents/                      # Built-in agent prompts
├── hooks/                       # PostToolUse hook config + script
├── templates/                   # Handlebars templates for scaffolding
├── scripts/                     # Stack detection, config validation
├── settings.json                # Default permissions
├── SKILL.md                     # Top-level entry point
└── LICENSE
```

## Requirements

- Claude Code v1.0+
- Git repository (agents use `git diff` for change detection)
- Works with any language/framework

## License

MIT — Open source, free forever.
