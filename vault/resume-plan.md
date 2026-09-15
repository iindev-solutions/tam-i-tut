# Resume Plan

## Stop Point

- Trust layer shipped end-to-end. Migrations 058 (emergency_contacts + places trust cutover) and 059 (Da Nang numbers) applied to hosted; prod deployed (worker 198dae93). `TrustBadge.vue` shows level + check date on every guide card, food card, place detail and the admin places table; the admin editor sets the level instead of a checkbox. `places.verified` is gone, replaced by `trust_badge` + `last_verified_at` with a CHECK that a trusted row carries its date.
- Safety page now renders real emergency numbers (city-scoped table, RLS: reader sees active cities only). Previously the block was empty for every live user, because the numbers lived only in the dev-only mock.
- Fixed two production-facing defects found on the way: the layout's mock banner headed the `v-if` chain and dropped `<main>` in mock mode (dev pages rendered the banner and nothing else); and a signed-in user with a failing read was shown the "open from the bot" gate instead of a retry. `useDb` also collapsed its per-caller 7-table reads into one in-flight promise.
- Evidence: pgTAP 016 PASS 10/10 + suites 010/011/014/015 re-run PASS on hosted; reader-contract probe returns cities 4 / categories 8 / places 29 / localizations 58 / guide_entries 48 / emergency_contacts 3; gates lint+typecheck+53 tests+build green; browser 360px RU+EN verified; prod bundle re-checked through `wrangler dev` for both the bot gate and the retry path.

- Late addendum: prod demo data root-caused and fixed - the build-stamp patch had introduced a duplicate `runtimeConfig` key that wiped the Supabase config from every build since 2026-08-31 (also the real cause of the "missing medicine guides" report). Config merged, `.env` renamed to `NUXT_PUBLIC_*`, prod build now fails loudly without the URL; redeployed and verified the URL is in the prod payload.

- 2026-09-07: bootstrap replay flake fixed (identical initData re-opens no longer 409; nonce is now a dedupe record, HMAC+freshness stay the guards) and the function redeployed; client skips bootstrap when a stored session refreshes. Founder must re-open the mini app twice to confirm live.

- 2026-09-07 (audit fixes): deploy.yml rewritten (build + migrations + functions, self-skipping on missing secrets), menu section titles stored/rendered (051), approved reviews shown on place pages, prod fallback is the bot-gate screen (mocks are dev-only), bootstrap failures logged to app_events, UI-map tests derived from mocks. Founder: add repo secrets CLOUDFLARE_API_TOKEN + SUPABASE_ACCESS_TOKEN to activate CI deploy.

## Next Step

1. founder: live Telegram walk-through - confirm the session exchange (5.5) and, with a session, that every guide card reads "На проверке" (all 48 published guides are still `under_review`), the safety page shows 113/114/115, and a place page shows its badge + date
2. founder: pending repo secrets (`CLOUDFLARE_API_TOKEN`, `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_URL` + R2), Telegram bot token rotation, `iind-vps` host key
3. Verification decision: promote guides/places out of `under_review` as they get checked (the admin places editor can set the level + date; guides still need the authoring form below)
4. Closed pilot with metrics: metric set from `app_events` after the first pilot week
5. Backlog: guide authoring form (incl. a per-guide "mark verified" action), city search, food category page for menu-decoder/drinks guides, freshness SLA in user UI, R2 restore drill, offline phrase pack / venue QR deep link (Phase C)
