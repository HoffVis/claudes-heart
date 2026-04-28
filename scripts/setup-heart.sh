#!/usr/bin/env bash
set -euo pipefail

# setup-heart.sh — Initialize the Heart heartbeat loop
# Called by /heart command

PROJECT_ROOT="$(pwd)"
HEART_FILE="$PROJECT_ROOT/HEART.md"
STATE_DIR="$PROJECT_ROOT/.claude"
STATE_FILE="$STATE_DIR/heart-state.local.md"

# Parse arguments
MAX_ITERATIONS=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --max-iterations)
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

# Check if already running
if [[ -f "$STATE_FILE" ]]; then
  ACTIVE=$(grep '^active:' "$STATE_FILE" | awk '{print $2}' || echo "false")
  if [[ "$ACTIVE" == "true" ]]; then
    echo "Heart is already beating! Use /heart-stop to cancel first."
    exit 1
  fi
fi

# Create HEART.md template if it doesn't exist
if [[ ! -f "$HEART_FILE" ]]; then
  cat > "$HEART_FILE" << 'TEMPLATE'
# Heart Tasks

## Config
- interval: immediate
- mode: sequential
- max_iterations: 0

## Tasks
- [ ] Example task — replace with your own

## Improvement Loops
<!-- These run every cycle -->
TEMPLATE
  echo "Created HEART.md template at $HEART_FILE"
  echo "Edit it with your tasks, then run /heart again."
  exit 0
fi

# Count tasks
TOTAL_TASKS=$(grep -c '^\- \[ \]' "$HEART_FILE" 2>/dev/null || echo "0")
DONE_TASKS=$(grep -c '^\- \[x\]' "$HEART_FILE" 2>/dev/null || echo "0")

if [[ "$TOTAL_TASKS" -eq 0 ]]; then
  echo "No incomplete tasks found in HEART.md. Add some tasks first!"
  exit 1
fi

# Read max_iterations from config if not set via args
if [[ "$MAX_ITERATIONS" -eq 0 ]]; then
  CONFIG_MAX=$(grep '^\- max_iterations:' "$HEART_FILE" | sed 's/.*: *//' | sed 's/ *#.*//' || echo "0")
  if [[ "$CONFIG_MAX" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS="$CONFIG_MAX"
  fi
fi

# Ensure .claude directory exists
mkdir -p "$STATE_DIR"

# Get the first incomplete task
FIRST_TASK=$(grep '^\- \[ \]' "$HEART_FILE" | head -1 | sed 's/^\- \[ \] //')

# Create state file
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$STATE_FILE" << EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
current_task: "$FIRST_TASK"
started_at: "$TIMESTAMP"
last_completed: ""
---

You are Heart, an autonomous task runner. Read HEART.md in the project root, find the next incomplete task (first unchecked checkbox under ## Tasks), execute it fully, then mark it as [x] in HEART.md. If all Tasks are done, check ## Improvement Loops for recurring items to run. Be focused, atomic, and brief in your reporting. When done with the current task, simply finish your response — the heartbeat will pick up the next task automatically.

Current task: $FIRST_TASK
EOF

echo ""
echo "=== Heart is now beating ==="
echo ""
echo "Tasks: $TOTAL_TASKS remaining, $DONE_TASKS completed"
echo "Max iterations: $([ "$MAX_ITERATIONS" -eq 0 ] && echo 'unlimited' || echo "$MAX_ITERATIONS")"
echo "First task: $FIRST_TASK"
echo ""
echo "Use /heart-stop to cancel at any time."
echo "Use /heart-add \"task\" to add tasks mid-session."
echo ""
