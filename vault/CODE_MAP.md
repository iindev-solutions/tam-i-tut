# CODE_MAP - TAMITUT Foundation

## Root

- `AGENTS.md` - vault-first project rules
- `README.md` - TAMITUT vision, MVP boundaries, success metric
- `.env.example` - local env placeholders
- `skills-lock.json` - reproducible project skill set lock
- `.github/workflows/ci.yml` - CI gates for frontend + Supabase DB policy tests

## Frontend (`frontend/`)

- `package.json` - Nuxt 4 toolchain, lint/test scripts
- `nuxt.config.ts` - public runtime defaults (`appName`, Supabase URL, anon/publishable key)
- `vitest.config.ts` - test runner; aliases `#telegram-validate` to the shared Supabase edge `validate.ts`
- `app/components/AppHeader.vue` - global header shell: logo, city select, locale, theme
- `app/components/AppCitySelect.vue` - shared city selector (header compact variant)
- `app/components/HousingTileMap.client.vue` - Leaflet tile map (CARTO light/dark) with district polygons and labels
- `app/components/AdminTable.vue` - generic typed admin table with cell slots
- `app/components/StatusBadge.vue` - status-to-tone badge with i18n labels
- `app/layouts/default.vue` - user-facing layout with the under-header back row on subpages
- `app/layouts/admin.vue` - admin prototype layout (sticky nav, prototype badge)
- `app/pages/index.vue` - landing; six category cards, city line with inline city select
- `app/pages/categories/housing.vue` - housing with Guide/Map tabs; guide cards, 12 real search-channel links, district price list opens the map tab
- `app/pages/categories/food.vue` - mock places with wrapped filter chips and a UCarousel (arrows + dots)
- `app/pages/categories/transport.vue` / `money.vue` / `safety.vue` / `culture.vue` - mock-driven guide pages
- `app/pages/journey/first-day.vue` - interactive first-day checklist with progress counter
- `app/pages/admin/*` - mock admin prototype: dashboard, cities, categories, districts, places, guides, reviews
- `app/composables/useMockDb.ts` - reactive mock DB store seeded from `mocks/db.ts` with admin mutations (admin prototype only)
- `app/composables/useDb.ts` - RLS-safe Supabase reads for user routes (schema v2: cities/categories/places/reviews) with mock fallback when unconfigured
- `app/composables/db-mappers.ts` - pure DB-row -> UI-shape mappers + static CITY_UI/CATEGORY_UI chrome (unit-tested)
- `app/composables/useSupabaseClient.ts` - shared Supabase client factory from runtimeConfig
- `app/composables/useAuth.ts` - read-side TMA session state (session is established by the telegram plugin)
- `app/composables/useLocalized.ts` - renders bilingual mock fields by locale
- `app/plugins/telegram.client.ts` - Telegram Mini App bridge: native BackButton synced with routing + single-consumer initData bootstrap that exchanges a Supabase session via `setSession`
- `app/plugins/spa-loader.client.ts` - finishes SPA loader after app mount/suspense
- `app/mocks/housing.ts` + `app/types/housing.ts` - production-shaped illustrative housing content contract
- `app/mocks/db.ts` + `app/types/content.ts` - bilingual mock DB: cities, categories, places, guides, contacts, reviews, activity
- `i18n/locales/en.json` / `ru.json` - full UI copy for app and admin (parity enforced by tests)
- `app/spa-loading-template.html` - pre-hydration curtain loader (arrow open + wordmark + panel reveal)
- `scripts/audit-i18n.mjs` - CLI locale parity + unused-key audit
- `tests/unit/content.test.ts` - locale parity and mock-data integrity tests (ids, references, GeoJSON rings)
- `tests/unit/db-mappers.test.ts` - DB-row -> UI-shape mapper tests (cities/categories/places/reviews)
- `tests/unit/telegram-initdata.test.ts` - Telegram initData HMAC/freshness validation tests (shares `validate.ts` with the edge function)
- `tests/unit/smoke.test.ts` - baseline test runner check
- Wiki: `vault/wiki/services/housing-map.md` - how to change districts, geometry, tiles, and map behavior

## Supabase (`supabase/`)

- `config.toml` - local Supabase runtime config (incl. `[functions.telegram-bootstrap]` with `verify_jwt = false`)
- `seed.sql` - local deterministic seed scaffold
- `migrations/*_001..023_*.sql` - ordered schema, RLS, guard, replay, and city-aware v2 migrations (cities/places/reviews)
- `tests/rls/*.sql` - pgTAP RLS/guard regression suite (incl. `010_places_and_reviews_rls.sql`)
- `functions/telegram-bootstrap/` - implemented Edge Function: `index.ts` (session exchange, nonce replay, profile upsert) + `validate.ts` (pure initData HMAC/freshness, shared with frontend tests)

## Vault (`vault/`)

- `master_index.md` - knowledge base entry point
- `WORKFLOW.md` - mandatory session protocol
- `sprint.md` - active sprint goals/tasks
- `resume-plan.md` - stop point and next steps
- `logs/changelog.md` - chronological change log
- `SESSION_LEDGER.md` - session summaries

### Architecture & Design

- `architecture.md` - current product and system architecture
- `design.md` - TMA visual system rules and mobile verification checklist
- `wiki/architecture/auth-flow.md` - role/session auth flow
- `wiki/architecture/trust-state-machine.md` - trust badge transition rules
- `wiki/architecture/telegram-auth-contract.md` - Telegram auth validation contract
- `wiki/architecture/schema-v2-city-aware.md` - city-aware v2 cutover design (cities/places/reviews/RLS)

### Service Docs

- `wiki/services/README.md` - service docs index
- `wiki/services/agent-skills-stack.md` - installed skill stack and restore/update flow
- `wiki/services/content-seeding-protocol.md` - launch seeding process
- `wiki/services/quality-gates-ci.md` - CI and quality gates baseline
- `wiki/services/vps-supabase-runtime.md` - VPS Docker runbook for migration/test validation
- `wiki/services/service-template.md` - template for new service docs
