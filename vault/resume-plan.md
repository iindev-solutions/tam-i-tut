# Resume Plan

## Stop Point

- TAMITUT architecture changed to Supabase-only.
- Laravel transitional backend files were removed from the repository.
- Supabase is the only backend platform: Edge Functions, Auth, Postgres/PostGIS, Storage, Realtime, and RLS.
- Supabase Studio is the private pilot operations/admin surface; project membership is restricted and database invariants must survive privileged Studio edits through constraints/triggers/guarded workflows.
- Nuxt runtime config now exposes only public Supabase URL and anon/publishable key.
- Legacy Nuxt Laravel API helper and API response types were removed.
- Existing Supabase migrations, RLS policies, and pgTAP tests remain the database baseline.
- The first implementation gap is Telegram auth: Edge Function must validate raw `Telegram.WebApp.initData`, freshness, replay, and establish the Supabase session contract.

## Next Step

1. create `supabase/functions/telegram-bootstrap`
2. validate Telegram HMAC, freshness, malformed input, and replay behavior
3. validate Supabase Auth identity/session exchange for Telegram users
4. connect Nuxt Supabase client with RLS-safe reads/writes
5. verify Studio editorial workflow on a small Da Nang dataset
6. add off-site database + Storage backup procedure before production data

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, vault/resume-plan.md, and vault/design.md.
Current direction is Supabase-only: Nuxt TMA -> Supabase public client/RLS and Edge Functions for privileged workflows. Laravel has been removed. Supabase Studio is temporary private pilot admin. Next implement and test telegram-bootstrap, including Telegram initData validation, replay protection, and Supabase Auth session establishment.
```
