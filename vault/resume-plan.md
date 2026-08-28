# Resume Plan

## Stop Point

- Phase 0-3 DONE (admin + map editor live). Phase 3 hardening CODE DONE and verified: durable per-IP rate limiting on `telegram-bootstrap` (429 + Retry-After, RPC locked to service_role via migration 031), migration 032 grants for fresh-stack parity, keepalive worker, privacy page, cleanup, deploy root cause fixed (`deployConfig: false`). CI fully GREEN for the first time (sha 252c144): frontend gates + all 12 RLS pgTAP suites.
- Phase 4 started: migration `20260828000000_033_food_expansion_seed.sql` written with 13 new sourced Da Nang venues (Michelin/Tripadvisor/official sources; 3 researched venues were already seeded), mirrored into `seed.sql`; new pgTAP suite `013_seed_localization_parity.sql` guards ru/en rows-per-language integrity. Static parity checks pass; frontend vitest 39/39. NOT yet applied to any database (no local Docker; hosted untouched) - CI db job or `supabase db push` must prove it.
- Live infra verified earlier: burst -> 429 with Retry-After, window expiry restores, anon still reads zero rows (RLS intact), TMA serves baked env, bootstrap healthy.

## Next Step

1. founder: review the 13 venues in migration 033, then commit + push (CI db job validates migrations+seed+pgTAP) and `supabase db push` to apply 033 to hosted
2. founder: add repo secret `CLOUDFLARE_API_TOKEN` (Deploy workflow fails fast at auth without it; local OAuth deploys work as fallback)
3. founder: add backup secrets `SUPABASE_DB_URL` + `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` / `R2_ENDPOINT` / `R2_BUCKET`; rotate the Telegram bot token shared in chat (twice)
4. founder: live Telegram test of the session exchange (5.5) - open @tamittutbot, menu button, verify a `tg-<id>@tma.tamitut.local` user + nonce row
5. then Phase 4 continues: freshness SLA rollout to other categories, closed pilot
6. Improvement backlog from the 2026-08-28 audit (high priority first): silent mock-fallback in `useDb.ts`/`useHousingDb.ts`, guide authoring form, user review submission path, seed integrity already covered by 013

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, vault/resume-plan.md, and vault/wiki/architecture/admin-panel-and-prod-plan.md.
Current direction: Phases 0-3 done in code; CI green (frontend + pgTAP). Rate limiting is live and locked down. Remaining: founder secrets for auto-deploy (CLOUDFLARE_API_TOKEN) and backups (SUPABASE_DB_URL, R2), Telegram live session test, then Phase 4 content & pilot.
```
