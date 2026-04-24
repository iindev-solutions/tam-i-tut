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
  - `npx supabase test db supabase/tests/rls --local` → FAIL (test stubs have no TAP plan/assertions)
- Core implementation prerequisites are explicit: schema/RLS, trust transitions, Telegram auth, seeding, CI gates.

## Next Step

1. implement concrete pgTAP assertions in `supabase/tests/rls/001..009_*.sql`
2. re-run `npx supabase test db supabase/tests/rls --local` on VPS until passing
3. capture and fix any policy/guard behavior issues revealed by tests
4. scaffold CI checks for frontend + DB policy verification
5. implement Telegram auth contract endpoint logic

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, and vault/resume-plan.md.
VPS runtime setup is complete and migrations/lint are validated. Continue by implementing pgTAP assertions in `supabase/tests/rls/`, then re-run VPS `supabase test db` until green.
```
