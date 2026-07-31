# Resume Plan

## Stop Point

- Project skill stack installed and locked for this repo (`skills-lock.json`).
- Architecture is consolidated in `vault/architecture.md`; detailed auth/trust contracts remain in `vault/wiki/architecture/`.
- Historical schema/RLS planning documents were removed from the active vault; SQL migrations and tests remain the implementation baseline.
- `supabase/` scaffold created with ordered migration stubs (`001`–`020`) and RLS test stubs.
- Base schema migrations `001`–`013` now contain concrete SQL from locked schema contract.
- RLS/policy migrations `014`–`018` now contain concrete SQL.
- Trust/safety guard migrations `019`–`020` now contain concrete SQL.
- VPS runtime is prepared: Docker + Node.js installed, repo cloned at `/srv/tam-i-tut`.
- Supabase runtime validation executed on VPS:
  - `npx supabase start` succeeded (after disk cleanup)
  - `npx supabase migration up --local` → up to date
  - `npx supabase db lint --local --fail-on error` → no schema errors
  - `npx supabase test db supabase/tests/rls --local` → PASS (80 tests)
- `supabase/tests/rls/001..009_*.sql` now contain concrete pgTAP assertions for RLS and guard behaviors.
- CI baseline is wired in `.github/workflows/ci.yml` for frontend and Supabase DB quality gates.
- Transitional Telegram auth endpoint implemented in backend (`POST /api/auth/telegram`) with:
  - Telegram signature validation
  - payload age check
  - replay detection via cache
  - typed error codes per contract
  - Supabase profile upsert by `telegram_user_id`
  - opaque cache-backed bearer session token issuance (`3600s` TTL)
- Core implementation prerequisites are explicit: schema/RLS, trust transitions, Telegram auth, seeding, CI gates.
- Recommended production boundary is now explicit: Nuxt -> Laravel BFF -> Supabase PostgreSQL/Storage; no opaque-token direct Supabase path.
- The validated v1 schema is now treated as a historical baseline that requires a city-aware normalized v2 cutover before bulk seeding.
- Lean MVP scope is now explicit: Telegram Bot only launches the TMA; no inline mode, public web, separate Nuxt admin, payments, or multi-city work in first release.
- Admin direction is Laravel server-rendered CRUD/moderation (Filament-compatible), while Nuxt is reserved for TMA.
- Frontend baseline now uses Nuxt 4 + Nuxt UI + Tailwind, Russian as default locale, and logo assets under `frontend/app/assets/brand/`.
- Header now uses Nuxt UI `USelectMenu` for city context and `UColorModeButton` for light/dark mode; Da Nang is selected, while Nha Trang, Pattaya, and Phuket are visible but disabled with country flags.

## Next Step

1. finish Bot -> TMA -> Laravel authenticated vertical slice
2. build Laravel server-rendered admin/editorial CRUD and moderation
3. keep Nuxt UI/Tailwind as the only TMA UI layer and validate mobile layout
4. seed first Da Nang newcomer journeys, not the full future platform
5. defer inline mode, separate admin frontend, public web, payments, and city expansion

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, and vault/resume-plan.md.
Current direction is a lean Bot -> TMA -> Laravel pilot. Nuxt 4 uses Nuxt UI/Tailwind; the header owns city selection and light/dark mode. Da Nang is active, while Nha Trang, Pattaya, and Phuket are disabled future options. Next build the Telegram bootstrap and connect guide actions to Laravel.
```
