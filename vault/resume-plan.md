# Resume Plan

## Stop Point

- Project skill stack installed and locked for this repo (`skills-lock.json`).
- Startup critical path documented in architecture/services docs.
- Schema contract v1 locked in `vault/wiki/architecture/supabase-schema-rls-plan.md`.
- Migration sequencing and RLS policy matrix now documented in:
  - `vault/wiki/architecture/supabase-migration-file-plan.md`
  - `vault/wiki/architecture/supabase-rls-policy-matrix-v1.md`
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
  - contract tests in `backend/tests/Feature/TelegramAuthApiTest.php` (including config-failure path)
- Core implementation prerequisites are explicit: schema/RLS, trust transitions, Telegram auth, seeding, CI gates.

## Next Step

1. validate Telegram auth contract tests in a full Laravel runtime environment
2. decide whether to keep opaque cache-backed session tokens in production or migrate to Supabase-native/session service
3. create content seeding backlog execution plan and ownership
4. start first end-to-end backend API slice on top of verified schema/policies
5. monitor CI runtime and optimize Supabase job exclusions if needed

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, and vault/resume-plan.md.
CI baseline is wired and RLS/guard tests pass on VPS (`80` tests). Telegram auth now performs Supabase profile upsert and issues opaque cache-backed sessions; next focus is full runtime test execution and production session strategy decision.
```
