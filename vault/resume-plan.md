# Resume Plan

## Stop Point

- Phase 0-3 DONE. Phase 4 content shipped: hosted Supabase now has 23 published da-nang places (13 new sourced venues via migration 033), 46 ru/en localizations, 14 photo URLs (migration 034). CI green on sha 357341d (frontend gates + all 13 pgTAP suites incl. the new 013 localization-parity suite); CI caught and the fix landed for a cities-before-seed FK ordering bug in 033.
- Food UI rebuilt (list of photo cards, no carousel) + new /places/[slug] detail page with Google Maps deep link; frontend tests/lint/typecheck/build all pass.
- Deploy workflow fails only on the missing `CLOUDFLARE_API_TOKEN` secret - the new UI is NOT live until that secret is set (or a local OAuth wrangler deploy is run).

## Next Step

1. founder: set repo secret `CLOUDFLARE_API_TOKEN` (or run a local `npm run deploy` with OAuth) so the new food UI ships
2. founder: add backup secrets `SUPABASE_DB_URL` + `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` / `R2_ENDPOINT` / `R2_BUCKET`; rotate the Telegram bot token shared in chat (twice)
3. founder: live Telegram test of the session exchange (5.5) - open @tamittutbot, menu button, verify a `tg-<id>@tma.tamitut.local` user + nonce row; then walk the new food list/detail in the TMA
4. Phase 4 continues: freshness SLA rollout to other categories, closed pilot
5. Improvement backlog (2026-08-28 audit): silent mock-fallback in `useDb.ts`/`useHousingDb.ts`, guide authoring form, user review submission path

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, vault/resume-plan.md, and vault/wiki/architecture/admin-panel-and-prod-plan.md.
Current direction: Phases 0-3 done in code; CI green (frontend + pgTAP). Rate limiting is live and locked down. Remaining: founder secrets for auto-deploy (CLOUDFLARE_API_TOKEN) and backups (SUPABASE_DB_URL, R2), Telegram live session test, then Phase 4 content & pilot.
```
