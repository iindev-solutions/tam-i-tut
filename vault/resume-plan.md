# Resume Plan

## Stop Point

- Project skill stack installed and locked for this repo (`skills-lock.json`).
- Startup critical path documented in architecture/services docs.
- Core implementation prerequisites are now explicit: schema/RLS, trust transitions, Telegram auth, seeding, CI gates.

## Next Step

1. draft first Supabase SQL migration for core tables and enums
2. write RLS policies for `user/curator/moderator/admin/trusted_source`
3. add trust-state transition checks and audit event writes
4. implement Telegram auth validation endpoint contract
5. scaffold CI checks for frontend + DB policy verification

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, and vault/resume-plan.md.
Startup docs and skill stack are ready. Start with first Supabase migration + RLS matrix, then trust transition enforcement, then Telegram auth contract implementation.
```
