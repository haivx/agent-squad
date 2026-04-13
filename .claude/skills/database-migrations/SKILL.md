---
name: database-migrations
description: Safe schema changes with Prisma — migration discipline, zero-downtime patterns, and rollback strategies for production databases.
---

# Database Migrations

## Core Rules

1. **Never edit a migration file after it has been applied.** Prisma checksums migrations; editing breaks `migrate deploy`.
2. **Schema changes and data migrations are separate PRs.** A column rename touching 10M rows must not be bundled with feature code.
3. **Every migration must have a tested rollback path.** Write the `DOWN` SQL before you write the `UP` SQL.
4. **Test against production-sized data before deploying.** A 1-second migration on staging can be a 20-minute table lock on prod.

## Safe Migration Patterns

### Adding a column
```sql
-- Step 1: nullable (safe, no lock)
ALTER TABLE users ADD COLUMN display_name TEXT;

-- Step 2: backfill in batches (separate deploy)
UPDATE users SET display_name = name WHERE display_name IS NULL;

-- Step 3: add NOT NULL constraint (separate deploy, after backfill complete)
ALTER TABLE users ALTER COLUMN display_name SET NOT NULL;
```
Never add a NOT NULL column without a default or backfill in a single migration — it locks the table.

### Renaming a column (4-step, never 1-step)
1. Add new column (`display_name`)
2. Dual-write in application code (write to both columns)
3. Backfill old → new; switch reads to new column; stop writing to old
4. Drop old column in a separate PR after the dual-write deploy is stable

### Adding an index
```sql
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```
Never `CREATE INDEX` without `CONCURRENTLY` on a table with live traffic — it takes an exclusive lock.

### Dropping a column
1. Deploy code that no longer reads/writes the column (Prisma: remove from schema, keep in DB)
2. Verify in production logs that no queries reference the column
3. Drop the column in a subsequent migration

## Prisma-Specific

**`prisma migrate dev`** — development only. Creates migration files and applies them to the dev DB. Never run in staging/prod.

**`prisma migrate deploy`** — CI/CD and production. Applies pending migrations without generating new ones. Fails if a migration file was edited after being applied.

**Preview migration SQL before applying:**
```bash
pnpm prisma migrate diff \
  --from-schema-datasource prisma/schema.prisma \
  --to-schema-datamodel prisma/schema.prisma \
  --script
```

**Baseline for existing databases** (database has tables but no migration history):
```bash
pnpm prisma migrate resolve --applied "0_init"
```
Use when adding Prisma to an existing project — marks the initial state as applied without running SQL.

## Pre-Deploy Checklist

- [ ] Migration tested on staging with production data volume
- [ ] If migration is backward-compatible (additive only): deploy code first, then migration
- [ ] If migration is breaking (drop/rename): deploy migration first, then code
- [ ] Rollback SQL written, tested, and committed alongside the migration
- [ ] No `ALTER TABLE` on tables > 10M rows without `CONCURRENTLY` or a batched approach
- [ ] `EXPLAIN ANALYZE` run on any new query paths introduced by the schema change
- [ ] Index creation time estimated on prod data size before scheduling the deploy window
