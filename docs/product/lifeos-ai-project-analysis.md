# LifeOS AI Project Analysis

Version: 1.0  
Date: May 29, 2026  
Project: LifeOS AI  
Audience: Product, Design, Engineering, AI, QA, Operations

## 1. Purpose

This document summarizes the current LifeOS AI documentation and implementation readiness. It turns the project review dashboard into a repo-native reference for planning, sequencing, risk tracking, and acceptance review.

Use this document alongside:

- `docs/product/lifeos-ai-tor.md`
- `docs/product/lifeos-ai-user-flows.md`
- `docs/product/lifeos-ai-user-stories.md`
- `docs/product/DEVELOPMENT_TODO_SEQUENCE.md`

## 2. Overview

| Area | Current Count | Notes |
|---|---:|---|
| Documentation phases | 11 | Phases 1-11, from repo setup to final acceptance |
| P0 user stories | 20 | Required for MVP launch |
| Epics defined | 15 | E01-E15 across onboarding, capture, memory, retrieval, privacy, operations |
| Open assumptions | 17 | Require product owner sign-off before downstream implementation hardens |

## 3. Phase Readiness

| Phase | Status | Notes |
|---|---|---|
| Phase 1: Repository and environment setup | Started | Dependencies and apps exist; local DB/pgvector/Docker setup still needs reproducible path |
| Phase 2: Core system foundation | Partially done | Auth, API clients, contracts, database, AI/jobs/storage need hardening |
| Phase 3: Auth/accounts | Partially done | Web and mobile auth exist; onboarding/consent data model is not complete |
| Phase 4: Capture loop | Not started / partial implementation | Mobile capture UI exists; production transcription/extraction workflow needs completion |
| Phase 5: Dependent modules | Not started / partial implementation | Timeline, search, ask, reflections, exports, settings depend on saved memories |
| Phase 6: Workflow/status | Not started | Requires connected records and job status handling |
| Phase 7: Dashboard/analytics | Not started | Requires real module data and analytics provider decision |
| Phase 8: Integration | Not started | Cross-module behavior and deletion/privacy rules need end-to-end verification |
| Phase 9: QA | Not started / ongoing | Existing checks exist, but P0 flow coverage remains incomplete |
| Phase 10: Deployment | Not started | Needs env, migrations, storage, queue workers, monitoring, rollback plan |
| Phase 11: Acceptance | Not started | Requires mapping TOR and P0 stories to implementation status |

## 4. Product Roles

### End User (Mobile)

The primary user who owns and interacts with their private life data. The Flutter mobile app is the MVP's main product surface.

Core capabilities:

- Voice capture
- Text capture
- Memory review
- Timeline browsing
- Ask/search
- Daily reflection
- Export data
- Delete account/data
- Privacy settings
- Offline capture

### End User (Web)

The same user on desktop. For MVP, web remains limited to authentication, support pages, and internal smoke testing. Full web product surfaces are post-MVP unless reprioritized.

Current scope:

- Login/register
- Submit support ticket
- Smoke-test protected dashboard routes
- Full web product deferred

### Admin / Support Staff

Internal operational users for ticket triage and support. This role is not fully defined for MVP and must not imply access to private user memories.

Potential capabilities, pending confirmation:

- View support tickets
- Update ticket status
- No access to user memories
- Separate permission model if in scope

### AI / Worker Agents

Background system actors, not human users. They process user-owned data under product and privacy constraints.

System responsibilities:

- Transcribe audio
- Extract structured memories
- Generate embeddings
- Generate reflections
- Build export files

## 5. Critical Documentation Gaps

### Critical: Consent and Preferences Data Model Is Missing

US-003 requires consent profiles, onboarding progress, notification preferences, reflection tone, and sensitive topic settings. The current schema does not yet define these as durable records.

Impact:

- Blocks onboarding completion tracking
- Blocks consent-aware AI behavior
- Blocks privacy/settings acceptance criteria
- Blocks notification and reflection personalization

Recommended action:

- Add a dedicated settings/preferences schema after product owner confirmation.
- Include onboarding progress, required consent, optional AI personalization, notification settings, reflection tone, sensitive topic controls, and app-lock settings.

### Critical: pgvector Setup Is Not Automated

Semantic search and Ask depend on vector embeddings. The `memories.embedding` column requires pgvector, but setup remains manual or environment-specific.

Impact:

- Blocks local setup reproducibility
- Blocks semantic search/Ask development
- Blocks staging/production migration confidence

Recommended action:

- Document and automate `CREATE EXTENSION IF NOT EXISTS vector;`.
- Add local, staging, and production instructions.
- Verify migration order before any embedding-dependent tables or indexes.

### Critical: Local Infrastructure Blocks Phase 1 Completion

Current setup notes include Docker/path and PostgreSQL/pgvector blockers. A new developer cannot reliably run the full local workflow without manual fixes.

Impact:

- Slows onboarding
- Makes tests and migrations inconsistent
- Increases support burden for contributors

Recommended action:

- Add a one-command local setup flow for dependencies, database, pgvector, migrations, and seed data.

### High: Queue and Redis Decision Is Deferred

Voice capture, transcription, extraction, exports, retries, and failure recovery need a clear async processing strategy. The docs still leave production queue behavior open.

Impact:

- Unclear retry/dead-letter behavior
- Unclear production scaling path
- Risk of synchronous dev behavior leaking into production assumptions

Recommended action:

- Confirm whether BullMQ/Redis is required for MVP.
- Define retry, timeout, failure, and recovery behavior for transcription, extraction, and export jobs.

### High: Offline Sync Conflict Strategy Is Missing

The docs mention `syncId` duplicate prevention, but do not define conflict resolution when offline local edits diverge from server-processed state.

Impact:

- Duplicate prevention may not cover all reconnect cases
- User edits could be overwritten or ignored

Recommended action:

- Define conflict policy: server wins, client wins, merge, or explicit review.
- Document how local captures, processed candidates, and user edits reconcile.

### High: Admin and Role Model Is Undocumented

Support tickets exist, but staff/admin permissions are not confirmed in the product model.

Impact:

- Support implementation may accidentally expose private data
- Admin functionality lacks safe access boundaries

Recommended action:

- Keep MVP as standard authenticated user only unless confirmed.
- If admin is required, add separate role/permission model with no memory access by default.

### Medium: AI Guardrails Are Mentioned but Not Written

The documentation references grounding, citations, uncertainty, and avoiding medical claims, but prompt templates and evaluation criteria are not yet specified.

Impact:

- Runtime correctness risk
- Harder QA for Ask, reflections, and extraction

Recommended action:

- Add prompt templates and response contracts.
- Add test cases for hallucination, sensitive topics, uncertainty, and citation behavior.

### Medium: Analytics Provider and Event Taxonomy Are Unconfirmed

MVP success metrics require activation, capture habit, retrieval value, and retention tracking. No analytics provider is confirmed.

Impact:

- MVP success cannot be measured reliably
- Privacy-safe event boundaries remain undefined

Recommended action:

- Confirm provider or explicitly defer analytics.
- Define privacy-safe event names and payload rules.
- Never log private memory content.

## 6. Recommendations

### 1. Nail the First 60 Seconds

The first memory should feel magical. Users should see their own words become a structured memory before they leave the first session.

Recommended action:

- Add a live or simulated extraction preview in onboarding.
- Show title, mood, people, decisions, and actions from a first capture.

### 2. Confirm the 17 Open Assumptions

Unresolved assumptions create downstream rework, especially around consent, queues, admin roles, archive behavior, audio retention, deletion timing, exports, and analytics.

Recommended action:

- Hold a focused product owner session.
- Close each assumption.
- Update TOR, user flows, and development sequence before major Phase 4+ work.

### 3. Add an AI Quality Loop Early

User trust depends on accurate extraction. Treat AI quality as product behavior, not only a Phase 9 testing concern.

Recommended action:

- Track correction rate per field in review.
- Use corrections to improve prompts and identify low-confidence fields.
- Prioritize user-corrected data as source of truth.

### 4. Add Weekly Digest as a Retention Feature

Daily reflection is P0, but weekly summaries can increase retention for users who do not capture every day.

Recommended action:

- Consider a post-MVP weekly digest of top memories, mood arc, open actions, and insights.

### 5. Make Privacy Visible

Privacy should be reinforced at capture, review, settings, export, and delete moments.

Recommended action:

- Add subtle data-ownership language in capture and onboarding.
- Keep export/delete controls easy to find.
- Avoid logging or surfacing private memory content in support tooling.

### 6. Define Web MVP Scope Now

The mobile-first rule is correct, but web should still have a small explicit roadmap to avoid backend design surprises.

Recommended action:

- Define whether web v1 supports memory review, timeline, support only, or admin tooling.
- Keep backend contracts compatible with future web surfaces.

### 7. Make Ask the Killer Feature

Semantic search is useful, but grounded conversational retrieval with citations is the differentiated experience.

Recommended action:

- Prioritize citation UX.
- Show source memory context clearly.
- Make answers transparent and easy to verify.

### 8. Add One-Command Local Setup

Local setup gaps are slowing foundation work.

Recommended action:

- Add a setup command or script that installs dependencies, starts DB services, enables pgvector, runs migrations, and seeds safe dev data.

## 7. User Journey

1. Discover and install  
   User installs the mobile app and sees a clear welcome screen with the private second-mind value proposition.

2. Create account  
   User creates an account through email/SSO/passkey and lands in privacy/onboarding, not an empty dashboard.

3. Privacy and consent setup  
   User accepts required consent and configures optional personalization, insights, reminders, and sensitive topic preferences.

4. First capture  
   User records a voice thought or writes text. AI extracts a structured memory candidate. This is the activation moment.

5. Review and save  
   User edits title, mood, people, actions, transcript, or other extracted fields, then saves the memory.

6. Browse timeline  
   Saved memories appear chronologically. User can filter by mood, person, topic, or date.

7. Ask a question  
   User asks about past memories. AI returns a grounded answer with citations that can be opened.

8. Read daily reflection  
   User receives or opens a daily reflection grounded in captured memories, then rates or edits it.

9. Control data  
   User exports data, deletes specific memories, or deletes their account with clear scope explanation.

10. Long-term value  
   Weekly digests, pattern insights, and a personal knowledge graph create long-term retention and meaning.

## 8. Documentation Maintenance Rules

- Update this analysis when implementation status materially changes.
- Keep blockers linked to `DEVELOPMENT_TODO_SEQUENCE.md`.
- Keep P0 scope aligned with `lifeos-ai-user-stories.md`.
- Keep journey changes aligned with `lifeos-ai-user-flows.md`.
- Do not treat web as full product scope during MVP unless the mobile-first decision changes.
- Do not add admin/support staff access to private memories without explicit product and security approval.
