## Summary

<!-- One sentence: what does this PR do? -->

## Plan reference

<!-- Link to the plan in docs/plans/ if applicable -->

## Changes

<!-- Brief list of what changed and why -->

---

## Review checklist

### For the author
- [ ] All tasks followed TDD (red → green → refactor)
- [ ] CodeRabbit review passed (no Critical/High findings)
- [ ] `pnpm test && pnpm tsc --noEmit` passes locally
- [ ] Each teammate only touched files within their ownership
- [ ] Commits are scoped to individual tasks

### For the human reviewer (Layer 4)
> AI handles syntax, bugs, and style. You focus on what it can't.

- [ ] **Architecture**: Do changes respect module boundaries defined in CLAUDE.md?
- [ ] **Business logic**: Is the logic correct for our domain, not just syntactically valid?
- [ ] **Integration points**: Will this work with the rest of the system?
- [ ] **Naming & abstractions**: Do new names and abstractions make the codebase clearer?
- [ ] **What's missing**: Is there something this PR should have included but didn't?
- [ ] **Rollback**: Can this be safely reverted if something goes wrong?
