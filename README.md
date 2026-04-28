# Claude's Heart

**It's just a markdown file and a bash script, but it works!**

A heartbeat for Claude Code. Not just a task runner — a recurring loop that keeps checking, keeps responding, keeps maintaining. Write what you want it to do, and it does it. Every 10 minutes. Forever.

Check email, summarize what's new, flag anything urgent. Monitor your services, alert you if something's down. Run the build, fix what broke. Review code quality, add improvement tasks. With MCP servers connected, the loops reach into anything — Gmail, Slack, databases, APIs.

Tasks get done too. But the heartbeat is the point.

> Built on official Claude Code primitives. No token extraction. No daemons. No ToS violations.

> **Status:** Experimental, but battle-tested. 76 tasks, 10+ hours overnight, zero crashes. You're an early adopter, and it's still young. Here be dragons, bring coffee.

> **Field report:** Set `/loop 10m /heart` running, went to bed. Woke up to 76 completed tasks and a working app. See [Pulse](https://github.com/HoffVis/pulse) — the app Heart built that night.

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

The file has two sections that work differently:

**Tasks** get done and checked off:

```markdown
## Tasks
- [ ] Add dark mode
- [ ] Fix the login page
  - **Goal:** Fix the redirect loop on expired sessions
  - **Constraints:** Don't touch the auth middleware
  - **Quality:** User sees a clear error, not a blank page
```

**Improvement Loops** never get checked off. They run every heartbeat, forever:

```markdown
## Improvement Loops
- [ ] Check email via Gmail MCP, summarize unread, flag anything urgent
- [ ] Run the build — if errors, add fix tasks
- [ ] Monitor all services in pulse.config.json, alert if any are down
- [ ] Review recent git commits for code quality issues
- [ ] Check for outdated dependencies, add upgrade tasks if needed
```

Tasks are the sprint. Improvement loops are the heartbeat. The loops are what make this more than a task runner — they're recurring workflows that keep going as long as Heart is running. With MCP servers connected, they can reach into email, Slack, databases, APIs, anything.

The brain enriches simple tasks with context before executing. Rich tasks with Goal/Constraints/Quality just give it a head start.

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

## Monitor From Your Phone

Heart pairs naturally with Claude Code's `/remote` feature. Start Heart on your machine, connect from the Claude Code app on your phone, and watch it work from the couch. Or bed. Or wherever you deserve to be while your AI is building.

```
# On your machine — start Heart
/loop 10m /heart

# On your phone — connect to the session
# Use the Claude Code mobile app with /remote
```

You can see every task as it completes, watch the agent spawn, and even add tasks mid-session from your phone with `/heart-add "new task"`. It's the closest thing to managing a remote dev team from your pocket.

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
