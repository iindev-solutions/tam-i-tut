# CODE_MAP — TAMITUT Foundation

## Root

- `AGENTS.md` — vault-first project rules
- `README.md` — TAMITUT vision, MVP boundaries, success metric
- `.env.example` — local env placeholders
- `skills-lock.json` — reproducible project skill set lock
- `.github/workflows/ci.yml` — CI gates for frontend + Supabase DB policy tests

## Frontend (`frontend/`)

- `package.json` — Nuxt 4 toolchain, lint/test scripts
- `nuxt.config.ts` — runtime defaults (`appName`, `apiBase`)
- `app/components/AppHeader.vue` — global header shell
- `app/pages/index.vue` — curated-guide MVP direction landing page
- `i18n/locales/en.json` — primary copy strings
- `app/composables/useAPI.ts` — simple typed fetch helper
- `app/types/api.ts` — API response/error interfaces
- `tests/unit/smoke.test.ts` — baseline test runner check

## Backend (`backend/`)

- `README.md` — transitional backend note
- `composer.json` — legacy Laravel-oriented dependency baseline
- `routes/api.php` — health + Telegram auth route definitions
- `app/Http/Controllers/HealthController.php` — health response
- `app/Http/Controllers/AuthController.php` — Telegram initData auth validation + Supabase profile upsert + signed session token + typed error responses
- `tests/Feature/HealthApiTest.php` — health endpoint contract test
- `tests/Feature/TelegramAuthApiTest.php` — Telegram auth contract tests (signature/expiry/replay/malformed)

## Supabase (`supabase/`)

- `config.toml` — local Supabase runtime config
- `seed.sql` — local deterministic seed scaffold
- `migrations/*_001..020_*.sql` — ordered migration files implementing schema, RLS, and guard logic
- `tests/rls/*.sql` — pgTAP RLS/guard regression suite (80 tests) mapped to policy matrix

## Vault (`vault/`)

- `master_index.md` — knowledge base entry point
- `WORKFLOW.md` — mandatory session protocol
- `sprint.md` — active sprint goals/tasks
- `resume-plan.md` — stop point and next steps
- `logs/changelog.md` — chronological change log
- `SESSION_LEDGER.md` — session summaries

### Architecture Docs

- `wiki/architecture/project-vision.md` — full product vision
- `wiki/architecture/roadmap.md` — phased delivery roadmap
- `wiki/architecture/system-design.md` — domain model and enforcement boundaries
- `wiki/architecture/auth-flow.md` — role/session auth flow
- `wiki/architecture/startup-critical-path.md` — mandatory startup sequence
- `wiki/architecture/supabase-schema-rls-plan.md` — schema and RLS contract
- `wiki/architecture/supabase-migration-file-plan.md` — ordered migration file plan
- `wiki/architecture/supabase-rls-policy-matrix-v1.md` — role-by-table RLS matrix
- `wiki/architecture/trust-state-machine.md` — trust badge transition rules
- `wiki/architecture/telegram-auth-contract.md` — Telegram auth validation contract

### Service Docs

- `wiki/services/README.md` — service docs index
- `wiki/services/agent-skills-stack.md` — installed skill stack and restore/update flow
- `wiki/services/content-seeding-protocol.md` — launch seeding process
- `wiki/services/quality-gates-ci.md` — CI and quality gates baseline
- `wiki/services/vps-supabase-runtime.md` — VPS Docker runbook for migration/test validation
- `wiki/services/service-template.md` — template for new service docs
