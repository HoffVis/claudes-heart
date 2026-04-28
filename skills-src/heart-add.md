---
name: heart-add
description: >
  Add a task to HEART.md for the heartbeat loop to pick up. Use when the user
  wants to add a new task mid-session. Trigger on "add task", "heart add",
  "add to heart", or similar.
argument-hint: "<task description>"
---

# Heart — Add Task

Add a task to the `## Tasks` section of `HEART.md` in the project root.

**Task to add:** $ARGUMENTS

Instructions:
1. Read `HEART.md`
2. Find the `## Tasks` section
3. Think about the task — can you enrich it with useful context? If the task is vague, add sub-bullets with Goal, Constraints, and Quality criteria:
   ```
   - [ ] Task description
     - **Goal:** What this should achieve
     - **Constraints:** Size limits, patterns to follow, scope boundaries
     - **Quality:** What "done well" looks like
   ```
   If the task is already specific enough, just add it as a simple checkbox.
4. Append it as the last item in the Tasks section (before any other `##` heading)
5. Write the updated file
6. Confirm the task was added with a brief summary
