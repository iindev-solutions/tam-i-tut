# Resume Plan

## Stop Point

- **Fixed a live regression that made the app render empty** (no city control, no category cards, no gate, no error) for any returning user with a session already in storage. Cause: `read()` mapped via `remapFromRaw()` BEFORE setting `source = 'supabase'`, and that function early-returns unless `source === 'supabase'` - so the first read always mapped nothing. It had only worked because 11 components each called `useDb()` and a second concurrent instance finished after the flag flipped; this session's in-flight dedupe removed that race, making the empty state deterministic. `remapFromRaw()` is now guarded by `raw` alone, and `raw` is cleared whenever the data is not Supabase data.
- **The authenticated path is now actually verified.** Every earlier check this session used a build with NO session (dev = mock, prod = bot gate), which is precisely why the regression shipped. A real JWT (Admin API user + password grant) now drives the real prod bundle in a browser: home shows `Дананг` + 8 category cards, safety shows 113/114/115, food shows real venues, guides show `На проверке`, the place page shows `Проверено командой · 18.08.2026`.
- Trust badge on `under_review` entries no longer shows a date: `last_verified_at` is also stamped on under-review rows, and "На проверке · 18.08.2026" reads as "checked on 18.08". Dates render only for trusted levels, per `design.md`.
- Trust layer end-to-end (earlier this session): migrations 058/059 on hosted, `TrustBadge.vue` on every guide/place surface, city-scoped emergency contacts, honest `error` state instead of the bot gate for a signed-in user.
- Review pass (2026-09-15 (5)): removed an outage risk I had just introduced (adding `clinics` to the strict read group meant one failing table blanked the whole app - now only `cities`/`categories` are strict, every other table degrades to an empty section and logs - PROVEN by A/B on a local build: same bogus column gave 0 cards + error screen under the strict loop vs 8 cards and only the clinics section lost under degradation); moved consular facts out of i18n into a `consulates` table so an admin can correct them (the wrong address had been unfixable); fixed a false provenance claim in the clinics subtitle; and corrected a pgTAP assertion that assumed an RLS-denied UPDATE throws (it silently affects 0 rows).
- Evidence: pgTAP 016 PASS 10/10 + 010/011/014/015 re-run PASS on hosted; reader-contract probe (cities 4 / categories 8 / places 29 / localizations 58 / guide_entries 48 / emergency_contacts 3); gates lint+typecheck+53 tests+build; all 76 JS assets of the deployed worker match the built output byte for byte (worker `643244ae`).

- Late addendum: prod demo data root-caused and fixed - the build-stamp patch had introduced a duplicate `runtimeConfig` key that wiped the Supabase config from every build since 2026-08-31 (also the real cause of the "missing medicine guides" report). Config merged, `.env` renamed to `NUXT_PUBLIC_*`, prod build now fails loudly without the URL; redeployed and verified the URL is in the prod payload.

- 2026-09-07: bootstrap replay flake fixed (identical initData re-opens no longer 409; nonce is now a dedupe record, HMAC+freshness stay the guards) and the function redeployed; client skips bootstrap when a stored session refreshes. Founder must re-open the mini app twice to confirm live.

- 2026-09-07 (audit fixes): deploy.yml rewritten (build + migrations + functions, self-skipping on missing secrets), menu section titles stored/rendered (051), approved reviews shown on place pages, prod fallback is the bot-gate screen (mocks are dev-only), UI-map tests derived from mocks. Founder: add repo secrets CLOUDFLARE_API_TOKEN + SUPABASE_ACCESS_TOKEN to activate CI deploy.
  - The same commit (0c9d772) added server-side bootstrap observability: `logEvent()` in `supabase/functions/telegram-bootstrap/index.ts:92-108` posts `bootstrap_error` (with the failure reason and client IP) to `app_events` via the service role on every validation failure. Zero `bootstrap_error` rows in the table therefore means NO validation failure ever occurred - which independently confirms task 5.5.
  - Scope note (2026-09-15): logging covers SERVER-side validation failures only. The plugin's client-side failure states (`no_init_data`, `bad_payload`, `set_session_failed`, `network`, raw HTTP status - `app/plugins/telegram.client.ts:104-138`) are written to a UI variable and then discarded, so a failure before/around the request leaves no trace. That gap is a backlog item, not a documentation error.

## Content gaps vs vietnamspot.ru (researched 2026-09-15; needs field verification)

Ranked by value for a newcomer. The project's trust rule is evidence-before-
publication, so imported rows land as `under_review` with a visible source
rather than as trusted content.

1. ~~**Da Nang hospital directory with prices**~~ - SHIPPED 2026-09-15 (4) as
   migration 061 + `/categories/health`: 20 venues, 8 specialisations, prices,
   24/7 flags, all `under_review` with the source printed above the list.
   **Still open:** the rows are read-only in the UI (no `/admin` editor yet - the
   same gap now applies to `consulates`) and
   no price has been verified on site. Verification path: Family Medical
   Practice (0236 358 2699) and Vinmec are independently corroborated as
   venues; the rest need a visit or a call. The source's headline claim - a
   medical translator gets local-resident pricing (165 000 ₫ vs 350 000 ₫ at
   Thiện Nhân) - is a business insight worth understanding, not copying.
2. **Crisis algorithms** - numbered steps for road accident, lost/stolen
   passport, calling an ambulance, fraud, visa overstay, food poisoning, lost
   phone, typhoon. We have scam guides (`safety-scam-*`) but no step-by-step
   incident runbooks. Our `safety-numbers` guide already covers "numbers in
   advance"; this extends the same idea into procedures.
3. **Show-on-screen phrase mode** - Vietnamese phrases + Cyrillic
   transliteration, full-screen for showing a stranger. Highest UX value per
   unit of work for a phone-only Mini App; fits the existing TMA back-button
   and slide-over patterns.
4. **Insurance guidance** - coverage floors and the motorbike clause; an
   independent source corroborates that the motorbike clause is what catches
   people out. We have a `health-insurance` guide; check it covers the clause.
5. **Pharmacy chains** - we have `health-pharmacies` (Pharmacity, FPT Long
   Chau); worth cross-checking the "what is sold without a prescription" angle.

Also worth noting for strategy: their model is free guide -> paid services
(Fast Track, visa, transfers, translator) -> partner catalogue with discounts.
Our architecture defers monetization until after repeat usage, so this is a
signal about what users actually pay for, not a model to copy now.

## Next Step

1. founder: open the failing CI run (Actions run 34950737645) or hand over a token with repo access - the frontend job dies at `npm --prefix frontend install` and the database job at `supabase start`, neither reproducible from the committed tree, and job logs are unreadable without one. Until then Deploy dies at install too, so **all deploys are manual** (`wrangler deploy` from `frontend/`)
2. founder: confirm the trust surfaces visually in Telegram - guide cards should read "На проверке" (all 48 published guides are still `under_review`), safety shows 113/114/115, and a place page shows `Проверено командой · <date>`. Session exchange (5.5) is now DONE - the empty-app report itself proved it, since the bot gate would otherwise have been shown
3. founder: pending repo secrets (`CLOUDFLARE_API_TOKEN`, `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_URL` + R2), Telegram bot token rotation, `iind-vps` host key
4. Verification decision: promote guides/places out of `under_review` as they get checked (the admin places editor can set the level + date; guides still need the authoring form)
5. Closed pilot with metrics: metric set from `app_events` after the first pilot week. Server-side bootstrap failures ARE already logged (`bootstrap_error`, reason + IP); the client-side states are not - see next item
6. Backlog: **client-side session telemetry** (the plugin's `bootstrapError` states - `no_init_data`, `bad_payload`, `set_session_failed`, `network` - and read failures are discarded today, so a failure that never reaches the Edge Function leaves no trace), guide authoring form (incl. a per-guide "mark verified" action), city search, food category page for menu-decoder/drinks guides, freshness SLA in user UI, R2 restore drill, offline phrase pack / venue QR deep link (Phase C)
7. Backlog (process): never hand-write `auth.users` rows on the live project - GoTrue scans its token columns into non-nullable Go strings, so a partial row breaks EVERY auth query, including `telegram-bootstrap`'s user creation. Create users through the Admin API instead

## Known inconsistency to fix BEFORE activating a second city

City scoping is applied unevenly, and it is invisible today only because Da Nang is the sole city with content:

- **Gated on active city (correct):** `districts` / `district_localizations` (RLS `exists ... c.is_active`, 024) and `emergency_contacts` (same pattern, 058) plus a client-side filter by `selectedCity` (`safety.vue:15`).
- **Not gated at all (latent bug):** `places` / `place_localizations` / `reviews` / `guide_entries`. `places__authenticated__select_published` checks only `is_authenticated() and status = 'published'` (023) - no city condition - and `useDb` selects `city_slug` on places but never filters by it, while `mapPlaces` maps every published row it receives. `selectedCity` currently reaches only the header selector, the home hero line and the safety contacts.
- **Failure mode:** publishing any place in a second city (even one still marked inactive) puts it straight into the Da Nang food list, and the same applies to guides, while the contacts block stays correctly per-city. `cities` itself is readable for all rows by design (039, so the selector can show disabled future cities).
- **Fix when needed:** add the active-city condition to the places/guides/reviews read policies, and either filter the queries by `city_slug` or filter client-side in `db-mappers` off the selected city. Do it as one slice with a pgTAP case publishing a row in an inactive city and asserting it stays invisible.

## Verification of prod/git parity (2026-09-15)

After the final deploy (worker `59dc53f2`, buildTime `2026-09-15T09:21:33Z`) every JS asset of the local build was compared byte-for-byte against the live worker: **76 assets, 0 differ, 0 missing**. Prod serves exactly the committed tree (`475745d`).
