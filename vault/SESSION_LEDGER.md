# Session Ledger

Short record of durable project decisions and handoffs. Detailed history lives in `vault/logs/changelog.md`.

## 2026-08-22 - Phase 3 Hardening Complete + CI Green

- Resumed the uncommitted rate-limiting WIP; finished it: migration 031 locked `check_rate_limit` to service_role, edge function returns 429 + Retry-After (two-layer: in-isolate + Postgres RPC), live burst verified (10 req then 429, window resets).
- Migration 032: explicit anon/authenticated/service_role grants for fresh-stack parity (hosted init scripts do this implicitly); RLS still gates everything.
- CI green for the first time ever: fixed health timeout, workdir/network mismatch, non-gating db lint, and repaired stale pgTAP suites (slug NOT NULL from 029, seeded-row counts, policy 028 audit inserts).
- Deploy root cause: Nitro `deployConfig: true` hijacked wrangler into a missing server bundle; set `deployConfig: false`. Local OAuth deploys verified.
- Founder blockers: repo secrets `CLOUDFLARE_API_TOKEN` (deploy), `SUPABASE_DB_URL` + R2 (backups); rotate shared bot token; Telegram live session test.

## 2026-08-18 - Live Verification on Hosted Supabase Free

- Path B chosen (free hosted project `tepsurbgsrivvcvizxph`, restored from pause).
- Fixed migration 023 timestamp collision (shared `20260818000000` with 022) -> renamed to `20260818120000`; all 23 migrations applied; seed live (4 cities, 10 places, 20 locs).
- RLS proven live: authenticated sees active/published only, anon sees nothing.
- `telegram-bootstrap` deployed (`--no-verify-jwt`); guards probed OK; session exchange pending `TELEGRAM_BOT_TOKEN`.
- Browser live-read verified: no session -> mock fallback; session -> real DB categories/places, EN from DB localizations. City selector shows only active cities (RLS posture, accepted).
- `nuxt generate` + `frontend/public/_headers` ready for Cloudflare Pages free hosting.

## 2026-08-18 - Nuxt RLS-Safe Read Layer (food slice)

- `useDb()` + pure `db-mappers` (11 new tests) + `useSupabaseClient` + `useAuth`; telegram plugin completes the session exchange (`setSession`) as the single consumer of the one-shot initData nonce.
- Home, food, city selector read through the RLS path with mock fallback (same mock store reference, so the admin->user demo link is preserved); admin/housing/culture/journey stay on mocks per the accepted slice.
- Food-slice seed confirmed (cities + 10 places in seed.sql); off-site backup runbook written.
- Gates: test 32/32, lint, typecheck, build PASS; browser-verified fallback path.
- Blocked locally (no Docker): RLS pgTAP suite, telegram-bootstrap session exchange, Studio editorial workflow, live Supabase read path.

## 2026-08-18 - Supabase Cutover: Edge Function + Schema v2 + Nuxt RLS Layer Start

- `telegram-bootstrap` Edge Function implemented (initData HMAC via shared pure `validate.ts`, 24h freshness + 5m future skew, replay nonce table, magic-link session exchange, idempotent profile upsert); 11-case vitest suite shares the same file via the `#telegram-validate` alias.
- Schema v2 migrations landed: cities + food enums (022), places/reviews/localizations with published/approved RLS (023), nonce table (021); 8-assert pgTAP suite for places/reviews RLS.
- Fixed: nonce insert omitted `telegram_user_id` (NOT NULL) - would 503 every request; registered function in `config.toml` with `verify_jwt = false`.
- Frontend gates: test 21/21, lint, typecheck, build PASS. Runtime DB validation not possible locally (no Docker) - CI-gated.
- Next: RLS-safe Nuxt read layer with mock fallback (useSupabaseClient/useAuth/useContentDb), page rewiring, Docker-host validation, Studio check, seeding, backup runbook.

## 2026-08-17 - Real Rental Sources

- Housing content rebuilt on a resident-compiled rental guide: real contract/deposit/registration facts, inspection checklist, and 12 checked search channels (Telegram/Facebook/Cho Tot/Zalo/agencies) as a links block.
- Resource list lives in `mocks/housing.ts` (`HousingResource[]`); integrity covered by content tests (10).

## 2026-08-17 - Full Audit Pass

- Ran the vue-best-practices skill audit across the frontend; fixed a real GeoJSON ring-closure bug (4/6 districts), locale-frozen map labels, dead i18n keys, and template-level derivations; patched prod dependency vulnerabilities.
- Added audit-as-code: content integrity tests (8) and the i18n parity CLI script.
- Accepted and documented: X-Powered-By fingerprint (Nuxt 4.5), mutable mock store (prototype scope).

## 2026-08-17 - UX Pass: Back Row, Hero Text, Bottom Sheets

- Back button moved out of the header into a slim row under it (logo always intact).
- Hero city line is large plain text now; hero dropdown removed.
- Map attribution strip removed from the map canvas (credits under the map); district details moved into a bottom USlideover.
- Found and fixed: closed overlay layers blocking input when exit animations do not fire (global CSS guard).

## 2026-08-16 - Tile Map + TMA Back + Carousels

- Housing split into Guide/Map tabs; map is real Leaflet + CARTO tiles with theme-aware tile swap; old SVG map removed.
- Food cards moved into Nuxt UI `UCarousel`; horizontal chip strips replaced with wrapping chips.
- Shared `AppCitySelect` powers the header and the new home-hero city line ("в Дананге" + dropdown).
- Telegram native BackButton synced via client plugin + bridge script; browser fallback is a header back arrow.
- Map how-to docs live in `vault/wiki/services/housing-map.md`.

## 2026-08-16 - Real Data Prototype + Hardening

- Rebuilt the housing map on six real Da Nang districts with real rent ranges; replaced food/guide mocks with real venues, streets, and price levels; first-day steps now contain concrete arrival instructions.
- Hardening: 404 page, baseline security headers (framable for TMA), reduced-motion restored, dead CSS class defined.
- Bug fixes from the hunt: mixed-script locale typos, dead anchor, config key order.
- All gates pass; browser-verified interactions and 360px layout.

## 2026-08-16 - Full Mock Prototype

- Built the complete clickable prototype: six category pages, first-day journey checklist, and a mock admin under `/admin` (dashboard, cities, categories, districts, places, guides, reviews).
- One mock DB (`mocks/db.ts` + `useMockDb()` store) feeds both the app and the admin; admin publish/moderate actions are reflected live in the app within one SPA session.
- All mock content is bilingual; RU/EN, dark/light, and 340px floor checks pass.
- Admin is a frontend prototype only: Supabase Studio remains the pilot admin per architecture; this surface demos the editorial workflow.

## 2026-07-31 - Supabase-Only Cutover

- Removed Laravel transitional backend from active repository path.
- Locked Supabase as only backend platform: Edge Functions, Auth, Postgres/PostGIS, Storage, Realtime, and RLS.
- Nuxt exposes only public Supabase client configuration.
- Supabase Studio is private pilot admin; Studio membership is restricted and database constraints/triggers protect invariants because privileged Studio edits can bypass client RLS.
- Next: implement Telegram bootstrap Edge Function and validate Supabase Auth session exchange.
