# Agent Team Prompt Templates

Copy-paste these prompts to quickly spin up common team configurations.
Customize the specifics for your project.

---

## Solo Dev Quick Start

Best for: building a feature end-to-end alone, no multi-teammate coordination needed.

```
I need to implement [FEATURE].

Read the plan at docs/plans/[PLAN_FILE].md before starting.

Your role: implement end-to-end — DB migration → service → API route → UI.
Follow the fullstack-integration skill order (DB first, UI last).
Follow TDD: write a failing test before each implementation unit.

Files you own: [LIST]
Files off-limits: [LIST]

Acceptance criteria:
- [ ] [criterion 1]
- [ ] [criterion 2]
- [ ] pnpm test passes
- [ ] pnpm tsc --noEmit passes
- [ ] pnpm lint passes

Report back: DONE / DONE_WITH_CONCERNS / BLOCKED
```

---

## 1. Feature Implementation Team

Best for: Building a new feature with clear frontend/backend separation.

```
I need to implement [FEATURE DESCRIPTION].

Before spawning any teammates:
1. Read the plan at docs/plans/[PLAN_FILE].md
2. Verify the file map has no overlapping ownership

Then create an agent team:
- Teammate "types": Implement Task 1 (types & schemas). Only touch files listed in Task 1.
- Teammate "api": Implement Task 2 (API endpoint). Wait for types teammate to finish Task 1 first. Only touch files listed in Task 2.
- Teammate "ui": Implement Task 3 (UI components). Wait for types teammate to finish Task 1 first. Only touch files listed in Task 3.

All teammates MUST follow TDD: write failing test → implement → verify pass → commit.
All teammates MUST run `/coderabbit:review uncommitted` before marking their task complete.

After all teammates finish, I'll handle Task 4 (integration) or spawn a new teammate.

Use delegate mode — do NOT implement any code yourself. Only coordinate.
```

## 2. Code Review Team

Best for: Thorough review of a PR or feature branch from multiple angles.

```
Review the changes in [BRANCH/PR] from multiple perspectives.

Create an agent team with 3 reviewers:
- Teammate "security": Review for security vulnerabilities. Focus on auth, input validation, data exposure, injection risks. Report findings with severity ratings (Critical/High/Medium/Low).
- Teammate "quality": Review for code quality. Check test coverage, error handling, naming, DRY violations, unnecessary complexity. Reference the Code Review Checklist in CLAUDE.md.
- Teammate "perf": Review for performance issues. Check N+1 queries, unnecessary re-renders, bundle size impact, missing memoization.

Each reviewer should:
1. List files they reviewed
2. Rate overall: Approve / Request Changes / Needs Discussion
3. Provide specific line-level feedback

Synthesize all findings into a single review summary when done.
Do NOT fix any code — review only.
```

## 3. Debugging Team

Best for: Complex bugs where the root cause is unclear.

```
We have a bug: [BUG DESCRIPTION]

Steps to reproduce: [STEPS]
Expected: [EXPECTED]
Actual: [ACTUAL]

Create an agent team to investigate from different angles:
- Teammate "repro": Write a failing test that reproduces the bug. Do NOT fix it. Just prove it exists with a test.
- Teammate "trace": Read the code path from [ENTRY POINT] and trace the data flow. Document where the data gets corrupted or the logic breaks.
- Teammate "history": Check git log for recent changes to [RELEVANT FILES]. Identify which commit likely introduced the regression.

After all teammates report findings, synthesize the root cause and create a fix plan.
Then spawn one teammate to implement the fix using TDD.
```

## 4. Refactoring Team

Best for: Large refactors that can be parallelized by module.

```
Refactor [DESCRIPTION OF REFACTORING].

Create an agent team with module specialists:
- Teammate "module-a": Refactor files in [DIR_A]. Keep the same public API. Only change internals.
- Teammate "module-b": Refactor files in [DIR_B]. Keep the same public API. Only change internals.
- Teammate "tests": Update tests for both modules. Ensure coverage doesn't decrease. Run full test suite after each change.

Rules:
- NO changes to shared interfaces without lead approval
- Each teammate commits after each TDD cycle
- If a teammate needs to change a shared file, message the lead and WAIT
- Require plan approval before making changes

Use delegate mode.
```

## 5. Exploration / Research Team

Best for: Evaluating approaches before committing to implementation.

```
I'm considering [TECHNICAL DECISION]. Help me evaluate options.

Create an agent team:
- Teammate "option-a": Prototype approach A — [DESCRIPTION]. Build a minimal proof-of-concept in a scratch directory `scratch/option-a/`. Document trade-offs.
- Teammate "option-b": Prototype approach B — [DESCRIPTION]. Build a minimal proof-of-concept in `scratch/option-b/`. Document trade-offs.
- Teammate "critic": After option-a and option-b finish, review both prototypes. Compare on: complexity, maintainability, performance, testability, and alignment with our existing patterns in CLAUDE.md.

Synthesize findings into a recommendation at `docs/specs/[TOPIC]-evaluation.md`.
Do NOT merge any prototype into the main codebase.
```

---

## Tips for All Templates

1. **Always use delegate mode** — add "Use delegate mode" to your prompt
2. **Pre-approve permissions** — check `.claude/settings.json` covers common ops
3. **Define file boundaries** — most team failures come from overlapping file access
4. **Start with 2-3 teammates** — more teammates = more coordination overhead
5. **Include context in spawn prompts** — teammates don't inherit lead's conversation
6. **Enable CodeRabbit review** — install the plugin (`claude plugin install coderabbit`) and add "Run /coderabbit:review before completing each task" to your spawn prompts
