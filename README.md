# agent-squad

A starter template for Claude Code Agent Teams, combining Anthropic's native multi-agent system with workflow discipline from [Superpowers](https://github.com/obra/superpowers).

## What's Included

```
.
├── CLAUDE.md                       # Core instructions (all teammates read this)
├── .claude/
│   ├── settings.json               # Agent teams flag + pre-approved permissions
│   └── skills/
│       ├── backend-patterns/       # Repository pattern, service layer, middleware
│       ├── api-design/             # REST conventions, status codes, pagination
│       ├── database-migrations/    # Zero-downtime schema changes, Prisma discipline
│       ├── database-optimizer/     # EXPLAIN ANALYZE, index strategy, N+1 fixes
│       ├── security-review/        # Secrets, auth patterns, OWASP checklist
│       ├── fullstack-integration/  # DB → service → API → UI type-safe wiring
│       ├── design-taste-frontend/  # Premium UI engineering, anti-cliché rules
│       ├── high-end-visual-design/ # Visual hierarchy, spacing, color systems
│       ├── minimalist-ui/          # Editorial minimalism, warm monochrome
│       ├── industrial-brutalist-ui/# Bold, structural, high-contrast interfaces
│       ├── redesign-existing-projects/ # Audit + elevate existing UI
│       ├── stitch-design-taste/    # Stitch-specific design patterns
│       └── full-output-enforcement/# Bans truncation, enforces complete output
├── docs/
│   ├── plans/
│   │   └── TEMPLATE.md             # Plan template (fill before spawning teammates)
│   └── PROMPT-TEMPLATES.md         # Copy-paste prompts for common team configs
└── hooks/
    ├── teammate-idle.sh            # Auto-assigns review work when teammate finishes
    └── task-completed.sh           # Quality gate: tests + types must pass
```

## Philosophy

This template combines two approaches:

| From Superpowers (Jesse Vincent) | From Agent Teams (Anthropic) |
|---|---|
| Plan before code | Parallel execution |
| TDD (RED-GREEN-REFACTOR) | Shared task list |
| Verification before completion | Peer-to-peer messaging |
| Code review discipline | Delegate mode |
| Systematic debugging | TeammateIdle / TaskCompleted hooks |

The key insight: Agent Teams give you **parallelism**, but without **discipline** teammates waste tokens going in circles. This template bakes discipline into the CLAUDE.md so every teammate follows it automatically.

## Skills

Skills are domain expertise injected into agent context automatically when relevant.
They live in `.claude/skills/` and activate based on task type — no manual invocation needed.

### Backend
| Skill | Activates when... |
|---|---|
| `backend-patterns` | Designing service layer, repository, middleware |
| `api-design` | Creating or reviewing API endpoints |
| `database-migrations` | Adding/changing DB schema with Prisma |
| `database-optimizer` | Slow queries, index design, connection pooling |
| `security-review` | Auth, secrets, input validation, OWASP |
| `fullstack-integration` | Wiring a full feature from DB to UI |

### Frontend
| Skill | Activates when... |
|---|---|
| `design-taste-frontend` | Any UI component or page |
| `high-end-visual-design` | Visual hierarchy, spacing, color decisions |
| `minimalist-ui` | Editorial/minimal interface style |
| `industrial-brutalist-ui` | Bold, structural UI |
| `redesign-existing-projects` | Auditing or elevating existing UI |
| `stitch-design-taste` | Stitch-specific patterns |

### Meta
| Skill | Activates when... |
|---|---|
| `full-output-enforcement` | Any task requiring complete, untruncated output |

To add a skill: create a folder in `.claude/skills/` with a `SKILL.md` file.
Frontmatter needs only `name` and `description`. The description is the auto-trigger signal.

## Code Review Model

This template implements a 4-layer review process where each layer catches what the previous one missed:

| Layer | What | How | Catches |
|-------|------|-----|---------|
| 1. Automate the obvious | Hooks run on task completion | `hooks/task-completed.sh` — tests, types, lint | Syntax errors, type bugs, test failures |
| 2. AI reviewing AI | Fresh-context AI reviews teammate code | CodeRabbit CLI via `/coderabbit:review` | Logic errors, edge cases, security issues |
| 3. Automated CI | Server-side checks on every PR | `.github/workflows/ci.yml` | Anything bypassed locally |
| 4. Human review | Architecture & judgement | PR template + lead review | Business logic, design decisions, what's missing |

The key insight: layers 1-3 are automated and fast. They free up human reviewers (layer 4) to focus on the things only humans can judge — architecture, business context, and "is this the right thing to build?"

## Quick Start

### Prerequisites

- Claude Code (latest version)
- Opus 4.6 model
- tmux (for split-pane mode, optional but recommended)
- CodeRabbit CLI (optional but recommended): `curl -fsSL https://cli.coderabbit.ai/install.sh | sh`

### Setup

1. **Copy this template into your project root:**

```bash
# Copy CLAUDE.md, .claude/, docs/, hooks/ into your project
cp -r agent-squad/* your-project/
cp -r agent-squad/.claude your-project/
```

2. **Customize CLAUDE.md:**
   - Update the tech stack section
   - Define your module boundaries (this is critical!)
   - Add project-specific patterns

3. **Make hooks executable:**

```bash
chmod +x hooks/teammate-idle.sh hooks/task-completed.sh
```

4. **Install CodeRabbit plugin (recommended):**

```bash
claude plugin install coderabbit
coderabbit auth login
```

5. **Start a tmux session (recommended for split panes):**

```bash
cd your-project
tmux new-session -s agent-team
```

6. **Launch Claude Code:**

```bash
claude
```

## Workflow

### Step 1: Plan

Before spawning any teammates, create a plan:

```
Help me plan a feature for [DESCRIPTION].
Break it into tasks with clear file ownership.
Save the plan to docs/plans/YYYY-MM-DD-feature-name.md
Use the template at docs/plans/TEMPLATE.md
```

### Step 2: Review & Approve

Read the plan. Verify:
- No two teammates touch the same files
- Dependencies are explicit
- Each task has clear acceptance criteria

### Step 3: Execute

Copy a prompt from `docs/PROMPT-TEMPLATES.md` or write your own.
Enable delegate mode immediately after the team starts.

### Step 4: Integrate

After all teammates finish, handle integration yourself or spawn one final teammate.

## Customization

### Adding Your Own Hooks

Register hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "TeammateIdle": {
      "command": "bash hooks/teammate-idle.sh"
    },
    "TaskCompleted": {
      "command": "bash hooks/task-completed.sh"
    }
  }
}
```

### Adapting for Your Stack

The CLAUDE.md assumes a TypeScript/Next.js stack. Replace:
- Test commands (`pnpm test` → your test runner)
- Type check commands (`pnpm tsc` → your type checker)
- Lint commands (`pnpm lint` → your linter)
- File structure patterns

### Adding Project-Specific Rules

Add to CLAUDE.md's "Common Patterns" section:
- API conventions
- Error handling patterns
- State management patterns
- Naming conventions

## FAQ

**Q: Do I need tmux?**
No. In-process mode works in any terminal, including VSCode. You just won't get split panes — you'll use Shift+Down to cycle through teammates.

**Q: How many teammates should I spawn?**
Start with 2-3. Token costs scale linearly. A 3-teammate team uses ~3-4x the tokens of a single session. The trade-off is speed vs cost.

**Q: What if teammates conflict on a file?**
This template prevents it by design — CLAUDE.md requires explicit file ownership per task. If it happens anyway, the lead should sequence the edits.

**Q: Can I use this with Superpowers plugin too?**
Yes, but they serve different purposes. Superpowers adds skills for single-agent subagent workflows. This template adapts Superpowers' discipline principles for the multi-agent Agent Teams system. They complement each other.

## Credits

- Workflow discipline: [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent
- Multi-agent system: [Claude Code Agent Teams](https://code.claude.com/docs/en/agent-teams) by Anthropic
- Best practices aggregated from community: [Claude Code Ultimate Guide](https://github.com/FlorianBruniaux/claude-code-ultimate-guide), [ClaudeFast](https://claudefa.st), and many blog posts from the community
