---
name: fullstack-integration
description: End-to-end feature implementation — wiring DB schema through service layer to API route to UI component, with type safety across the full stack.
---

# Fullstack Integration

## The Full Stack Contract

Types flow in one direction: **DB schema → service types → API response types → UI props**.

- One source of truth per type. Use `zod.infer<typeof Schema>` as the shared type — don't duplicate it in `types.ts`.
- Prisma-generated types (`Prisma.UserGetPayload`) are internal. Map to a domain type before they leave the service layer.
- The client must never receive a Prisma model — it exposes DB column names and can include sensitive fields.

```typescript
// One schema, used everywhere
// src/features/posts/schemas.ts
export const PostSchema = z.object({
  id: z.string().uuid(),
  title: z.string().min(1).max(200),
  content: z.string(),
  publishedAt: z.string().datetime().nullable(),
});
export type Post = z.infer<typeof PostSchema>;
// Use this type in: service return types, API response, UI props
```

## Implementation Order

For any CRUD feature, build in this order — each step has a defined contract before the next begins:

1. **DB schema / migration** → output: table with columns and constraints
2. **Zod schema** → output: `PostSchema`, `CreatePostSchema`, `UpdatePostSchema` in `src/features/posts/schemas.ts`
3. **Repository** → output: `PostRepository` interface + `PrismaPostRepository` in `src/features/posts/`
4. **Service** → output: `PostService` with business logic, returns `Post` domain type
5. **API route** → output: `GET/POST /api/posts`, validates with Zod, delegates to service
6. **UI hook** → output: `usePosts()`, `useCreatePost()` using TanStack Query
7. **UI component** → output: renders data, handles loading + error + empty states

Never skip steps. Never implement step 6 before step 5 has a defined response shape.

## Type Safety Across the Stack

```typescript
// zod.infer for shared types (not manual type duplication)
export type CreatePostInput = z.infer<typeof CreatePostSchema>;

// satisfies for config objects — catches typos without widening the type
const queryConfig = {
  staleTime: 5 * 60 * 1000,
  retry: 2,
} satisfies QueryObserverOptions;

// as const for enum-like values — prevents accidental widening to string
const POST_STATUS = ['draft', 'published', 'archived'] as const;
type PostStatus = typeof POST_STATUS[number]; // 'draft' | 'published' | 'archived'
```

API dates: always serialize as ISO 8601 strings (`toISOString()`). Parse on the client with `new Date(post.publishedAt)`. Never send `Date` objects — JSON serialization is inconsistent across runtimes.

## Common Integration Bugs

**Unhandled loading / error states:**
```typescript
// BAD — only handles success
const { data: posts } = usePosts();
return <PostList posts={posts} />;

// GOOD
const { data: posts, isLoading, error } = usePosts();
if (isLoading) return <PostListSkeleton />;
if (error) return <ErrorMessage error={error} />;
if (!posts?.length) return <EmptyState />;
return <PostList posts={posts} />;
```

**Optimistic updates without rollback:**
```typescript
useMutation({
  mutationFn: deletePost,
  onMutate: async (id) => {
    await queryClient.cancelQueries({ queryKey: ['posts'] });
    const previous = queryClient.getQueryData(['posts']);
    queryClient.setQueryData(['posts'], (old) => old.filter(p => p.id !== id));
    return { previous }; // snapshot for rollback
  },
  onError: (err, id, context) => {
    queryClient.setQueryData(['posts'], context.previous); // rollback
  },
});
```

**Mixed success/error conventions:** pick one and never deviate. Either use HTTP status codes (recommended) or a `{ success: boolean }` envelope — never mix them in the same API.

## Checklist Before Marking Feature Done

- [ ] Happy path works end-to-end from DB to UI
- [ ] Loading state renders (skeleton or spinner)
- [ ] Error state renders with actionable message (not just `console.log`)
- [ ] Empty state renders with a hint on how to populate data
- [ ] Types are consistent DB → API → UI — zero `any`, zero `as SomeType` casts
- [ ] Tests cover: service unit tests, API route integration tests, component render tests
- [ ] No Prisma models leaking to the client response
- [ ] Optimistic updates have rollback on error
- [ ] Date fields serialized as ISO 8601 strings in API responses
