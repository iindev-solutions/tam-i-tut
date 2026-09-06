# Sprint - TAMITUT Supabase-Only Pilot

## Goal

Ship lean Da Nang pilot with one Telegram Bot, one Telegram Mini App, Supabase Edge Functions/Auth/Postgres/Storage, and Supabase Studio for private pilot operations. No Laravel, VPS backend, separate admin frontend, inline mode, public web, payments, or multi-city work in first release.

Nuxt UI + Tailwind remain the frontend UI standard.

## Current Direction

Menu translator Phase A+B shipped and live (dictionary, scan, curation queue, storage purge). Review submission and pilot metrics (`app_events`) live. CI red items resolved in code (stale pgTAP 010 assertion after 039, stale health category test); the only expected-red job is Deploy (`CLOUDFLARE_API_TOKEN` founder secret). Next phase: closed pilot with metrics.

## Plan Phases

| Phase | Scope | Status |
|---|---|---|
| 0 | Foundations: PostGIS, districts migration, admin write RLS, founder admin identity, pg_cron nonce purge, district seed | DONE |
| 1 | Content admin: auth gate, useAdminDb, places/reviews/cities/guides CRUD, audit, UI polish | DONE (guide authoring form = follow-up) |
| 2 | Map admin: Leaflet.draw polygon editor, housing page cutover to DB | DONE |
| 3 | Prod hardening: keep-awake worker, automated backups, CI on GitHub + auto-deploy, cleanup, privacy, rate limits | CODE DONE + CI GREEN; auto-deploy/backup secrets pending founder |
| 4 | Content & launch: pilot seed, freshness SLA, closed pilot | IN PROGRESS (content shipped: 23 venues, guides across 8 categories; closed pilot + metrics decision next) |

## Current Tasks

| # | Task | Status |
|---|---|---|
| 5.1 | Lock Supabase-only runtime boundary | DONE |
| 5.2 | Remove Laravel transitional backend from active repository path | DONE |
| 5.3 | Align Nuxt public runtime config with Supabase | DONE |
| 5.4 | Implement Telegram bootstrap Edge Function | DONE (code + 11 validation tests + deployed live, --no-verify-jwt) |
| 5.5 | Validate Supabase Auth session exchange for Telegram identity | PARTIAL - RLS + live reads verified; live session test awaits founder Telegram test |
| 5.6 | Connect Nuxt client with RLS-safe Supabase queries | DONE (useDb + mappers + fallback; live-verified against hosted project) |
| 5.7 | Validate Supabase Studio editorial workflow | BLOCKED - superseded by the admin plan (Phase 1) |
| 5.8 | Approve city-aware schema v2 before content seeding | DONE (migrations 022/023 + RLS verified live) |
| 5.9 | Seed first Da Nang newcomer journeys | DONE (23 places, 23 photos, guides across 8 categories incl. health) |
| 5.10 | Add off-site database and Storage backup runbook | DONE (vault/wiki/services/supabase-backup-runbook.md) |

## Current Priority

1. founder: set `CLOUDFLARE_API_TOKEN` repo secret (auto-deploy) and `SUPABASE_DB_URL` + R2 secrets (backups); rotate the Telegram bot token that was shared in chat
2. founder: live Telegram test of the full session exchange (5.5)
3. Menu translator LIVE incl. Phase B curation queue (`/admin/menu`); dish photos for unmatched lines should be sourced by queue frequency, not in advance
4. Phase 4: closed pilot with metrics next - founder does the live Telegram walk-through (session, review, scan) first
5. Optional follow-ups: R2 restore drill

## Notes
- 2026-09-06: Phase B + review submission + metrics shipped (migration 049). pgTAP suites now run on hosted via `db query --linked --file` when Docker is unavailable. CI red-on-main since 08-29 explained: stale 010 cities assertion (039) + stale health category test - both fixed.
- 2026-08-22: Phase 3 hardening completed (rate limiting live + locked down, migration 032 grants, CI fully green for the first time, deploy root cause fixed at the source). Details: vault/logs/changelog.md.

- 2026-08-16: full mock prototype shipped (six categories, first-day journey, `/admin` demo with live publish/moderate loop), upgraded to real-world Da Nang data (six real districts with VND rents, ten real venues), then given a real Leaflet/CARTO map in a Guide/Map tab split, food carousels, hero city select, and Telegram-native back navigation. It defines the UI/content contract for the Supabase cutover but replaces no backend work.
