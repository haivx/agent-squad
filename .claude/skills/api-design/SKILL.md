---
name: api-design
description: REST API conventions — resource naming, status codes, pagination, error response format, and versioning for Next.js API routes.
---

# API Design

## URL Conventions

- Plural nouns, kebab-case: `/api/users`, `/api/blog-posts`
- No verbs: not `/api/getUser`, not `/api/createPost`
- Nested resources only when the child cannot exist without the parent: `/api/posts/:postId/comments`
- Flat with query params when the child can exist independently: `/api/comments?postId=123`

Query param conventions:
- Filtering: `?status=active&role=admin`
- Sorting: `?sort=createdAt&order=desc`
- Pagination: `?cursor=<token>` or `?page=2&limit=20`

## HTTP Status Codes

| Code | When to use |
|------|-------------|
| `200` | Successful GET, PUT, PATCH |
| `201` | Resource created (POST) — include `Location` header |
| `204` | Successful DELETE — no body |
| `400` | Malformed request, unparseable JSON, missing required header |
| `401` | Not authenticated — no valid session/token |
| `403` | Authenticated but not authorized for this resource |
| `404` | Resource not found |
| `409` | Conflict — duplicate unique key, optimistic lock failure |
| `422` | Structurally valid but semantically invalid — use for Zod validation failures |
| `429` | Rate limited |
| `500` | Unexpected server error — never expose stack traces |

**Never return `200` with `{ success: false }` inside.** Pick the right status code.

## Consistent Error Response Shape

```typescript
// src/lib/types/api.ts
type ApiError = {
  error: {
    code: string;       // machine-readable: "EMAIL_TAKEN", "VALIDATION_FAILED"
    message: string;    // human-readable
    details?: Record<string, string[]>; // field-level errors from Zod
  };
};
```

```typescript
// 422 example
Response.json({
  error: {
    code: 'VALIDATION_FAILED',
    message: 'Request body is invalid',
    details: parsed.error.flatten().fieldErrors,
  }
}, { status: 422 });
```

Always use string error codes — clients should branch on `code`, not `message`. Messages change; codes are a contract.

## Pagination

**Cursor-based** — use when: table is large, records are inserted frequently, order matters for UI (feeds, activity logs).

**Offset-based** — use when: small datasets, user needs to jump to page N, admin tables with stable data.

```typescript
// src/lib/types/pagination.ts
type PaginatedResponse<T> = {
  data: T[];
  meta: {
    total: number;         // offset-based only
    nextCursor?: string;   // cursor-based only
    hasMore: boolean;
  };
};
```

```typescript
// Cursor query with Prisma
const rows = await db.post.findMany({
  take: limit + 1,
  cursor: cursor ? { id: cursor } : undefined,
  orderBy: { createdAt: 'desc' },
});
const hasMore = rows.length > limit;
const data = hasMore ? rows.slice(0, -1) : rows;
const nextCursor = hasMore ? data[data.length - 1].id : undefined;
```

## Versioning

**Default for Next.js App Router: URL versioning** — `/api/v1/users`.

- Simple to implement with route groups: `src/app/api/v1/`
- Cacheable, debuggable, no header parsing needed
- Header versioning (`Accept: application/vnd.api+json;version=2`) is harder to test and adds middleware complexity

**When to version:** only on breaking changes (removing a field, changing a field type, changing semantics).

**Deprecation:** add `Deprecation: true` and `Sunset: <date>` response headers on the old version. Remove after the sunset date.

Non-breaking changes (adding optional fields, new endpoints) do not require a version bump.
