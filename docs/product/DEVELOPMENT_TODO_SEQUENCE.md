# LifeOS AI Development To-Do Sequence

Version: 1.0  
Date: May 22, 2026  
Repository: `LifeOS AI`

## 1. Project Development Strategy

Development must follow the existing monorepo architecture and product documentation already present in the repository. The current project is a TypeScript-first Turborepo with:

- `apps/backend`: NestJS API using oRPC contracts and Better Auth session integration.
- `apps/web`: Next.js 16 web app using Tailwind CSS, shadcn/ui components, Better Auth client helpers, and placeholder LifeOS dashboard UI.
- `apps/mobile`: Flutter mobile app with LifeOS tabs for Capture, Timeline, Ask, Insights, and Privacy.
- `packages/contracts`: shared oRPC contracts and Zod schemas for API inputs/outputs.
- `packages/db`: Drizzle ORM schema for PostgreSQL, including Better Auth tables and LifeOS data tables.
- `packages/auth`: shared Better Auth configuration.
- `packages/e2e-web`: Playwright test package.

Execution should be **mobile-first for the MVP**. The backend, database, contracts, auth, AI, jobs, and storage foundations must still be built because the mobile app depends on them, but product-facing feature work should prioritize `apps/mobile` before building the full `apps/web` experience. The existing web app can remain limited to authentication, basic internal checks, support pages, or temporary developer/admin surfaces until the mobile MVP is stable.

The project should be built dependency-first. Each module should become an end-to-end deliverable before dependent modules are treated as complete. For example, captures must persist reliably before AI memory extraction can be trusted; saved memories must work before timeline, search, reflections, exports, and analytics can be validated.

Core foundations that must be completed first:

- [ ] Repository, environment, database, and local development setup.
- [ ] Better Auth session handling across backend, web, and mobile.
- [ ] Database migration and seeding workflow for Drizzle/PostgreSQL.
- [ ] Contract-first API flow through `packages/contracts` and `apps/backend/src/modules/v1`.
- [ ] Shared validation patterns through Zod schemas in `packages/contracts`.
- [ ] Base API clients for web and mobile.
- [ ] Protected routes, authenticated user context, and user-owned database queries.
- [ ] AI, job queue, and storage abstractions required by capture, memory, search, reflection, and export workflows.
- [ ] Mobile app navigation, auth state, API client, offline storage, permissions, and LifeOS tab shell.

### Mobile-first execution rule

- [ ] Build user-facing MVP flows in `apps/mobile` first.
- [ ] Build backend APIs, contracts, database schemas, workers, storage, and tests as needed to support the mobile flows.
- [ ] Defer full `apps/web` product screens until the mobile MVP flow is complete and accepted.
- [ ] Keep `apps/web` changes limited to auth validation, support pages, developer verification screens, or temporary internal tooling unless the product owner explicitly reprioritizes web.
- [ ] Do not duplicate mobile feature work into web during MVP unless it is required for testing, operations, or acceptance review.
- [ ] When a phase below mentions frontend work, treat mobile UI as the required deliverable and web UI as deferred unless explicitly marked as needed.
- [ ] Keep web contracts/API compatibility in mind so web can be built later without redesigning backend modules.

## 2. Development Sequence Overview

1. **Repository and Environment Setup**
   - Comes first because every feature depends on a working monorepo, database, env config, auth secrets, and reproducible build/test commands.

2. **Core System Foundation**
   - Comes before business modules because LifeOS data is private and every protected feature depends on authentication, authorization, validation, error handling, database access, contracts, and API clients.

3. **User and Account Module**
   - Comes before protected LifeOS workflows because all captures, memories, reflections, exports, and settings are scoped to the authenticated user. Complete the mobile auth/onboarding path first; keep web auth working for local verification.

4. **Primary Business Module: Capture -> AI Memory Extraction -> Review**
   - This is the core LifeOS value loop. It must work end to end in the mobile app before timeline, search, reflections, and insights can be meaningful.

5. **Dependent Business Modules**
   - Timeline, search/ask, reflections, exports, privacy controls, offline sync, notifications, and future insights all depend on captures and saved memories. Build their mobile surfaces first.

6. **Workflow and Status Management**
   - Comes after core modules exist because status transitions must coordinate real records across `raw_captures`, `memories`, `reflections`, exports, queues, and UI states.

7. **Reports, Dashboard, and Analytics**
   - Comes after real data modules are working because dashboards and analytics must aggregate accurate captures, memories, reflections, streaks, pending review counts, and search activity.

8. **System Integration**
   - Comes after the modules are individually complete to verify cross-module behavior, remove duplicate logic, and align UI/UX across web and mobile.

9. **Testing and Quality Assurance**
   - Runs throughout development, then becomes a dedicated hardening phase after the full workflow is connected.

10. **Deployment Preparation**
    - Comes after feature behavior stabilizes because production env vars, migrations, security, logging, storage, queue workers, and monitoring need the final runtime shape.

11. **Final Acceptance Review**
    - Comes last to map TOR requirements, user stories, and user flows to actual implementation status.

## 3. Detailed End-to-End To-Do List

## Phase 1: Repository and Environment Setup

### Existing architecture references

- Root scripts: `package.json`
- Workspace config: `pnpm-workspace.yaml`, `turbo.json`
- Docker setup: `docker-compose.yml`, `docker-compose.staging.yml`, `docker-compose.production.yml`, `Dockerfile`
- Database package: `packages/db`
- Backend app: `apps/backend`
- Web app: `apps/web`
- Mobile app: `apps/mobile`
- Test guide: `TESTING.md`
- Product docs: `docs/product/lifeos-ai-tor.md`, `docs/product/lifeos-ai-user-flows.md`, `docs/product/lifeos-ai-user-stories.md`

### Tasks

- [x] Verify the monorepo structure matches the README:
  - [x] Confirm `apps/web` is the Next.js frontend.
  - [x] Confirm `apps/backend` is the NestJS API.
  - [x] Confirm `apps/mobile` is the Flutter app.
  - [x] Confirm `packages/contracts` owns API contracts and DTO schemas.
  - [x] Confirm `packages/db` owns Drizzle schema, migrations, and seed logic.
  - [x] Confirm `packages/auth` owns Better Auth shared config.
  - [x] Confirm `packages/e2e-web` owns Playwright tests.
- [x] Install dependencies using the repo package manager:
  - [x] Run `pnpm install`.
  - [x] Confirm Node version is `>=22.20.0`.
  - [x] Confirm pnpm version is `>=10.15.1`.
  - [x] Confirm Flutter/Dart toolchain is installed for `apps/mobile`.
- [x] Create and verify environment files:
  - [x] `apps/backend/.env`
  - [x] `apps/web/.env`
  - [x] `packages/db/.env`
  - [x] `apps/mobile/.env` if the mobile env file is required by the mobile runtime.
- [x] Configure required backend env vars in `apps/backend/src/config/env.config.ts`:
  - [x] `DATABASE_URL`
  - [x] `BETTER_AUTH_SECRET`
  - [x] `BETTER_AUTH_TRUSTED_ORIGINS`
  - [x] `CORS_ORIGINS`
  - [x] `PORT`
  - [x] `HOST`
  - [x] Optional `GOOGLE_CLIENT_ID`
  - [x] Optional `GOOGLE_CLIENT_SECRET`
  - [x] Optional `OPENAI_API_KEY`
  - [x] Optional `OPENAI_MODEL`
  - [x] Optional `OPENAI_EMBEDDING_MODEL`
  - [x] Optional `REDIS_URL`
  - [x] Optional `STORAGE_BUCKET`
  - [x] Optional `STORAGE_ENDPOINT`
  - [x] Optional `STORAGE_ACCESS_KEY`
  - [x] Optional `STORAGE_SECRET_KEY`
  - [x] Optional `STORAGE_REGION`
- [x] Configure required web env vars:
  - [x] `NEXT_PUBLIC_APP_URL`
  - [x] `NEXT_PUBLIC_API_BASE_URL`
  - [x] `NEXT_PUBLIC_API_VERSION`
- [ ] Configure mobile API settings:
  - [x] Review `apps/mobile/lib/core/constants/api_constants.dart`.
  - [x] Confirm mobile points to the same backend base URL used by Better Auth and oRPC.
  - [ ] Confirm Android emulator/device can reach the backend host.
- [ ] Start local PostgreSQL:
  - [ ] Run `docker compose up -d db`.
  - [x] Confirm PostgreSQL is reachable through `DATABASE_URL`.
- [ ] Confirm Drizzle database workflow:
  - [ ] Run `pnpm db:push` for local schema push.
  - [ ] Run `pnpm db:generate` if migration files are required for team workflow.
  - [ ] Run `pnpm db:migrate` if migrations exist and are the chosen source of truth.
  - [ ] Run `pnpm db:seed` and confirm seed data does not conflict with LifeOS user data.
- [ ] Confirm pgvector readiness:
  - [ ] Verify `CREATE EXTENSION IF NOT EXISTS vector;` is applied before using `memories.embedding`.
  - [ ] Document where the extension is enabled for local, staging, and production databases.
- [ ] Run existing project commands:
  - [ ] `pnpm build`
  - [ ] `pnpm typecheck`
  - [ ] `pnpm lint`
  - [ ] `pnpm test`
  - [ ] `pnpm test:e2e:web`
  - [ ] Mobile: `flutter analyze` inside `apps/mobile`
  - [ ] Mobile: `flutter test` inside `apps/mobile`
- [ ] Confirm local dev commands:
  - [ ] `pnpm dev`
  - [ ] `pnpm dev:backend`
  - [ ] `pnpm dev:mobile`
  - [ ] `pnpm dev:web` for auth/support/internal verification only during mobile-first MVP work.
- [ ] Document setup gaps:
  - [x] Missing `.env.example` files, if any.
  - [ ] Missing migration files, if any.
  - [x] Missing pgvector setup instructions, if any.
  - [ ] Missing local Redis setup for background jobs, if any.
  - [ ] Missing object storage setup for voice audio and exports, if any.
  - [ ] Current blocker: Docker is not installed or not on PATH, so `docker compose up -d db` cannot run.
  - [ ] Current blocker: reachable local PostgreSQL does not have pgvector installed, so `pnpm db:push` fails on `memories.embedding vector(1536)`.

### Done when

- [ ] A new developer can install dependencies, start PostgreSQL, push schema, build, test, and run all apps locally.
- [ ] Required env vars are documented and validated.
- [ ] Database connection and schema setup are confirmed.
- [ ] Any missing setup items are listed in this document or a linked setup document.

## Phase 2: Core System Foundation

### Existing architecture references

- Auth package: `packages/auth/src/config.ts`
- Backend auth usage: `apps/backend/src/modules/v1/*/*.controller.ts`
- Backend env: `apps/backend/src/config/env.config.ts`
- Backend app bootstrap: `apps/backend/src/main.ts`, `apps/backend/src/bootstrap.ts`, `apps/backend/src/app.module.ts`
- Backend oRPC module: `apps/backend/src/common/orpc/orpc.module.ts`
- API contracts: `packages/contracts/src/modules/v1/v1.contract.ts`
- Contract type bridge: `apps/backend/src/config/contract-types.ts`
- Database client: `apps/backend/src/common/database/database.client.ts`, `packages/db/src/client.ts`
- Exception filter: `apps/backend/src/common/filters/http-exception.filter.ts`
- AI abstraction: `apps/backend/src/common/ai/ai.service.ts`
- Jobs abstraction: `apps/backend/src/common/jobs/jobs.service.ts`
- Web auth client/server: `apps/web/services/better-auth`
- Web query provider: `apps/web/services/tanstack-query`
- Mobile API client: `apps/mobile/lib/services/api/api_client.dart`

### Tasks

- [ ] Authentication and authorization:
  - [ ] Confirm Better Auth tables in `packages/db/src/schema.ts`: `users`, `sessions`, `accounts`, `verifications`.
  - [ ] Confirm `packages/auth/src/config.ts` uses the same schema and env vars as the backend.
  - [ ] Confirm Nest controllers use `@Session()` and `UserSession` for protected LifeOS APIs.
  - [ ] Add explicit unauthenticated request handling for all protected endpoints.
  - [ ] Ensure every LifeOS query filters by `userId`.
  - [ ] Ensure account deletion cascades through user-owned records.
- [ ] User roles and permissions:
  - [ ] Confirm whether MVP has only the standard authenticated user role.
  - [ ] If admin/support roles are required for tickets or operations, add role fields or role tables only after product confirmation.
  - [ ] Keep LifeOS memory data private to the owning user by default.
  - [ ] Ensure support ticket access does not expose private memories.
- [ ] Shared route protection:
  - [ ] Protect mobile LifeOS tabs behind auth state in `apps/mobile/lib/core/navigation`.
  - [ ] Protect web routes under `apps/web/app/(site)` that remain active during mobile-first development.
  - [ ] Confirm unauthenticated web users redirect to `apps/web/app/(auth)/login/page.tsx`.
  - [ ] Confirm authenticated users cannot access login/register pages unnecessarily.
- [ ] Shared layout and navigation:
  - [ ] Keep mobile tab order from user flows: Capture, Timeline, Ask, Insights, Settings/Privacy.
  - [ ] Complete mobile navigation and tab shell before expanding web navigation.
  - [ ] Align web `apps/web/features/lifeos/components/site-sidebar.tsx` later when web product screens are approved.
  - [ ] Replace placeholder sidebar links that all point to `/dashboard` only when route files exist and web work is resumed.
  - [ ] Ensure mobile exposes privacy controls from Settings/Privacy for MVP.
- [ ] Base API client/service layer:
  - [ ] Add mobile repositories for LifeOS modules using `Dio` from `apps/mobile/lib/services/api/api_client.dart`.
  - [ ] Persist Better Auth session cookies consistently on mobile using the existing cookie jar and secure storage.
  - [ ] Decide how web calls backend oRPC routes from `packages/contracts` before web product work resumes.
  - [ ] Add typed web service wrappers later for captures, memories, timeline, search, reflections, and exports.
  - [ ] Keep TanStack Query hooks in feature folders for future web data fetching/mutations.
- [ ] Validation patterns:
  - [ ] Keep request validation in `packages/contracts/src/modules/v1/*/*.schema.ts`.
  - [ ] Reuse contract schemas in backend handlers instead of duplicate DTO definitions.
  - [ ] Use matching frontend/mobile form validation for user-facing forms.
  - [ ] Add schema tests for high-risk contracts, following `packages/contracts/src/modules/v1/examples/todos/todos.schema.test.ts`.
- [ ] Error handling:
  - [ ] Standardize backend exceptions through `apps/backend/src/common/filters/http-exception.filter.ts`.
  - [ ] Map database not found errors to 404.
  - [ ] Map unauthorized access to 401/403.
  - [ ] Map AI unavailable and job/storage failures to user-safe messages.
  - [ ] Add web/mobile empty, loading, error, and retry states for each module.
- [ ] Database migration and seeding structure:
  - [ ] Confirm `packages/db/src/schema.ts` is the current source of truth.
  - [ ] Add migration workflow around Drizzle for schema changes.
  - [ ] Add seed data for development users, raw captures, candidate memories, saved memories, reflections, and export requests.
  - [ ] Keep seed data clearly non-production and privacy-safe.
- [ ] AI foundation:
  - [ ] Replace `AiService` stubs with provider calls for transcription, extraction, embeddings, reflection generation, and grounded answers.
  - [ ] Add deterministic test doubles for AI service.
  - [ ] Add prompts/guardrails that preserve original source, avoid unsupported invention, cite memories, and avoid medical claims.
- [ ] Job foundation:
  - [ ] Decide whether BullMQ/Redis is required for MVP or whether synchronous processing is acceptable in development.
  - [ ] Implement real queue handling in `JobsService` when `REDIS_URL` is configured.
  - [ ] Add workers for `transcription`, `extraction`, and `export`.
  - [ ] Define retry, dead-letter, and failed-job status behavior.
- [ ] Storage foundation:
  - [ ] Decide local/S3-compatible storage for voice audio.
  - [ ] Implement secure upload and download URL generation.
  - [ ] Implement export file storage and expiry.
  - [ ] Ensure deletion removes or invalidates stored audio and export files.

### Done when

- [ ] Authenticated API access, user scoping, typed contracts, database access, AI abstraction, job queue behavior, storage behavior, and shared UI/API patterns are ready for feature modules.
- [ ] Web and mobile have a clear path for calling protected backend APIs.
- [ ] Foundation tests exist for auth, validation, database connectivity, and API error handling.

## Phase 3: User and Account Module

### Existing architecture references

- Database tables: `users`, `sessions`, `accounts`, `verifications`
- Auth package: `packages/auth`
- Web auth routes: `apps/web/app/(auth)/login/page.tsx`, `apps/web/app/(auth)/register/page.tsx`, `apps/web/app/(auth)/session/page.tsx`
- Web auth features: `apps/web/features/auth`
- Mobile auth screens: `apps/mobile/lib/features/auth/presentation/screens/login_screen.dart`, `register_screen.dart`
- Mobile auth repository: `apps/mobile/lib/features/auth/data/auth_repository.dart`
- Mobile auth provider: `apps/mobile/lib/features/auth/presentation/providers/auth_provider.dart`
- Account deletion API: `DELETE /v1/account` through `packages/contracts/src/modules/v1/exports/exports.contract.ts`

### Tasks

- [ ] User model/schema review:
  - [ ] Confirm `users.id` type matches Better Auth generated user IDs.
  - [ ] Confirm `users.email` uniqueness.
  - [ ] Confirm `users.name`, `image`, `emailVerified`, `createdAt`, and `updatedAt` satisfy profile requirements.
  - [ ] Identify missing account preference fields under assumptions instead of adding them silently.
- [ ] Registration/login:
  - [ ] Confirm web register form creates Better Auth account.
  - [ ] Confirm web login form creates a backend session cookie.
  - [ ] Confirm mobile register screen creates account through backend Better Auth endpoints.
  - [ ] Confirm mobile login stores session cookies in secure storage and cookie jar.
  - [ ] Handle invalid credentials, duplicate email, weak password, network error, and verification failure states.
- [ ] Onboarding:
  - [ ] Build onboarding state after account creation.
  - [ ] Include product promise content from user flow Flow 1.
  - [ ] Include privacy promise content: data ownership, edit/delete/export, AI processing disclosure.
  - [ ] Include required consent and optional AI feature toggles.
  - [ ] Include first capture prompt before showing empty dashboard.
  - [ ] Persist onboarding progress so abandoned onboarding resumes at the right step.
- [ ] Profile management:
  - [ ] View current user name/email/avatar.
  - [ ] Edit display name if supported by Better Auth configuration.
  - [ ] Show active session/device information if available.
  - [ ] Implement logout on web and mobile.
- [ ] Role-based access behavior:
  - [ ] Treat all LifeOS data as private to the authenticated owner.
  - [ ] Keep admin/staff controls out of MVP unless product confirms them.
  - [ ] If ticket admin is required, create a separate permission model and keep it isolated from LifeOS memory data.
- [ ] Account deletion:
  - [ ] Use `DELETE /v1/account`.
  - [ ] Show serious confirmation and explain deletion scope.
  - [ ] Delete or cascade `raw_captures`, `memories`, `reflections`, `data_exports`, `sessions`, and `accounts`.
  - [ ] Confirm deleted account cannot sign in to old data.
  - [ ] Confirm queued processing does not recreate deleted data.
- [ ] End-to-end frontend/backend integration:
  - [ ] Mobile login -> LifeOS tabs.
  - [ ] Mobile register -> onboarding -> first capture prompt.
  - [ ] Web login -> protected dashboard -> logout for smoke testing only.
  - [ ] Web register -> onboarding -> first capture prompt is deferred unless web MVP is reprioritized.
- [ ] Tests:
  - [ ] Backend auth-protected API e2e tests.
  - [ ] Web form validation tests for login/register.
  - [ ] Mobile auth repository/provider tests.
  - [ ] Playwright login/register/protected route tests.
  - [ ] Account deletion integration test.

### Done when

- [ ] Users can register, log in, remain authenticated, log out, and delete their account on supported clients.
- [ ] Protected LifeOS routes and APIs cannot be accessed without a valid session.
- [ ] User-owned data access is enforced in backend queries.

## Phase 4: Primary Business Module: Capture -> AI Memory Extraction -> Review

The primary business module is the LifeOS memory creation loop:

`raw capture -> transcription if voice -> structured memory candidate -> user review/correction -> saved memory`

This module maps to the TOR MVP features for voice thought capture, quick text capture, memory review, and memory editing. It maps to user stories US-004 through US-010 and is the dependency for timeline, search, ask, reflections, insights, exports, and analytics.

### Existing architecture references

- Database tables: `raw_captures`, `memories`
- Contracts:
  - `POST /v1/captures`
  - `GET /v1/captures/{id}`
  - `PATCH /v1/captures/{id}/transcript`
  - `GET /v1/memories/candidates`
  - `GET /v1/memories/{id}`
  - `PATCH /v1/memories/{id}`
  - `DELETE /v1/memories/{id}`
  - `PATCH /v1/memories/{id}/archive`
  - `PATCH /v1/memories/{id}/restore`
- Backend modules:
  - `apps/backend/src/modules/v1/captures`
  - `apps/backend/src/modules/v1/memories`
- AI service: `apps/backend/src/common/ai/ai.service.ts`
- Jobs service: `apps/backend/src/common/jobs/jobs.service.ts`
- Mobile UI: `apps/mobile/lib/features/lifeos/presentation/screens/capture_tab.dart`
- Web dashboard placeholder: `apps/web/app/(site)/dashboard/page.tsx`

### Database/schema tasks

- [ ] Review `raw_captures` fields:
  - [ ] `id`
  - [ ] `userId`
  - [ ] `type`: `voice` or `text`
  - [ ] `body`
  - [ ] `audioUrl`
  - [ ] `transcript`
  - [ ] `transcriptCorrected`
  - [ ] `mood`
  - [ ] `status`: `pending`, `transcribing`, `extracting`, `done`, `failed`
  - [ ] `syncId`
  - [ ] `capturedAt`
  - [ ] `createdAt`
  - [ ] `updatedAt`
- [ ] Review `memories` fields:
  - [ ] `id`
  - [ ] `userId`
  - [ ] `rawCaptureId`
  - [ ] `title`
  - [ ] `summary`
  - [ ] `eventDate`
  - [ ] `emotions`
  - [ ] `people`
  - [ ] `places`
  - [ ] `topics`
  - [ ] `goals`
  - [ ] `decisions`
  - [ ] `actions`
  - [ ] `sensitivity`
  - [ ] `confidence`
  - [ ] `status`: `candidate`, `saved`, `archived`, `deleted`
  - [ ] `isUserCorrected`
  - [ ] `embedding`
  - [ ] `createdAt`
  - [ ] `updatedAt`
- [ ] Confirm indexes support lookup by user, status, event date, raw capture, and sync ID.
- [ ] Add any missing constraints needed for idempotent offline sync.
- [ ] Confirm pgvector column dimensions match `OPENAI_EMBEDDING_MODEL`.

### Backend/API tasks

- [ ] Complete `POST /v1/captures`:
  - [ ] Validate text captures require `body`.
  - [ ] Validate voice captures require `audioUrl`.
  - [ ] Persist raw capture before starting AI work.
  - [ ] Use `syncId` for idempotent offline sync.
  - [ ] Enqueue `transcription` for voice.
  - [ ] Enqueue `extraction` for text.
  - [ ] Return saved capture with status.
- [ ] Complete `GET /v1/captures/{id}`:
  - [ ] Enforce ownership by `userId`.
  - [ ] Return status for processing UI.
  - [ ] Return transcript/body according to privacy rules.
- [ ] Complete `PATCH /v1/captures/{id}/transcript`:
  - [ ] Enforce ownership by `userId`.
  - [ ] Save corrected transcript.
  - [ ] Mark `transcriptCorrected=true`.
  - [ ] Re-enqueue extraction from corrected transcript.
- [ ] Implement transcription worker:
  - [ ] Load audio from storage.
  - [ ] Set capture status to `transcribing`.
  - [ ] Call `AiService.transcribe`.
  - [ ] Save transcript.
  - [ ] Set status to `extracting`.
  - [ ] Enqueue extraction.
  - [ ] Set status to `failed` on unrecoverable errors.
- [ ] Implement extraction worker:
  - [ ] Load capture source text from corrected transcript, transcript, or body.
  - [ ] Set capture status to `extracting`.
  - [ ] Call `AiService.extractMemory`.
  - [ ] Create or update one memory candidate linked by `rawCaptureId`.
  - [ ] Generate embedding with `AiService.embed`.
  - [ ] Save field-level `confidence`.
  - [ ] Save `sensitivity` if detected.
  - [ ] Set capture status to `done`.
  - [ ] Set capture status to `failed` with retry path if extraction fails.
- [ ] Complete candidate review APIs:
  - [ ] `GET /v1/memories/candidates` lists only owner candidate memories.
  - [ ] `GET /v1/memories/{id}` excludes deleted records.
  - [ ] `PATCH /v1/memories/{id}` updates fields and converts candidate to saved.
  - [ ] `DELETE /v1/memories/{id}` soft-deletes and clears embedding.
  - [ ] `PATCH /v1/memories/{id}/archive` archives.
  - [ ] `PATCH /v1/memories/{id}/restore` restores archived memory to saved.
- [ ] Add source-of-truth rules:
  - [ ] User edits override AI values.
  - [ ] Corrected transcript overrides original transcript for future extraction.
  - [ ] Deleted memories are excluded from all downstream modules.

### Frontend/UI tasks - mobile

- [ ] Replace placeholder buttons in `CaptureTab` with working flows.
- [ ] Voice capture:
  - [ ] Request microphone permission.
  - [ ] Show elapsed time.
  - [ ] Support pause, resume, stop, and cancel.
  - [ ] Save local temporary audio.
  - [ ] Upload or queue audio.
  - [ ] Submit `POST /v1/captures` with `type=voice` and `audioUrl`.
  - [ ] Show transcription/processing status.
- [ ] Text capture:
  - [ ] Open composer.
  - [ ] Require non-empty body.
  - [ ] Autosave draft locally.
  - [ ] Support optional mood.
  - [ ] Submit `POST /v1/captures` with `type=text`.
  - [ ] Show processing status.
- [ ] Memory review:
  - [ ] Candidate list.
  - [ ] Candidate detail view.
  - [ ] Original text/transcript display.
  - [ ] Let user correct transcript before extraction if needed.
  - [ ] Editable title and summary.
  - [ ] Editable event date.
  - [ ] Editable emotions, people, places, topics, goals, decisions, and actions.
  - [ ] Confidence indicators for low-confidence fields.
  - [ ] Sensitive content indicator with careful wording.
  - [ ] Save memory action.
  - [ ] Delete/discard action.
- [ ] Add loading, empty, error, and retry states.
- [ ] Offline readiness:
  - [ ] Generate `syncId` for locally queued captures.
  - [ ] Queue text capture offline.
  - [ ] Queue voice capture metadata/audio offline if storage allows.
  - [ ] Retry sync when network returns.

### Frontend/UI tasks - web deferred

- [ ] Do not build full web capture/review screens during mobile-first MVP unless explicitly reprioritized.
- [ ] Keep `apps/web/app/(site)/dashboard/page.tsx` as placeholder/internal smoke surface until mobile MVP is stable.
- [ ] When web resumes, reuse backend contracts and mobile-validated behavior rather than changing architecture.

### Validation tasks

- [ ] Add tests for `CreateCaptureSchema`.
- [ ] Add tests for `UpdateTranscriptSchema`.
- [ ] Add tests for `UpdateMemorySchema`.
- [ ] Validate max text length, max mood length, URL requirement, UUIDs, and dates.
- [ ] Validate empty capture rejection.
- [ ] Validate invalid status transitions are blocked.

### Testing tasks

- [ ] Backend unit tests for `CapturesService`.
- [ ] Backend unit tests for `MemoriesService`.
- [ ] Worker tests for transcription and extraction.
- [ ] Contract schema tests for captures and memories.
- [ ] Integration test: text capture creates raw capture and memory candidate.
- [ ] Integration test: voice capture enters transcription flow.
- [ ] Integration test: corrected transcript re-extracts memory.
- [ ] Integration test: saving candidate creates saved memory.
- [ ] Integration test: deleting memory removes it from active reads.
- [ ] Web component tests for capture and review forms.
- [ ] Mobile widget/provider tests for capture and review flows.
- [ ] E2E test: user creates text capture, reviews candidate, saves memory, sees it in timeline after Phase 5.

### Completion criteria

- [ ] A signed-in mobile user can create a text capture and see a memory candidate.
- [ ] A signed-in mobile user can create or upload a voice capture and see transcription/extraction status.
- [ ] A signed-in mobile user can review, edit, save, archive, restore, or delete a memory.
- [ ] AI errors preserve raw capture data and show retryable states.
- [ ] Deleted memories are excluded from all active memory reads.

### Done when

- [ ] The primary LifeOS loop works end to end on mobile, with backend support reusable by web later.
- [ ] The module is covered by backend, contract, frontend/mobile, and integration tests.

## Phase 5: Dependent Business Modules

Dependent modules must be developed in this order because each one consumes data from the previous modules.

1. Timeline
2. Semantic Search
3. Conversational Retrieval / Ask
4. Daily Reflections
5. Privacy and Data Export
6. Settings and Personalization
7. Offline Sync
8. Notifications and Reminders
9. Insight Engine
10. Personal Knowledge Graph
11. Support Tickets / Operations

## Phase 5.1: Timeline Module

### Existing architecture references

- Contract: `GET /v1/timeline`
- Contract files: `packages/contracts/src/modules/v1/timeline`
- Backend module: `apps/backend/src/modules/v1/timeline`
- Database: `memories`
- Mobile screen: `apps/mobile/lib/features/lifeos/presentation/screens/timeline_tab.dart`
- Web dashboard recent memories placeholder: `apps/web/app/(site)/dashboard/page.tsx`

### Tasks

- [ ] Database/schema:
  - [ ] Use saved memories only: `memories.status = "saved"`.
  - [ ] Exclude `deleted` and default-exclude `archived`.
  - [ ] Use `eventDate` for chronological grouping.
  - [ ] Confirm indexes for `userId`, `status`, and `eventDate`.
- [ ] Backend/API:
  - [ ] Complete `GET /v1/timeline` pagination.
  - [ ] Support filters from `TimelineQuerySchema`: `mood`, `person`, `topic`, `from`, `to`.
  - [ ] Keep cursor behavior stable across edits/deletes.
  - [ ] Return groups by `YYYY-MM-DD`.
  - [ ] Enforce owner-only results.
- [ ] Frontend/UI:
  - [ ] Build timeline page/tab.
  - [ ] Render date groups.
  - [ ] Render memory cards with title, summary, time, mood/emotions, source type if available.
  - [ ] Open memory detail.
  - [ ] Add filter controls for mood, person, topic, date range.
  - [ ] Add active filter chips and clear controls.
  - [ ] Add empty state for no memories.
  - [ ] Add no-results state for filters.
  - [ ] Add infinite scroll or load more.
- [ ] Integration:
  - [ ] Newly saved memories appear in the correct date group.
  - [ ] Edited memory dates move the memory to the correct group.
  - [ ] Archived/deleted memories disappear from default timeline.
- [ ] Testing:
  - [ ] Unit test grouping logic.
  - [ ] Integration test filters.
  - [ ] E2E test saved memory appears in timeline.

### Done when

- [ ] Users can browse saved memories chronologically, filter them, and open details.

## Phase 5.2: Semantic Search Module

### Existing architecture references

- Contract: `POST /v1/search`
- Contract files: `packages/contracts/src/modules/v1/search`
- Backend module: `apps/backend/src/modules/v1/search`
- Database: `memories.embedding`
- AI method: `AiService.embed`
- Mobile Ask tab includes search-like UI: `apps/mobile/lib/features/lifeos/presentation/screens/ask_tab.dart`

### Tasks

- [ ] Database/schema:
  - [ ] Ensure pgvector extension is installed.
  - [ ] Ensure embeddings are generated for saved memories.
  - [ ] Decide whether candidate memories should be searchable; default should be no.
  - [ ] Ensure deleted memories have null embeddings or are filtered.
- [ ] Backend/API:
  - [ ] Complete `POST /v1/search`.
  - [ ] Embed query with `AiService.embed`.
  - [ ] Use vector similarity through pgvector.
  - [ ] Filter by owner.
  - [ ] Exclude deleted and archived memories by default.
  - [ ] Return memory and score.
  - [ ] Add graceful response when AI provider is unavailable.
- [ ] Frontend/UI:
  - [ ] Add search input to Timeline and/or Ask.
  - [ ] Render ranked results.
  - [ ] Show source memory title, summary, event date, and matched metadata.
  - [ ] Open memory detail from result.
  - [ ] Show no-results state.
  - [ ] Show AI unavailable state.
- [ ] Testing:
  - [ ] Unit test search filters.
  - [ ] Integration test deleted memories never appear.
  - [ ] Integration test archived memories are excluded by default.
  - [ ] Contract test `SearchInputSchema`.

### Done when

- [ ] Users can find memories by meaning, not only exact keyword matching.
- [ ] Search never returns deleted memory content.

## Phase 5.3: Conversational Retrieval / Ask Module

### Existing architecture references

- Contract: `POST /v1/ask`
- Backend module: `apps/backend/src/modules/v1/search`
- AI method: `AiService.answerQuestion`
- Mobile screen: `apps/mobile/lib/features/lifeos/presentation/screens/ask_tab.dart`
- Web dashboard placeholder: ask input in `apps/web/app/(site)/dashboard/page.tsx`

### Tasks

- [ ] Backend/API:
  - [ ] Use search results as retrieval context.
  - [ ] Generate answer using only retrieved memories.
  - [ ] Return `answer` and `citations`.
  - [ ] Filter citations against live, user-owned, non-deleted memories.
  - [ ] Add uncertainty language when evidence is limited.
  - [ ] Add no-evidence response.
  - [ ] Prevent unsupported medical/therapy claims.
- [ ] Frontend/UI:
  - [ ] Build Ask page/tab.
  - [ ] Add question input.
  - [ ] Show answer.
  - [ ] Show citations with links to memories.
  - [ ] Show limited evidence/uncertainty state.
  - [ ] Add follow-up question support if planned for MVP.
  - [ ] Add feedback action: helpful/not accurate if included in MVP/P1.
- [ ] Integration:
  - [ ] Ask can cite memories created from capture flow.
  - [ ] Ask opens cited memory detail.
  - [ ] Deleted memories are not used in answers.
- [ ] Testing:
  - [ ] Unit tests for citation filtering.
  - [ ] Integration test grounded answer with citations.
  - [ ] Integration test no matching memory response.
  - [ ] E2E test ask about a saved memory.

### Done when

- [ ] Users can ask natural language questions and receive grounded answers with memory references.

## Phase 5.4: Daily Reflections Module

### Existing architecture references

- Database: `reflections`
- Contracts:
  - `GET /v1/reflections/today`
  - `GET /v1/reflections/{date}`
  - `PATCH /v1/reflections/{id}`
  - `POST /v1/reflections/{id}/feedback`
- Backend module: `apps/backend/src/modules/v1/reflections`
- AI method: `AiService.generateReflection`
- Mobile screen: `apps/mobile/lib/features/lifeos/presentation/screens/insights_tab.dart`
- Web dashboard reflection placeholder: `apps/web/app/(site)/dashboard/page.tsx`

### Tasks

- [ ] Database/schema:
  - [ ] Confirm `reflections.date` stores `YYYY-MM-DD`.
  - [ ] Confirm `sourceMemoryIds` references live saved memories.
  - [ ] Confirm `isUserEdited` and `feedback` support product stories.
- [ ] Backend/API:
  - [ ] Complete today reflection generation.
  - [ ] Generate from saved, non-deleted memories for the selected day.
  - [ ] Exclude deleted memories.
  - [ ] Decide whether archived memories are included; default should be excluded unless confirmed.
  - [ ] Include limited-data wording when few memories exist.
  - [ ] Regenerate or invalidate reflection when source memory is deleted.
  - [ ] Support user edits through `PATCH /v1/reflections/{id}`.
  - [ ] Support feedback through `POST /v1/reflections/{id}/feedback`.
- [ ] Frontend/UI:
  - [ ] Show today's reflection on dashboard/Insights.
  - [ ] Render summary, key moments, mood pattern, decisions, actions, and source links when available.
  - [ ] Add feedback buttons: helpful, inaccurate.
  - [ ] Add edit reflection action.
  - [ ] Add empty state when no memories exist.
  - [ ] Add loading/error/retry states.
- [ ] Integration:
  - [ ] Reflection links open source memories.
  - [ ] Deleted source memory is removed from future reflection output.
  - [ ] User-edited reflection remains distinguishable from AI-generated reflection.
- [ ] Testing:
  - [ ] Backend tests for get-or-generate behavior.
  - [ ] Backend tests for feedback/update.
  - [ ] Integration test reflection excludes deleted memories.
  - [ ] UI tests for empty and limited-data states.

### Done when

- [ ] Users can read, edit, and rate a daily reflection grounded in saved memories.

## Phase 5.5: Privacy and Data Export Module

### Existing architecture references

- Database: `data_exports`
- Contracts:
  - `POST /v1/exports`
  - `GET /v1/exports/{id}`
  - `DELETE /v1/account`
- Backend module: `apps/backend/src/modules/v1/exports`
- Jobs service: `apps/backend/src/common/jobs/jobs.service.ts`
- Mobile privacy screen: `apps/mobile/lib/features/lifeos/presentation/screens/life_settings_tab.dart`
- Web sidebar Settings link: `apps/web/features/lifeos/components/site-sidebar.tsx`

### Tasks

- [ ] Database/schema:
  - [ ] Confirm `data_exports.status`: `pending`, `ready`, `failed`.
  - [ ] Confirm `downloadUrl` and `expiresAt`.
  - [ ] Add audit fields only if required.
- [ ] Backend/API:
  - [ ] Complete export request flow.
  - [ ] Implement export job worker.
  - [ ] Include readable user data:
    - [ ] Account profile.
    - [ ] Raw captures.
    - [ ] Transcripts.
    - [ ] Memories and metadata.
    - [ ] Reflections and feedback.
    - [ ] Data export metadata.
  - [ ] Include voice/audio only according to retention and storage policy.
  - [ ] Store export file securely.
  - [ ] Generate expiring download URL.
  - [ ] Set status to `ready` or `failed`.
  - [ ] Require authentication for export request and download.
  - [ ] Complete account deletion cascade and storage cleanup.
- [ ] Frontend/UI:
  - [ ] Build Privacy/Data settings page.
  - [ ] Show data categories and counts if available.
  - [ ] Request data export.
  - [ ] Poll/check export status.
  - [ ] Show ready, failed, expired, and retry states.
  - [ ] Delete account confirmation flow.
  - [ ] Explain deletion scope.
- [ ] Testing:
  - [ ] Integration test export request creates `data_exports` record.
  - [ ] Worker test export file contains expected user-owned data only.
  - [ ] Integration test user cannot access another user's export.
  - [ ] Account deletion test cascades user data.

### Done when

- [ ] Users can request and retrieve a data export and can delete their account/data through a clear confirmation flow.

## Phase 5.6: Settings and Personalization Module

### Existing architecture references

- Product docs require consent, optional AI features, reminders, tone, and sensitive topic handling.
- Current schema does not appear to include dedicated preference/consent tables.
- Mobile privacy/settings UI exists as a placeholder in `apps/mobile/lib/features/lifeos/presentation/screens/life_settings_tab.dart`.

### Tasks

- [ ] Confirm missing data model:
  - [ ] Consent profile.
  - [ ] Optional AI personalization toggle.
  - [ ] Proactive insight toggle.
  - [ ] Reflection tone.
  - [ ] Sensitive topic handling preferences.
  - [ ] Reminder settings.
  - [ ] App lock preference.
- [ ] Add schema only after confirmation:
  - [ ] User preferences table or JSON profile.
  - [ ] Consent history table if auditability is required.
  - [ ] Updated contracts for settings read/update.
- [ ] Backend/API:
  - [ ] Add settings contract in `packages/contracts/src/modules/v1` if missing.
  - [ ] Add settings module in `apps/backend/src/modules/v1`.
  - [ ] Enforce consent gates in AI processing.
  - [ ] Respect disabled insights/proactive processing.
- [ ] Frontend/UI:
  - [ ] Build settings sections:
    - [ ] Account.
    - [ ] Privacy and data.
    - [ ] AI processing consent.
    - [ ] Sensitive topic preferences.
    - [ ] Reflection preferences.
    - [ ] Notifications/reminders.
    - [ ] Security/app lock where mobile supports it.
  - [ ] Show save states and validation errors.
- [ ] Testing:
  - [ ] Settings update tests.
  - [ ] Consent enforcement tests for AI processing.
  - [ ] UI tests for toggle states.

### Done when

- [ ] Users can view and update privacy, consent, and personalization settings, and backend processing respects those settings.

## Phase 5.7: Offline Sync Module

### Existing architecture references

- `raw_captures.syncId`
- `POST /v1/captures` idempotency by `syncId`
- Mobile storage services in `apps/mobile/lib/services/storage`
- Mobile API client in `apps/mobile/lib/services/api/api_client.dart`

### Tasks

- [ ] Database/schema:
  - [ ] Ensure `syncId` supports idempotent capture creation per user.
  - [ ] Consider unique composite index on `userId + syncId` if needed.
- [ ] Mobile:
  - [ ] Detect offline state.
  - [ ] Queue text captures locally.
  - [ ] Queue voice capture metadata and audio locally when storage allows.
  - [ ] Encrypt local queue where platform capabilities allow.
  - [ ] Generate stable `syncId`.
  - [ ] Sync queued captures on reconnect.
  - [ ] Avoid duplicates on retry.
  - [ ] Show sync status: pending, syncing, failed, done.
- [ ] Backend:
  - [ ] Return existing capture on duplicate `syncId`.
  - [ ] Keep processing idempotent for repeated extraction requests.
  - [ ] Prevent deleted queued data from reprocessing.
- [ ] Testing:
  - [ ] Mobile repository tests for queue behavior.
  - [ ] Backend idempotency tests.
  - [ ] Manual QA with airplane mode/reconnect.

### Done when

- [ ] Users can capture offline and sync later without duplicate memories or data loss.

## Phase 5.8: Notifications and Reminders Module

### Existing architecture references

- Mobile notification service: `apps/mobile/lib/services/notifications/notification_service.dart`
- Product stories US-031 and US-032.
- Reflections module creates daily reflection readiness signal.

### Tasks

- [ ] Confirm notification scope:
  - [ ] Daily reflection ready notification.
  - [ ] Optional capture reminders.
  - [ ] Processing complete/failed notification if desired.
- [ ] Backend:
  - [ ] Decide whether reminders are local-only or server scheduled.
  - [ ] Add notification settings data model if needed.
  - [ ] Emit reflection-ready event after reflection generation.
- [ ] Mobile:
  - [ ] Request notification permission.
  - [ ] Schedule local capture reminders.
  - [ ] Show reflection-ready notification.
  - [ ] Deep link notification taps to Insights/reflection.
  - [ ] Respect disabled notifications.
- [ ] Web:
  - [ ] Decide whether browser notifications are in MVP or post-MVP.
- [ ] Testing:
  - [ ] Permission denied behavior.
  - [ ] Disabled notification behavior.
  - [ ] Deep link behavior.

### Done when

- [ ] Users receive only opted-in, calm, useful notifications, and can control timing.

## Phase 5.9: Insight Engine Module

### Existing architecture references

- Product stories mark Insight Engine as P1.
- Current database does not appear to include an `insights` table.
- Current contracts do not appear to include an insights module.
- Mobile has placeholder Insights tab.

### Tasks

- [ ] Confirm whether insight engine is MVP or post-MVP for the current build.
- [ ] Add data model after confirmation:
  - [ ] `insights` table.
  - [ ] Source memory IDs.
  - [ ] Insight type.
  - [ ] Confidence/evidence strength.
  - [ ] Status: active, saved, dismissed, deleted.
  - [ ] Feedback.
  - [ ] Sensitive category handling.
- [ ] Add contracts:
  - [ ] List insights.
  - [ ] Get insight detail.
  - [ ] Save/unsave insight.
  - [ ] Dismiss insight.
  - [ ] Submit insight feedback.
- [ ] Backend:
  - [ ] Generate insights only from multiple saved memories.
  - [ ] Respect consent and sensitive topic preferences.
  - [ ] Ground each insight in source memory IDs.
  - [ ] Avoid medical or diagnostic claims.
  - [ ] Label weak evidence as tentative.
- [ ] Frontend/UI:
  - [ ] Show active insights.
  - [ ] Show saved insights.
  - [ ] Show supporting memories.
  - [ ] Allow save, dismiss, hide similar, and feedback.
- [ ] Testing:
  - [ ] Insight generation guardrail tests.
  - [ ] Sensitive topic preference tests.
  - [ ] Deleted memory exclusion tests.

### Done when

- [ ] Users can review pattern insights with evidence and control whether insights are saved, dismissed, or hidden.

## Phase 5.10: Personal Knowledge Graph Module

### Existing architecture references

- Product stories mark Personal Knowledge Graph as P1.
- Current `memories` table stores extracted arrays for `people`, `places`, `topics`, `goals`, `decisions`, and `actions`.
- Current database does not appear to include dedicated `entities` or graph edge tables.

### Tasks

- [ ] Confirm MVP scope:
  - [ ] Use memory metadata arrays only for MVP.
  - [ ] Add graph tables only when relationship browsing/merge/split is required.
- [ ] Add data model if confirmed:
  - [ ] `entities`
  - [ ] `memory_entities`
  - [ ] `entity_relationships`
  - [ ] `entity_corrections`
- [ ] Backend:
  - [ ] Link entities conservatively.
  - [ ] Support user correction for wrong entity merges.
  - [ ] Exclude deleted and archived memories from default related views.
  - [ ] Explain why related items are linked.
- [ ] Frontend/UI:
  - [ ] Related memories section on memory detail.
  - [ ] Entity detail pages for person/topic/goal if in scope.
  - [ ] Split/merge correction UI if in scope.
- [ ] Testing:
  - [ ] Related memory tests.
  - [ ] Entity correction tests.
  - [ ] Deleted memory exclusion tests.

### Done when

- [ ] Users can see related memories and, if graph scope is approved, inspect and correct entity links.

## Phase 5.11: Support Tickets / Operations Module

### Existing architecture references

- Database table: `tickets`
- Contract files: `packages/contracts/src/modules/v1/tickets`
- Backend module: `apps/backend/src/modules/v1/tickets`
- Web route: `apps/web/app/(site)/submit-ticket/page.tsx`

### Tasks

- [ ] Confirm support ticket scope for MVP.
- [ ] Backend/API:
  - [ ] Validate ticket input.
  - [ ] Allow authenticated or unauthenticated ticket submission as product requires.
  - [ ] Store `name`, `email`, `subject`, `priority`, `concern`, `status`, and optional `authorId`.
  - [ ] Add admin/status APIs only if admin role exists.
- [ ] Frontend/UI:
  - [ ] Complete submit ticket form.
  - [ ] Add success/error states.
  - [ ] Avoid asking users to include sensitive memory content unless necessary.
- [ ] Testing:
  - [ ] Contract schema tests.
  - [ ] Backend service tests.
  - [ ] Web form tests.

### Done when

- [ ] Users can submit support issues without exposing private LifeOS memory data unnecessarily.

## Phase 6: Workflow and Status Management

### Tasks

- [ ] Capture status transitions:
  - [ ] `pending -> transcribing -> extracting -> done`
  - [ ] `pending -> extracting -> done` for text captures.
  - [ ] Any processing state -> `failed` on unrecoverable failure.
  - [ ] `failed -> pending/extracting/transcribing` on retry where valid.
- [ ] Memory status transitions:
  - [ ] `candidate -> saved` after user save/update.
  - [ ] `candidate -> deleted` when discarded.
  - [ ] `saved -> archived`
  - [ ] `archived -> saved`
  - [ ] `saved/archived/candidate -> deleted`
  - [ ] Block `deleted -> saved` unless explicit restore policy exists.
- [ ] Reflection workflow:
  - [ ] Generate only from eligible memories.
  - [ ] Mark `isUserEdited=true` after user edit.
  - [ ] Save `feedback=helpful` or `feedback=inaccurate`.
  - [ ] Refresh or invalidate reflection when source memory is deleted.
- [ ] Export workflow:
  - [ ] `pending -> ready`
  - [ ] `pending -> failed`
  - [ ] Handle expired download URL.
  - [ ] Allow retry after failure if product requires it.
- [ ] Approval/rejection:
  - [ ] Memory candidate save is approval.
  - [ ] Candidate delete is rejection/discard.
  - [ ] Reflection feedback supports helpful/inaccurate.
  - [ ] Insight feedback supports helpful/not helpful/wrong/hide topic when insights are implemented.
- [ ] Activity logs:
  - [ ] Confirm whether user-visible processing history is required.
  - [ ] If required, add audit/activity table before implementing UI.
  - [ ] Track capture created, transcript corrected, memory saved, memory edited, memory deleted, export requested, account deleted.
- [ ] Notifications:
  - [ ] Notify when reflection is ready if user opted in.
  - [ ] Notify when capture processing completes/fails only if useful and non-invasive.
  - [ ] Notify when export is ready.
- [ ] Tests:
  - [ ] Valid transition tests.
  - [ ] Invalid transition tests.
  - [ ] Retry tests.
  - [ ] Deletion propagation tests.

### Done when

- [ ] Every status shown in the UI maps to a real backend state.
- [ ] Invalid transitions are blocked.
- [ ] Users always know whether their data is saved, processing, failed, ready for review, saved to timeline, archived, deleted, or exported.

## Phase 7: Reports, Dashboard, and Analytics

### Existing architecture references

- Web dashboard placeholder: `apps/web/app/(site)/dashboard/page.tsx`
- Mobile dashboard-style LifeOS tabs: `apps/mobile/lib/features/lifeos`
- TOR success metrics: activation, capture habit, review trust, retrieval value, reflection value, privacy confidence.

### Tasks

- [ ] Build only after captures, memories, timeline, search, and reflections are working.
- [ ] Identify required dashboard data:
  - [ ] Total memories.
  - [ ] Memories captured today.
  - [ ] Current capture streak.
  - [ ] Pending review count.
  - [ ] Today's reflection.
  - [ ] Recent memories.
  - [ ] Processing failures needing attention.
  - [ ] Privacy/export status if relevant.
- [ ] Backend/API:
  - [ ] Add dashboard summary contract if current modules cannot provide efficient aggregation.
  - [ ] Aggregate by authenticated `userId`.
  - [ ] Exclude deleted memories.
  - [ ] Decide whether archived memories count in totals.
  - [ ] Add indexes if aggregation is slow.
- [ ] Frontend/UI:
  - [ ] Replace hardcoded web dashboard arrays with live data.
  - [ ] Keep quick capture as a real entry point.
  - [ ] Show recent memories from timeline.
  - [ ] Show reflection from reflections API.
  - [ ] Show pending candidate count.
  - [ ] Add empty state for new users that leads to first capture.
- [ ] Analytics:
  - [ ] Define product analytics events without logging private memory content.
  - [ ] Track capture created, candidate reviewed, memory saved, memory edited, search used, ask used, reflection opened, export requested, privacy settings opened.
  - [ ] Keep privacy-safe event payloads.
- [ ] Validation:
  - [ ] Compare dashboard counts against database seed/test data.
  - [ ] Confirm deleted memories are excluded from reports.
- [ ] Testing:
  - [ ] Aggregation tests.
  - [ ] Dashboard UI tests for populated, empty, and error states.
  - [ ] Privacy-safe analytics tests if analytics are implemented.

### Done when

- [ ] Dashboard/report views are driven by real user-owned data and match database truth.

## Phase 8: System Integration

### Tasks

- [ ] Connect all modules together:
  - [ ] Login/register -> onboarding -> first capture.
  - [ ] Capture -> processing -> candidate review.
  - [ ] Candidate review -> saved memory.
  - [ ] Saved memory -> timeline.
  - [ ] Saved memory -> search.
  - [ ] Search result -> memory detail.
  - [ ] Ask answer -> citations -> memory detail.
  - [ ] Saved memories -> daily reflection.
  - [ ] Memory delete -> timeline/search/ask/reflection/export exclusion.
  - [ ] Export -> export file/status/download.
  - [ ] Settings -> consent/preferences -> AI processing behavior.
- [ ] Verify cross-module data flow:
  - [ ] `raw_captures` link to `memories` through `rawCaptureId`.
  - [ ] `memories` link to `reflections` through `sourceMemoryIds`.
  - [ ] Search uses `memories.embedding`.
  - [ ] Exports include the same data visible to the user.
- [ ] Verify role/access:
  - [ ] User A cannot read User B captures.
  - [ ] User A cannot read User B memories.
  - [ ] User A cannot read User B reflections.
  - [ ] User A cannot read User B exports.
  - [ ] Deleted account cannot access any old protected route.
- [ ] Fix broken or duplicated logic:
  - [ ] Keep API validation in contracts.
  - [ ] Keep database access in services/workers.
  - [ ] Keep UI state logic in feature hooks/providers/repositories.
  - [ ] Remove mock dashboard data once live data is ready.
  - [ ] Remove example todos from user-facing navigation if not part of product.
- [ ] Ensure consistent UI/UX patterns:
  - [ ] Same status language on web and mobile.
  - [ ] Same privacy wording on onboarding and settings.
  - [ ] Same empty/error/loading patterns.
  - [ ] Same memory field names across capture review, memory detail, timeline, ask citations, reflections, and export.

### Done when

- [ ] The system behaves like one connected product instead of separate feature demos.
- [ ] Cross-module deletion, privacy, and status rules are consistent.

## Phase 9: Testing and Quality Assurance

### Existing references

- Test guide: `TESTING.md`
- Root Vitest config: `vitest.config.ts`
- Backend e2e tests: `apps/backend/test`
- Web tests: `apps/web/*.test.tsx`, `apps/web/**/*.test.tsx`
- Contracts tests: `packages/contracts/**/*.test.ts`
- Web e2e: `packages/e2e-web`
- Mobile tests: `apps/mobile/test`

### Tasks

- [ ] Unit tests:
  - [ ] Contract schemas for captures, memories, timeline, search, reflections, exports, settings if added, insights if added.
  - [ ] Backend services: Captures, Memories, Timeline, Search, Reflections, Exports.
  - [ ] AI service prompt/response parsing with mocked provider.
  - [ ] Job workers with mocked AI/storage/database.
  - [ ] Web components and hooks.
  - [ ] Mobile repositories, providers, and widgets.
- [ ] Integration tests:
  - [ ] Authenticated API access.
  - [ ] Text capture to candidate.
  - [ ] Voice capture to transcript to candidate.
  - [ ] Candidate to saved memory.
  - [ ] Saved memory to timeline.
  - [ ] Saved memory to search.
  - [ ] Search to ask answer citations.
  - [ ] Saved memories to daily reflection.
  - [ ] Export request to ready export.
  - [ ] Account deletion cascade.
- [ ] End-to-end tests:
  - [ ] New user registration.
  - [ ] Onboarding privacy consent.
  - [ ] First text capture.
  - [ ] Memory review and save.
  - [ ] Timeline browsing.
  - [ ] Ask question with citation.
  - [ ] Reflection review and feedback.
  - [ ] Export request.
  - [ ] Delete memory and verify it disappears.
- [ ] Manual QA checklist:
  - [ ] Web desktop.
  - [ ] Web mobile viewport.
  - [ ] Android emulator/device.
  - [ ] iOS simulator/device if supported.
  - [ ] Slow network.
  - [ ] Offline capture.
  - [ ] AI unavailable.
  - [ ] Storage unavailable.
  - [ ] Queue unavailable.
  - [ ] Database unavailable.
- [ ] Regression testing:
  - [ ] Deleted memories never appear in timeline, search, ask, reflections, graph, insights, exports, or dashboard.
  - [ ] User-corrected data remains source of truth.
  - [ ] Account deletion removes user-owned records.
  - [ ] Auth cookies/session persistence still works after app restart.
- [ ] Edge cases:
  - [ ] Empty timeline.
  - [ ] Empty search result.
  - [ ] No memories for daily reflection.
  - [ ] Low-confidence extraction.
  - [ ] Sensitive memory.
  - [ ] Duplicate offline sync.
  - [ ] Very long text capture.
  - [ ] Bad audio URL.
  - [ ] AI timeout.
  - [ ] Export failure.
  - [ ] Expired export URL.
- [ ] Permission testing:
  - [ ] Unauthenticated API access.
  - [ ] Cross-user record access.
  - [ ] Deleted account access.
  - [ ] Mobile microphone denied.
  - [ ] Mobile notifications denied.

### Done when

- [ ] All critical user stories have automated coverage or documented manual QA.
- [ ] All P0 flows pass on the supported client(s).
- [ ] Known test gaps are documented before release.

## Phase 10: Deployment Preparation

### Existing architecture references

- Docker: `Dockerfile`, `apps/backend/Dockerfile`, `apps/web/Dockerfile`
- Compose: `docker-compose.yml`, `docker-compose.staging.yml`, `docker-compose.production.yml`
- README deployment sections for staging/production.
- GitHub workflows in `.github`

### Tasks

- [ ] Production environment variables:
  - [ ] Backend `DATABASE_URL`.
  - [ ] Backend `BETTER_AUTH_SECRET`.
  - [ ] Backend `BETTER_AUTH_TRUSTED_ORIGINS`.
  - [ ] Backend `CORS_ORIGINS`.
  - [ ] Backend `OPENAI_API_KEY`.
  - [ ] Backend `OPENAI_MODEL`.
  - [ ] Backend `OPENAI_EMBEDDING_MODEL`.
  - [ ] Backend `REDIS_URL`.
  - [ ] Backend storage env vars.
  - [ ] Web `NEXT_PUBLIC_APP_URL`.
  - [ ] Web `NEXT_PUBLIC_API_BASE_URL`.
  - [ ] Web `NEXT_PUBLIC_API_VERSION`.
  - [ ] Mobile production API base URL.
- [ ] Build optimization:
  - [ ] Run `pnpm build`.
  - [ ] Run backend production-like local start: `pnpm build` then `pnpm --filter @repo/backend start`.
  - [ ] Build web Docker image.
  - [ ] Build backend Docker image.
  - [ ] Build mobile release artifact if mobile is included in release.
- [ ] Database migration strategy:
  - [ ] Enable pgvector in every environment.
  - [ ] Apply Drizzle migrations before app rollout.
  - [ ] Define rollback strategy for schema changes.
  - [ ] Verify migration does not drop user data.
- [ ] Seed/default admin strategy:
  - [ ] Confirm whether a default admin/support user is required.
  - [ ] Do not seed real private memory data in staging/production.
  - [ ] Create test data only in non-production environments.
- [ ] Security checks:
  - [ ] Validate CORS and trusted origins.
  - [ ] Validate cookies are secure in production.
  - [ ] Confirm secrets are not committed.
  - [ ] Confirm export downloads are authenticated or signed and expire.
  - [ ] Confirm audio/object storage is private.
  - [ ] Confirm account deletion cleans storage and queued jobs.
  - [ ] Confirm no private memory content is sent to analytics/logs.
- [ ] Logging/monitoring:
  - [ ] Backend request/error logs.
  - [ ] Job queue monitoring.
  - [ ] AI provider failures/timeouts.
  - [ ] Export job failures.
  - [ ] Database connectivity.
  - [ ] Storage upload/download failures.
  - [ ] Client error reporting with privacy-safe payloads.
- [ ] Backup considerations:
  - [ ] PostgreSQL backups.
  - [ ] Storage backups if retaining voice audio/export files.
  - [ ] Restore test.
  - [ ] Deletion compliance with backups documented.
- [ ] Deployment checklist:
  - [ ] Staging deploy passes smoke tests.
  - [ ] Production deploy plan reviewed.
  - [ ] Health endpoint verified.
  - [ ] Auth verified.
  - [ ] Capture flow verified.
  - [ ] Memory review verified.
  - [ ] Timeline/search/reflection/export verified.
  - [ ] Rollback plan documented.

### Done when

- [ ] The project can be deployed to staging and production with required env vars, migrations, storage, queue workers, monitoring, and rollback plan.

## Phase 11: Final Acceptance Review

### Tasks

- [ ] Match every TOR MVP requirement to implementation status:
  - [ ] Account and onboarding.
  - [ ] Voice thought capture.
  - [ ] Quick text capture.
  - [ ] Memory review.
  - [ ] Memory editing.
  - [ ] Life timeline.
  - [ ] Daily reflection.
  - [ ] Conversational retrieval.
  - [ ] Semantic search.
  - [ ] Privacy controls.
  - [ ] Export data.
  - [ ] Delete data/account.
- [ ] Match every P0 user story to completed features:
  - [ ] US-001 Create Account.
  - [ ] US-002 Understand Product Promise.
  - [ ] US-003 Set Consent Preferences.
  - [ ] US-004 Start Voice Recording Quickly.
  - [ ] US-005 Save Voice Recording.
  - [ ] US-006 Transcribe Voice Capture.
  - [ ] US-007 Create Text Capture.
  - [ ] US-009 Generate Structured Memory From Capture.
  - [ ] US-010 Review Memory Candidate.
  - [ ] US-012 View Memory Detail.
  - [ ] US-013 Edit Saved Memory.
  - [ ] US-014 Delete Saved Memory.
  - [ ] US-016 Browse Chronological Timeline.
  - [ ] US-017 Filter Timeline.
  - [ ] US-018 Search Memories by Meaning.
  - [ ] US-019 Ask Question About Past Memories.
  - [ ] US-021 Generate Daily Summary.
  - [ ] US-027 Export My Data.
  - [ ] US-028 Delete Account and Data.
- [ ] Verify user flow from start to finish:
  - [ ] New user opens app.
  - [ ] Creates account.
  - [ ] Reviews privacy promise.
  - [ ] Sets required consent.
  - [ ] Captures first text or voice memory.
  - [ ] Reviews AI memory candidate.
  - [ ] Corrects memory field.
  - [ ] Saves memory.
  - [ ] Sees memory in timeline.
  - [ ] Searches memory semantically.
  - [ ] Asks question and sees citation.
  - [ ] Reads daily reflection.
  - [ ] Exports data.
  - [ ] Deletes memory/account if desired.
- [ ] Verify AI guardrails:
  - [ ] AI output is grounded in raw input or saved memories.
  - [ ] Confidence/uncertainty is shown where needed.
  - [ ] User corrections override AI interpretation.
  - [ ] AI does not diagnose or make therapy claims.
  - [ ] Sensitive content follows user settings.
- [ ] List remaining risks:
  - [ ] AI provider cost/latency.
  - [ ] Transcription quality.
  - [ ] Embedding/search quality.
  - [ ] Offline sync duplicate prevention.
  - [ ] Data deletion completeness.
  - [ ] Mobile platform permission behavior.
  - [ ] Export security.
- [ ] List blockers:
  - [ ] Missing data models.
  - [ ] Missing env vars.
  - [ ] Missing storage/queue infrastructure.
  - [ ] Missing API routes/contracts.
  - [ ] Missing test coverage.
- [ ] Final go-live checklist:
  - [ ] P0 stories complete.
  - [ ] P0 tests pass.
  - [ ] No critical security gaps.
  - [ ] Privacy controls verified.
  - [ ] Deletion verified.
  - [ ] Exports verified.
  - [ ] Monitoring active.
  - [ ] Rollback plan ready.
  - [ ] Product owner acceptance received.

### Done when

- [ ] The implemented app satisfies the approved TOR, user flows, and P0 user stories, with all remaining assumptions and risks clearly documented.

## 4. Module Dependency Map

- Authentication -> required before all protected LifeOS modules.
- Better Auth database tables -> required before sessions, route protection, user-owned data, and account deletion.
- User ownership enforcement -> required before captures, memories, timeline, search, ask, reflections, exports, settings, and support history.
- Environment/database setup -> required before backend API and Drizzle schema validation.
- Contracts/Zod schemas -> required before backend controllers/services and frontend/mobile typed integration.
- Base API clients -> required before web/mobile feature integration.
- `raw_captures` -> required before transcription and extraction.
- Voice storage -> required before voice capture and transcription.
- Job queue/workers -> required before asynchronous transcription, extraction, and exports.
- AI service -> required before transcription, memory extraction, embeddings, reflections, and ask answers.
- Memory candidates -> required before memory review.
- Saved memories -> required before timeline, semantic search, ask, daily reflections, insights, exports, dashboards, and knowledge graph.
- Memory embeddings -> required before semantic search and ask.
- Timeline -> requires saved memories and metadata filters.
- Search -> requires saved memories and embeddings.
- Ask -> requires search results and grounded answer generation.
- Reflections -> require saved memories and source memory IDs.
- Privacy/export -> requires all user data modules to know what must be included or deleted.
- Settings/consent -> required before optional AI personalization, proactive insights, sensitive topic handling, and reminders.
- Offline sync -> depends on capture create API idempotency through `syncId`.
- Notifications -> depend on reflection readiness, processing status, and user notification settings.
- Insights -> depend on enough saved memories, consent settings, and optional insight data model.
- Knowledge graph -> depends on memory metadata and optional entity/relationship data model.
- Dashboard/analytics -> depend on stable captures, memories, timeline, search, reflections, and privacy-safe event definitions.
- Deployment -> depends on stable env vars, migrations, storage, queues, and build/test success.

## 5. Completion Criteria by Major Phase

- [ ] **Phase 1 done when** local setup, env files, database, build, lint, typecheck, and tests can run reproducibly.
- [ ] **Phase 2 done when** auth, protected APIs, validation, database access, API clients, AI abstraction, jobs, storage, and error handling are ready.
- [ ] **Phase 3 done when** users can register, log in, complete onboarding, access protected areas, log out, and delete accounts.
- [ ] **Phase 4 done when** capture, transcription/extraction, memory candidate review, save, edit, archive, restore, and delete work end to end.
- [ ] **Phase 5 done when** timeline, search, ask, reflections, exports, settings, offline sync, notifications, insights, graph, and support modules meet their scoped completion criteria.
- [ ] **Phase 6 done when** all status transitions are valid, visible, retryable where appropriate, and tested.
- [ ] **Phase 7 done when** dashboard/report data is live, accurate, privacy-safe, and validated against test data.
- [ ] **Phase 8 done when** all modules work together across web/mobile/backend/database without broken data flow.
- [ ] **Phase 9 done when** unit, integration, e2e, manual QA, regression, edge-case, and permission testing are complete for P0 scope.
- [ ] **Phase 10 done when** staging/production deployment requirements are ready and smoke-tested.
- [ ] **Phase 11 done when** every P0 TOR requirement and user story is accepted or explicitly documented as remaining work.

## 6. Assumptions / Needs Confirmation

- [ ] Confirm whether the current architecture documentation is limited to README plus product docs, or whether another architecture file should be added/referenced.
- [ ] Confirm whether MVP target client is mobile-first only, web plus mobile, or web admin/dashboard plus mobile consumer app.
- [ ] Confirm whether web should support browser voice recording or only quick text/dashboard/review flows.
- [ ] Confirm whether voice audio is stored in S3-compatible object storage, local storage, or a third-party media service.
- [ ] Confirm whether transcription uses OpenAI Whisper, another OpenAI-compatible provider, or platform-native transcription.
- [ ] Confirm whether `OPENAI_MODEL=gpt-4o` and `OPENAI_EMBEDDING_MODEL=text-embedding-3-small` are final.
- [ ] Confirm whether `text-embedding-3-small` output dimensions match the current `vector(1536)` column in `memories.embedding`.
- [ ] Confirm whether BullMQ/Redis is required for MVP or can be deferred behind synchronous/development processing.
- [ ] Confirm whether consent/preferences need dedicated tables. Current schema does not appear to include consent profile, onboarding progress, notification preferences, reflection tone, sensitive topic settings, or app lock settings.
- [ ] Confirm whether user roles beyond a standard authenticated user are required. Current LifeOS flows appear single-user/private by default.
- [ ] Confirm whether support/admin staff workflows are in scope for MVP.
- [ ] Confirm whether Insight Engine and Personal Knowledge Graph are P1 post-MVP or included in the current development scope.
- [ ] Confirm whether account deletion must hard-delete immediately or support delayed deletion/undo/legal-retention windows.
- [ ] Confirm whether exports must include raw audio files or only transcript/body plus structured memories.
- [ ] Confirm whether archived memories should be excluded from search, ask, reflections, insights, and dashboard by default.
- [ ] Confirm whether analytics tooling is required and which provider is approved, since private memory content must not be logged.
- [ ] Confirm mobile offline encryption requirements and supported platforms.
- [ ] Confirm notification scope for MVP: daily reflection only, processing status, reminders, or all of these.

## 7. Developer Notes

- [ ] Follow the existing architecture; do not redesign the app unless a missing dependency is confirmed.
- [ ] Treat this file, the TOR, user flows, user stories, and architecture/code structure as the source of truth before creating AI rules or sub-agent instructions.
- [ ] Add AI rules or sub-agent prompts only as workflow helpers after the development sequence is agreed:
  - [ ] Mobile implementation agent/rules: focus on `apps/mobile`, Flutter UI, Riverpod providers, Dio repositories, permissions, offline queue, and mobile QA.
  - [ ] Backend implementation agent/rules: focus on `apps/backend`, `packages/contracts`, `packages/db`, auth, queues, AI service, storage, and API tests.
  - [ ] QA agent/rules: focus on `TESTING.md`, mobile scenarios, backend integration tests, privacy/deletion regressions, and acceptance mapping.
  - [ ] Documentation agent/rules: keep docs synced when confirmed behavior changes.
- [ ] Do not let AI rules or sub-agents override the mobile-first MVP decision unless the product owner changes the priority.
- [ ] Keep shared API contracts in `packages/contracts`.
- [ ] Keep database tables and relations in `packages/db`.
- [ ] Keep backend feature logic inside `apps/backend/src/modules/v1`.
- [ ] Keep cross-cutting backend infrastructure in `apps/backend/src/common`.
- [ ] Keep web feature UI and hooks under `apps/web/features`.
- [ ] Keep mobile feature screens/providers/repositories under `apps/mobile/lib/features`.
- [ ] Avoid large rewrites unless required to complete a verified dependency.
- [ ] Prefer incremental implementation by feature module and user flow.
- [ ] Treat each module as complete only when database, backend, API contract, frontend/mobile integration, validation, error states, and tests are done.
- [ ] Keep reusable components/services consistent across modules.
- [ ] Update Zod schemas and tests when API behavior changes.
- [ ] Update Drizzle migrations when database schema changes.
- [ ] Update seed data when new modules need realistic local QA data.
- [ ] Update documentation when behavior, setup, env vars, privacy handling, or user flows change.
- [ ] Never allow deleted memories to appear in timeline, search, ask, reflections, graph links, insights, exports, or dashboards.
- [ ] Treat user-corrected data as source of truth.
- [ ] Preserve raw input until the user deletes it or a confirmed retention policy removes it.
- [ ] Keep AI answers grounded in stored memories and citations.
- [ ] Use cautious language for sensitive topics and avoid diagnostic claims.
- [ ] Keep private memory content out of logs, analytics, tickets, and support tooling unless the user explicitly chooses to include it.
