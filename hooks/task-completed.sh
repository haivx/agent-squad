#!/bin/bash
# hooks/task-completed.sh
# Runs when a task is being marked complete.
# Exit code 2 = prevent completion, send feedback
# Exit code 0 = allow completion

# Run tests
echo "Running quality gate checks..."

# Optional: CodeRabbit review (non-blocking if CLI not installed)
if command -v coderabbit &> /dev/null; then
  echo "Running CodeRabbit review..."
  if ! coderabbit review --prompt-only 2>/dev/null; then
    echo "WARNING: CodeRabbit found issues. Review them before proceeding."
    echo "Run '/coderabbit:review uncommitted' for details."
    # Non-blocking — don't exit 2 here, let tests be the hard gate
  fi
else
  echo "Note: Install CodeRabbit CLI for AI-powered code review: curl -fsSL https://cli.coderabbit.ai/install.sh | sh"
fi

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
