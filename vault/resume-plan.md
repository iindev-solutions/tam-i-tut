# Resume Plan

## Stop Point

- **Fixed a live regression that made the app render empty** (no city control, no category cards, no gate, no error) for any returning user with a session already in storage. Cause: `read()` mapped via `remapFromRaw()` BEFORE setting `source = 'supabase'`, and that function early-returns unless `source === 'supabase'` - so the first read always mapped nothing. It had only worked because 11 components each called `useDb()` and a second concurrent instance finished after the flag flipped; this session's in-flight dedupe removed that race, making the empty state deterministic. `remapFromRaw()` is now guarded by `raw` alone, and `raw` is cleared whenever the data is not Supabase data.
- **The authenticated path is now actually verified.** Every earlier check this session used a build with NO session (dev = mock, prod = bot gate), which is precisely why the regression shipped. A real JWT (Admin API user + password grant) now drives the real prod bundle in a browser: home shows `Дананг` + 8 category cards, safety shows 113/114/115, food shows real venues, guides show `На проверке`, the place page shows `Проверено командой · 18.08.2026`.
- Trust badge on `under_review` entries no longer shows a date: `last_verified_at` is also stamped on under-review rows, and "На проверке · 18.08.2026" reads as "checked on 18.08". Dates render only for trusted levels, per `design.md`.
- Trust layer end-to-end (earlier this session): migrations 058/059 on hosted, `TrustBadge.vue` on every guide/place surface, city-scoped emergency contacts, honest `error` state instead of the bot gate for a signed-in user.
- Evidence: pgTAP 016 PASS 10/10 + 010/011/014/015 re-run PASS on hosted; reader-contract probe (cities 4 / categories 8 / places 29 / localizations 58 / guide_entries 48 / emergency_contacts 3); gates lint+typecheck+53 tests+build; all 76 JS assets of the deployed worker match the built output byte for byte (worker `643244ae`).

- Late addendum: prod demo data root-caused and fixed - the build-stamp patch had introduced a duplicate `runtimeConfig` key that wiped the Supabase config from every build since 2026-08-31 (also the real cause of the "missing medicine guides" report). Config merged, `.env` renamed to `NUXT_PUBLIC_*`, prod build now fails loudly without the URL; redeployed and verified the URL is in the prod payload.

- 2026-09-07: bootstrap replay flake fixed (identical initData re-opens no longer 409; nonce is now a dedupe record, HMAC+freshness stay the guards) and the function redeployed; client skips bootstrap when a stored session refreshes. Founder must re-open the mini app twice to confirm live.

- 2026-09-07 (audit fixes): deploy.yml rewritten (build + migrations + functions, self-skipping on missing secrets), menu section titles stored/rendered (051), approved reviews shown on place pages, prod fallback is the bot-gate screen (mocks are dev-only), bootstrap failures logged to app_events, UI-map tests derived from mocks. Founder: add repo secrets CLOUDFLARE_API_TOKEN + SUPABASE_ACCESS_TOKEN to activate CI deploy.

## Next Step

1. founder: open the failing CI run (Actions run 34950737645) or hand over a token with repo access - the frontend job dies at `npm --prefix frontend install` and the database job at `supabase start`, neither reproducible from the committed tree, and job logs are unreadable without one. Until then Deploy dies at install too, so **all deploys are manual** (`wrangler deploy` from `frontend/`)
2. founder: live Telegram walk-through - confirm the session exchange (5.5) and, with a session, that every guide card reads "На проверке" (all 48 published guides are still `under_review`), the safety page shows 113/114/115, and a place page shows its badge + date
3. founder: pending repo secrets (`CLOUDFLARE_API_TOKEN`, `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_URL` + R2), Telegram bot token rotation, `iind-vps` host key
4. Verification decision: promote guides/places out of `under_review` as they get checked (the admin places editor can set the level + date; guides still need the authoring form below)
5. Closed pilot with metrics: metric set from `app_events` after the first pilot week
6. Backlog: guide authoring form (incl. a per-guide "mark verified" action), city search, food category page for menu-decoder/drinks guides, freshness SLA in user UI, R2 restore drill, offline phrase pack / venue QR deep link (Phase C)

## Known inconsistency to fix BEFORE activating a second city

City scoping is applied unevenly, and it is invisible today only because Da Nang is the sole city with content:

- **Gated on active city (correct):** `districts` / `district_localizations` (RLS `exists ... c.is_active`, 024) and `emergency_contacts` (same pattern, 058) plus a client-side filter by `selectedCity` (`safety.vue:15`).
- **Not gated at all (latent bug):** `places` / `place_localizations` / `reviews` / `guide_entries`. `places__authenticated__select_published` checks only `is_authenticated() and status = 'published'` (023) - no city condition - and `useDb` selects `city_slug` on places but never filters by it, while `mapPlaces` maps every published row it receives. `selectedCity` currently reaches only the header selector, the home hero line and the safety contacts.
- **Failure mode:** publishing any place in a second city (even one still marked inactive) puts it straight into the Da Nang food list, and the same applies to guides, while the contacts block stays correctly per-city. `cities` itself is readable for all rows by design (039, so the selector can show disabled future cities).
- **Fix when needed:** add the active-city condition to the places/guides/reviews read policies, and either filter the queries by `city_slug` or filter client-side in `db-mappers` off the selected city. Do it as one slice with a pgTAP case publishing a row in an inactive city and asserting it stays invisible.

## Verification of prod/git parity (2026-09-15)

After the final deploy (worker `59dc53f2`, buildTime `2026-09-15T09:21:33Z`) every JS asset of the local build was compared byte-for-byte against the live worker: **76 assets, 0 differ, 0 missing**. Prod serves exactly the committed tree (`475745d`).
