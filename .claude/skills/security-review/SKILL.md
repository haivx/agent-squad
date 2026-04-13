---
name: security-review
description: Security checklist for Next.js APIs — secrets management, input validation, auth patterns, and common vulnerability prevention.
---

# Security Review

## Secrets Management

- Never hardcode secrets in source files. Never commit `.env.local`.
- `.env` — safe to commit, contains non-secret defaults and `NEXT_PUBLIC_` vars only.
- `.env.local` — never committed, holds real secrets. Add to `.gitignore` explicitly.
- Server-only secrets must never reach the client bundle:

```typescript
// src/lib/config/server.ts
import 'server-only'; // throws at build time if imported in a Client Component

export const config = {
  databaseUrl: process.env.DATABASE_URL!,
  sessionSecret: process.env.SESSION_SECRET!,
};
```

`NEXT_PUBLIC_` prefix exposes a variable to the client bundle — only use it for values that are intentionally public (analytics IDs, public API base URLs). Audit all `NEXT_PUBLIC_` vars before every release.

## Input Validation

Validate at the API boundary before any DB operation. Never trust the shape of `req.body`.

```typescript
export async function POST(req: Request) {
  const body = await req.json().catch(() => null);
  if (!body) return Response.json({ error: { code: 'INVALID_JSON' } }, { status: 400 });

  const parsed = CreatePostSchema.safeParse(body);
  if (!parsed.success) {
    return Response.json({ error: parsed.error.flatten() }, { status: 422 });
  }
  // parsed.data is now safe to use
}
```

File uploads: enforce `Content-Length` limit in middleware, validate MIME type from magic bytes (not just extension), and store outside the webroot.

## Authentication Patterns

**Session tokens: httpOnly cookies only.** Never `localStorage` — XSS can steal it.

```typescript
res.cookies.set('session', token, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'lax',
  maxAge: 60 * 60 * 24 * 7, // 7 days
  path: '/',
});
```

**JWT:** use only when you need stateless auth across multiple services. For a single Next.js app, a signed session cookie backed by a DB lookup is simpler and revocable.

**`middleware.ts` auth guard** — protect entire route groups at the edge:
```typescript
export function middleware(req: NextRequest) {
  const session = req.cookies.get('session')?.value;
  if (!session) return NextResponse.redirect(new URL('/login', req.url));
  return NextResponse.next();
}
export const config = { matcher: ['/dashboard/:path*'] };
```

## Authorization

Authentication = "who are you". Authorization = "can you access THIS resource".

Always check ownership at the service or route level — middleware only checks authentication:

```typescript
const post = await postService.findById(params.id);
if (!post) return notFound();
if (post.authorId !== session.userId) return forbidden(); // row-level ownership check
```

Prefer UUIDs over auto-increment IDs in URLs — they don't enumerate resources. For user-facing slugs, ensure they're scoped to the authenticated user's namespace.

## Common Vulnerabilities Checklist

- [ ] No raw SQL string concatenation — use Prisma parameterized queries exclusively
- [ ] No `dangerouslySetInnerHTML` with unsanitized user content
- [ ] Rate limiting on auth endpoints (`/api/auth/login`, `/api/auth/register`)
- [ ] Error responses do not include stack traces, DB error messages, or internal paths
- [ ] CORS: explicitly configured with an allowlist, never `Access-Control-Allow-Origin: *` in production
- [ ] Dependencies audited: `pnpm audit` — fix Critical and High before shipping
- [ ] `Content-Security-Policy` header set (at minimum: `default-src 'self'`)
- [ ] All `NEXT_PUBLIC_` environment variables reviewed — none contain secrets
- [ ] File upload endpoints: size limit, MIME validation, no path traversal in filenames
