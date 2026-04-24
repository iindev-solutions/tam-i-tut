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
