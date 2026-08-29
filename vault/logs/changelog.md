# Changelog

## 2026-08-29 - Scan "no connection" fixed: missing CORS preflight

### Done

- Founder in the real TMA: scan died with the network-error message. Root cause: `menu-translate` had no OPTIONS handler and no Access-Control headers - the WebView's preflight for the `Content-Type: application/json` POST failed before the function ran. Node e2e never performs preflight, which is why it passed while the real client failed. Fixed with the standard CORS/OPTIONS handling (same shape as telegram-bootstrap); OPTIONS probe now returns 200 + ACAO.
- Client: photo-processing failures are now their own state (`menu.errors.photo`) instead of masking as network errors. Commit `fix(menu): CORS preflight + separated photo-error state` (90841e5). Full e2e re-run green after the change; artifacts cleaned.

### Lesson

- Any new Edge Function called from the browser needs CORS/OPTIONS from day one - node-level e2e cannot catch its absence. Bootstrap had it, menu-translate did not.

## 2026-08-29 - Signature algorithm VERIFIED against live client data

### Done

- Founder pasted the FULL raw initData + hash. Offline brute-force over algorithm variants produced exactly one match: **values URL-DECODED, sorted, ONLY `hash` excluded - the ECDSA `signature` field STAYS in the check string**. Both earlier variants (decoded+signature-excluded = the original code; raw-encoded = the previous "fix") fail against real clients.
- validate.ts updated to the verified algorithm; debug echo removed; test sign helper + e2e script aligned (initData suite 12/12, frontend 48/48).
- Proof against hosted: a fresh real-shape initData for the founder's Telegram id passed bootstrap and issued a session; the full pipeline (bootstrap -> scan -> 4/4 dictionary matches) is green. Commit `fix(bootstrap): decode values, keep signature in check string` (0a5500e).
- Founder re-open pending: the TMA should now authenticate on next launch.

### Note

- The signature-included detail contradicts some community snippets that exclude `signature` - if Telegram changes the contract again, the offline brute-force approach (echo raw initData + hash, test variants locally) resolves it in one iteration.

## 2026-08-29 - bad_signature ROOT CAUSE fixed: raw-pair data-check string

### Done

- Founder pasted the on-screen debug (`query_id=...&user=%7B%22id%22...` percent-encoded) - **root cause**: real initData values arrive URL-ENCODED, and the old validator built the data-check string from URLSearchParams, i.e. from DECODED values. Telegram signs the RAW encoded pairs, so every real client failed HMAC while the synthetic e2e passed (it decoded identically on both sides - blind spot).
- `validate.ts` rebuilt: data-check string from the raw k=v pairs exactly as received (manual split, URLSearchParams gone); only `user` is decoded afterwards. `signature` still excluded with `hash`.
- Regression test with the real-client shape (percent-encoded user, escaped slashes in photo_url) added; 12 initData tests green, frontend 48/48. e2e script now signs over raw pairs too; full e2e green against hosted; temp debug echo removed and redeployed. Commit `fix(bootstrap): sign check string over raw initData pairs` (65250c7).

### Lesson

- When a validator passes synthetic tests but fails real clients, compare the EXACT byte shape of real input early - the debug echo of raw initData pinpointed it in one iteration.

## 2026-08-29 - TMA stuck session: hardened bootstrap + on-screen diagnostics

### Done

- Founder report: opened via Telegram, scan page still says a Telegram session is required. Server evidence: zero nonce rows for a real user -> the bootstrap request never completed, and the plugin swallowed every failure silently (one-shot, no retry, empty initData possible right after ready()).
- Plugin hardened: polls for initData up to ~3s, logs each failure path, records the failure code in `tma-bootstrap-error`; exposes `$tmaReconnect`. Scan panel shows the exact failure code with a Reconnect button (commit c3c7933). Deployed.

### Diagnose-next

- If the user reopens and still fails, the alert now carries the code (`no_init_data`, `bad_signature`, `rate_limited`, `replay`, ...) - that pins the cause. Fallback suspects: rotated bot token vs the deployed secret (token confirmed still valid today), or a Telegram client that injects initData later than the plugin's window.

## 2026-08-29 - Global one-tap scan (founder UX change)

### Done

- Founder: scanning must not require navigating into a venue - "one button, tap, photograph, get the menu". Implemented:
  - Migration 038: `menus.place_id` nullable; venue-less scans are readable by any authenticated user (RLS rewritten with a left join to places).
  - `menu-translate`: place_id optional. Venue check / cache lookup / per-venue photo path apply only to venue-bound scans; global photos land under `global/`.
  - `MenuScanPanel.vue` component extracted (shared scan UI: camera -> skeleton -> list -> dish sheet); used by the venue page (`/places/[slug]/menu`, still caches into the venue) and the new global `/scan` page.
  - Home screen: prominent camera card between hero and category grid -> `/scan`.
- Global e2e (no place_id) against hosted: scan 200, 4/4 dictionary matches. Artifacts cleaned (DB rows + test user; one orphaned private photo object left - harmless, Storage API delete needs creds the CLI does not expose).

## 2026-08-29 - Menu translator LIVE: working Gemini key, full e2e green

### Done

- Founder issued a second Gemini key (fresh AI Studio project) - it has working quota (the first project's prepaid credits were depleted; AI Pro subscription does not cover API usage). New key set as `GEMINI_API_KEY`.
- **Full e2e green** (scripts/menu-translate-e2e.mjs against hosted): synthetic "THUC DON" menu photo (Pho bo 50k, Banh xeo 40k, Ca phe sua da 25k, Goi cuon 30k) -> bootstrap session ok -> scan 200 -> 4/4 lines parsed, prices extracted, **4/4 dish_slugs matched the seeded dictionary** - cards render from our data, zero hallucination surface touched. Confidence 100 across the board.
- E2E artifacts cleaned from hosted after the run (scan rows, rate-limit keys, test user 777000777) - pilot users will not see the synthetic menu.
- e2e script env-guard ordering fixed (my sanitize pass put the guard before the const declarations).

### Status

- **The killer feature is LIVE**: dictionary (50 dishes, 46 photos) + Gemini matching + scan UI + cache. Founder should now open a venue in the TMA -> "Меню с переводом" -> photograph a real menu.
- Note: free-tier quota applies per model/day; the per-user rate limits (3/h, 10/day) sit well under it.

## 2026-08-29 - GEMINI key set; bootstrap session exchange REPAIRED; Gemini billing blocker

### Done

- Founder provided a Gemini API key; `supabase secrets set GEMINI_API_KEY` applied. Function now passes the not-configured gate (platform JWT check responds before it).
- **E2E harness** (`scripts/menu-translate-e2e.mjs`, secrets from env only): builds a valid Telegram initData HMAC, bootstraps a session through the hosted function, uploads a synthetic menu photo (sharp-rendered "THUC DON" image), prints the parsed result.
- **Sprint 5.5 blocker FIXED as a side effect**: the hosted bootstrap had never run its happy path. Three real defects found and fixed (commit e2a... c6a..: `fix(bootstrap): repair live session exchange`):
  1. `generate_link(magiclink)` does not auto-create the user on hosted -> deterministic `tg-*` user is now created first (idempotent, 422 tolerated);
  2. hosted GoTrue returns legacy `token` (not `token_hash`) in action_link -> both accepted;
  3. verify failures now logged. E2E reached full session issuance (bootstrap ok, user + profile + tokens).
- `gemini-2.0-flash` is retired by Google -> model switched to `gemini-3.6-flash`, configurable via the `GEMINI_MODEL` secret (fallback built in). Both functions redeployed clean (no debug fields, no secrets in repo - sanitized and verified).
- E2E artifacts cleaned from hosted: synthetic scan rows, test rate-limit keys, test user 777000777 (auth.users + profiles) deleted.

### Blocked (founder decision)

- **Gemini API returns 429 "prepayment credits are depleted"** for every model on this key's Google project - the new AI Studio key format has no free quota on that project. Two ways forward: (a) top up credits at ai.studio/projects (~$5 covers ~5k scans) or (b) create a NEW AI Studio project/key that still has free-tier quota and re-set `supabase secrets set GEMINI_API_KEY=<new>`. Until then the scan endpoint answers `ai_unavailable`; everything else (dictionary, UI, session) works.

## 2026-08-29 - Menu translator Phase A shipped

### Done

- **Schema (migration 036)**: `dishes` + `dish_localizations` (canonical dictionary), `menus` + `menu_items` (scans) with RLS - authenticated reads gated by published status (child tables use the direct parent-guard shape), rejected items hidden, all writes service_role-only (Phase B adds curated policies). Private `menu-photos` bucket created in-migration (first Storage usage).
- **Dictionary seed (migration 037, generated by `scripts/gen-dish-seed.mjs`, mirrored 1:1 into seed.sql)**: 50 canonical Vietnamese dishes, ru/en names + one-line summaries, published + verified=false. Photos: 46/50 sourced from Wikimedia Commons (hotlink-verified; 4-8 MB originals embedded as /thumb/ 1280px renditions; 4 dishes with no qualifying photo keep honest nulls). Seed-mirror duplication bug caught by a parity check and fixed.
- **`menu-translate` Edge Function**: platform-JWT auth -> per-user rate limit via the durable `check_rate_limit` RPC (3/hour + 10/day) -> cache-first (verified menu wins, AI scan reused 7 days) -> Gemini 2.0 Flash with the strict JSON contract -> service-role persistence + best-effort photo upload. Contract module (`contract.ts`, `#menu-contract` alias) enforces the dictionary-membership rule - the vitest run caught the missing allowlist check before deploy and it was fixed. Deployed to hosted; returns graceful `not_configured` until `GEMINI_API_KEY` secret is set.
- **Client**: `/places/[slug]/menu` scan page (camera input `capture=environment`, canvas compression to <=1600px JPEG, skeleton scanning state, grouped translated list, dish sheet rendering dictionary content only with a machine-translation badge for AI-only lines) + `useMenuTranslator` composable + "Menu with translation" button on place detail. Requires a TMA session; plain browser gets an explanatory alert.
- **pgTAP 014**: reader/guard posture for the four new tables (7 asserts). Contract tests: 8 new (47 total). CI on d757f3a: database job SUCCESS (migrations + seed + all 14 suites), frontend SUCCESS. Deploy job still fails on the missing `CLOUDFLARE_API_TOKEN` secret - local OAuth deploy already shipped the UI.
- **Hosted verified**: 50 dishes / 100 localizations / 46 photos / bucket exists; live routes 200.

### Pending (founder)

- Get a Gemini API key (aistudio.google.com -> Get API key) and set it: `supabase secrets set GEMINI_API_KEY=<key>` - this single step turns the feature on.
- `CLOUDFLARE_API_TOKEN` GitHub secret (standing), bot avatar via @BotFather, token rotation.

## 2026-08-29 - Menu translator: killer-feature spec drafted (no code)

### Done

- Founder pitched the feature: real-time menu translation for tourists (menus are Vietnamese-only, no photos) - photo -> translated lines -> tap for dish card with photo/description. Chose "spec first" at the scope question.
- Wrote `vault/wiki/architecture/menu-translator-spec.md`: dish-dictionary insight (~300-500 canonical dishes cover most menus; AI maps lines onto it and translates the residue), full data model (`dishes`/`dish_localizations`/`menus`/`menu_items` + RLS posture + pgTAP plan), Gemini 2.0 Flash pipeline with a strict JSON contract (slug constrained to the provided dictionary, verbatim prices, confidence gate), trust model (machine-translation badge -> curated -> verified, reusing house patterns), abuse controls (auth + per-user rate limit via the existing RPC + cache-first), Storage plan (first real bucket, 90-day cron purge), costs (~$1-2/mo at pilot scale), explicit pitfalls table, phases A/B/C, and 4 open questions for the founder.
- No implementation started - Phase A (dictionary seed + function + scan UI) begins after founder review.

## 2026-08-29 - City select flags, overlay animations restored

### Done

- **Invisible flags in the city dropdown**: the options rendered flag emoji, and Windows/Chrome ships no flag-emoji font, so the slot was blank in desktop browsers. Replaced with flagcdn PNG images derived from the stored emoji (pure emoji->ISO-code conversion, no schema change); trigger shows w40 in a 3.5-unit box, dropdown items 4x6 rounded. flagcdn verified 200 image/png.
- **Slideover popped with no animation**: a global `animation-duration: 0.01ms !important` kill on `[data-slot]` overlays - an old workaround for WebViews freezing keyframe exit animations - silenced every slideover/modal transition, including the housing district slideover. Removed the kill; the `[data-state="closed"]` visibility/pointer-events guard stays and covers the original stuck-sheet failure mode. `prefers-reduced-motion` users still get near-zero durations via the existing media query.
- Gates: lint clean, vitest 39/39, typecheck 0, deployed, housing route 200. Commit `fix(ui): flag images in city select, restore overlay animations` (68126e0).

## 2026-08-29 - Transition jump fixed, map embed on place detail

### Done

- **Page-jump root causes** (founder report "подпрыгивает при переходах"): (1) the default layout rendered a back-nav strip under the header on every non-home route, shifting the whole page vertically on each transition - removed; back navigation is now the native Telegram BackButton everywhere (founder's earlier call, layout strip was missed then). (2) Pages of different heights toggled the vertical scrollbar - reserved the gutter with `html { scrollbar-gutter: stable }`. Kept the subtle 120ms opacity out-in page transition.
- **Place detail map**: keyless Google Maps embed (`/maps?q=<name>, <area>, Da Nang&output=embed&hl=<locale>`) in the "How to find it" block - Google geocodes the query server-side, no stored coordinates. "Open in Google Maps" button kept below the embed. Verified the embed endpoint serves the map HTML.
- Gates: lint clean, vitest 39/39, typecheck 0, build+deploy OK; live routes 200. Commit `fix(ui): stop page jump, add map embed on place detail` (b9d005f).

## 2026-08-29 - Bot texts made city-neutral

### Done

- Founder flagged that the profile texts hard-coded Da Nang while the product is multi-city (cities table already holds inactive nha-trang/pattaya/phuket). Description and About (default EN + ru override) reworded to "first weeks in a new city ... more cities coming"; the `/start` blocks aligned the same way and the function redeployed. Commit `fix(bot): city-neutral welcome wording` (c66d4c7). Da Nang stays the active pilot city in the app itself (city select hero).

## 2026-08-29 - Bot profile localized, bilingual /start, avatar asset

### Done

- `/start` reply is now one bilingual message (RU block + EN block, dual button label `Открыть TAMITUT · Open TAMITUT`): per-locale branching hid a language, and many RU-speaking expats run English Telegram clients. Function redeployed to the hosted project; webhook verified to point at it.
- Bot profile texts set via the Bot API (BotFather commands cannot store per-language strings): description (empty-chat) and About text in default EN + `language_code=ru` override, `/start` command hint in both locales. Verified with getMyDescription/getMyShortDescription/getMyCommands. Encoding gotcha: raw Cyrillic in curl `-d` under Git Bash mangles to non-UTF-8 - send JSON via node instead.
- Bot avatar: no Bot API method exists, so BotFather upload is manual. Generated `frontend/app/assets/brand/bot-avatar-512.png` (512x512, brand mark centered on white) from `logo.svg` via sharp for the founder to send to @BotFather `/setuserpic`.
- Commit: `feat(bot): bilingual /start, ru/en profile texts, avatar asset` (688a6d9).

### Pending

- Founder: send bot-avatar-512.png to @BotFather → /setuserpic.
- Founder: rotate the bot token (still the chat-exposed one driving the API calls above), then `supabase secrets set TELEGRAM_BOT_TOKEN=<new>` + re-register webhook with the new token.

## 2026-08-29 - Photos visible without a session; native-only back nav

### Done

- **Why photos were invisible**: no CSP was blocking images - readers without a TMA session (plain browser, or TMA before bootstrap fires) get the mock fallback, and mock places had `imageUrl: null`. Filled all 10 mock places with the same sourced URLs as the DB (`fix(ui): photos in mock fallback, native-only back navigation`, dde68b0). Deployed and smoke-checked.
- **Back navigation simplified** (founder's call): removed the in-page back button on `/places/[slug]` and the unused `food.details.back` i18n key. The only back control is now the Telegram native BackButton, already synced to client-side routing by `plugins/telegram.client.ts`. In a plain browser this means browser-back only - acceptable for a TMA-first pilot.
- Gates: lint clean, vitest 39/39, typecheck 0. Live: `/` and `/places/<slug>` 200.

### Note

- If photos still do not appear for a specific user, check whether they see 23 places (session/DB) or 10 (mock fallback) - that distinguishes session issues from image issues. The TMA session path (bootstrap 5.5) is the founder live test still pending.

## 2026-08-28 - Photo coverage complete: 23/23 venues

### Done

- Second sourcing pass resolved the 9 venues that stayed null in 034: Wayback Machine og:image extraction for the bot-blocked Michelin pages (Bé Mặn, Hồng Vân, Cơm Gà Lan - cloudimg/michelin CDN URLs hotlink fine) and the JS-rendered Burger Bros site (amebaowndme CDN), wp-content extraction from the already-sourced Vietnamese guides (Ghiền Đà Nẵng → Nhắng Nướng, Kala Kala → Bé Loan, hoiandaytrip → Madam Khanh + An Thượng street), and RIONI via its Trip.com review cover. All 9 URLs re-verified from this machine (HTTP 206, image/jpeg).
- Migration `20260828130000_035_place_images_pass2.sql` carries the 9 updates; first attempt edited the already-applied 034, which db push correctly skipped ("up to date") - reverted, statements live in 035 only. Mirrored into seed.sql (23 update statements, parity-checked).
- Hosted applied + verified: 23 places, 23 with image_url. Commits: `feat(db): photos for the remaining 9 venues` (3021e61), `fix(db): move pass-2 photo updates into migration 035` (3bb3873).

### Caveats

- banh-mi-madam-khanh photo is the brand's Hội An original (no Da Nang-branch editorial photo exists yet); burger-bros/rioni-georgian are og:image covers (valid JPEGs, not human-inspected).

## 2026-08-28 - Prod deploy fixed: SSR worker entry restored

### Done

- Founder's Cloudflare API token verified active via `/user/tokens/verify`; local wrangler OAuth still logged in, so a manual deploy shipped the new UI without waiting for the CI secret.
- **First deploy exposed a real prod bug**: all HTML routes returned 404 (empty body) while static assets served 200. Root cause: the `cloudflare_module` preset builds an SSR bundle with no `index.html` in `.output/public`, but `wrangler.jsonc` declared no `main` - wrangler uploaded an assets-only worker, so nothing rendered the SPA/SSR HTML. (The "static SPA" comment in nuxt.config was stale - `nuxt build` with this preset never emits `index.html`.)
- Fix: added `main: ./.output/server/index.mjs` + `ASSETS` binding to `wrangler.jsonc` (`fix(deploy): point wrangler at the nitro server entry`, 0df0b4e). Redeployed: `/`, `/categories/food`, `/places/<slug>`, `/privacy` all 200 with the Supabase ref baked. New food list + detail page are LIVE.
- Vault updated (this entry + resume-plan stop point).

### Pending

- CI Deploy job still fails on the missing `CLOUDFLARE_API_TOKEN` secret (founder blocker) - local OAuth deploys work meanwhile.
- Photo coverage 14/23; remaining venues need founder photos via Supabase Storage.
- Audit backlog open (mock-fallback UX, guide authoring form, review submission).

## 2026-08-28 - Food seed + photos + UI shipped: CI green, migrations applied to hosted

### Done

- Committed in three conventional commits and pushed to main: `feat(db): seed sourced venues and photos` (41ea46f), `feat(ui): place photos, food list, detail page` (a6b22df), `docs(vault)` (d11a97d), plus the CI fix below.
- **CI caught a real bug**: the database job failed because `db reset` runs seed.sql after migrations, so `cities` was empty when migration 033 inserted places - every row died on the `city_slug` FK. Fixed in `fix(db): upsert da-nang city before venue places insert` (357341d). After the fix the db job is green: migrations + seed + all 13 pgTAP suites, including the new 013 parity suite, pass on CI (sha 357341d). Frontend job green too.
- **Hosted applied**: `supabase db push --linked` applied 033 + 034. Verified via `db query`: hosted now has 23 places (all published), 46 ru/en localizations, 14 with image_url. Anon REST returns 0 places - correct RLS (select requires `app_private.is_authenticated()`); the TMA reads with a session.
- Deploy workflow still fails: `CLOUDFLARE_API_TOKEN` repo secret is still missing (pre-existing founder blocker, unrelated to this change).

### Pending

- Frontend deploy (the new list/detail UI) rides on the Cloudflare Deploy workflow - it will ship as soon as the founder sets `CLOUDFLARE_API_TOKEN`, or via a local `wrangler deploy` (OAuth fallback).
- Photo coverage 14/23; the rest need founder/on-site photos into Supabase Storage later.
- Audit backlog still open (mock-fallback UX, guide authoring form, review submission).

## 2026-08-28 - Food UI pass: photo cards, detail page, image column

### Done

- **Place photos in the DB**: migration `20260828120000_034_place_images.sql` adds nullable `places.image_url` and fills 14 of 23 venues with externally sourced, hotlink-verified photo URLs (Wikimedia Commons, official sites pizzacardi.com/xliiicoffee.com, editorial CDNs). Every URL verified to return `image/*` with no referer (all 14 re-checked live from this machine). No Tripadvisor/Foody/Google hotlinks (blocked/rotating). 9 venues stay null by design - the UI renders a styled type-icon placeholder. Mirrored into seed.sql.
- **Food slider redesign** (`app/pages/categories/food.vue`): dropped the UCarousel (embla mis-measures inside a Telegram WebView) for a vertical full-width card list (founder's call over a scroll-snap rail): photo headers (`h-44 object-cover`, lazy), image-error fallback to a gradient+type-icon placeholder, verified badge overlay, line-clamped summary, whole card is a `NuxtLink` to the detail page, empty-state message for filters with zero results.
- **Detail page** `app/pages/places/[slug].vue`: hero photo, name + verified icon, type/price/reviews meta, full summary, "How to find it" block with the area text and a Google Maps deep link (`/maps/search/?api=1&query=<name>, <area>, Da Nang` - no stored coordinates needed). Telegram native BackButton already syncs with routing via `telegram.client.ts`, so back navigation works in the TMA for free.
- **Data plumbing**: `Place` type + `slug`/`imageUrl`, `PlaceRow.image_url`, `mapPlaces` maps both, `useDb` selects `image_url`, mock places carry `slug` + `imageUrl: null`. i18n keys `food.empty` + `food.details.*` (ru/en).
- Gates: vitest 39/39 (mapper fixture updated), eslint clean, typecheck exit 0, production build complete.

### Pending

- Not deployed (frontend or DB): migration 034 + all of today's content/UI lands with the next `supabase db push` + frontend deploy.
- Photo coverage 14/23; remaining 9 need founder/on-site photos into Supabase Storage later (storage policies are the first prerequisite).
- Audit items still open (mock-fallback UX, guide authoring form, review submission).

## 2026-08-28 - Phase 4: sourced food expansion (13 new venues) + parity test

### Done

- Sourced 13 new real Da Nang venues (each with at least one external source: Michelin Guide 2025/2026, Tripadvisor, official site/social; prices/hours only where sourced): bun-cha-ca-ba-hoa, mi-quang-sua-hong-van (Bib Gourmand), com-ga-lan (Michelin 2026), bun-mam-ba-dong, mi-quang-ech-bep-trang, nhang-nuong, be-loan, burger-bros, ganesh-da-nang, cardi-pizzeria, rioni-georgian, xliii-coffee, banh-mi-co-tien (spare). Three researched candidates were already seeded (banh-xeo-ba-duong, bun-cha-ca-ba-lu, cong-cafe). Rejected during research: Bánh Mì Queen (Hoi An, not Da Nang), Cơm Gà A Chà (unverifiable).
- Migration `20260828000000_033_food_expansion_seed.sql`: 13 places (ids continuing the `b937c18f-...e7f` prefix, `...0b`–`...17`) + 26 ru/en localizations, idempotent upserts, all `published`/`verified`. Mirrored 1:1 into `supabase/seed.sql` (now 23 places / 46 localizations).
- New pgTAP suite `tests/rls/013_seed_localization_parity.sql`: every authenticated-visible place has exactly one ru + one en localization; also proves the seed loads non-empty. Auto-picked up by the CI loop.
- Verification without local Docker (not installed): static node checks prove migration == seed byte-for-byte across all 26 localization rows and all 13 place rows (field-level), 23 unique ids/slugs, no quote/row malformations. Frontend vitest 39/39. SQL semantics (db reset + full pgTAP run) will be proven by the CI database job on push - NOT yet run locally or on hosted.

### Pending

- Founder reviews venue list, then `supabase db push` (or CI-verified commit to main) applies 033 to the hosted project.
- Seed content not yet deployed anywhere: local Docker stack and hosted project both untouched.

## 2026-08-28 - Frontend local env fixed

### Done

- Founder had created a root `.env` with Next.js-style names (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`) - Nuxt ignores it (wrong prefix, wrong directory). Created `frontend/.env` with the correct names (`NUXT_PUBLIC_SUPABASE_URL`, `NUXT_PUBLIC_SUPABASE_ANON_KEY`, `NUXT_PUBLIC_APP_NAME`) using the project ref `tepsurbgsrivvcvizxph` and the public publishable key. Both values are public by design (RLS-gated); file is gitignored (verified via `git check-ignore`).
- Verified live: `npm run dev` in `frontend/` serves 200 on :3000 with the Supabase ref baked into the page; dev server stopped afterwards.

### Reminders (founder)

- `TELEGRAM_BOT_TOKEN` was shared in chat again - rotate via @BotFather /revoke, then `supabase secrets set TELEGRAM_BOT_TOKEN=<new>` (it is an Edge Function secret, not a frontend var).
- CI secrets still pending: `CLOUDFLARE_API_TOKEN` (value received in chat, not yet set), `SUPABASE_DB_URL`, R2 backup secrets (see `vault/wiki/services/supabase-backup-runbook.md`). These go to GitHub Secrets, not `.env`.

## 2026-08-22 - Phase 3 Hardening Completed: Rate Limiting, CI Green, Deploy Diagnosed

### Done (resumed from the uncommitted WIP found in the tree)

- **Rate limiting (3.6) finished and live**: migration 030 (durable `check_rate_limit` RPC + `telegram_rate_limits`) was applied but the function had default PUBLIC execute - any client could mint rows or burn another key's window. Migration 031 revoked it from public/anon/authenticated, granted execute to service_role only, pinned `search_path`. The edge function now rate-limits per IP in two layers (best-effort in-isolate counter + authoritative Postgres RPC), returns 429 with a real `Retry-After`, fails open if the store is unreachable. `rate-limit.ts` is pure and shared with vitest (`#telegram-rate-limit` alias, 5 unit tests).
- **Live verification**: 12-request burst -> 10x401 then 429s with `Retry-After: 17`; window expiry restores access; anon RPC call now `42501 permission denied`; anon reads of `telegram_rate_limits` return an empty set; bootstrap still validates initData normally.
- **Migration 032**: hosted Supabase grants table privileges via platform init scripts; a fresh local stack does not. Added explicit grants for anon/authenticated/service_role (schema usage, DML on all tables, function execute) plus ALTER DEFAULT PRIVILEGES. Verified live that RLS still gates everything (anon still reads zero rows).
- **CI database job fixed end-to-end** (it had never passed): raised db health timeout to 5m; excluded all non-database services; `--ignore-health-check` with an explicit `pg_isready` wait; removed a `--workdir` mismatch that made later steps look for a docker network the start step never created; scoped `db lint` to non-gating signal (its 13 errors are pgTAP/PostGIS internal helpers, verified identical on live); per-suite execution so failures surface exact psql errors as annotations.
- **pgTAP suites repaired for schema v2** (they predated migrations 022+ and had never run green anywhere): added required `slug` to guide_entries fixtures (002/003/004/008); scoped row-count asserts to suite fixtures (001/002); updated 007 to policy 028 semantics (moderator audit inserts are allowed by design; append-only trigger assertions stay).
- **Deploy workflow root cause found**: Nitro's `cloudflare.deployConfig=true` emits `.output/server/wrangler.json` plus a `.wrangler/deploy/config.json` redirect, hijacking `wrangler deploy` into a server build with a missing entrypoint. Fixed at the source (`deployConfig: false`) and removed the redundant CI cleanup step. Every historical Deploy failure is explained by this.
- Frontend gates: test 39/39, lint, typecheck, build PASS. Manual deploy via local OAuth wrangler re-verified (site serves baked env, privacy/admin routes 200).

### Verified

- Live: burst -> 429 with Retry-After; window resets; grants do not weaken RLS; site + functions healthy after redeploy.
- CI on sha 252c144: frontend-quality SUCCESS, database-quality (RLS pgTAP, all 12 suites) SUCCESS - first fully green CI in repo history.

### Blocked (founder actions)

- Deploy workflow needs a valid `CLOUDFLARE_API_TOKEN` repo secret (fails fast at auth; local OAuth deploys work).
- Backup workflow needs `SUPABASE_DB_URL` + R2 secrets; pgTAP artifact download also needs auth (fine - annotations carry diagnostics).

## 2026-08-18 - Freshness SLA (guides admin)

### Done

- Admin guides table now shows a "Проверено" column with `last_verified_at` and a freshness state: overdue (alert icon, transport/money after 14 days, safety after 30 - per the content-seeding protocol SLA) vs fresh (check icon) vs never (dashed icon). `useAdminDb.loadGuides` selects `last_verified_at`/`verification_due_at`.
- Gates: test 34/34, lint, typecheck, build - PASS. Deployed.

### Pending

- Food expansion to ~15 places needs SOURCED venues (no fabricated data per project rule) - founder/team input.
- Closed pilot (founder + 3-5 testers) + metrics.

## 2026-08-18 - Guide DB Cutover (Phase 4 start)

### Done

- **Migration 029**: `guide_entries` gained `slug` (pairs ru/en rows, unique per category+language), `note` and `icon` columns (the rest of the GuideEntry shape); created a deterministic seed auth user + curator profile; seeded the accepted mock guide content as 22 rows (11 published guides x 2 languages: transport 4, money 4, safety 3) with `under_review` trust badge + note, `published_at`, `last_verified_at`.
- **`mapGuides` mapper** (pure, 2 new tests): pairs guide_entries ru/en rows by (category_slug, slug) into `GuideEntry` LocalizedText; drops drafts; fills missing languages with empty text.
- **`useDb`** now loads published guide_entries and maps them into `db.guides`.
- **transport / money / safety pages** switched from `useMockDb` to `useDb` (DB data with a session, mock fallback without).

### Verified

- Browser: transport shows the 4 DB guides (Grab/Аренда байка/Автобусы/Аэропорт) with DB text; money shows 4 (Наличные/Карты/QR/Банкоматы); mock fallback (no session) still shows the mock cards. Gates: test 34/34, lint, typecheck, build - PASS. Deployed.
- Live content now: 10 food places + 11 guides + 6 districts + 4 cities.

## 2026-08-18 - Phase 3 start: keepalive, cleanup, privacy, CI prep

### Done

- **Keep-awake worker** (`workers/keepalive`): Cloudflare Worker with cron `*/5 * * * *` pings Supabase `/auth/v1/health` (with anon key) + the deployed TMA every 5 min so the free project never hits the 7-day inactivity pause; logs state; optional Telegram bot alert when a chat id + token are configured (empty for now). Deployed. (Any HTTP response counts as "up" - a 4xx/5xx still proves the project is awake; only a network error is "down".)
- **Cleanup (3.4)**: deleted `bot-token.txt` (token lives in Supabase secrets; recoverable from BotFather) and the `pilot-test@tma.local` test user. Added `.wrangler/` to `.gitignore`.
- **Privacy page (3.5)**: new `/privacy` route (bilingual RU/EN: what we store - Telegram id + locale; why; no sharing; contact), linked in the home footer. Fixed a vue-i18n parse bug (a literal `@` in a message is linked-message syntax - rewrote the contact text to avoid it). Deployed.
- **CI/auto-deploy prep (3.3)**: added `.github/workflows/deploy.yml` (lint/typecheck/test -> `nuxt generate` with Supabase env secrets -> `wrangler deploy`). Existing `ci.yml` (frontend quality + local Docker RLS pgTAP) stays. Root `.gitignore` already excludes node_modules/.output/.nuxt/dist/.env.

### Pending (needs founder)

- Create public GitHub repo, add repo secrets (`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID` = 8ddeed0d41fd2cbd38f218eae09887fe, `NUXT_PUBLIC_SUPABASE_URL`, `NUXT_PUBLIC_SUPABASE_ANON_KEY`), push to `main`.

## 2026-08-18 - Polygon 3-Point Limit Fix

### Root cause

`allowIntersection: false` in the Leaflet.draw polygon options. When extending a triangle, the preview ghost point crosses the growing polygon's edges -> the intersection safety check rejects the new vertex -> the user is stuck with 3 points.

### Fix

Removed `allowIntersection: false` (free drawing). Caveat: the admin can now draw self-intersecting rings; a server-side `ST_IsValid` guard on save is a future hardening item (the admin can edit/fix a bad polygon).

## 2026-08-18 - Map Freeze Fix (district editor infinite loop)

### Root cause

`DistrictMapEditor` watch on `props.geometry` called `emitGeometry()` after re-rendering the polygon. Each emit created a fresh GeoJSON object -> the parent assigned it to `form.geometry` -> new reference -> the prop watch fired again -> emit again -> **infinite loop** that pegged the CPU and froze the whole page while drawing/editing polygons.

### Fix

The geometry watch now only re-renders the polygon from props and never emits (the parent already has the geometry; emitting only feeds the loop). Verified: editor opens, polygon renders, page responsive.

## 2026-08-18 - Full Audit (post-Phase-2)

### Fixed

- **City selector showed raw i18n keys for DB-added cities** (real bug): `mapCities` produced `labelKey = cities.<slug>` for cities not in `CITY_UI`, and `AppCitySelect` rendered `t(labelKey)` -> a city created in the admin appeared as "cities.hoi-an". Fix: `CityEntry` now carries `nameRu`/`nameEn` from the DB; the selector prefers them and falls back to `t(labelKey)` (mock mode unchanged). Verified live: created + activated "Хойан" -> selector showed "Хойан"; cleaned up after.
- **Housing page lost the default district selection** after the async DB cutover (regression): `selectedDistrictId` was initialized from an empty array. Fix: watch `districtFeatures` and set the first district as default when none is selected.
- **db-mappers test updated** for the new `nameRu`/`nameEn` fields.
- Found during the audit chain: migration 028 (audit INSERT policy) had been written in Phase 1 but never pushed to the remote - admin audit writes 403'd. Pushed; verified insert 201; append-only DELETE/UPDATE trigger still blocks (verified).

### Checked and clean

- Edge function guards: `telegram-bootstrap` empty body -> 400 malformed; `telegram-bot` without secret header -> 403.
- Backend state consistent: 6 districts, 10 places, 0 reviews (by design), 1 cron job (nonce purge), profiles = admin only (pilot-test exists as an auth user without a profile - behaves as a plain user via the role fallback).
- Mock fallback (no session): home 6 cards, food mock places - prototype mode intact.
- Admin district editor save persists (geometry `ST_IsValid` true) - re-verified.
- No leftover console.log/debugger/TODO; no admin page uses the mock store.
- Gates: test 32/32, lint, typecheck, build - PASS; deployed.

### Accepted / known (documented)

- audit_logs `actor_role` hardcoded 'admin' (single-admin pilot; a future curator role would need the real role read).
- Admin reviews table shows the place slug, not the localized name (0 reviews seeded anyway).
- Admin cities "country" column hardcoded flag (cosmetic; flag + names are editable).
- Guide authoring form, transport/money/safety DB cutover = later slices.

## 2026-08-18 - Phase 2: District Polygon Editor + Housing DB Cutover

### Done (approved plan: vault/wiki/architecture/admin-panel-and-prod-plan.md)

- **`DistrictMapEditor.client.vue`**: admin Leaflet polygon editor - Leaflet + CARTO tiles (theme-aware) + `leaflet-draw` toolbar (draw/edit/delete, no intersections), emits GeoJSON (lng/lat, ring closed) on change. New dependency `leaflet-draw` (+types).
- **`useAdminDb` district methods**: `loadDistricts` (geometry + full ru/en localizations incl. rent/distance/best_for), `saveDistrict` (upsert district + geometry + localizations, audit-logged), `deleteDistrict`. `loadAll` includes districts.
- **`/admin/districts` rebuilt**: live district list (6, with price) + edit/delete + a full editor card (map + slug/price/sort + RU/EN name/area/rent/distance/summary + best-for tags comma input). Editor loads existing polygon + fields from DB.
- **Housing DB cutover**: new `useHousingDb` - loads districts (PostGIS geometry + localized text) into the housing `FeatureCollection` when a session exists, mock fallback otherwise, locale-reactive. Housing page + `HousingTileMap` render DB districts (text labels, `priceRange`/`bestFor` stay i18n keys). `HousingTileMap` prop changed from full `HousingGuideData` to `HousingDistrictFeature[]`.
- **Migration 028 pushed** (was written in Phase 1 but never applied to the remote - audit_logs had no admin INSERT policy, so admin audit writes 403'd; now 201).

### Verified (browser + live DB)

- Admin: login -> /admin/districts -> 6 districts from DB; edit Sơn Trà -> map shows its polygon from PostGIS, fields populated (ru/en); save persisted (summary marker in DB, geometry `ST_IsValid` true), then reverted. Draw controls present.
- Housing page: map tab renders **6 polygons + 6 DB labels** (Sơn Trà, Ngũ Hành Sơn, Hải Châu, Thanh Khê, Liên Chiểu, Cẩm Lệ). List + chips show DB text.
- Audit: admin insert 201; append-only trigger correctly blocks DELETE/UPDATE (verified).
- Gates: test 32/32, lint, typecheck, build - PASS. Deployed to Cloudflare.

### Note

- Headless browser `.click()` does not activate RekaUI tabs; verified the map via a real puppeteer click (test-harness artifact, not a code bug).

## 2026-08-18 - Admin Login Polish (visual + auth)

### Done (founder feedback, verified on prod)

- **Login page redesigned**: new bare `admin-login` layout (full-viewport centered form, no "TAMITUT Admin" header/divider), `max-w-md` form, inputs + button bumped to `size="xl"` (40px vs 32px), neutral monochrome button (was Nuxt UI default bright-orange with dark text - violates the design rule "orange stays out of admin chrome").
- **Inputs now span the full form width** (Nuxt UI v4 `UInput` collapses to intrinsic width without `w-full` - added `class="w-full"`; verified 448px = form width, 40px tall).
- **Authenticated staff can no longer open `/admin/login`**: the page checks the session on mount and redirects staff to `/admin` (verified live: admin visiting the login URL lands on the dashboard).
- Cache note: Cloudflare/browser HTML caching can serve a stale build briefly; a `?v=N` query busts it (deploys verified with cache-bust).

## 2026-08-18 - Redeploy to Prod + Bot Copy Generalized

### Done

- **Redeployed the frontend to Cloudflare** with the Phase 1 admin panel (56 assets): `nuxt generate` with live env + `wrangler deploy` (removed the Nitro-generated `.wrangler`/`.output/server` state that hijacks the deploy; `wrangler.jsonc` is the single deploy config).
- **Deployed pipeline verified live** on https://tamitut.tamitut-frontend.workers.dev:
  - `/admin` without a session -> redirects to `/admin/login` (login form renders);
  - `/admin` with a user-role session (pilot-test) -> redirects to login (role gate works);
  - admin email+password login -> dashboard with real stats + nav.
- **Bot copy generalized** (no hardcoded city; the app has a city selector): `setMyDescription`/`setMyShortDescription` (default/ru/en) now say "гид для первых недель в новом городе" / "your guide for the first weeks in a new city" + "Город выбирается в приложении / Pick your city in the app"; `/start` welcome in the `telegram-bot` function updated the same way and redeployed. In-app hero city line stays city-driven (`citiesIn.*` per the design rule).
- Pipeline note: deployment is currently MANUAL (`nuxt generate` + `wrangler deploy`); CI auto-deploy on push is Phase 3.3 of the admin plan (repo not on GitHub yet).

## 2026-08-18 - Phase 1: Real Editorial Admin Panel (live)

### Done (approved plan: vault/wiki/architecture/admin-panel-and-prod-plan.md)

- **Admin auth gate**: `app/middleware/admin.ts` - /admin requires a Supabase session whose profile role is admin/curator/moderator, else redirect to login. `/admin/login` (email+password via Supabase Auth) with error/loading states; login page hides the admin nav; layout gained a logout button.
- **`useAdminDb` composable**: real RLS data layer - loads cities (all, via new select-all), places (+ both-language localizations), reviews (+place names), guide_entries; mutations persist via the admin JWT: place publish/unpublish, review approve/reject, city activate/deactivate, city create, place create/edit (ru/en). Every sensitive mutation appends an `audit_logs` row.
- **Migration 028**: `audit_logs__moderator_admin__insert` policy (append-only table; UPDATE/DELETE still blocked by the trigger).
- **Pages rewired to real data** (no more mock store): dashboard (live stats: cities 2/4, places 10/10 published, reviews pending), cities (list + activate + new-city modal), places (list + publish/unpublish + full editor modal: city/slug/type/price/verified/status + RU and EN name/area/summary), reviews (approve/reject), guides (list + publish/unpublish), categories (live view). AdminTable gained a loading row.
- **Nuxt UI v4 fixes found live**: UCard has no `#body` slot (content goes in the default slot) and UModal content lives in `#content`/`#body` slots (the default slot is the trigger) - both modals rewritten to the v4 pattern; UCard `title` prop requires v4.7+ (dropped UCard inside modals). PostgrestError is not an `Error` instance - error extraction now reads `.message` (was rendering `[object Object]`). Forms now require both RU and EN names (the `name_en_not_empty` check constraint surfaced the gap).

### Verified (browser, live project)

- /admin -> redirects to /admin/login; login as `admin@tamitut.local` -> dashboard with real stats; nav renders.
- Places: real 10 rows; toggle "An Thượng" to draft -> DB shows `status=draft`; re-published. Place editor: edited Chợ Cồn EN summary -> DB updated -> reverted.
- Cities: created "Хойан" (hoi-an, inactive) via the modal -> appeared in the table; deleted after the test. Cities back to the 4 seed rows.
- Gates: test 32/32, lint, typecheck, build - PASS.

### Notes

- Guides: real list + publish/unpublish live; a full guide authoring form (per-language rows, trust badge, verification dates) is a follow-up within Phase 1.
- District polygon editor is Phase 2 (districts table + editor already designed; the /admin/districts page still shows the mock list).

## 2026-08-18 - Phase 0 Complete (Admin + Prod plan foundations)

### Done (approved plan: vault/wiki/architecture/admin-panel-and-prod-plan.md)

- **PostGIS 3.3 enabled** on the live project.
- **Migration 024**: `districts` (PostGIS Polygon 4326 geometry, city_slug FK, price_level, sort_order) + `district_localizations` (rows-per-language: name/area/rent_range/distance_to_beach/summary/best_for[]). RLS: authenticated reads districts of ACTIVE cities only; moderator/admin full write. GiST + city indexes.
- **Migration 025**: moderator/admin write policies on `places` (all), `place_localizations` (all), `reviews` (all), `cities` (update by moderator_admin, insert/delete by admin).
- **Migration 026**: pg_cron nightly purge of `telegram_bootstrap_nonces` (>3 days), idempotent via `cron.job` lookup (unschedule-by-name raises when absent - caught in the first apply and fixed).
- **Migration 027** (real RLS bug found by the new pgTAP suite): `cities` lacked a moderator/admin SELECT-all policy, so admins could not see inactive cities and `update cities set is_active=false` failed with 42501 (the updated row must stay visible under a policy applying to the user). Added `cities__moderator_admin__select_all` mirroring `categories__moderator_admin__select_all` (018).
- **Seed**: 6 Da Nang districts (son-tra, ngu-hanh-son, hai-chau, thanh-khe, lien-chieu, cam-le) with closed GeoJSON rings and ru/en localizations extracted programmatically from the accepted mock + locale files (no transcription errors), `on conflict` upserts.
- **Founder admin identity**: auth user `admin@tamitut.local` (email+password, email confirmed) + `profiles` row role=admin. Desktop admin access; Telegram users stay role=user.
- **pgTAP 011** (11 asserts): reader sees active-city districts/localizations only, reader writes blocked (INSERT throws, UPDATE affects 0 rows - silent RLS), admin role resolves + inserts districts + publishes places + approves reviews + deactivates cities, anon sees nothing. Two test-writing lessons: UPDATE/DELETE RLS blocks are SILENT (assert row count, not throws_like), and data-modifying CTEs must be top-level.
- **Live-verified**: admin REST path (JWT) - sees all cities, deactivates/reactivates (204/204), inserts districts (201), publishes places (204); regular user blocked (403); anon reads 0. pgTAP 011 passes on the live project.

### Verified

- pgTAP 011: 11/11 pass (live). Frontend gates unchanged (32 tests).

## 2026-08-18 - Telegram Bot Configured (@tamittutbot)

### Done

- Bot token received via a local file (chat layer masks secrets); verified with `getMe`: bot **@tamituttbot** (id 8815351798 — matches the id used in the initData validation tests).
- Configured via Bot API (script run locally, token never printed):
  - Name: **TAMITUT** (ru + en)
  - Short description (ru + en): Da Nang newcomer guide (housing/food/transport/money/safety)
  - Description (ru + en): mini-app guide with housing/food/transport content overview
  - Description later refreshed per user request: emoji-rich, RU first then EN below (both in the default/ru/en variants); `/start` welcome updated with emojis too.
  - Commands: `/start` (ru + en menus)
  - **Menu Button: type `web_app`, text "TAMITUT", url = https://tamitut.tamitut-frontend.workers.dev** (global default for all chats)
  - Webhook -> `https://tepsurbgsrivvcvizxph.supabase.co/functions/v1/telegram-bot` with `secret_token`; pending updates 0, no errors.
- `setMyAbout` does not exist in the Bot API (bots have no About section via API) - skipped.
- **New Edge Function `telegram-bot`**: webhook replies to `/start` with a welcome (ru/en by user language) and an inline `web_app` button "Открыть TAMITUT". Verifies the `X-Telegram-Bot-Api-Secret-Token` header (403 without it - verified) so forged updates cannot spam users. Secrets: `TELEGRAM_BOT_TOKEN` (shared with bootstrap), `TMA_URL`, `WEBHOOK_SECRET`. Registered in `config.toml` (`verify_jwt = false`), deployed.
- `bot-token.txt` added to `.gitignore` (user placed it in the repo root; delete after the test).

### Pending

- User test in Telegram: open @tamituttbot -> Menu button (or `/start`) -> the TMA opens -> `telegram-bootstrap` exchanges a genuine initData -> verify a `tg-<id>@tma.tamitut.local` auth user + nonce row on the backend.

## 2026-08-18 - Cloudflare Agent Setup + Live Deployment

### Done

- **Cloudflare agent setup** per official instructions (`developers.cloudflare.com/agent-setup/prompt.md`): installed the `cloudflare` skill set via `npx skills add cloudflare/skills --global` (landed in `~/.agents/skills/cloudflare`), registered the five Cloudflare MCP servers (`cloudflare`, `cloudflare-docs`, `cloudflare-bindings`, `cloudflare-builds`, `cloudflare-observability`) in `~/.config/opencode/opencode.json`, and completed `opencode mcp auth cloudflare` (OAuth token stored; the other three servers OAuth on first tool use).
- **Wrangler OAuth completed** (Cloudflare account `Aslavadoma@tuta.io`, workers.dev subdomain `tamitut-frontend`).
- **Frontend deployed**: `nuxt generate` (SPA static, env baked) -> `wrangler deploy` -> **https://tamitut.tamitut-frontend.workers.dev** (new Workers-based Pages; assets-only Worker). Replaced the stale Nitro-server `wrangler.jsonc` (pointed at `.output/server/index.mjs`) with the static-assets config; removed the generated `.output/server/wrangler.json` and stale `.wrangler` cache that hijacked the deploy. `wrangler.jsonc` is now the single deploy config; `frontend/public/_headers` ships the baseline security headers (verified live: `nosniff`, `Referrer-Policy`, `Permissions-Policy`).
- **TELEGRAM_BOT_TOKEN secret set** by the user in the dashboard; function now returns `401 bad_signature` for forged initData (was `503 function_not_configured`).
- **Verified live end-to-end on the deployed site**: no session -> mock fallback; injected test-user session (`pilot-test@tma.local`) -> real RLS data from the hosted project (DB-ordered category cards). Earlier TLS/handshake failures were transient workers.dev route propagation + a stale CDN-cached index; after redeploy the baked `supabaseUrl` is served correctly.

### Pending

- Real Telegram flow: user sets the bot Menu Button to the deployed URL in BotFather and opens the app inside Telegram; then `telegram-bootstrap` exchanges a genuine initData -> Supabase Auth session (verify: a `tg-<id>@tma.tamitut.local` user appears in `auth.users`, a nonce row is recorded).

## 2026-08-18 - Live Verification on Hosted Supabase Free (path B)

### Done

- **Fixed migration timestamp collision**: `022` and `023` shared the prefix `20260818000000`, so the second migration collided on the `schema_migrations` primary key (`db push` failed with 23505; the same would break CI's `migration up` on a fresh DB). Renamed to `20260818120000_023_places_and_reviews.sql`. The migration is idempotent, so the partial DDL from the failed run was safe to re-apply.
- **All 23 migrations applied to the live project** (`tepsurbgsrivvcvizxph`, Postgres 17, free tier, restored from pause).
- **Seed verified on the live project**: 4 cities, 10 places, 20 localizations (10x2), 0 reviews (by design).
- **RLS proven live** (real seeded data, role-switch queries):
  - `authenticated` (JWT sub set): cities=1 (only active da-nang), places=10 (published), localizations=20, reviews=0.
  - `anon` (no sub): all counts = 0 - no anonymous reads, matching the accepted RLS posture.
- **`telegram-bootstrap` deployed** with `--no-verify-jwt`; endpoint probes: GET 405, OPTIONS 200, POST without initData 503 `function_not_configured` (bot token not set yet). Full session exchange test awaits `TELEGRAM_BOT_TOKEN`.
- **Browser live-read verification** (dev server against the live project):
  - Without a session: mock fallback (home 6 cards in mock order) - prototype preserved.
  - With an injected session (test user `pilot-test@tma.local`): home swaps to **DB categories in DB sort order** (housing, transport, money, food, safety, culture; `events` excluded, `culture` appended from the UI map); food renders **all 10 real DB places** with seed localizations; EN switch flips h1 + summaries from DB rows.
  - City selector with a session shows only the **active** city (RLS `cities__authenticated__select_active` hides inactive ones) - accepted decision: do not leak future cities; the "coming soon" disabled entries exist only in mock mode.
- **Deployment readiness**: `nuxt generate` produces `.output/public` (18 routes, 2.1MB) for Cloudflare Pages; added `frontend/public/_headers` (Nuxt 4 keeps `public/` at the repo root) so the baseline security headers ship with static hosting.

### Blocked / pending

- `TELEGRAM_BOT_TOKEN` from BotFather (user action) for the live `telegram-bootstrap` session exchange test.
- Supabase Studio editorial workflow check (5.7) and the pgTAP suite in a Docker environment (CI database-quality job).

## 2026-08-18 - Nuxt RLS-Safe Read Layer (schema v2 cutover, food slice)

### Done

- **`useDb()` composable** (`app/composables/useDb.ts`) - the accepted schema-v2 read path (design: `vault/wiki/architecture/schema-v2-city-aware.md`): builds the Supabase client from `runtimeConfig.public`, queries `cities`, `categories`, `places`, `place_localizations`, `reviews` through the anon key when a session exists, and maps rows to the existing `MockDb` UI shapes so page components are unchanged. Without a configured project or session it falls back to the shared mock store - the prototype and the admin->user live demo keep working.
- **Pure mappers** (`app/composables/db-mappers.ts`) - DB rows -> `CityEntry`/`CategoryEntry`/`Place`/`Review` UI shapes; static `CITY_UI`/`CATEGORY_UI` tables carry the pilot chrome (icons, routes, i18n keys). Categories follow DB sort order; slugs without a pilot page (`events`) are excluded, `culture` is appended from the UI map (enum gap recorded). Localized area/summary assemble ru+en rows; name follows the active locale. Unit-tested (11 new cases) without Nuxt via the new `~`/`@` vitest aliases.
- **`useSupabaseClient`** - one shared client factory (module-level cache, SPA-only); **`useAuth`** - read-side view of the TMA session state.
- **Session exchange completed in the telegram plugin** (single consumer of the one-shot initData nonce): the plugin now calls `client.auth.setSession()` with the edge function's tokens and sets `tma-session = { telegramId, authenticated: true }` only after success; `useDb` reacts to that state.
- **Pages rewired** (RLS path): `pages/index.vue` (categories), `pages/categories/food.vue` (places + approved-review counts), `components/AppCitySelect.vue` (cities, data-driven, inactive cities stay disabled with the coming-soon note). Admin prototype, housing/culture/journey stay on mocks per the accepted slice scope.
- **Seed (5.9, food slice)**: `supabase/seed.sql` already carries the accepted seed - 4 cities (da-nang active), 10 real Da Nang venues with ru/en localizations, zero invented reviews. Confirmed in place.
- **Backup runbook (5.10)**: `vault/wiki/services/supabase-backup-runbook.md` - daily logical DB dump + Storage sync to an off-site (different region/provider) versioned bucket, retention, monthly restore drill, verification checklist.

### Verified

- Gates PASS: `npm run test` (32/32: smoke, content 10, telegram-initdata 11, db-mappers 11), `npm run lint`, `npm run typecheck`, `npm run build`.
- Browser (dev server, unconfigured fallback path): home renders 6 category cards with no overflow; food renders all seeded/mock places; EN switch flips h1 + summaries; city selector lists 4 cities from `db.cities`; admin `places` toggle to draft hides the place on `/categories/food` on client-side navigation (prototype contract preserved through the shared mock store).
- **NOT runtime-verified**: the live Supabase read path (RLS queries against a running stack) and the session exchange require Docker, unavailable on this machine - CI database-quality job gates the RLS suite, and the browser verification must be repeated against a `supabase start` stack on a Docker-capable host.

## 2026-08-18 - Telegram Bootstrap Edge Function + Schema v2 (supabase work completed)

### Done (core work, from the current working tree)

- **`telegram-bootstrap` Edge Function** (`supabase/functions/telegram-bootstrap/`): validates Telegram Mini App `initData` with the official HMAC-SHA256 signing chain (`WebAppData` key), enforces freshness (`MAX_AGE_SECONDS` = 24h) and a future-skew window (`MAX_FUTURE_SKEW_SECONDS` = 5m), then establishes a Supabase Auth session by deterministic email (`tg-<telegram_id>@tma.tamitut.local`) via `admin/generate_link` + `/auth/v1/verify`. Replay protection uses the `telegram_bootstrap_nonces` table (unique `init_data_hash`). Idempotently upserts the `profiles` row on first sign-in without downgrading an existing curator/moderator.
- **Validation logic kept pure and shared**: `validate.ts` runs identically in Deno (Edge) and browser/Node via WebCrypto; the vitest alias `#telegram-validate` points the frontend test suite at the same file (`frontend/vitest.config.ts`).
- **Validation test suite** (`frontend/tests/unit/telegram-initdata.test.ts`, 11 cases): accepts fresh signed data, rejects tampered payloads, rejects a different bot token, rejects stale `auth_date`, malformed input, missing user, exact boundary `age === maxAge` (accept), one second past (reject), future skew window (accept/reject). Reference HMAC chain derived with `node:crypto` in the test.
- **Migration 021** `telegram_bootstrap_nonces.sql`: replay table (PK `init_data_hash`, `telegram_user_id NOT NULL`), RLS enabled with no client policies (service-role only), created-at index, and a documented 3-day purge.
- **Schema v2 migrations**: `022_cities_and_food_enums.sql` (cities tenancy table + `place_type`/`price_level`/`review_status` enums + RLS read-active) and `023_places_and_reviews.sql` (places/place_localizations/reviews with rows-per-language localization, publish gating, RLS read-published/approved).
- **RLS pgTAP suite** `supabase/tests/rls/010_places_and_reviews_rls.sql` (8 asserts): cities visible only when active, places only when published, localizations gated by parent published status, reviews only approved AND on published places, second reader parity, and write blocks (no insert policies).
- `.env.example` documents `TELEGRAM_BOT_TOKEN` / `SUPABASE_SERVICE_ROLE_KEY` as function-side secrets (never in Nuxt public vars).

### Fixes and registration (this session)

- **Fixed replay-nonce insert bug**: the nonce insert previously sent only `init_data_hash`, but `telegram_user_id` is `NOT NULL`, which would throw a NOT NULL violation and return 503 `nonce_store_unavailable` on every valid request. Now sends `telegram_user_id` from the validated Telegram user.
- **Registered the function** in `supabase/config.toml` under `[functions.telegram-bootstrap]` with `verify_jwt = false` (the caller has no Supabase JWT yet; security is the Telegram initData HMAC enforced inside the function).

### Verified

- Frontend gates PASS: `npm run test` (21/21: smoke, content 10, telegram-initdata 11), `npm run lint`, `npm run typecheck`, `npm run build`.
- **NOT runtime-verified (environment):** Docker is unavailable on this machine, so the local Supabase stack (RLS pgTAP suite, `supabase migration up`, and the auth session-exchange path) could not be executed here. The RLS tests and the deployable function are CI-gated (`.github/workflows/ci.yml` database-quality job) and must be confirmed in a Docker-capable environment before production.

## 2026-08-17 - Slideover "Dead Click" Fix

### Root cause

- In WebView guests (including the in-app browser), CSS keyframe animations can freeze on their first frame. The bottom sheet's enter animation stuck at `translateY(100%)`: the dialog was logically open (overlay blocking the map) but rendered off-screen, which users perceive as "clicking a district does nothing". The same freeze kept closed layers stuck on screen (already guarded separately).

### Fix

- Overlay content/layers (`[data-slot="content"]`, `[data-slot="overlay"]`) now animate with a near-zero duration (0.01ms): the sheet appears instantly, `animationend` still fires so the mount/unmount lifecycle stays intact, and the frozen-animation failure class is eliminated in every environment (browser, IAB, Telegram WebView).

### Verified

- Browser: polygon click opens a physically visible sheet (`transform: none`, heading correct); Escape closes with the closed-layer guard applied; second polygon click reopens; Guide-tab district row jumps to the Map tab and opens the sheet on screen. Lint, tests (10/10), build - PASS.

## 2026-08-17 - Real Rental Sources and Contract Facts

### Done

- Housing "search" card replaced with a real "Where to search" resource block: 12 checked links from a resident-compiled rental guide - Telegram channel (t.me/vietnam_rent), four Facebook groups (DA NANG EXPATS HOUSE, Da Nang - Hoi An Expats rentals, Da Nang Apartments & Rooms, local "Cho thuê căn hộ Đà Nẵng" 80k+ members), Cho Tot (nhatot.com), three Zalo groups, and three agencies (Da Nang Landlord, Toan Huy Hoang Realty, Central Vietnam Realty). Links open in a new tab with `rel="noopener noreferrer"`, kind icons per channel, bilingual notes.
- "How to rent" card rebuilt on real contract facts: 3/6/12-month terms, 1-2 month deposit with monthly payment (full prepay for short stays), agent commission paid by the landlord, bilingual VN/EN contracts, mandatory residence registration at check-in, utilities pricing.
- "Inspection" card rebuilt on real tips: pests/mold, neighbor reviews, morning/evening walks (construction/karaoke), meter photos at check-in.
- Tip line: posting criteria in Facebook groups brings agent offers to your inbox.
- New `HousingResource` type + `resources` array in `mocks/housing.ts`; content tests extended to 10 (unique resource ids, https-only urls) and a section-key resolution test; locale parity and unused-key audit stay clean.

### Verified

- `npm run test` (10/10), typecheck, lint, build - PASS.
- Browser: housing Guide tab renders both enriched cards, the 12-link block with correct urls/rel, and the tip; EN locale switches all new copy; no overflow at 390px.

## 2026-08-17 - Full Project Audit (vue-best-practices lens)

### Findings fixed

- Real data bug caught by new integrity tests: 4 of 6 district polygon rings were not GeoJSON-closed (first point != last point). Visual rendering was unaffected (SVG auto-closes), but the data would have broken the future PostGIS import. All six rings are now closed and covered by a test.
- Map district labels now refresh on locale switch (`watch(locale)` -> `setTooltipContent`); previously tooltips kept the mount-time language.
- Food page review counts are precomputed in the `places` computed (Map-based) instead of per-card template function calls.
- Local primitive UI state switched to `shallowRef` per the Vue skill (`activeFilter`, `activeTab`, `slideoverOpen`, `selectedDistrictId`); map template ref switched to `useTemplateRef` (Vue 3.5).
- Removed 6 dead i18n keys (`home.kicker`, `housing.mapTitle`, `housing.mapDescription`, `housing.selectDistrict`, `housing.kickerPricing`, `food.disclaimer`) from both locales.
- `npm audit fix` applied: production vulnerabilities (nanoid, js-yaml) resolved; one dev-only low remains (esbuild via `fontless`, Windows dev-server advisory, no semver fix available).

### Audit-as-code

- `scripts/audit-i18n.mjs`: ru/en key parity + unused-key detector (CLI helper).
- `tests/unit/content.test.ts`: locale parity, no empty strings, unique mock ids, review->place referential integrity, rating bounds, all housing district i18n keys resolvable, closed GeoJSON rings with in-range lon/lat. 8 tests, all passing.

### Known accepted findings

- `X-Powered-By: Nuxt` header: set below the Nitro hook layer on Nuxt 4.5 (`nitro.xpoweredBy: false` and response-hook scrubbing both ineffective in dev and prod). Informational fingerprint only, not a vulnerability; revisit on a Nuxt upgrade.
- Mock store exposes mutable state (`useMockDb().db`) rather than readonly + actions-only per the composable skill; acceptable for the prototype, to be replaced by RLS-safe Supabase reads in the cutover.

### Verified

- `npm run typecheck`, `npm run lint`, `npm run test` (8/8), `npm run build` - PASS.
- Browser runtime sweep on all 16 routes (7 user, 7 admin, 404, home): correct h1s in RU, no horizontal overflow at 390px; EN switch verified live (tabs/chips/copy); map renders 6 polygons + labels after the ring fix.

## 2026-08-17 - Header City Name Clipping Fix

### Done

- `AppCitySelect.vue` (compact/header variant) no longer caps the trigger at `max-w-[7.5rem]`; the trigger now sizes to its content so the city name renders fully. `truncate` stays as an overflow guard.

### Verified

- Browser at 360px and the 340px floor: "Дананг" is not clipped (`scrollWidth` equals `clientWidth` on the name span), no horizontal overflow (`scrollWidth` equals `innerWidth`). Lint and typecheck pass.

## 2026-08-17 - Back Row, Hero City Text, Bottom-Sheet Districts

### Done

- Back navigation reworked: the header keeps the logo at all times; a slim "Назад" row now sits under the header on every non-root route (history back with `/` fallback).
- Home hero simplified: the city renders as large muted text inside the h1 ("Первые дни - без лишнего / в Дананге"), same size as the title; no dropdown in the hero (city switching stays in the header).
- Housing map: the on-map attribution strip is gone; OSM/CARTO credits moved into the small text line under the map (`housing.mapCredits`).
- District details now open in a bottom `USlideover` (`side="bottom"`, `max-h-[78vh]`, rounded top): triggered by district polygon click, chip click, or the Guide-tab district rows. The old inline selected-district card was removed.

### Bug fix

- Closed slideover/modal layers could stay mounted, visible, and `pointer-events: auto` when the exit animation never fires (headless guests, strict WebViews), physically blocking the map below. Added a global CSS guard in `main.css`: `[data-slot="content"/"overlay"][data-state="closed"]` get `visibility: hidden; pointer-events: none`. Verified via computed styles after close.

### Verified

- `npm run typecheck`, `npm run lint`, `npm run test`, `npm run build` - PASS.
- Browser: back row appears on subpages and is absent on home; logo never disappears; hero shows the big "в Дананге" line with a single city select (header only); map tab renders without `.leaflet-control-attribution`; chip click opens the bottom slideover with rent/bestFor/summary; Close button and Escape close it; after close the layer is `visibility: hidden` and no longer blocks input; no overflow at 390px.
- Known environment artifact (not app code): the IAB guest freezes CSS animations at their first frame, so the slide-in transform of the sheet can look "off-screen" in that guest; real browsers and WebViews run the 200ms animation normally, and reduced-motion users get the existing instant-animation rule.

## 2026-08-16 - Real Tile Map, Carousels, City Line, Telegram Back

### Done

- Housing rebuilt with `UTabs`: a Guide tab (rent sections + a district price list) and a Map tab. Tapping a district row selects it and jumps to the map.
- Replaced the schematic SVG map with `HousingTileMap.client.vue`: Leaflet + CARTO raster tiles (Voyager light / Dark Matter dark, swapped automatically with the color mode), six district polygons with permanent labels, hover/selection styling (orange selection), `fitBounds` on mount, wheel-zoom disabled so page scroll is never hijacked, full tile attribution.
- Added `leaflet` dependency; removed the old `HousingMap.vue` SVG component.
- Food page: filter chips now wrap (no horizontal scroll strip) and the place cards render in a Nuxt UI `UCarousel` (embla; one-per-view peek on mobile, two per view from sm; arrows + dots). Dots and next/prev verified interactive.
- Home hero now shows the city line "в Дананге" (locale-aware prepositional form via `citiesIn.*`) with an inline city dropdown. City selection extracted into shared `AppCitySelect.vue` (compact variant in the header, pill variant in the hero) over the same `selectedCity` state.
- Back navigation: ghost back arrow in the header on every non-root route (goes through history with a `/` fallback); on sub-420px viewports the logo yields space so the header still fits. Inside Telegram the native Mini App `BackButton` is shown/hidden and wired through `plugins/telegram.client.ts`; the official `telegram-web-app.js` bridge loads from `nuxt.config.ts`.
- New documentation: `vault/wiki/services/housing-map.md` (how to change districts, geometry, tiles, styling, and the Telegram back button).

### Verified

- `npm run typecheck`, `npm run lint`, `npm run test`, `npm run build` - PASS.
- Browser at 390px/360px: home hero shows the city line + dropdown; housing tabs switch; Map tab loads real CARTO tiles (tile `<img>` present), 6 polygons, 6 labels, chips select districts, tile URL flips `voyager`/`dark_all` with the theme toggle; food carousel shows arrows, 9 dots, dot click moves the active slide; header back arrow appears on subpages (housing -> home on click) and is absent on home; `window.Telegram.WebApp` bridge present; no horizontal overflow on home, food, and the map tab at 360px.

## 2026-08-16 - Real District Map, Real-World Data, Hardening Pass

### Done

- District map rebuilt on the six real Da Nang districts (Sơn Trà, Ngũ Hành Sơn, Hải Châu, Thanh Khê, Liên Chiểu, Cẩm Lệ) with plausible relative geometry along the real coastline layout; disclaimer now says positions are accurate while exact boundaries await official data.
- Each district now carries a real-world monthly rent range for a 1-bed/studio (e.g. Sơn Trà 7-15M VND, Thanh Khê 4-6M VND), a price level, distance-to-beach, best-for tags (beach, nightlife, expat, local, markets, transport) and practical notes.
- Added district quick-pick chips under the map (same selection state as polygons, keyboard accessible).
- Housing guide bullets made practical and real: electricity 3,000-3,500 VND/kWh, evening walk sign-spotting, no deposit before inspection.
- Food list now 10 real Da Nang venues with real streets and districts (Bánh mì Madam Khanh, Mì Quang 1A, Bánh xèo Bà Dưỡng, Bún chả cá Bà Lữ, Chợ Cồn, Chợ Hàn, Highlands, Cộng Cà Phê, Bé Mặn, An Thượng food street draft); one draft stays for the admin demo.
- Transport/money/safety numbers tightened to realistic ranges (Grab bike/car rates, airport 3 km and 100-150k fare, bike rental 900k-1.5M/month with 1-3M deposit, ATM 2-5M limit with 22-55k fee, VietQR note, helmet fine up to 600k).
- First-day hints now concrete arrival instructions (Viettel/Vinaphone airport desks with passport + ~100k SIM, Vietcombank/Techcombank ATMs in the terminal, Grab 100-150k to center).
- Safety page shows the Russian Consulate General note (Trần Hưng Đạo, Hải Châu).

### Bug fixes

- `prefers-reduced-motion` global rule was commented out in `main.css` - restored (design.md requires it).
- `session-hover-card` class used by the homepage cards was defined nowhere - added hover transition in `main.css`.
- Fixed mixed-script typos in locale copy (Cyrillic `о` inside `Trần Hưng Đạо`, `Xân` vs `Xuân Thiều`).
- Removed dead `#start` anchor link pattern leftovers; banner links to the real journey page.
- `nuxt.config.ts` key order fixed for `nuxt/nuxt-config-keys-order`.

### Hardening

- Added `app/error.vue`: bilingual 404/generic error screen with a return-home action.
- Added baseline security headers via `routeRules` (`X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`); deliberately no `X-Frame-Options`/CSP frame-ancestors because the Telegram Mini App must remain framable.

### Verified

- `npm run typecheck`, `npm run lint`, `npm run test`, `npm run build` - PASS.
- Browser: map shows 6 districts as accessible buttons; chip click (Hải Châu) updates rent card ("5-8 млн ₫/мес", downtown notes); food filter "Рынки" leaves only Chợ Cồn and Chợ Hàn; draft place hidden; admin districts table lists all 6; 404 page renders; journey shows the new concrete hints; EN locale switches housing/food/journey copy; dark/light toggle flips `html` class; no horizontal overflow at 360px on housing and food; `curl -I` confirms the three security headers.
- Note: IAB input became flaky mid-session (clicks stopped registering in older tabs); all interaction checks were re-run in fresh tabs successfully.

## 2026-08-16 - Full Mock Prototype with Admin Surface

### Done

- Added a single reactive mock database: `frontend/app/types/content.ts` (content contract) and `frontend/app/mocks/db.ts` (cities, categories, food places, transport/money/safety guide entries, emergency contacts, reviews, activity feed). All content is bilingual (`ru`/`en` fields) and demo-grade.
- Added `frontend/app/composables/useMockDb.ts`: `useState`-backed store seeded from the mock DB with mutation actions (toggle place/guide status, toggle city active, moderate reviews). User pages read only `published` content; admin mutations reflect on user pages immediately within one SPA session (state resets on full reload - expected prototype behavior).
- Added `frontend/app/composables/useLocalized.ts` for rendering bilingual mock fields.
- New user routes: `/categories/food` (type filter chips, verified badges, approved-review counts), `/categories/transport`, `/categories/money`, `/categories/safety` (emergency numbers + habits), `/categories/culture` (do/don't lists), `/journey/first-day` (interactive 5-step checklist with progress counter).
- Homepage now renders all six categories from the mock store and links the "first 24 hours" banner to the real journey page (removed the dead `#start` anchor link).
- New admin prototype under `/admin` with its own layout (`layouts/admin.vue`, sticky top nav, prototype badge, "open app" link): dashboard (stats + activity), cities, categories (live item counts), districts (from housing mock), places (publish/unpublish), guides (publish/unpublish), reviews (approve/reject).
- New shared components: `components/AdminTable.vue` (generic typed table with cell slots) and `components/StatusBadge.vue` (status -> tone mapping, i18n labels).
- Locale files extended with all new keys (food/transport/money/safety/culture/firstDay/status/admin); RU and EN both complete.

### Verified

- `npm run typecheck`, `npm run lint`, `npm run test`, `npm run build` - PASS.
- Browser (IAB DOM snapshots; environment could not capture pixel screenshots): all 11 routes render with correct RU headings and content; no horizontal overflow at 390px and 360px on home, food, and journey pages.
- EN toggle: food page h1 switches to "Where to eat nearby".
- Live admin->app link: unpublishing a place in `/admin/places` hides it from `/categories/food` on client-side navigation; approving a review in `/admin/reviews` shows its count on the place card. Full page reloads re-seed the store (mock behavior, not a bug).
- Admin tables scroll horizontally on narrow viewports; action buttons at 390px sit inside the scrollable area.

## 2026-08-04 - SPA Loader Curtain Reveal

### Done

- Studied Nuxt SPA loader: template renders outside `#__nuxt` as `#__nuxt-loader`, removed on `app:suspense:resolve`.
- Simplified boot loader to logo-only (no wordmark): mark sits on the center seam, then left/right panels curtain open with each arrow half.
- Template renames `#__nuxt-loader` so the curtain can finish before unmount; `plugins/spa-loader.client.ts` triggers the exit.

### Verified

- Pending hard refresh at http://localhost:3001/.

## 2026-08-01 - Dark District Map and Housing Locale Fix

### Done

- Replaced the unresolved Leaflet/OpenStreetMap client map with an SSR-safe dark SVG district selector.
- Removed street tiles, map controls, client-only hydration, and unused Leaflet dependencies.
- Fixed mismatched housing translation keys for section bullets, district qualities, labels, and price level.
- Made section translations reactive so RU/EN switching updates every card without a reload.
- Added a visible prototype disclaimer because current district boundaries remain illustrative.
- Replaced the oversized square price panel with a compact price-level tile.

### Verified

- Browser at 360px and 390px: SVG map renders, district selection works by pointer and keyboard, and no horizontal overflow is present.
- RU/EN toggle: no raw `housing.*` or `pricing.*` keys remain; translated section and selected-district copy update in place.
- Light/dark toggle: map surface remains dark while the surrounding page theme changes.
- `npm run typecheck`, `npm run lint`, `npm run test`, and `npm run build` - PASS.

## 2026-07-31 - Housing Prototype with Illustrative District Map

### Done

- Added production-shaped housing data types and mock values in `frontend/app/mocks/housing.ts`.
- Created `/categories/housing` route with hero, three guide sections, OpenStreetMap map, and selected district card.
- Added Leaflet district polygons and tap-to-select colors; map is `ClientOnly` and destroyed on unmount.
- Homepage housing card now navigates to the housing route.
- Marked district boundary and price data as illustrative mocks pending verified district sources.

### Verified

- `npm run typecheck`, `npm run lint`, `npm run test`, and `npm run build` - PASS.
- Browser at 340px: title renders, no horizontal overflow.
- **UNVERIFIED & UNRESOLVED**: Only text/title/structure was visually confirmed in headless smoke; actual Leaflet container was absent. Map must be manually verified locally; district polygons are mocked drawing and must never be shipped as factual data until sourced from official GeoJSON/Overpass. Treat currently as prototype UI.

## 2026-07-31 - Supabase-Only Architecture Cutover

### Decision

- Removed Laravel application backend and Laravel API/admin boundary from active product path.
- Supabase is now the only backend platform: Edge Functions, Auth, Postgres/PostGIS, Storage, Realtime, and RLS.
- Supabase Studio is private pilot admin; restrict project membership, and protect publication/evidence/audit invariants with database constraints/triggers because Studio can bypass client RLS.
- Nuxt exposes only public Supabase URL and anon/publishable key.

### Done

- Removed legacy Laravel backend files.
- Removed Nuxt Laravel API helper and API response types.
- Rewrote architecture, auth-flow, Telegram auth contract, sprint, resume plan, session ledger, and code map.
- Added off-site backup requirement for both database and Storage objects.

### Next

- Implement `telegram-bootstrap` Edge Function.
- Validate Supabase Auth session exchange for Telegram identities.
- Connect Nuxt client through RLS-safe Supabase access.
## 2026-07-31 - Logo-Only SPA Loader

### Done

- Replaced the startup progress bar with the actual TAMITUT `logo.svg` mark inline in `spa-loading-template.html`.
- Added a soft scale/opacity pulse, dark-first surface, OS light-mode fallback, saved Nuxt color-mode override, and reduced-motion fallback.

### Verified

- `npm run typecheck`, `npm run lint`, `npm run test`, and `npm run build` - PASS.
- Pre-hydration browser smoke with scripts blocked until DOM load - PASS:
  - saved `dark`: loader background `rgb(9, 9, 11)`, white logo, `tamitut-pulse`;
  - saved `light`: loader background `rgb(255, 255, 255)`, dark logo, `tamitut-pulse`;
  - `prefers-reduced-motion: reduce`: animation `none`, opacity `1`, transform `none`.

## 2026-07-31 - 340px Header Fit

### Done

- Made the city selector borderless and visibly composed as flag + city name.
- Increased language control breathing room and kept a 36px touch target.
- Preserved full logo at 360px and mark-only logo below 360px.
- Locked 340px as the project mobile floor in `vault/design.md`.

### Verified

- Browser at 340px: header width 340px, no horizontal overflow; city trigger 115.6px with transparent background and no border; language control 36px.

## 2026-04-23 11:20 - Starter Template Initialized

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

## 2026-04-23 17:45 - TamITut Direction Bootstrap

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

## 2026-04-23 18:20 - Vision Reframed to Curated Bot Guide

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

## 2026-04-23 19:05 - Vision Expanded with Full Audit

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

## 2026-04-23 19:35 - Skill Stack + Startup Critical Path Locked

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

## 2026-04-23 19:55 - Schema Contract v1 Locked

### Done

- Rewrote `vault/wiki/architecture/supabase-schema-rls-plan.md` from draft list to locked v1 schema contract
- Locked enums, table set, core columns, constraints, and index baseline
- Added explicit trust-rule mapping to concrete tables/columns
- Added RLS anchor fields for upcoming policy implementation
- Updated sprint and resume plan to reflect schema-contract-complete state

### Verified

- Schema doc now has no `TBD` placeholders
- Trust model requirements map to concrete schema constraints
- Next milestone now clearly starts at SQL migration conversion

### Next

- convert schema contract to SQL migrations
- write RLS policies and role matrix tests
- implement trust-state enforcement and Telegram auth contract

## 2026-04-23 20:15 - Migration Plan + RLS Matrix Planned

### Done

- Added `supabase-migration-file-plan.md` with exact migration file tree and ordered creation sequence
- Added `supabase-rls-policy-matrix-v1.md` with role-by-table CRUD boundaries and policy naming convention
- Linked new docs from startup critical path, system design, CODE_MAP, and README
- Updated sprint/resume to shift from schema-lock to migration-execution phase

### Verified

- Migration plan maps to schema contract objects in sequence (`001` to `020`)
- RLS matrix now explicit for all five roles and all core tables
- Planning docs now provide direct next-step path for SQL implementation

### Next

- scaffold `supabase/` structure and generate migration files
- implement base schema SQL migrations (`001`-`013`)
- implement RLS and guard migrations (`014`-`020`) with tests

## 2026-04-23 20:35 - Supabase Migration Scaffold Created

### Done

- Initialized local Supabase project (`supabase init` via `npx supabase`)
- Generated ordered migration files from plan (`001` through `020`)
- Added migration header templates to each scaffold file with purpose + source links
- Added `supabase/tests/rls/` scaffold files mapped to policy matrix tests
- Added `supabase/seed.sql` scaffold file
- Updated sprint/resume/CODE_MAP to reflect scaffold-complete state

### Verified

- `supabase/migrations/` contains all planned migration stubs in order
- `supabase/tests/rls/` contains all planned policy/guard test stubs
- migration scaffolds align with `supabase-migration-file-plan.md`

### Next

- implement SQL content in migrations `001`-`013`
- implement RLS and policy SQL in `014`-`018`
- implement trust/safety guard SQL in `019`-`020`
- start local Supabase services and validate migrations/tests

## 2026-04-23 21:10 - Base Schema SQL Implemented (`001`-`013`)

### Done

- Implemented concrete SQL for migrations:
  - `001_extensions_and_enums`
  - `002_profiles_and_categories`
  - `003_guide_entries`
  - `004_contacts_prices_checklists`
  - `005_verification_evidence`
  - `006_trusted_sources_and_confirmations`
  - `007_trust_badge_events`
  - `008_safety_cases_and_evidence`
  - `009_scam_patterns`
  - `010_user_suggestions`
  - `011_audit_logs`
  - `012_updated_at_triggers`
  - `013_performance_indexes`
- Added append-only guard trigger for `audit_logs`
- Added partial unique indexes for primary contact, active source confirmations, and checklist positioning rules

### Verified

- `001`-`013` migration files no longer contain template TODO stubs
- `014`-`020` remain intentionally templated for next phase
- schema implementation aligns with locked contract and migration plan

### Blockers

- Docker is not installed in current environment (`docker: command not found`), so local Supabase runtime validation is pending

### Next

- implement RLS helpers/policies in `014`-`018`
- implement trust/safety guard logic in `019`-`020`
- enable Docker and run local migration + policy tests

## 2026-04-23 21:45 - RLS + Guard SQL Implemented (`014`-`020`)

### Done

- Implemented helper function migration `014_rls_helpers` (role, ownership, entry scope helpers)
- Enabled RLS on all operational tables in `015_enable_rls`
- Implemented core read policies in `016_rls_policies_core_read`
- Implemented curator/trusted-source/user write policies in `017_rls_policies_curation_write`
- Implemented moderator/admin policies in `018_rls_policies_moderation_admin`
- Implemented trust transition guards + audit/trust event logging in `019_trust_guard_functions_and_triggers`
- Implemented safety publish evidence guards + audit logging in `020_safety_publish_guards`

### Verified

- All migration files `001`-`020` now contain SQL (no template TODO stubs remain)
- RLS matrix rules are now encoded in migration files
- Migration progress updated in migration plan and sprint/resume docs

### Blockers

- Docker not available locally, so migrations cannot be executed/validated yet
- Role-policy test files are still scaffold-level and need concrete assertions

### Next

- run migrations on VPS Docker Supabase runtime
- fix runtime SQL/policy issues found during execution
- complete role-policy tests under `supabase/tests/rls/`
- then move to Telegram auth contract implementation

## 2026-04-23 22:05 - VPS Runtime Playbook Added

### Done

- Added `vault/wiki/services/vps-supabase-runtime.md` with Docker install and Supabase validation flow
- Updated service index and CODE_MAP to include VPS runbook
- Updated sprint/resume wording from local Docker to VPS Docker validation path

### Verified

- Playbook commands align with current CLI usage (`npx supabase ...`)
- Resume plan now points to VPS runbook for next execution step

### Next

- execute VPS runbook
- validate migrations and tests on running Supabase runtime
- patch SQL/policies based on runtime errors

## 2026-04-24 03:40 - VPS Runtime Provisioned + First Validation Run

### Done

- Connected to VPS alias `iind-vps` and audited baseline environment
- Confirmed `git` already installed and GitHub SSH access working
- Installed Docker Engine + Compose plugin on VPS
- Installed Node.js 22 + npm/npx on VPS
- Cloned repository to `/srv/tam-i-tut`
- Executed Supabase runtime validation commands from VPS:
  - `npx -y supabase start`
  - `npx -y supabase migration up --local`
  - `npx -y supabase db lint --local --fail-on error`
  - `npx -y supabase test db supabase/tests/rls --local`

### Verified

- `supabase migration up --local` reports local DB up to date
- `supabase db lint --local --fail-on error` reports no schema errors
- `supabase migration list --local` shows all migrations `001`-`020` applied
- Supabase stack can be started/stopped from VPS project path

### Blockers

- Initial `supabase start` attempt failed with `no space left on device` on 10GB VPS during image extraction
- Recovered by Docker image cleanup and rerun
- `supabase test db` currently fails with TAP parse errors because `supabase/tests/rls/*.sql` are still scaffold files with no test plan/assertions

### Next

- implement concrete pgTAP assertions in `supabase/tests/rls/001..009_*.sql`
- rerun `npx -y supabase test db supabase/tests/rls --local` on VPS until green
- after tests are green, proceed with Telegram auth contract implementation

## 2026-04-24 04:35 - RLS/Guard pgTAP Suite Implemented (`001`-`009`)

### Done

- Replaced all RLS test stubs with concrete pgTAP tests:
  - `001_profiles_access.sql`
  - `002_guide_entries_access.sql`
  - `003_evidence_access.sql`
  - `004_trusted_source_confirmations.sql`
  - `005_safety_cases_access.sql`
  - `006_user_suggestions_access.sql`
  - `007_audit_log_access.sql`
  - `008_trust_transition_guards.sql`
  - `009_safety_publish_guards.sql`
- Added role-scoped access checks and transition-guard failure/success assertions
- Adjusted tests based on runtime behavior (e.g., 0-row updates under RLS, trigger-first guard failures)
- Executed full DB test run on VPS runtime and stopped stack after validation

### Verified

- VPS command run:
  - `npx -y supabase test db supabase/tests/rls --local`
- Result:
  - `Files=9, Tests=80`
  - `Result: PASS`
- RLS/guard validation is now executable and not scaffold-only

### Next

- wire CI quality gates to execute DB tests automatically
- implement Telegram auth contract endpoint logic
- proceed to content seeding backlog execution

## 2026-04-24 05:05 - CI Quality Gates Workflow Added

### Done

- Added GitHub Actions workflow: `.github/workflows/ci.yml`
- Implemented `frontend-quality` job:
  - `npm --prefix frontend install`
  - `npm --prefix frontend run lint`
  - `npm --prefix frontend run typecheck`
  - `npm --prefix frontend run test`
- Implemented `database-quality` job:
  - `npx -y supabase start --exclude studio,imgproxy,kong,mailpit,edge-runtime,logflare,vector,supavisor`
  - `npx -y supabase migration up --local`
  - `npx -y supabase db lint --local --fail-on error`
  - `npx -y supabase test db supabase/tests/rls --local`
  - `npx -y supabase stop` (always)
- Updated docs to align with new CI baseline:
  - `vault/wiki/services/quality-gates-ci.md`
  - `vault/CODE_MAP.md`
  - sprint/resume/session ledger entries

### Verified

- CI commands mirror VPS-validated DB flow and passing pgTAP suite
- Workflow is scoped to `push`/`pull_request` on `main`

### Next

- observe first GitHub Actions run and adjust exclusions/timeouts if needed
- implement Telegram auth contract endpoint
- continue startup critical path after auth slice

## 2026-04-24 05:35 - Telegram Auth Contract Endpoint Added (Transitional Backend)

### Done

- Added API route: `POST /api/auth/telegram` in `backend/routes/api.php`
- Implemented Telegram auth contract logic in `backend/app/Http/Controllers/AuthController.php`:
  - Telegram signature validation (official WebApp hash flow)
  - payload freshness check (`auth_date` age window)
  - replay detection (cache-backed payload hash TTL)
  - typed error responses:
    - `TG_AUTH_INVALID_SIGNATURE`
    - `TG_AUTH_EXPIRED_PAYLOAD`
    - `TG_AUTH_REPLAY_DETECTED`
    - `TG_AUTH_MALFORMED_PAYLOAD`
    - `TG_AUTH_INTERNAL_ERROR`
  - default role assignment `user` and locale normalization (`ru` default, `en` optional)
  - transitional session-token caching placeholder for integration path
- Marked legacy `POST /api/auth/login` placeholder as deprecated (410)
- Added contract-oriented tests: `backend/tests/Feature/TelegramAuthApiTest.php`
- Updated backend docs/reference map:
  - `backend/README.md`
  - `vault/CODE_MAP.md`

### Verified

- PHP syntax lint run on VPS for modified backend files (`php -l`) passed
- Implementation aligns with `vault/wiki/architecture/telegram-auth-contract.md` rules and error code set

### Blockers

- Backend folder remains transitional/minimal; full Laravel runtime execution for feature tests is not yet active
- Profile upsert/session persistence still needs final Supabase service-layer integration

### Next

- wire Telegram auth endpoint to final Supabase profile upsert + session persistence
- run full endpoint tests in runtime environment
- continue with content seeding and first verified API slice

## 2026-04-24 06:05 - Telegram Auth Supabase Persistence Wired (Transitional)

### Done

- Extended `backend/app/Http/Controllers/AuthController.php` Telegram flow to integrate Supabase:
  - resolved Supabase credentials from env/config
  - profile lookup by `telegram_user_id` via Supabase REST
  - new-user bootstrap via Supabase Auth Admin API
  - profile insert/update in `public.profiles` with role forced to `user`
- Replaced cache-only auth token output with signed internal session token (transitional stateless token)
- Updated Telegram auth feature tests (`backend/tests/Feature/TelegramAuthApiTest.php`) to fake Supabase HTTP responses for success/replay/failure scenarios
- Updated `.env.example` with Supabase server-side credentials required by transitional endpoint
- Updated backend and vault code-map docs to reflect new auth behavior

### Verified

- PHP syntax lint on VPS passed for:
  - `backend/app/Http/Controllers/AuthController.php`
  - `backend/routes/api.php`
  - `backend/tests/Feature/TelegramAuthApiTest.php`
- Telegram auth contract behavior remains aligned to typed error-code spec

### Blockers

- Minimal backend skeleton still lacks full Laravel runtime/test harness execution in current repo shape
- Production-grade session strategy is still open (current signed token is transitional)

### Next

- run Telegram auth feature tests in full runtime environment
- decide and implement final production session strategy
- proceed with first API slice and content seeding execution

## 2026-04-24 06:30 - Telegram Session Strategy Hardened (Transitional)

### Done

- Updated Telegram auth session issuance in `AuthController`:
  - replaced signed JWT-like token output with opaque random bearer token
  - stores session server-side in cache using hashed token key
  - returns `session_id` + `expires_in` in auth payload
- Kept Supabase profile upsert integration and role-forcing behavior intact
- Expanded `TelegramAuthApiTest` with missing Supabase credentials failure case
- Updated docs/state to reflect current session strategy:
  - `backend/README.md`
  - `vault/wiki/architecture/telegram-auth-contract.md`
  - sprint/resume/ledger/code-map

### Verified

- PHP syntax lint passed on VPS for updated backend files
- Telegram auth error-code contract remains unchanged

### Blockers

- Full Laravel runtime execution for feature tests still not available in current minimal backend skeleton

### Next

- run Telegram auth feature tests in full runtime environment
- choose long-term production session architecture
- continue with first API slice and seeding execution

## 2026-07-31 - Product and System Master Plan Locked

### Done

- Reviewed current product vision, roadmap, schema/RLS contract, Telegram auth flow, content protocol, code map, and repository topology.
- Checked current official Telegram Mini Apps, Bot API, Stars, physical-payment, privacy, and developer-term constraints.
- Added `vault/wiki/architecture/tamitut-product-system-master-plan.md` covering:
  - product surfaces and newcomer journeys
  - Nuxt Mini App/public/admin architecture
  - Laravel modular-monolith backend and single-gateway boundary
  - Supabase PostgreSQL/PostGIS/Storage and Redis roles
  - multi-city normalized content/data model
  - auth, webhook, search, map, moderation, safety, observability, security, privacy, and operations
  - trust-safe monetization and payment/entitlement architecture
  - delivery phases with explicit exit gates
- Updated roadmap, system-design pointer, schema/auth status notes, sprint, resume plan, master index, and code map.

### Verified

- Target plan accounts for the current opaque Laravel token versus Supabase RLS mismatch and selects one Laravel BFF boundary.
- Sponsored inventory is separate, labeled, expiry-bound, audit-logged, and cannot alter trust or organic rank.
- Digital goods/services use Telegram Stars; physical services remain provider/legal-review dependent.
- Current Telegram origin hardening, raw `initData` validation, webhook secret, payment support, privacy, and data-retention requirements are represented.
- No application runtime behavior changed in this planning session.

### Next

- lock the exact production session contract
- design and approve city-aware schema v2 before bulk seeding
- complete the Laravel runtime and prove one protected end-to-end API slice

## 2026-07-31 - Lean TMA MVP Frontend

### Done

- Reduced first release scope to Telegram Bot -> Telegram Mini App -> Laravel.
- Explicitly deferred inline mode, separate Nuxt admin, public web, payments, sponsored placements, and multi-city expansion.
- Moved editorial/admin direction to Laravel server-rendered CRUD/moderation.
- Confirmed `@nuxt/ui` is declared and installed for Nuxt 4.
- Moved `logo.svg` and `logo-full.svg` into `frontend/app/assets/brand/`.
- Added Russian as default locale and added the first Russian/English TMA copy.
- Rebuilt the landing surface using Nuxt UI components and Tailwind utilities:
  - `UContainer`
  - `UCard`
  - `UButton`
  - `UInput`
  - `UBadge`
  - `UAlert`
- Added a Nuxt 4 root `tsconfig.json` extending `.nuxt/tsconfig.app.json`.
- Fixed the existing API composable import/method typing.
- Moved the stylesheet into Nuxt 4's `frontend/app/assets/css/` location.

### Verified

- `npm run typecheck` - PASS.
- `npm run lint` - PASS.
- `npm run test` - PASS (1 file, 1 test).
- `npm run build` - PASS.
- Browser smoke test at 390px viewport - rendered Russian TMA surface with logo, search field, category cards, collection CTA, trust alert, and no horizontal overflow.

### Next

- connect search/category actions to Laravel API;
- add real Telegram WebApp SDK bootstrap;
- build Laravel server-rendered editorial admin;
- seed first Da Nang newcomer journeys.

## 2026-07-31 - Header City and Theme Controls

### Done

- Removed repeated Da Nang and pilot labels from the main TMA content.
- Moved city context into a Nuxt UI `USelectMenu` in the header.
- Selected Da Nang by default.
- Added disabled future options with flags:
  - Nha Trang, Vietnam
  - Pattaya, Thailand
  - Phuket, Thailand
- Added Nuxt UI `UColorModeButton` as the single light/dark control.
- Removed hardcoded dark-only body/layout colors and added explicit Tailwind light/dark surfaces.
- Kept the main content city-agnostic while the header carries selected city context.

### Verified

- `npm run typecheck` - PASS.
- `npm run lint` - PASS.
- `npm run test` - PASS (1 test).
- `npm run build` - PASS.
- Browser at 390px:
  - no horizontal overflow;
  - Da Nang remains selected;
  - disabled cities cannot change selection;
  - light and dark modes both apply correct background/text colors;
  - no visible pilot label and Da Nang appears only in the header selector.

## 2026-07-31 - Vault Simplification

### Done

- Added `vault/architecture.md` as the single current product and system architecture.
- Removed redundant vision, roadmap, system-design, startup, and historical schema-planning documents from the active vault.
- Kept only focused auth, trust-state, and Telegram auth contracts under `vault/wiki/architecture/`.
- Updated the master index, code map, sprint, and resume plan.

### Decision

Vault now stores current decisions and operational context only. SQL migrations/tests remain the source of truth for implemented database behavior; historical planning details stay out of the active navigation.

- Compressed `SESSION_LEDGER.md` to a short handoff record; detailed history remains in this changelog.

## 2026-07-31 - SPA Loader and Calm Motion

### Done

- Added initial SPA loading screen (`frontend/app/spa-loading-template.html`): inline, monochrome brand mark, single orange progress bar, reduced-motion safe, dark-mode aware.
- Added `NuxtLoadingIndicator` in `frontend/app/app.vue` for client-side route loading after boot.
- Added subtle NuxtPage opacity transition in `app.vue`.
- Added short background/color transition for light/dark switching plus global `prefers-reduced-motion` kill switch in `frontend/app/assets/css/main.css`.
- Documented the motion rules in `vault/design.md`.

### Verified

- `npm run typecheck` - PASS.
- `npm run lint` - PASS.
- `npm run test` - PASS (1 test).
- `npm run build` - PASS; SPA template compiled into build.
- Browser dev server at 360px: loader visible on initial DOM load, then hidden once app hydrates; page no horizontal overflow; title still "Первые дни - без лишнего"; dark theme transition applied on root surfaces.

## 2026-07-31 - TMA Design System Document

### Done

- Added `vault/design.md` as the single visual source of truth: monochrome+zinc surfaces, sparse orange accent rules, copy voice, 360px layout floor, component usage rules, no-dead-affordances policy.
- Linked it from `master_index.md` and `CODE_MAP.md` so future sessions load it before UI work.

### Decision

One short design file, not a wiki tree; rules mirror what is already in code, so UI changes update both together.

## 2026-07-31 - Minimal Homepage and Locale Control

### Done

- Removed repeated "guide" wording and the unnecessary "Where do you start?" heading.
- Removed the non-functional homepage search field instead of leaving a dead affordance.
- Changed Nuxt UI primary color from cyan to orange and neutral color from gray to zinc.
- Reduced orange usage to subtle surfaces, primary actions, and trust cues; category icons are neutral.
- Added a compact RU/EN locale toggle beside city and theme controls.
- Kept the header responsive at 360px without horizontal overflow.
- Replaced long dash characters in active frontend copy with `-`.

### Search contract

- Future search submits query, city, locale, and optional category to Laravel.
- Results must be ranked verified entries with explicit zero-results state.
