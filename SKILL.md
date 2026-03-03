---
name: Shiplog
description: Automatic project tracking, progress management, and background quality agents for Claude Code
version: "1.0.0"
---

# Shiplog

Automatic project tracking, progress management, and background quality agents for Claude Code.

## Commands

- `/shiplog init` — Initialize project tracking
- `/shiplog status` — Show project dashboard
- `/shiplog feature <name>` — Create a new feature
- `/shiplog sprint <n>` — Start a new sprint
- `/shiplog review` — Trigger background agents manually
- `/shiplog config` — View/edit configuration

## What It Does

Shiplog gives every project persistent memory and automatic progress tracking:

1. **Session start**: Reads `docs/PROGRESS.md` so Claude picks up where you left off
2. **During work**: Tracks features, architecture decisions, and security
3. **After commits**: Background agents automatically update specs, PRD status, security reviews, and memory

## Getting Started

Run `/shiplog init` in your project to set up tracking.
