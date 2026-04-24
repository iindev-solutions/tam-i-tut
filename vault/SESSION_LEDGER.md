# Session Ledger

## 2026-04-23 11:20 — Starter Template Created

- Scope: create a minimal empty template with frontend, backend, and vault-first workflow
- Changes: added starter files under `empty-template/`
- Verified: starter structure reviewed after creation
- Blockers: backend template is intentionally minimal and not a full Laravel runtime
- Next: adapt the template for a new real project and update vault first

## 2026-04-23 17:45 — TamITut Scope Anchored

- Scope: study current repo, read `test-text.md`, and anchor project direction as TamITut
- Changes: updated root/frontend/backend naming docs and filled architecture docs in `vault/wiki/architecture/`
- Verified: sprint/resume/changelog updated; repository copy now reflects TamITut trust-first MVP intent
- Blockers: Supabase schema and auth implementation not started yet
- Next: design data model + RLS, then implement first listing flow

## 2026-04-23 18:20 — TAMITUT Vision Rewrite

- Scope: delete obsolete brief file and replace project vision with curated bot-guide direction
- Changes: removed `test-text.md`; updated README, frontend copy, and architecture docs for new TAMITUT framing
- Verified: sprint/resume/changelog/CODE_MAP aligned to "not marketplace" boundary
- Blockers: detailed category schema and verification data model still pending
- Next: design six-category content model + trust evidence workflow

## 2026-04-23 19:05 — Full Audit Vision Merge

- Scope: merge external full vision document into repo and select trust model option 2
- Changes: expanded README + architecture docs with audience priorities, UX rules, trust badges, KPIs, and risk controls
- Verified: docs consistently use 3-level trust model and preserve curated non-marketplace boundary
- Blockers: schema design and moderation workflow still conceptual, not implemented
- Next: translate trust/evidence rules into DB schema and moderation logic

## 2026-04-23 19:35 — Skills and Startup Baseline Added

- Scope: install recommended skills and lock startup-critical planning docs before implementation
- Changes: installed project skill stack, generated `skills-lock.json`, and added schema/RLS, trust-state, Telegram auth, seeding, CI, and skills-stack docs
- Verified: `npx skills ls --json` includes all target skills; sprint/resume/codemap/changelog aligned
- Blockers: no SQL migrations or policy tests implemented yet
- Next: start Phase 1 implementation with first Supabase migration and RLS matrix

## 2026-04-23 19:55 — Schema Contract Finalized

- Scope: execute plan step 1 by locking concrete schema contract in vault
- Changes: rewrote `supabase-schema-rls-plan.md` with full enum/table/constraint/index contract and RLS anchor fields
- Verified: schema contract has no TBDs and directly maps trust requirements to DB structures
- Blockers: SQL migrations and RLS test harness still not created
- Next: convert locked schema into SQL migrations, then implement RLS and trust transition guards

## 2026-04-23 20:15 — Migration and RLS Planning Step

- Scope: execute next plan step by defining exact migration order and policy matrix before SQL writing
- Changes: added migration file plan and RLS matrix docs; updated roadmap/startup/system-design/readme links
- Verified: planned migration sequence covers schema contract and policy matrix covers all roles/tables
- Blockers: Supabase CLI not installed globally; use `npx supabase`
- Next: scaffold `supabase/` project and create migration files in planned order

## 2026-04-23 20:35 — Migration Scaffold Execution

- Scope: execute scaffold phase for Supabase migrations and RLS test files
- Changes: initialized `supabase/`, generated migration stubs `001..020`, added template headers, created `supabase/tests/rls` stubs and `seed.sql`
- Verified: all planned migration/test files exist and match migration plan ordering
- Blockers: local Supabase containers not started yet, so migration list/test execution not validated against running DB
- Next: implement SQL in ordered migrations, then run local DB validation

## 2026-04-23 21:10 — Base Schema SQL Pass

- Scope: execute migration implementation phase for base schema (`001`–`013`)
- Changes: filled concrete SQL for enums, tables, constraints, triggers, and index set per schema contract
- Verified: migration files `001`–`013` no longer have TODO template lines; `014`–`020` kept for RLS/guards next
- Blockers: Docker unavailable, cannot run local Supabase containers for full migration execution tests
- Next: implement `014`–`020`, then validate on running local Supabase stack

## 2026-04-23 21:45 — RLS and Guard Migration Pass

- Scope: implement remaining migration SQL (`014`–`020`) after base schema completion
- Changes: added helper functions, enabled RLS, added policies for user/curator/trusted_source/mod/admin, and added trust/safety guard triggers with audit logging
- Verified: all migration files now contain SQL; no template TODO lines remain
- Blockers: no Docker on local machine; runtime validation must run on VPS Docker environment
- Next: execute migrations on VPS Supabase stack, then finish role-policy test assertions

## 2026-04-23 22:05 — VPS Validation Path Captured

- Scope: adapt validation plan to environment without local Docker
- Changes: added VPS Docker/Supabase runbook and linked it from docs/plans
- Verified: plan now consistently targets `npx supabase` + VPS Docker runtime
- Blockers: VPS execution not run yet
- Next: run playbook on VPS and fix migration/policy runtime issues

## 2026-04-24 03:40 — VPS Runtime Provisioned and First Validation Run

- Scope: execute VPS setup + first real migration/lint/test run from `iind-vps`
- Changes:
  - installed Docker Engine and Compose plugin on VPS
  - installed Node.js 22 + npm/npx on VPS
  - cloned repo to `/srv/tam-i-tut`
  - ran Supabase validation commands on VPS
- Verified:
  - `npx supabase migration up --local` → up to date
  - `npx supabase db lint --local --fail-on error` → no schema errors
  - `npx supabase migration list --local` shows `001`–`020` applied
- Blockers:
  - first `supabase start` attempt hit disk pressure (`no space left on device`)
  - resolved by Docker image cleanup and rerun
  - `supabase test db` currently fails because test files are still scaffold-level (no TAP plans/assertions)
- Next: implement pgTAP assertions in `supabase/tests/rls/001..009_*.sql`, then rerun VPS test command until green

## 2026-04-24 04:35 — RLS/Guard pgTAP Suite Implemented and Passing

- Scope: replace RLS test stubs with concrete assertions and validate on VPS runtime
- Changes:
  - implemented `supabase/tests/rls/001..009_*.sql` with role-policy and guard checks
  - added explicit checks for profile, guide entry, evidence, source confirmation, safety case, suggestion, and audit-log policy behavior
  - added trust/safety transition guard tests for migration `019` and `020`
- Verified:
  - ran `npx -y supabase test db supabase/tests/rls --local` on VPS (`/srv/tam-i-tut`)
  - result: PASS (`Files=9, Tests=80`)
  - all previously scaffold-only tests now provide TAP plans and assertions
- Blockers: none in DB policy test layer; next work is CI integration and Telegram auth contract
- Next: wire CI to run DB tests and implement Telegram auth contract

## 2026-04-24 05:05 — CI Quality Gates Wired

- Scope: implement automated CI jobs for frontend and Supabase DB policy verification
- Changes:
  - added `.github/workflows/ci.yml`
  - frontend job runs lint, typecheck, and unit tests under Node 22
  - database job runs Supabase start, migration up, db lint, and pgTAP RLS suite
  - updated quality-gates and vault planning docs to reflect CI baseline
- Verified: workflow file committed locally with explicit gate commands aligned to VPS-validated flow
- Blockers: GitHub Actions runtime execution pending first remote run result
- Next: monitor first CI run, tune job exclusions if needed, then implement Telegram auth contract

## 2026-04-24 05:35 — Telegram Auth Contract Endpoint (Transitional) Implemented

- Scope: implement Telegram initData auth contract in backend transitional layer
- Changes:
  - added `POST /api/auth/telegram` route
  - implemented signature verification, payload age window, replay guard, typed error responses, and session token issuance in `AuthController`
  - marked `/api/auth/login` placeholder as deprecated (410 response)
  - added contract-focused feature tests: `backend/tests/Feature/TelegramAuthApiTest.php`
  - updated backend README and CODE_MAP references
- Verified:
  - PHP syntax check on VPS (`php -l`) for modified backend files passed
  - contract logic matches error-code set from `telegram-auth-contract.md`
- Blockers:
  - backend folder is still transitional/minimal; full Laravel runtime test execution is not wired in current environment
  - profile upsert/session persistence is still placeholder and must be connected to final Supabase service layer
- Next: connect Telegram auth flow to final Supabase-backed persistence and execute full endpoint tests in runtime

## 2026-04-24 06:05 — Telegram Auth Supabase Persistence Wiring

- Scope: replace placeholder Telegram auth persistence path with real Supabase profile integration
- Changes:
  - wired `POST /api/auth/telegram` to Supabase REST/Auth Admin APIs via service-role key
  - implemented profile lookup/upsert by `telegram_user_id`
  - implemented auth-user bootstrap fallback flow for new Telegram users
  - replaced cache-only session token with signed internal token issuance (transitional)
  - updated Telegram auth tests to fake Supabase HTTP flows and validate contract behavior
  - updated env/example and backend docs
- Verified:
  - PHP syntax lint (`php -l`) passed on VPS for controller/routes/tests
  - contract tests updated for Supabase-integrated success/replay/signature/expiry/malformed paths
- Blockers:
  - full Laravel runtime execution for feature tests is still not wired in this minimal backend skeleton
  - final production session strategy remains pending (current token is transitional)
- Next: enable runtime test execution and choose final production session strategy
