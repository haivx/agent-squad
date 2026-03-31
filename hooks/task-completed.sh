#!/bin/bash
# hooks/task-completed.sh
# Runs when a task is being marked complete.
# Exit code 2 = prevent completion, send feedback
# Exit code 0 = allow completion

# Run tests
echo "Running quality gate checks..."

if ! pnpm test --run 2>/dev/null; then
  echo "QUALITY GATE FAILED: Tests are failing."
  echo "Fix all failing tests before marking this task as complete."
  exit 2
fi

if ! pnpm tsc --noEmit 2>/dev/null; then
  echo "QUALITY GATE FAILED: TypeScript type errors found."
  echo "Fix all type errors before marking this task as complete."
  exit 2
fi

echo "Quality gate passed. Task may be completed."
exit 0
