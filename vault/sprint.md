# Sprint - TAMITUT Supabase-Only Pilot

## Goal

Ship lean Da Nang pilot with one Telegram Bot, one Telegram Mini App, Supabase Edge Functions/Auth/Postgres/Storage, and Supabase Studio for private pilot operations. No Laravel, VPS backend, separate admin frontend, inline mode, public web, payments, or multi-city work in first release.

Nuxt UI + Tailwind remain the frontend UI standard.

## Current Direction

Real editorial admin (founder decision) + production hardening. Full plan: `vault/wiki/architecture/admin-panel-and-prod-plan.md` (DRAFT, awaiting approval).

## Plan Phases

| Phase | Scope | Status |
|---|---|---|
| 0 | Foundations: PostGIS, districts migration, admin write RLS, founder admin identity, pg_cron nonce purge, district seed | DONE |
| 1 | Content admin: auth gate, useAdminDb, places/reviews/cities/guides CRUD, audit, UI polish | DONE (guide authoring form = follow-up) |
| 2 | Map admin: Leaflet.draw polygon editor, housing page cutover to DB | DONE |
| 3 | Prod hardening: keep-awake worker, automated backups, CI on GitHub + auto-deploy, cleanup, privacy, rate limits | TODO |
| 4 | Content & launch: ~80-entry pilot seed, freshness SLA, closed pilot | TODO |

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
| 5.9 | Seed first Da Nang newcomer journeys | PARTIAL (food slice live: 4 cities, 10 places, 20 localizations) |
| 5.10 | Add off-site database and Storage backup runbook | DONE (vault/wiki/services/supabase-backup-runbook.md) |

## Current Priority

1. founder approves the admin + prod plan (3 decisions: admin identity, geometry storage, repo visibility)
2. Phase 0 foundations -> Phase 1 content admin -> Phase 2 map admin
3. Phase 3 hardening (keep-awake, backups, CI) in parallel where possible
4. Phase 4 pilot seed + closed pilot

## Notes

- 2026-08-16: full mock prototype shipped (six categories, first-day journey, `/admin` demo with live publish/moderate loop), upgraded to real-world Da Nang data (six real districts with VND rents, ten real venues), then given a real Leaflet/CARTO map in a Guide/Map tab split, food carousels, hero city select, and Telegram-native back navigation. It defines the UI/content contract for the Supabase cutover but replaces no backend work.
