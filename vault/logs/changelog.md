# Changelog

## 2026-07-31 - Housing Prototype with Real District Map

### Done

- Added production-shaped housing data types and mock values in `frontend/app/mocks/housing.ts`.
- Created `/categories/housing` route with hero, three guide sections, OpenStreetMap map, and selected district card.
- Added Leaflet district polygons and tap-to-select colors; map is `ClientOnly` and destroyed on unmount.
- Homepage housing card now navigates to the housing route.
- Marked district boundary and price data as illustrative mocks pending verified district sources.

### Verified

- `npm run typecheck`, `npm run lint`, `npm run test`, and `npm run build` - PASS.
- Browser at 340px: title renders, no horizontal overflow.
- **UNVERIFIED & UNRESOLVED**: Only text/title/structure was visually confirmed in headless smoke; actual Leaflet container was absent. Map must be manually verified locally; district polygons are mocked drawing and must never be shipped as factual data until sourced from official GeoJSON/Overpass. Treat currently as prototype UI.

## 2026-07-31 - Supabase-Only Architecture Cutover

### Decision

- Removed Laravel application backend and Laravel API/admin boundary from active product path.
- Supabase is now the only backend platform: Edge Functions, Auth, Postgres/PostGIS, Storage, Realtime, and RLS.
- Supabase Studio is private pilot admin; restrict project membership, and protect publication/evidence/audit invariants with database constraints/triggers because Studio can bypass client RLS.
- Nuxt exposes only public Supabase URL and anon/publishable key.

### Done

- Removed legacy Laravel backend files.
- Removed Nuxt Laravel API helper and API response types.
- Rewrote architecture, auth-flow, Telegram auth contract, sprint, resume plan, session ledger, and code map.
- Added off-site backup requirement for both database and Storage objects.

### Next

- Implement `telegram-bootstrap` Edge Function.
- Validate Supabase Auth session exchange for Telegram identities.
- Connect Nuxt client through RLS-safe Supabase access.
## 2026-07-31 - Logo-Only SPA Loader

### Done

- Replaced the startup progress bar with the actual TAMITUT `logo.svg` mark inline in `spa-loading-template.html`.
- Added a soft scale/opacity pulse, dark-first surface, OS light-mode fallback, saved Nuxt color-mode override, and reduced-motion fallback.

### Verified

- `npm run typecheck`, `npm run lint`, `npm run test`, and `npm run build` - PASS.
- Pre-hydration browser smoke with scripts blocked until DOM load - PASS:
  - saved `dark`: loader background `rgb(9, 9, 11)`, white logo, `tamitut-pulse`;
  - saved `light`: loader background `rgb(255, 255, 255)`, dark logo, `tamitut-pulse`;
  - `prefers-reduced-motion: reduce`: animation `none`, opacity `1`, transform `none`.

## 2026-07-31 - 340px Header Fit

### Done

- Made the city selector borderless and visibly composed as flag + city name.
- Increased language control breathing room and kept a 36px touch target.
- Preserved full logo at 360px and mark-only logo below 360px.
- Locked 340px as the project mobile floor in `vault/design.md`.

### Verified

- Browser at 340px: header width 340px, no horizontal overflow; city trigger 115.6px with transparent background and no border; language control 36px.

## 2026-04-23 11:20 - Starter Template Initialized

### Done

- Added a minimal frontend starter
- Added a minimal backend starter
- Added a vault-first documentation structure
- Added starter workflow and handoff docs

### Verified

- File structure created
- Core vault entry docs reviewed

### Next

- define product direction
- update sprint and resume plan

## 2026-04-23 17:45 - TamITut Direction Bootstrap

### Done

- Reviewed project brief in `test-text.md`
- Replaced starter identity with TamITut across README, env defaults, and frontend copy
- Updated transitional backend metadata to TamITut naming
- Filled architecture docs (`project-vision`, `roadmap`, `system-design`, `auth-flow`)
- Updated `vault/sprint.md`, `vault/resume-plan.md`, and `vault/CODE_MAP.md`

### Verified

- Core docs align with trust-first TamITut scope
- Frontend defaults now use TamITut app naming
- Vault stop point and next steps are explicit

### Next

- design Supabase schema + RLS matrix
- define Telegram initData verification contract
- implement first listings flow slice

## 2026-04-23 18:20 - Vision Reframed to Curated Bot Guide

### Done

- Removed `test-text.md` from repository
- Reframed project vision from marketplace/listings model to curated bot-companion model
- Updated `README.md` with new philosophy, categories, trust rule, non-goals, and 90-day metric
- Updated frontend copy (`app/pages/index.vue`, `i18n/locales/en.json`, branding defaults)
- Rewrote architecture docs (`project-vision`, `roadmap`, `system-design`, `auth-flow`)
- Updated `vault/sprint.md`, `vault/resume-plan.md`, and `vault/CODE_MAP.md`

### Verified

- No active planning docs depend on `test-text.md`
- Product framing now explicitly states: not marketplace, no user-generated listings
- Sprint and resume plan now point to category/verification modeling work

### Next

- finalize category schema and price snapshot model
- define verification evidence model and moderation publish gates
- draft Telegram navigation tree for Russian-first onboarding

## 2026-04-23 19:05 - Vision Expanded with Full Audit

### Done

- Loaded external full vision document (`tamitut.md`) and merged core product framing
- Adopted trust model option 2: `verified_team`, `recommended_expats`, `under_review`
- Expanded `README.md` with audience matrix, MVP category rationale, UX principles, trust badges, KPIs, and risk table
- Updated frontend messaging to reflect 2-tap UX and 3-level trust badges
- Expanded architecture docs with operational trust rules and trusted-source flow
- Updated sprint/resume to focus on schema + evidence + moderation execution

### Verified

- Vision now explicitly encodes both strict evidence policy and visible under-review state
- Product boundaries still enforce: no marketplace, no open user listings
- Planning docs consistently reference 3-level trust model

### Next

- model trust badge transitions in database schema
- define evidence object contract and trusted-source registry logic
- design moderation SLA and stale-entry re-verification cycle

## 2026-04-23 19:35 - Skill Stack + Startup Critical Path Locked

### Done

- Installed project-level skills: `nuxt`, `nuxt-ui`, `supabase`, `supabase-postgres-best-practices`, `vitest`, `vue-testing-best-practices`, `telegram-bot-builder`
- Added `skills-lock.json` for reproducible skill bootstrap
- Added startup architecture/service docs for:
  - schema + RLS plan
  - trust-state machine
  - Telegram auth contract
  - content seeding protocol
  - CI quality gates
  - agent skills stack
- Updated `README.md`, `vault/sprint.md`, `vault/resume-plan.md`, and `vault/CODE_MAP.md` to reflect startup baseline

### Verified

- `npx skills ls --json` shows all required project skills installed
- New startup docs are linked from system design and roadmap
- Sprint/resume now point to first implementation milestone (schema + RLS)

### Next

- implement first Supabase migration + RLS matrix
- implement trust badge transition enforcement
- implement Telegram auth endpoint contract

## 2026-04-23 19:55 - Schema Contract v1 Locked

### Done

- Rewrote `vault/wiki/architecture/supabase-schema-rls-plan.md` from draft list to locked v1 schema contract
- Locked enums, table set, core columns, constraints, and index baseline
- Added explicit trust-rule mapping to concrete tables/columns
- Added RLS anchor fields for upcoming policy implementation
- Updated sprint and resume plan to reflect schema-contract-complete state

### Verified

- Schema doc now has no `TBD` placeholders
- Trust model requirements map to concrete schema constraints
- Next milestone now clearly starts at SQL migration conversion

### Next

- convert schema contract to SQL migrations
- write RLS policies and role matrix tests
- implement trust-state enforcement and Telegram auth contract

## 2026-04-23 20:15 - Migration Plan + RLS Matrix Planned

### Done

- Added `supabase-migration-file-plan.md` with exact migration file tree and ordered creation sequence
- Added `supabase-rls-policy-matrix-v1.md` with role-by-table CRUD boundaries and policy naming convention
- Linked new docs from startup critical path, system design, CODE_MAP, and README
- Updated sprint/resume to shift from schema-lock to migration-execution phase

### Verified

- Migration plan maps to schema contract objects in sequence (`001` to `020`)
- RLS matrix now explicit for all five roles and all core tables
- Planning docs now provide direct next-step path for SQL implementation

### Next

- scaffold `supabase/` structure and generate migration files
- implement base schema SQL migrations (`001`-`013`)
- implement RLS and guard migrations (`014`-`020`) with tests

## 2026-04-23 20:35 - Supabase Migration Scaffold Created

### Done

- Initialized local Supabase project (`supabase init` via `npx supabase`)
- Generated ordered migration files from plan (`001` through `020`)
- Added migration header templates to each scaffold file with purpose + source links
- Added `supabase/tests/rls/` scaffold files mapped to policy matrix tests
- Added `supabase/seed.sql` scaffold file
- Updated sprint/resume/CODE_MAP to reflect scaffold-complete state

### Verified

- `supabase/migrations/` contains all planned migration stubs in order
- `supabase/tests/rls/` contains all planned policy/guard test stubs
- migration scaffolds align with `supabase-migration-file-plan.md`

### Next

- implement SQL content in migrations `001`-`013`
- implement RLS and policy SQL in `014`-`018`
- implement trust/safety guard SQL in `019`-`020`
- start local Supabase services and validate migrations/tests

## 2026-04-23 21:10 - Base Schema SQL Implemented (`001`-`013`)

### Done

- Implemented concrete SQL for migrations:
  - `001_extensions_and_enums`
  - `002_profiles_and_categories`
  - `003_guide_entries`
  - `004_contacts_prices_checklists`
  - `005_verification_evidence`
  - `006_trusted_sources_and_confirmations`
  - `007_trust_badge_events`
  - `008_safety_cases_and_evidence`
  - `009_scam_patterns`
  - `010_user_suggestions`
  - `011_audit_logs`
  - `012_updated_at_triggers`
  - `013_performance_indexes`
- Added append-only guard trigger for `audit_logs`
- Added partial unique indexes for primary contact, active source confirmations, and checklist positioning rules

### Verified

- `001`-`013` migration files no longer contain template TODO stubs
- `014`-`020` remain intentionally templated for next phase
- schema implementation aligns with locked contract and migration plan

### Blockers

- Docker is not installed in current environment (`docker: command not found`), so local Supabase runtime validation is pending

### Next

- implement RLS helpers/policies in `014`-`018`
- implement trust/safety guard logic in `019`-`020`
- enable Docker and run local migration + policy tests

## 2026-04-23 21:45 - RLS + Guard SQL Implemented (`014`-`020`)

### Done

- Implemented helper function migration `014_rls_helpers` (role, ownership, entry scope helpers)
- Enabled RLS on all operational tables in `015_enable_rls`
- Implemented core read policies in `016_rls_policies_core_read`
- Implemented curator/trusted-source/user write policies in `017_rls_policies_curation_write`
- Implemented moderator/admin policies in `018_rls_policies_moderation_admin`
- Implemented trust transition guards + audit/trust event logging in `019_trust_guard_functions_and_triggers`
- Implemented safety publish evidence guards + audit logging in `020_safety_publish_guards`

### Verified

- All migration files `001`-`020` now contain SQL (no template TODO stubs remain)
- RLS matrix rules are now encoded in migration files
- Migration progress updated in migration plan and sprint/resume docs

### Blockers

- Docker not available locally, so migrations cannot be executed/validated yet
- Role-policy test files are still scaffold-level and need concrete assertions

### Next

- run migrations on VPS Docker Supabase runtime
- fix runtime SQL/policy issues found during execution
- complete role-policy tests under `supabase/tests/rls/`
- then move to Telegram auth contract implementation

## 2026-04-23 22:05 - VPS Runtime Playbook Added

### Done

- Added `vault/wiki/services/vps-supabase-runtime.md` with Docker install and Supabase validation flow
- Updated service index and CODE_MAP to include VPS runbook
- Updated sprint/resume wording from local Docker to VPS Docker validation path

### Verified

- Playbook commands align with current CLI usage (`npx supabase ...`)
- Resume plan now points to VPS runbook for next execution step

### Next

- execute VPS runbook
- validate migrations and tests on running Supabase runtime
- patch SQL/policies based on runtime errors

## 2026-04-24 03:40 - VPS Runtime Provisioned + First Validation Run

### Done

- Connected to VPS alias `iind-vps` and audited baseline environment
- Confirmed `git` already installed and GitHub SSH access working
- Installed Docker Engine + Compose plugin on VPS
- Installed Node.js 22 + npm/npx on VPS
- Cloned repository to `/srv/tam-i-tut`
- Executed Supabase runtime validation commands from VPS:
  - `npx -y supabase start`
  - `npx -y supabase migration up --local`
  - `npx -y supabase db lint --local --fail-on error`
  - `npx -y supabase test db supabase/tests/rls --local`

### Verified

- `supabase migration up --local` reports local DB up to date
- `supabase db lint --local --fail-on error` reports no schema errors
- `supabase migration list --local` shows all migrations `001`-`020` applied
- Supabase stack can be started/stopped from VPS project path

### Blockers

- Initial `supabase start` attempt failed with `no space left on device` on 10GB VPS during image extraction
- Recovered by Docker image cleanup and rerun
- `supabase test db` currently fails with TAP parse errors because `supabase/tests/rls/*.sql` are still scaffold files with no test plan/assertions

### Next

- implement concrete pgTAP assertions in `supabase/tests/rls/001..009_*.sql`
- rerun `npx -y supabase test db supabase/tests/rls --local` on VPS until green
- after tests are green, proceed with Telegram auth contract implementation

## 2026-04-24 04:35 - RLS/Guard pgTAP Suite Implemented (`001`-`009`)

### Done

- Replaced all RLS test stubs with concrete pgTAP tests:
  - `001_profiles_access.sql`
  - `002_guide_entries_access.sql`
  - `003_evidence_access.sql`
  - `004_trusted_source_confirmations.sql`
  - `005_safety_cases_access.sql`
  - `006_user_suggestions_access.sql`
  - `007_audit_log_access.sql`
  - `008_trust_transition_guards.sql`
  - `009_safety_publish_guards.sql`
- Added role-scoped access checks and transition-guard failure/success assertions
- Adjusted tests based on runtime behavior (e.g., 0-row updates under RLS, trigger-first guard failures)
- Executed full DB test run on VPS runtime and stopped stack after validation

### Verified

- VPS command run:
  - `npx -y supabase test db supabase/tests/rls --local`
- Result:
  - `Files=9, Tests=80`
  - `Result: PASS`
- RLS/guard validation is now executable and not scaffold-only

### Next

- wire CI quality gates to execute DB tests automatically
- implement Telegram auth contract endpoint logic
- proceed to content seeding backlog execution

## 2026-04-24 05:05 - CI Quality Gates Workflow Added

### Done

- Added GitHub Actions workflow: `.github/workflows/ci.yml`
- Implemented `frontend-quality` job:
  - `npm --prefix frontend install`
  - `npm --prefix frontend run lint`
  - `npm --prefix frontend run typecheck`
  - `npm --prefix frontend run test`
- Implemented `database-quality` job:
  - `npx -y supabase start --exclude studio,imgproxy,kong,mailpit,edge-runtime,logflare,vector,supavisor`
  - `npx -y supabase migration up --local`
  - `npx -y supabase db lint --local --fail-on error`
  - `npx -y supabase test db supabase/tests/rls --local`
  - `npx -y supabase stop` (always)
- Updated docs to align with new CI baseline:
  - `vault/wiki/services/quality-gates-ci.md`
  - `vault/CODE_MAP.md`
  - sprint/resume/session ledger entries

### Verified

- CI commands mirror VPS-validated DB flow and passing pgTAP suite
- Workflow is scoped to `push`/`pull_request` on `main`

### Next

- observe first GitHub Actions run and adjust exclusions/timeouts if needed
- implement Telegram auth contract endpoint
- continue startup critical path after auth slice

## 2026-04-24 05:35 - Telegram Auth Contract Endpoint Added (Transitional Backend)

### Done

- Added API route: `POST /api/auth/telegram` in `backend/routes/api.php`
- Implemented Telegram auth contract logic in `backend/app/Http/Controllers/AuthController.php`:
  - Telegram signature validation (official WebApp hash flow)
  - payload freshness check (`auth_date` age window)
  - replay detection (cache-backed payload hash TTL)
  - typed error responses:
    - `TG_AUTH_INVALID_SIGNATURE`
    - `TG_AUTH_EXPIRED_PAYLOAD`
    - `TG_AUTH_REPLAY_DETECTED`
    - `TG_AUTH_MALFORMED_PAYLOAD`
    - `TG_AUTH_INTERNAL_ERROR`
  - default role assignment `user` and locale normalization (`ru` default, `en` optional)
  - transitional session-token caching placeholder for integration path
- Marked legacy `POST /api/auth/login` placeholder as deprecated (410)
- Added contract-oriented tests: `backend/tests/Feature/TelegramAuthApiTest.php`
- Updated backend docs/reference map:
  - `backend/README.md`
  - `vault/CODE_MAP.md`

### Verified

- PHP syntax lint run on VPS for modified backend files (`php -l`) passed
- Implementation aligns with `vault/wiki/architecture/telegram-auth-contract.md` rules and error code set

### Blockers

- Backend folder remains transitional/minimal; full Laravel runtime execution for feature tests is not yet active
- Profile upsert/session persistence still needs final Supabase service-layer integration

### Next

- wire Telegram auth endpoint to final Supabase profile upsert + session persistence
- run full endpoint tests in runtime environment
- continue with content seeding and first verified API slice

## 2026-04-24 06:05 - Telegram Auth Supabase Persistence Wired (Transitional)

### Done

- Extended `backend/app/Http/Controllers/AuthController.php` Telegram flow to integrate Supabase:
  - resolved Supabase credentials from env/config
  - profile lookup by `telegram_user_id` via Supabase REST
  - new-user bootstrap via Supabase Auth Admin API
  - profile insert/update in `public.profiles` with role forced to `user`
- Replaced cache-only auth token output with signed internal session token (transitional stateless token)
- Updated Telegram auth feature tests (`backend/tests/Feature/TelegramAuthApiTest.php`) to fake Supabase HTTP responses for success/replay/failure scenarios
- Updated `.env.example` with Supabase server-side credentials required by transitional endpoint
- Updated backend and vault code-map docs to reflect new auth behavior

### Verified

- PHP syntax lint on VPS passed for:
  - `backend/app/Http/Controllers/AuthController.php`
  - `backend/routes/api.php`
  - `backend/tests/Feature/TelegramAuthApiTest.php`
- Telegram auth contract behavior remains aligned to typed error-code spec

### Blockers

- Minimal backend skeleton still lacks full Laravel runtime/test harness execution in current repo shape
- Production-grade session strategy is still open (current signed token is transitional)

### Next

- run Telegram auth feature tests in full runtime environment
- decide and implement final production session strategy
- proceed with first API slice and content seeding execution

## 2026-04-24 06:30 - Telegram Session Strategy Hardened (Transitional)

### Done

- Updated Telegram auth session issuance in `AuthController`:
  - replaced signed JWT-like token output with opaque random bearer token
  - stores session server-side in cache using hashed token key
  - returns `session_id` + `expires_in` in auth payload
- Kept Supabase profile upsert integration and role-forcing behavior intact
- Expanded `TelegramAuthApiTest` with missing Supabase credentials failure case
- Updated docs/state to reflect current session strategy:
  - `backend/README.md`
  - `vault/wiki/architecture/telegram-auth-contract.md`
  - sprint/resume/ledger/code-map

### Verified

- PHP syntax lint passed on VPS for updated backend files
- Telegram auth error-code contract remains unchanged

### Blockers

- Full Laravel runtime execution for feature tests still not available in current minimal backend skeleton

### Next

- run Telegram auth feature tests in full runtime environment
- choose long-term production session architecture
- continue with first API slice and seeding execution

## 2026-07-31 - Product and System Master Plan Locked

### Done

- Reviewed current product vision, roadmap, schema/RLS contract, Telegram auth flow, content protocol, code map, and repository topology.
- Checked current official Telegram Mini Apps, Bot API, Stars, physical-payment, privacy, and developer-term constraints.
- Added `vault/wiki/architecture/tamitut-product-system-master-plan.md` covering:
  - product surfaces and newcomer journeys
  - Nuxt Mini App/public/admin architecture
  - Laravel modular-monolith backend and single-gateway boundary
  - Supabase PostgreSQL/PostGIS/Storage and Redis roles
  - multi-city normalized content/data model
  - auth, webhook, search, map, moderation, safety, observability, security, privacy, and operations
  - trust-safe monetization and payment/entitlement architecture
  - delivery phases with explicit exit gates
- Updated roadmap, system-design pointer, schema/auth status notes, sprint, resume plan, master index, and code map.

### Verified

- Target plan accounts for the current opaque Laravel token versus Supabase RLS mismatch and selects one Laravel BFF boundary.
- Sponsored inventory is separate, labeled, expiry-bound, audit-logged, and cannot alter trust or organic rank.
- Digital goods/services use Telegram Stars; physical services remain provider/legal-review dependent.
- Current Telegram origin hardening, raw `initData` validation, webhook secret, payment support, privacy, and data-retention requirements are represented.
- No application runtime behavior changed in this planning session.

### Next

- lock the exact production session contract
- design and approve city-aware schema v2 before bulk seeding
- complete the Laravel runtime and prove one protected end-to-end API slice

## 2026-07-31 - Lean TMA MVP Frontend

### Done

- Reduced first release scope to Telegram Bot -> Telegram Mini App -> Laravel.
- Explicitly deferred inline mode, separate Nuxt admin, public web, payments, sponsored placements, and multi-city expansion.
- Moved editorial/admin direction to Laravel server-rendered CRUD/moderation.
- Confirmed `@nuxt/ui` is declared and installed for Nuxt 4.
- Moved `logo.svg` and `logo-full.svg` into `frontend/app/assets/brand/`.
- Added Russian as default locale and added the first Russian/English TMA copy.
- Rebuilt the landing surface using Nuxt UI components and Tailwind utilities:
  - `UContainer`
  - `UCard`
  - `UButton`
  - `UInput`
  - `UBadge`
  - `UAlert`
- Added a Nuxt 4 root `tsconfig.json` extending `.nuxt/tsconfig.app.json`.
- Fixed the existing API composable import/method typing.
- Moved the stylesheet into Nuxt 4's `frontend/app/assets/css/` location.

### Verified

- `npm run typecheck` - PASS.
- `npm run lint` - PASS.
- `npm run test` - PASS (1 file, 1 test).
- `npm run build` - PASS.
- Browser smoke test at 390px viewport - rendered Russian TMA surface with logo, search field, category cards, collection CTA, trust alert, and no horizontal overflow.

### Next

- connect search/category actions to Laravel API;
- add real Telegram WebApp SDK bootstrap;
- build Laravel server-rendered editorial admin;
- seed first Da Nang newcomer journeys.

## 2026-07-31 - Header City and Theme Controls

### Done

- Removed repeated Da Nang and pilot labels from the main TMA content.
- Moved city context into a Nuxt UI `USelectMenu` in the header.
- Selected Da Nang by default.
- Added disabled future options with flags:
  - Nha Trang, Vietnam
  - Pattaya, Thailand
  - Phuket, Thailand
- Added Nuxt UI `UColorModeButton` as the single light/dark control.
- Removed hardcoded dark-only body/layout colors and added explicit Tailwind light/dark surfaces.
- Kept the main content city-agnostic while the header carries selected city context.

### Verified

- `npm run typecheck` - PASS.
- `npm run lint` - PASS.
- `npm run test` - PASS (1 test).
- `npm run build` - PASS.
- Browser at 390px:
  - no horizontal overflow;
  - Da Nang remains selected;
  - disabled cities cannot change selection;
  - light and dark modes both apply correct background/text colors;
  - no visible pilot label and Da Nang appears only in the header selector.

## 2026-07-31 - Vault Simplification

### Done

- Added `vault/architecture.md` as the single current product and system architecture.
- Removed redundant vision, roadmap, system-design, startup, and historical schema-planning documents from the active vault.
- Kept only focused auth, trust-state, and Telegram auth contracts under `vault/wiki/architecture/`.
- Updated the master index, code map, sprint, and resume plan.

### Decision

Vault now stores current decisions and operational context only. SQL migrations/tests remain the source of truth for implemented database behavior; historical planning details stay out of the active navigation.

- Compressed `SESSION_LEDGER.md` to a short handoff record; detailed history remains in this changelog.

## 2026-07-31 - SPA Loader and Calm Motion

### Done

- Added initial SPA loading screen (`frontend/app/spa-loading-template.html`): inline, monochrome brand mark, single orange progress bar, reduced-motion safe, dark-mode aware.
- Added `NuxtLoadingIndicator` in `frontend/app/app.vue` for client-side route loading after boot.
- Added subtle NuxtPage opacity transition in `app.vue`.
- Added short background/color transition for light/dark switching plus global `prefers-reduced-motion` kill switch in `frontend/app/assets/css/main.css`.
- Documented the motion rules in `vault/design.md`.

### Verified

- `npm run typecheck` - PASS.
- `npm run lint` - PASS.
- `npm run test` - PASS (1 test).
- `npm run build` - PASS; SPA template compiled into build.
- Browser dev server at 360px: loader visible on initial DOM load, then hidden once app hydrates; page no horizontal overflow; title still "Первые дни - без лишнего"; dark theme transition applied on root surfaces.

## 2026-07-31 - TMA Design System Document

### Done

- Added `vault/design.md` as the single visual source of truth: monochrome+zinc surfaces, sparse orange accent rules, copy voice, 360px layout floor, component usage rules, no-dead-affordances policy.
- Linked it from `master_index.md` and `CODE_MAP.md` so future sessions load it before UI work.

### Decision

One short design file, not a wiki tree; rules mirror what is already in code, so UI changes update both together.

## 2026-07-31 - Minimal Homepage and Locale Control

### Done

- Removed repeated "guide" wording and the unnecessary "Where do you start?" heading.
- Removed the non-functional homepage search field instead of leaving a dead affordance.
- Changed Nuxt UI primary color from cyan to orange and neutral color from gray to zinc.
- Reduced orange usage to subtle surfaces, primary actions, and trust cues; category icons are neutral.
- Added a compact RU/EN locale toggle beside city and theme controls.
- Kept the header responsive at 360px without horizontal overflow.
- Replaced long dash characters in active frontend copy with `-`.

### Search contract

- Future search submits query, city, locale, and optional category to Laravel.
- Results must be ranked verified entries with explicit zero-results state.
