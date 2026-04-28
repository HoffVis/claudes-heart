#!/usr/bin/env bash
set -euo pipefail

# stop-hook.sh — Heart v2 Stop hook
# Intercepts Claude's exit, feeds the brain prompt for the next iteration

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Determine project root from working directory in hook input
PROJECT_ROOT=$(echo "$HOOK_INPUT" | jq -r '.cwd // empty' 2>/dev/null || pwd)
STATE_FILE="$PROJECT_ROOT/.claude/heart-state.local.md"
HEART_FILE="$PROJECT_ROOT/HEART.md"

# --- Guard: If no state file or not active, allow exit ---
if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

ACTIVE=$(grep '^active:' "$STATE_FILE" | awk '{print $2}' || echo "false")
if [[ "$ACTIVE" != "true" ]]; then
  rm -f "$STATE_FILE"
  exit 0
fi

# --- Read current state ---
ITERATION=$(grep '^iteration:' "$STATE_FILE" | awk '{print $2}' || echo "1")
MAX_ITERATIONS=$(grep '^max_iterations:' "$STATE_FILE" | awk '{print $2}' || echo "0")
LAST_WAS_LOOP=$(grep '^last_was_loop:' "$STATE_FILE" | awk '{print $2}' || echo "false")
CURRENT_TASK=$(grep '^current_task:' "$STATE_FILE" | sed 's/^current_task: *//' | sed 's/^"\(.*\)"$/\1/' || echo "unknown")

# Validate iteration is numeric
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "Heart: State file corrupted, stopping." >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# --- Check max iterations ---
if [[ "$MAX_ITERATIONS" -gt 0 ]] && [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
  echo "Heart: Max iterations ($MAX_ITERATIONS) reached. Stopping." >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# --- Check HEART.md exists ---
if [[ ! -f "$HEART_FILE" ]]; then
  echo "Heart: HEART.md not found. Stopping." >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# --- Parse tasks from HEART.md ---
NEXT_TASK=""
IS_LOOP=false
IN_TASKS=false
IN_LOOPS=false

while IFS= read -r line; do
  if [[ "$line" =~ ^##[[:space:]]+Tasks ]]; then
    IN_TASKS=true
    IN_LOOPS=false
    continue
  fi
  if [[ "$line" =~ ^##[[:space:]]+Improvement[[:space:]]+Loops ]]; then
    IN_TASKS=false
    IN_LOOPS=true
    continue
  fi
  if [[ "$line" =~ ^##[[:space:]] ]] && [[ "$IN_TASKS" == true || "$IN_LOOPS" == true ]]; then
    IN_TASKS=false
    IN_LOOPS=false
    continue
  fi

  if [[ "$IN_TASKS" == true ]] && [[ "$line" =~ ^-[[:space:]]\[[[:space:]]\] ]]; then
    NEXT_TASK="${line#- \[ \] }"
    IS_LOOP=false
    break
  fi
done < "$HEART_FILE"

# If no one-shot tasks, check improvement loops
if [[ -z "$NEXT_TASK" ]]; then
  if [[ "$LAST_WAS_LOOP" == "true" ]]; then
    COMPLETED=$(grep -c '^\- \[x\]' "$HEART_FILE" 2>/dev/null || echo "0")
    echo "Heart: All tasks done ($COMPLETED completed). Resting until next heartbeat." >&2
    rm -f "$STATE_FILE"
    exit 0
  fi

  IN_LOOPS=false
  while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]+Improvement[[:space:]]+Loops ]]; then
      IN_LOOPS=true
      continue
    fi
    if [[ "$line" =~ ^##[[:space:]] ]] && [[ "$IN_LOOPS" == true ]]; then
      IN_LOOPS=false
      continue
    fi

    if [[ "$IN_LOOPS" == true ]] && [[ "$line" =~ ^-[[:space:]]\[[[:space:]]\] ]]; then
      NEXT_TASK="[LOOP] ${line#- \[ \] }"
      IS_LOOP=true
      break
    fi
  done < "$HEART_FILE"
fi

# --- If nothing to do, stop ---
if [[ -z "$NEXT_TASK" ]]; then
  COMPLETED=$(grep -c '^\- \[x\]' "$HEART_FILE" 2>/dev/null || echo "0")
  echo "Heart: All tasks complete! ($COMPLETED done). Heartbeat stopped." >&2
  rm -f "$STATE_FILE"
  exit 0
fi

# --- Increment iteration and update state ---
NEXT_ITERATION=$((ITERATION + 1))
TEMP_FILE="${STATE_FILE}.tmp.$$"

awk -v iter="$NEXT_ITERATION" -v task="$NEXT_TASK" -v was_loop="$IS_LOOP" '
  /^iteration:/ { print "iteration: " iter; next }
  /^current_task:/ { print "current_task: \"" task "\""; next }
  /^last_was_loop:/ { print "last_was_loop: " was_loop; next }
  { print }
' "$STATE_FILE" > "$TEMP_FILE"

if ! grep -q '^last_was_loop:' "$TEMP_FILE"; then
  sed -i '' "s/^---$/last_was_loop: $IS_LOOP\n---/" "$TEMP_FILE" 2>/dev/null || \
  sed -i "s/^---$/last_was_loop: $IS_LOOP\n---/" "$TEMP_FILE"
fi

mv "$TEMP_FILE" "$STATE_FILE"

# --- Build the brain prompt ---
TOTAL_REMAINING=$(grep -c '^\- \[ \]' "$HEART_FILE" 2>/dev/null || echo "0")
TOTAL_DONE=$(grep -c '^\- \[x\]' "$HEART_FILE" 2>/dev/null || echo "0")

PROMPT_TEXT="You are Heart, an autonomous project brain. You are a PM, prompt engineer, QA reviewer, and UX critic — not a checkbox machine.

Iteration: $NEXT_ITERATION | Done: $TOTAL_DONE | Remaining: $TOTAL_REMAINING
Last task completed: $CURRENT_TASK
Next task in backlog: $NEXT_TASK

Continue your Heart cycle:

1. UNDERSTAND — Read HEART.md and scan relevant source files. You have context from previous iterations — build on it.

2. PRIORITIZE — The next task in the backlog is shown above, but you may choose a different task if something else matters more right now (e.g., refining something you just built that isn't good enough).

3. CRAFT — Write a detailed, targeted prompt for the task. Include specific files, design constraints, acceptance criteria, and what 'done well' looks like. Think like a senior dev writing a brief for a capable but context-free junior.

4. EXECUTE — Spawn an Agent with your crafted prompt. Let it build.

5. REVIEW — Read what was changed. Run the build. Check quality: Does it match your criteria? Are proportions right? Does it fit the design language? Would you be proud of this?
   - If not satisfied: note what's wrong, craft a refinement prompt, spawn another Agent (max 3 attempts per task)
   - If satisfied: mark [x] in HEART.md

6. REFLECT — Did this change your priorities? Update HEART.md if needed. Then finish your response.

Quality over speed. Never mark [x] on work you wouldn't be proud of."

SYSTEM_MSG="Heart v2 iteration $NEXT_ITERATION | Next: $NEXT_TASK | Remaining: $TOTAL_REMAINING | Done: $TOTAL_DONE"

# --- Block exit and re-feed ---
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'
