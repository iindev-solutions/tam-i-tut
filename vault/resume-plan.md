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
- Core implementation prerequisites are explicit: schema/RLS, trust transitions, Telegram auth, seeding, CI gates.

## Next Step

1. provision Docker on VPS and run Supabase local stack for migration execution
2. run migration/policy validation and fix SQL issues found at runtime
3. complete role-policy SQL tests in `supabase/tests/rls/`
4. scaffold CI checks for frontend + DB policy verification
5. implement Telegram auth contract endpoint logic

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, and vault/resume-plan.md.
All migration files (`001`–`020`) have SQL. Next session: run VPS Docker playbook (`vault/wiki/services/vps-supabase-runtime.md`), fix runtime issues, then finish role-policy tests.
```
