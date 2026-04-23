# Changelog

## 2026-04-23 11:20 — Starter Template Initialized

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

## 2026-04-23 17:45 — TamITut Direction Bootstrap

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

## 2026-04-23 18:20 — Vision Reframed to Curated Bot Guide

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

## 2026-04-23 19:05 — Vision Expanded with Full Audit

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

## 2026-04-23 19:35 — Skill Stack + Startup Critical Path Locked

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
