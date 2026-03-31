#!/bin/bash
# hooks/teammate-idle.sh
# Runs when a teammate is about to go idle.
# Exit code 2 = send feedback to keep teammate working
# Exit code 0 = allow teammate to go idle

TEAMMATE_NAME="$1"
TASK_STATUS="$2"

# If teammate completed their task, assign review work
if [ "$TASK_STATUS" = "completed" ]; then
  echo "You've completed your assigned task. Please now:"
  echo "1. Run 'pnpm test' and verify all tests pass"
  echo "2. Run 'pnpm tsc --noEmit' and verify no type errors"
  echo "3. Review your own code against the Code Review Checklist in CLAUDE.md"
  echo "4. Report any concerns to the lead"
  exit 2
fi

# Allow idle for other statuses
exit 0
