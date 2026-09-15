# Sprint - TAMITUT Supabase-Only Pilot

## Goal

Ship lean Da Nang pilot with one Telegram Bot, one Telegram Mini App, Supabase Edge Functions/Auth/Postgres/Storage, and Supabase Studio for private pilot operations. No Laravel, VPS backend, separate admin frontend, inline mode, public web, payments, or multi-city work in first release.

Nuxt UI + Tailwind remain the frontend UI standard.

## Current Direction

Menu translator Phase A+B shipped and live (dictionary, scan, curation queue, storage purge). Review submission and pilot metrics (`app_events`) live. Trust layer now reaches the user: three documented levels + check date on every guide/place surface, city-scoped emergency contacts on the safety page, and honest load-failure handling. All 48 published guides are `under_review`, so the UI now states that instead of implying verification. Next phase: closed pilot with metrics.

## Plan Phases

| Phase | Scope | Status |
|---|---|---|
| 0 | Foundations: PostGIS, districts migration, admin write RLS, founder admin identity, pg_cron nonce purge, district seed | DONE |
| 1 | Content admin: auth gate, useAdminDb, places/reviews/cities/guides CRUD, audit, UI polish | DONE (guide authoring form = follow-up) |
| 2 | Map admin: Leaflet.draw polygon editor, housing page cutover to DB | DONE |
| 3 | Prod hardening: keep-awake worker, automated backups, CI on GitHub + auto-deploy, cleanup, privacy, rate limits | CODE DONE + CI GREEN; auto-deploy/backup secrets pending founder |
| 4 | Content & launch: pilot seed, freshness SLA, closed pilot | IN PROGRESS (content: 29 places, guides across 8 categories; trust levels now surface in the UI; closed pilot + metrics decision next) |

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
| 5.11 | Make the documented trust model visible in the Mini App | DONE (migration 058/059 + TrustBadge; evidence: pgTAP 016, reader-contract probe, browser RU/EN) |

## Current Priority

1. founder: live Telegram walk-through - session exchange (5.5), then confirm the trust badges render ("На проверке" on guides, badge + date on a place) and the safety numbers show
2. founder: set `CLOUDFLARE_API_TOKEN` + `SUPABASE_ACCESS_TOKEN` repo secrets (auto-deploy), `SUPABASE_DB_URL` + R2 secrets (backups); rotate the Telegram bot token that was shared in chat
3. Verification model: promote entries out of `under_review` as they are checked (admin places editor sets level + date; guides need the authoring form)
4. Phase 4: closed pilot with metrics next - decide the metric set from `app_events` after the first pilot week
5. Optional follow-ups: guide authoring form with per-guide verification, city search, R2 restore drill

## Notes
- 2026-09-15: trust layer live (migrations 058/059) - `places.trust_badge` + `last_verified_at` replace the boolean, `emergency_contacts` is city-scoped, `TrustBadge.vue` renders level + date, and a failed read with a live session shows a retry instead of the bot gate. Details: vault/logs/changelog.md.
- 2026-09-06: Phase B + review submission + metrics shipped (migration 049). pgTAP suites now run on hosted via `db query --linked --file` when Docker is unavailable. CI red-on-main since 08-29 explained: stale 010 cities assertion (039) + stale health category test - both fixed.
- 2026-08-22: Phase 3 hardening completed (rate limiting live + locked down, migration 032 grants, CI fully green for the first time, deploy root cause fixed at the source). Details: vault/logs/changelog.md.

- 2026-08-16: full mock prototype shipped (six categories, first-day journey, `/admin` demo with live publish/moderate loop), upgraded to real-world Da Nang data (six real districts with VND rents, ten real venues), then given a real Leaflet/CARTO map in a Guide/Map tab split, food carousels, hero city select, and Telegram-native back navigation. It defines the UI/content contract for the Supabase cutover but replaces no backend work.
