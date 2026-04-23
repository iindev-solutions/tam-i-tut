# CODE_MAP — TamITut Foundation

## Root

- `AGENTS.md` — vault-first project rules
- `README.md` — TamITut overview and MVP scope
- `test-text.md` — mini product brief source
- `.env.example` — local env placeholders aligned to TamITut

## Frontend (`frontend/`)

- `package.json` — Nuxt 4 toolchain, lint/test scripts
- `nuxt.config.ts` — runtime config defaults (`appName`, `apiBase`)
- `app/components/AppHeader.vue` — global header shell
- `app/pages/index.vue` — MVP direction landing page
- `i18n/locales/en.json` — primary copy strings
- `app/composables/useAPI.ts` — simple typed fetch helper
- `app/types/api.ts` — API response/error interfaces
- `tests/unit/smoke.test.ts` — baseline test runner check

## Backend (`backend/`)

- `README.md` — transitional backend note (Supabase target)
- `composer.json` — legacy Laravel-oriented dependency baseline
- `routes/api.php` — health/login route templates
- `app/Http/Controllers/HealthController.php` — sample health response
- `app/Http/Controllers/AuthController.php` — placeholder login action
- `tests/Feature/HealthApiTest.php` — sample feature test

## Vault (`vault/`)

- `master_index.md` — knowledge base entry point
- `WORKFLOW.md` — mandatory session protocol
- `sprint.md` — active sprint goals/tasks
- `resume-plan.md` — stop point and next steps
- `logs/changelog.md` — chronological change log
- `SESSION_LEDGER.md` — session summaries
- `wiki/architecture/` — vision, roadmap, system design, auth flow
- `wiki/services/` — service documentation templates
