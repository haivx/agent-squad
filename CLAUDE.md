# Project Instructions

## Overview

<!-- Replace with your project description -->
This project uses Claude Code Agent Teams for parallel development.
All teammates read this file on startup — keep it clear and actionable.

---

## Architecture & Tech Stack

<!-- Replace with your actual stack -->
- **Language:** TypeScript
- **Framework:** Next.js (App Router)
- **Styling:** Tailwind CSS + shadcn/ui
- **State:** TanStack Query, React Hook Form + Zod
- **Testing:** Vitest + Testing Library
- **Package Manager:** pnpm

---

## Module Boundaries

<!-- CRITICAL for Agent Teams: prevents file conflicts between teammates -->
<!-- Define clear ownership so no two teammates touch the same files -->

| Module | Directory | Description |
|--------|-----------|-------------|
| API Layer | `src/api/` | API routes, server actions |
| Core/Shared | `src/lib/` | Utilities, types, schemas (coordinate before editing) |
| Features | `src/features/<name>/` | Feature-specific components, hooks, utils |
| UI Components | `src/components/ui/` | Shared UI primitives (coordinate before editing) |
| Tests | `src/__tests__/` | Integration tests |

**Shared files** (`src/lib/`, `src/components/ui/`): teammates MUST coordinate with lead before editing.
If two teammates need to modify a shared file, the lead sequences the edits.

---

## Development Discipline

### 1. Planning Before Code (inspired by Superpowers brainstorming)

Before implementing any feature:
- Lead MUST decompose the task into independent subtasks with clear file boundaries
- Each subtask specifies: exact file paths, acceptance criteria, dependencies
- If a task touches >5 files or multiple modules, break it down further
- Save plans to `docs/plans/YYYY-MM-DD-<feature-name>.md`

### 2. Test-Driven Development (inspired by Superpowers TDD)

All teammates follow RED-GREEN-REFACTOR:

1. **RED:** Write a failing test first
2. **GREEN:** Write minimal code to make the test pass
3. **REFACTOR:** Clean up while keeping tests green
4. **COMMIT:** Commit after each green cycle

**Non-negotiable rules:**
- Never write implementation without a failing test
- Never write a test you haven't seen fail
- Tests must be deterministic — no `sleep()`, no timing dependencies
- One assertion per test when possible
- Test behavior, not implementation details

### 3. Review Protocol

Every teammate MUST run a CodeRabbit review before marking a task complete:

1. Stage your changes: `git add -A`
2. Run review: `/coderabbit:review uncommitted` (or `coderabbit review --prompt-only` in terminal)
3. Read every finding. Fix all Critical and High severity issues.
4. For Medium/Low findings: fix or add a code comment explaining why it's intentional.
5. Re-run review until no Critical/High findings remain.
6. Only then mark the task as complete.

#### Review Loop

The expected workflow is:
- Write code (TDD) → CodeRabbit review → Fix issues → Review again → Complete

This creates a "fresh eyes" review — CodeRabbit analyzes your code with zero context bias,
catching issues that the author is blind to.

#### CI Safety Net

A GitHub Actions workflow mirrors all local quality gates. Even if local checks are skipped,
the CI pipeline will catch failures on the PR. Never force-merge a PR with failing CI.

### 4. Verification Before Completion

Before marking ANY task as complete:
- Run the full test suite: `pnpm test`
- Run type checking: `pnpm tsc --noEmit`
- Run linting: `pnpm lint`
- Verify no regressions in existing functionality
- If any check fails, fix it before reporting done

### 4. Commit Discipline

- Commit after each meaningful unit of work (one TDD cycle = one commit)
- Commit message format: `type(scope): description`
  - types: `feat`, `fix`, `test`, `refactor`, `docs`, `chore`
  - scope: module or feature name
- Never commit failing tests or broken builds

---

## Agent Team Protocols

### For the Team Lead

- **Use delegate mode** (Shift+Tab) — do NOT implement code yourself
- Break work into tasks with explicit file ownership per teammate
- Include in each task assignment:
  - Exact file paths to create/modify
  - Acceptance criteria
  - Which files are off-limits (owned by other teammates)
  - Dependencies on other tasks
- Review teammate output before marking tasks complete
- If a teammate reports BLOCKED, provide context or reassign

### For Teammates

- Read this entire CLAUDE.md before starting work
- Only modify files explicitly assigned to you
- If you need to modify a shared file, message the lead first
- Report status clearly when done:
  - **DONE**: Task complete, all tests pass, ready for review
  - **DONE_WITH_CONCERNS**: Complete but found issues worth discussing
  - **BLOCKED**: Cannot proceed, need input (explain what you need)
  - **NEEDS_CONTEXT**: Missing information to complete the task
- Follow TDD — no exceptions

### Task Structure Template

When the lead creates tasks, use this format:

```
Task: [Short description]
Assigned to: [Teammate name]
Files to create: [list]
Files to modify: [list]
Files off-limits: [list]
Dependencies: [other task IDs if any]
Acceptance criteria:
  - [ ] Criterion 1
  - [ ] Criterion 2
  - [ ] All tests pass
  - [ ] Types check clean
```

---

## Code Review Checklist

When reviewing teammate output (lead or reviewer teammate):

- [ ] Tests exist and cover the happy path + edge cases
- [ ] Tests were written before implementation (TDD)
- [ ] No files modified outside the assigned scope
- [ ] Type safety — no `any`, no `as` type assertions without justification
- [ ] No dead code or commented-out code
- [ ] Commit messages follow convention
- [ ] No regressions in existing tests

---

## Debugging Protocol

When a teammate encounters a bug:

1. **Reproduce:** Write a failing test that demonstrates the bug
2. **Isolate:** Narrow down to the smallest reproduction
3. **Trace:** Find root cause (not symptoms)
4. **Fix:** Minimal change to fix the root cause
5. **Verify:** Confirm the failing test now passes
6. **Regression:** Ensure no other tests broke

Do NOT guess-and-check. Follow the protocol.

---

## Common Patterns

### API Response Types
```typescript
// Always define response types in src/lib/types/
type ApiResponse<T> = {
  data: T;
  error: null;
} | {
  data: null;
  error: { message: string; code: string };
};
```

### Zod Schema Convention
```typescript
// Form schema (client validation) in feature directory
// API schema (server validation) in api directory
// Shared base schema in src/lib/schemas/
```

### Component Structure
```
src/features/<name>/
  ├── components/     # Feature-specific components
  ├── hooks/          # Feature-specific hooks
  ├── utils/          # Feature-specific utilities
  ├── schemas.ts      # Zod schemas for this feature
  ├── types.ts        # Types for this feature
  └── index.ts        # Public exports
```
