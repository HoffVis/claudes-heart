# Heart

An autonomous project brain for Claude Code. Give it a task list, walk away, and come back to quality work — reviewed, refined, and iterated.

Heart reads a `HEART.md` file, prioritizes tasks, crafts targeted prompts, spawns sub-agents to execute, reviews results for quality, and iterates until satisfied. It's a PM, prompt engineer, QA reviewer, and UX critic rolled into one.

## Quick Start

```bash
# Install
git clone https://github.com/th2025/heart.git ~/.claude/plugins/local/heart
~/.claude/plugins/local/heart/bin/heart install
# Restart your terminal

# Use
cd your-project
heart init
# Edit HEART.md with your tasks
# Open Claude Code in the project
/heart                  # Start the brain
/loop 10m /heart        # Or run on interval
```

## What It Does

```
/heart fires
  ↓
UNDERSTAND — reads HEART.md, CLAUDE.md, scans codebase
  ↓
PRIORITIZE — picks highest-impact task
  ↓
CRAFT — writes detailed brief with acceptance criteria
  ↓
EXECUTE — spawns Agent with the brief
  ↓
REVIEW — checks quality, iterates up to 3x if not satisfied
  ↓
REFLECT — marks done, adds improvement tasks if it sees issues
  ↓
Stop hook → next iteration
```

## CLI

```bash
heart install              # One-time setup
heart uninstall            # Remove from Claude Code

heart init                 # Create HEART.md (agent mode)
heart init agent           # Single project executor
heart init reviewer <path> # Reviews another project, adds tasks
heart init watcher         # Monitors build, tests, deps, security
heart init multi           # Monorepo orchestrator

heart start                # Start the brain
heart start --loop 10m     # Start with interval
heart stop                 # Stop the heartbeat
heart add "task"           # Add a task
heart status               # Show progress
```

## HEART.md Format

Heart works with simple checkboxes but produces better results with rich tasks:

```markdown
# Heart Tasks

## Config
- mode: agent
- max_iterations: 0

## Tasks
- [ ] Build the authentication system
  - **Goal:** JWT-based auth with refresh tokens
  - **Constraints:** Use existing user table, no third-party auth providers
  - **Quality:** Login flow should feel instant, errors should be specific

- [ ] Add input validation to API endpoints

## Improvement Loops
- [ ] Run build and fix errors
- [ ] Review code quality and add improvement tasks
```

**Simple tasks** work fine — the brain enriches them with context before executing.
**Rich tasks** with Goal/Constraints/Quality produce significantly better output.

## Modes

### Agent (default)
Focused single-project executor. Reads tasks, builds, reviews, iterates.

```bash
heart init agent
```

### Watcher
Continuous monitoring — checks build, tests, dependencies, security. Adds fix tasks when issues are found.

```bash
heart init watcher
```

### Reviewer
Reviews another project's codebase and adds improvement tasks to its HEART.md. Useful for cross-project oversight.

```bash
heart init reviewer /path/to/target/project
```

### Multi (Orchestrator)
Manages multiple sub-projects from a root HEART.md. Reads each sub-project's backlog, prioritizes globally, respects cross-project dependencies.

```bash
heart init multi
# Edit HEART.md to list sub-projects:
# ## Projects
# - web: ./apps/web/HEART.md
# - api: ./apps/api/HEART.md
#
# ## Dependencies
# - web depends on api (API endpoints needed first)
```

## How It Works

Heart uses three Claude Code primitives:

1. **Skills** — `/heart`, `/heart-stop`, `/heart-add` are Claude Code skills that load automatically
2. **Stop Hook** — intercepts Claude's exit, reads HEART.md for the next task, and re-feeds it as a new prompt
3. **Cron** — `/loop Nm /heart` runs the brain on an interval using Claude Code's built-in scheduler

The brain (main session) spawns **Agent sub-agents** for each task. The brain thinks and reviews; the agents build. This separation means quality judgment stays in the context-rich main session while execution happens in focused sub-agents.

## Running Overnight

```bash
# In Claude Code:
/loop 10m /heart
```

Heart will process tasks, run improvement loops, and rest between cycles. When the backlog empties, it scans for improvement opportunities and self-generates new tasks. Tested for 10+ hours continuous operation.

### Permissions

For autonomous operation, add permissions to your project's `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(npm test*)", "Bash(npm run *)", "Bash(npx *)",
      "Bash(mkdir *)", "Bash(git status)", "Bash(git diff*)",
      "Bash(git add *)", "Bash(git commit *)", "Bash(git log*)"
    ],
    "deny": [
      "Bash(rm -rf *)", "Bash(git push*)", "Bash(git reset*)"
    ]
  }
}
```

## Design Principles

Heart was inspired by [OpenClaw](https://github.com/openclaw/openclaw) but built entirely on official Claude Code features:

- **No token extraction** — uses your Claude subscription through official CLI
- **No third-party daemons** — runs inside Claude Code sessions
- **ToS compliant** — uses skills, hooks, and cron as designed
- **1M context** — the brain accumulates project understanding and gets better over time

### v1 vs v2

Heart v1 was a blind checkbox machine — it completed 76 tasks overnight but quality was mediocre. v2 introduced the brain architecture: agent spawning, quality gates, iterative refinement, and proactive task generation. The difference is dramatic.

## Requirements

- Claude Code CLI
- Claude Pro or Max subscription
- Node.js (used by installer for JSON manipulation)
- macOS or Linux (Windows untested)

## File Structure

```
~/.claude/plugins/local/heart/
├── bin/heart              CLI
├── hooks/stop-hook.sh     Loop mechanism
├── skills-src/            Canonical skill files
├── templates/             HEART.md templates
└── .claude-plugin/        Plugin metadata
```

## License

MIT
