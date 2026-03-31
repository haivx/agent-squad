# [Feature Name] Implementation Plan

> **Date:** YYYY-MM-DD
> **Author:** Team Lead
> **Status:** Draft | Approved | In Progress | Done

## Goal

[One sentence: what does this feature do for the user?]

## Architecture Decision

[2-3 sentences: what approach are we taking and why?]

## File Map

<!-- Lock in decomposition decisions BEFORE writing tasks -->
<!-- This prevents teammates from creating overlapping files -->

| Action | File Path | Owner | Description |
|--------|-----------|-------|-------------|
| Create | `src/features/xxx/types.ts` | Teammate A | Type definitions |
| Create | `src/features/xxx/schema.ts` | Teammate A | Zod validation |
| Create | `src/features/xxx/components/Foo.tsx` | Teammate B | Main UI |
| Create | `src/api/xxx/route.ts` | Teammate C | API endpoint |
| Modify | `src/lib/types/index.ts` | Lead (sequenced) | Add shared type |

## Dependencies

<!-- Tasks that must complete before others can start -->
```
Task 1 (types & schemas) ──→ Task 2 (API) ──→ Task 4 (integration)
                          ──→ Task 3 (UI)  ──→ Task 4 (integration)
```

## Tasks

### Task 1: Types & Schemas
- **Assigned to:** Teammate A
- **Files to create:** `src/features/xxx/types.ts`, `src/features/xxx/schema.ts`
- **Files to modify:** none
- **Files off-limits:** everything else
- **Blocks:** Task 2, Task 3
- **Acceptance criteria:**
  - [ ] Types cover all API request/response shapes
  - [ ] Zod schemas validate all edge cases
  - [ ] Failing tests written first, then implementation
  - [ ] `pnpm test` passes
  - [ ] `pnpm tsc --noEmit` clean

### Task 2: API Endpoint
- **Assigned to:** Teammate B
- **Files to create:** `src/api/xxx/route.ts`, `src/__tests__/api/xxx.test.ts`
- **Files to modify:** none
- **Files off-limits:** `src/features/`, `src/components/`
- **Depends on:** Task 1
- **Acceptance criteria:**
  - [ ] Endpoint handles happy path + error cases
  - [ ] Input validated with Zod schema from Task 1
  - [ ] Tests cover: valid input, invalid input, edge cases
  - [ ] `pnpm test` passes

### Task 3: UI Components
- **Assigned to:** Teammate C
- **Files to create:** `src/features/xxx/components/`, `src/features/xxx/hooks/`
- **Files to modify:** none
- **Files off-limits:** `src/api/`, `src/lib/`
- **Depends on:** Task 1
- **Acceptance criteria:**
  - [ ] Components render correctly with mock data
  - [ ] Form validation uses Zod schema from Task 1
  - [ ] Tests cover: render, user interactions, error states
  - [ ] `pnpm test` passes

### Task 4: Integration & Wiring
- **Assigned to:** Lead or dedicated teammate
- **Depends on:** Task 2, Task 3
- **Files to modify:** routing, page components
- **Acceptance criteria:**
  - [ ] Feature accessible from navigation
  - [ ] End-to-end flow works: UI → API → response → UI update
  - [ ] All existing tests still pass
  - [ ] Full `pnpm test && pnpm tsc --noEmit && pnpm lint` passes

## Rollback Plan

If integration fails: revert to commit before Task 4 started.
Each task has its own commits, so partial rollback is possible.
