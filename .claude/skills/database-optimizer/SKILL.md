---
name: database-optimizer
description: PostgreSQL query performance — EXPLAIN ANALYZE, index strategy, N+1 detection, and connection pooling for production databases.
---

# Database Optimizer

## Reading EXPLAIN ANALYZE

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT * FROM posts WHERE user_id = $1;
```

What to look for:

| Signal | Problem |
|--------|---------|
| `Seq Scan` on large table | No usable index — add one |
| `actual rows` >> `estimated rows` | Stale statistics — run `ANALYZE tablename` |
| `Nested Loop` with large outer row count | N+1 in the query plan |
| `Buffers: hit=0 read=50000` | Cold cache or missing index — data from disk |

**The number that matters most:** `actual time` on the outermost node. Everything else is diagnosis; this is the patient's pulse.

Cost numbers are relative, not milliseconds. A cost of `10000` is only bad relative to other queries in your system. Focus on `actual time` and `rows`.

## Index Strategy

Add an index when:
- A column appears in `WHERE`, `JOIN ON`, or `ORDER BY` on a large table
- A foreign key column has no index (Postgres does not auto-index FK columns)

Do not add an index when:
- The table has < 10k rows (sequential scan is faster)
- The column has very low cardinality (e.g., boolean `is_active` on a 50/50 split)
- The table has very high write volume (indexes slow down `INSERT`/`UPDATE`/`DELETE`)

**Composite index column order: equality columns first, range column last.**
```sql
-- Query: WHERE tenant_id = $1 AND created_at > $2
CREATE INDEX CONCURRENTLY idx_posts_tenant_date ON posts(tenant_id, created_at);
-- NOT: (created_at, tenant_id) — range column first kills index efficiency
```

**Partial indexes** — dramatically better when you query a small subset:
```sql
-- Only index unprocessed jobs (usually < 1% of the table)
CREATE INDEX CONCURRENTLY idx_jobs_pending ON jobs(created_at) WHERE status = 'pending';
```

Always use `CREATE INDEX CONCURRENTLY` in production. Without it, the table is locked for writes for the duration.

## Common N+1 Patterns in Prisma

How to spot: queries in a loop, or a count of DB queries proportional to result set size.

```typescript
// BAD — N+1: 1 query for posts + N queries for each author
const posts = await db.post.findMany();
for (const post of posts) {
  const author = await db.user.findUnique({ where: { id: post.authorId } }); // N queries
}

// GOOD — 2 queries total
const posts = await db.post.findMany({ include: { author: true } });

// GOOD — when you need partial fields
const posts = await db.post.findMany({
  select: { id: true, title: true, author: { select: { name: true } } },
});
```

When `include` makes things worse: if a post can have 10k comments and you do `include: { comments: true }`, you're hydrating 10k objects per post. Use a separate paginated query or `_count` instead:
```typescript
const posts = await db.post.findMany({
  include: { _count: { select: { comments: true } } },
});
```

## Connection Pooling

Serverless functions (Vercel, Lambda) create a new process per request — each process opens its own DB connection. Under load, you exhaust Postgres's `max_connections` (default 100).

**Solution: use a connection pooler between the app and Postgres.**
- **PgBouncer** (self-hosted): transaction-mode pooling; many clients share a small pool of real connections.
- **Prisma Accelerate** (managed): drop-in for `DATABASE_URL`, handles pooling + edge caching.

Connection pool sizing formula:
```
pool_size = (num_worker_processes × 2) + effective_spindle_count
```
For a t3.medium Postgres instance with 2 vCPUs: start at `pool_size = 5–10`. Tune up only if you measure connection wait time under load.

## Quick Wins Checklist

- [ ] Run `ANALYZE tablename` after bulk inserts or large deletes (stale statistics cause bad plans)
- [ ] Check `pg_stat_user_tables` for `seq_scan` > 0 on tables > 100k rows
- [ ] Enable `pg_stat_statements` extension for slow query tracking (`track_activity_query_size = 4096`)
- [ ] Replace `SELECT *` with explicit column lists in production queries
- [ ] Verify foreign key columns are indexed — Postgres does not do this automatically
- [ ] Check for `VACUUM` bloat on high-churn tables: `pg_stat_user_tables.n_dead_tup`
