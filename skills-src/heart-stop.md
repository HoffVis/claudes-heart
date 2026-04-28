---
name: heart-stop
description: >
  Stop the Heart autonomous heartbeat loop. Use when the user wants to cancel,
  stop, or pause the heartbeat. Trigger on "stop heart", "heart stop", "cancel heartbeat",
  "kill the loop", or similar.
---

# Heart — Stop Heartbeat

Stop the Heart loop by removing the state file:

1. Check if `.claude/heart-state.local.md` exists
2. If it does, remove it
3. Read `HEART.md` and give a summary:
   - How many tasks completed vs remaining
   - What iteration the brain was on
   - Any tasks that were refined (multiple attempts)
   - Any blocked tasks and why
