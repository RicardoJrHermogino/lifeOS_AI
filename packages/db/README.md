# @repo/db

Drizzle ORM database package with schema definitions and client.

## Structure

```
packages/db/
├── src/
│   ├── client.ts         # Database client factory
│   ├── schema.ts         # Schema exports
│   └── utils/            # Database utilities
├── drizzle.config.ts     # Drizzle configuration
└── package.json
```

## Usage

```typescript
import { db } from "@repo/db"
import { todos, users } from "@repo/db/schema"

// Query examples
const allTodos = await db.select().from(todos)
const user = await db.query.users.findFirst({ where: eq(users.id, "123") })
```

## Environment Variables

| Variable       | Description                  |
| -------------- | ---------------------------- |
| `DATABASE_URL` | PostgreSQL connection string |

## pgvector Extension

The `memories.embedding` column uses the pgvector extension. Before pushing the
schema or writing embeddings, run this once per database (local, staging,
production):

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

The extension must be installed by a Postgres superuser. The `docker-compose.yml`
uses the `pgvector/pgvector:pg17` image and mounts `packages/db/init`, so new
local databases create the extension automatically. Existing local volumes still
need the `CREATE EXTENSION` statement to be run once after the image is updated.

If you use a local Postgres distribution instead of Docker, such as DBngin, make
sure that distribution has the pgvector extension installed. A plain Postgres
install will fail with `extension "vector" is not available`.

## Scripts

| Command            | Description             |
| ------------------ | ----------------------- |
| `pnpm db:push`     | Push schema to database |
| `pnpm db:studio`   | Open Drizzle Studio     |
| `pnpm db:generate` | Generate migrations     |
| `pnpm db:migrate`  | Run migrations          |
| `pnpm db:seed`     | Push schema, then seed users and mock data |

## Adding Tables

1. Create schema in `src/schema/`:

```typescript
// src/schema/posts.ts
import { pgTable, text, timestamp } from "drizzle-orm/pg-core"

export const posts = pgTable("posts", {
	id: text("id").primaryKey(),
	title: text("title").notNull(),
	createdAt: timestamp("created_at").defaultNow(),
})
```

2. Export from `src/schema/index.ts`
3. Run `pnpm db:push` to sync with database
