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
- `app/components/AppHeader.vue` - global header shell
- `app/pages/index.vue` - curated-guide MVP direction landing page
- `i18n/locales/en.json` - primary copy strings
- `app/spa-loading-template.html` - pre-hydration logo loader
- `tests/unit/smoke.test.ts` - baseline test runner check

## Supabase (`supabase/`)

- `config.toml` - local Supabase runtime config
- `seed.sql` - local deterministic seed scaffold
- `migrations/*_001..020_*.sql` - ordered schema, RLS, and guard migrations
- `tests/rls/*.sql` - pgTAP RLS/guard regression suite
- `functions/` - planned Telegram bootstrap and privileged workflow Edge Functions

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

### Service Docs

- `wiki/services/README.md` - service docs index
- `wiki/services/agent-skills-stack.md` - installed skill stack and restore/update flow
- `wiki/services/content-seeding-protocol.md` - launch seeding process
- `wiki/services/quality-gates-ci.md` - CI and quality gates baseline
- `wiki/services/vps-supabase-runtime.md` - VPS Docker runbook for migration/test validation
- `wiki/services/service-template.md` - template for new service docs
