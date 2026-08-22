# Resume Plan

## Stop Point

- Phase 0-2 DONE (admin + map editor live). Phase 3 hardening CODE DONE and verified: durable per-IP rate limiting on `telegram-bootstrap` (429 + Retry-After, RPC locked to service_role via migration 031), migration 032 grants for fresh-stack parity, keepalive worker, privacy page, cleanup, deploy root cause fixed (`deployConfig: false`). CI fully GREEN for the first time (sha 252c144): frontend gates + all 12 RLS pgTAP suites.
- Live infra verified after changes: burst -> 429 with Retry-After, window expiry restores, anon still reads zero rows (RLS intact), TMA serves baked env, bootstrap healthy.

## Next Step

1. founder: add repo secret `CLOUDFLARE_API_TOKEN` (Deploy workflow fails fast at auth without it; local OAuth deploys work as fallback)
2. founder: add backup secrets `SUPABASE_DB_URL` + `R2_ACCESS_KEY_ID` / `R2_SECRET_ACCESS_KEY` / `R2_ENDPOINT` / `R2_BUCKET`; rotate the Telegram bot token shared in chat
3. founder: live Telegram test of the session exchange (5.5) - open @tamittutbot, menu button, verify a `tg-<id>@tma.tamitut.local` user + nonce row
4. then Phase 4: sourced food expansion (~15 venues), freshness SLA rollout to other categories, closed pilot

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, vault/resume-plan.md, and vault/wiki/architecture/admin-panel-and-prod-plan.md.
Current direction: Phases 0-3 done in code; CI green (frontend + pgTAP). Rate limiting is live and locked down. Remaining: founder secrets for auto-deploy (CLOUDFLARE_API_TOKEN) and backups (SUPABASE_DB_URL, R2), Telegram live session test, then Phase 4 content & pilot.
```
