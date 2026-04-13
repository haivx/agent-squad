---
name: backend-patterns
description: Node.js/Next.js server-side architecture — repository pattern, service layer, error handling, middleware, and API route structure.
---

# Backend Patterns

## Repository Pattern

Separate interface from implementation. The service layer depends on the interface, never the concrete Prisma implementation.

```typescript
// src/lib/repositories/user.repository.ts
export interface UserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  create(data: CreateUserInput): Promise<User>;
}

export class PrismaUserRepository implements UserRepository {
  constructor(private db: PrismaClient) {}

  async findById(id: string): Promise<User | null> {
    const row = await this.db.user.findUnique({ where: { id } });
    return row ? toDomainUser(row) : null;
  }
}
```

Never expose `PrismaClient` outside the repository. Map Prisma models to domain types at the boundary with a `toDomain*` function.

## Service Layer

Business logic lives here — not in route handlers, not in repositories.

```typescript
// src/features/users/user.service.ts
export class UserService {
  constructor(private users: UserRepository) {}

  async registerUser(input: RegisterInput): Promise<Result<User, AppError>> {
    const existing = await this.users.findByEmail(input.email);
    if (existing) return err(new ConflictError('Email already registered'));
    const hashed = await hashPassword(input.password);
    return ok(await this.users.create({ ...input, password: hashed }));
  }
}
```

- Input: validated DTO (post-Zod parse)
- Output: domain object or typed error — never throw from services
- Never return Prisma models; always map to domain types

## API Route Structure (Next.js App Router)

```typescript
// src/app/api/users/route.ts
export async function POST(req: Request) {
  const body = await req.json();
  const parsed = RegisterSchema.safeParse(body);
  if (!parsed.success) {
    return Response.json({ error: parsed.error.flatten() }, { status: 422 });
  }

  const result = await userService.registerUser(parsed.data);
  if (!result.ok) {
    return errorToResponse(result.error); // maps AppError → HTTP status
  }
  return Response.json(result.value, { status: 201 });
}
```

Error handling belongs in the route handler. Services return `Result<T, E>`, never throw HTTP errors.

HTTP status conventions:
- `201` — resource created
- `400` — malformed request (bad JSON, missing field)
- `422` — structurally valid but semantically invalid (Zod failures)
- `409` — conflict (duplicate email)
- `404` — not found
- `401` / `403` — unauthenticated / unauthorized

## N+1 Prevention

**Prefer `include` when you always need the relation and the count is bounded:**
```typescript
const posts = await db.post.findMany({ include: { author: true } });
```

**Prefer `select` when you need a subset of fields — reduces payload size:**
```typescript
const posts = await db.post.findMany({
  select: { id: true, title: true, author: { select: { name: true } } },
});
```

**Never call `findUnique` inside a loop.** Use `findMany` with `where: { id: { in: ids } }` and re-map by ID.

DataLoader pattern: needed when resolving relations in a GraphQL context or when relations are conditionally needed across different callers. For REST, `include` / batched `findMany` is sufficient.

## Middleware Patterns

**Global auth in `middleware.ts`** — runs on the edge, fast, before any route:
```typescript
// middleware.ts
export function middleware(req: NextRequest) {
  const token = req.cookies.get('session')?.value;
  if (!token && isProtectedPath(req.nextUrl.pathname)) {
    return NextResponse.redirect(new URL('/login', req.url));
  }
}
export const config = { matcher: ['/dashboard/:path*', '/api/protected/:path*'] };
```

**Route-level auth** — use when you need fine-grained ownership checks (middleware can't query the DB efficiently):
```typescript
// src/app/api/posts/[id]/route.ts
const session = await getSession(req);
if (!session) return unauthorized();
const post = await postService.findById(params.id);
if (post.authorId !== session.userId) return forbidden();
```

Rate limiting: apply at the middleware layer for auth endpoints; use an edge-compatible store (Upstash Redis). Request logging: structured JSON via a `withLogging` wrapper — never `console.log` in production routes.
