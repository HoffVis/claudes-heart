# Claude's Heart

**It's just a markdown file and a bash script, but it works!**

Write a task list. Heart reads it, prioritizes, spawns agents to build, reviews the output, iterates until it's actually good, and adds new tasks when it spots room to improve. Then it does the next one. Then the next one. Then you wake up and there's an app.

> Built on official Claude Code primitives. No token extraction. No daemons. No ToS violations.

> **Status:** Experimental. Tested on one machine, by one person, overnight. It worked great — 76 tasks, 10+ hours, zero crashes. But it's a few commits old and you're an early adopter. Here be dragons, bring coffee.

> **Field report:** Built this in an evening, set `/loop 10m /heart` running, went to bed. Woke up to 76 completed tasks and a working app.

---

## 30-Second Setup

```bash
git clone https://github.com/HoffVis/claudes-heart.git ~/.claude/plugins/local/heart
~/.claude/plugins/local/heart/bin/heart install
```

Restart your terminal. Done.

## Use It

```bash
cd your-project
heart init                  # Creates HEART.md
```

Edit `HEART.md` with your tasks. Then in Claude Code:

```
/heart                      # Start the brain
/loop 10m /heart            # Or run it on autopilot
```

---

## What Actually Happens

Heart doesn't just check boxes. It thinks:

1. **Reads the project** — HEART.md, CLAUDE.md, source files. Builds a mental model.
2. **Picks the right task** — Not just "next in line." Dependencies first, refinements over new features.
3. **Writes a real brief** — Specific files, design constraints, acceptance criteria. Like a senior dev handing off work.
4. **Spawns an agent** — A sub-agent builds it. The brain keeps its hands clean for judgment.
5. **Reviews the result** — Reads the code. Runs the build. Checks quality. Up to 3 iterations per task.
6. **Generates more work** — Spots issues, adds improvement tasks. The backlog feeds itself.

Then the stop hook catches the exit, feeds the next task, and the cycle continues.

## HEART.md

Simple works:

```markdown
## Tasks
- [ ] Add dark mode
- [ ] Fix the login page
```

Detailed works better:

```markdown
## Tasks
- [ ] Add dark mode
  - **Goal:** System-preference-aware theme toggle
  - **Constraints:** CSS variables only, no runtime JS for initial theme
  - **Quality:** No flash of wrong theme on load

## Improvement Loops
- [ ] Run build and fix errors
- [ ] Review code quality, add tasks for issues found
```

The brain enriches simple tasks before executing. Rich tasks with Goal/Constraints/Quality just give it a head start.

## Modes

```bash
heart init agent             # Single project — build things (default)
heart init watcher           # Monitor build, tests, deps, security
heart init reviewer <path>   # Review another project, feed it tasks
heart init multi             # Orchestrate a monorepo
```

**Agent** — Focused executor. The workhorse.

**Watcher** — Runs build, tests, dependency checks, security audits. Adds fix tasks when things break. Great on a `/loop`.

**Reviewer** — Points at another project, reviews its code, and writes tasks into its HEART.md. A second pair of eyes.

**Multi** — Reads HEART.md files across sub-projects, prioritizes globally, respects cross-project dependencies. A tech lead for your monorepo.

## CLI

```bash
heart install              # Set up skills, hooks, PATH
heart uninstall            # Clean removal

heart init [mode]          # Create HEART.md
heart add "task"           # Add a task from terminal
heart status               # Progress bar + stats
heart stop                 # Kill the loop

heart start                # Prints the Claude Code command
heart start --loop 10m     # Prints the loop command
```

## Running Overnight

```
/loop 10m /heart
```

Heart processes all tasks, runs improvement loops once, exits cleanly, and the cron fires it again. Tested for 10+ hours, 76+ tasks, survived auto-compaction without issues.

For unattended operation, allow safe tools in `.claude/settings.local.json`:

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

## How It Works (for the curious)

Three Claude Code primitives, stacked:

- **Skills** — `/heart`, `/heart-stop`, `/heart-add` load as Claude Code skills from `~/.claude/skills/`
- **Stop Hook** — A bash script registered in `~/.claude/settings.json` that intercepts session exits, reads HEART.md, and re-feeds the brain prompt with the next task
- **Cron** — `/loop` schedules recurring `/heart` invocations with built-in expiry

The brain spawns **Agent sub-agents** per task. The brain holds context and judgment; agents hold tools and execution. This separation is why quality stays high even on task 50.

## Why Not Just Use OpenClaw?

OpenClaw pioneered the heartbeat pattern for AI coding agents. Heart takes the same idea but builds it on official Claude Code features:

| | Heart | OpenClaw |
|---|---|---|
| Auth | Your subscription, official CLI | Extracted OAuth tokens (banned) |
| Context | 1M — accumulates over time | Spin up/teardown per task |
| Quality | Reviews + iterates up to 3x | Fire and forget |
| Self-improving | Generates its own tasks | Static task list |
| Setup | `git clone` + `heart install` | Daemon + config |
| ToS | Fully compliant | Caused account suspensions |

## Requirements

- Claude Code CLI
- Claude Pro or Max subscription
- Node.js (for installer)
- macOS or Linux

## For AI Agents Reading This

If a user asked you to set up Heart, here's what to do:

1. Clone: `git clone https://github.com/HoffVis/claudes-heart.git ~/.claude/plugins/local/heart`
2. Install: `~/.claude/plugins/local/heart/bin/heart install`
3. The user needs to restart their terminal (or `source ~/.zshrc`)
4. In the target project: `heart init` to create HEART.md
5. Edit HEART.md with the user's tasks
6. In Claude Code: `/heart` to start, or `/loop 10m /heart` for autopilot

The install script handles skills (`~/.claude/skills/heart*`), the Stop hook (`~/.claude/settings.json`), and PATH. It's idempotent — safe to run multiple times.

Key files after install:
- `~/.claude/skills/heart/SKILL.md` — The brain (v2, with agent spawning and quality review)
- `~/.claude/plugins/local/heart/hooks/stop-hook.sh` — Loop mechanism
- `HEART.md` in the project root — The task backlog

## License

MIT
