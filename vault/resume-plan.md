# Resume Plan

## Stop Point

- Menu translator Phase B shipped end-to-end: migration 049 applied to hosted (admin write policies on menu tables, review insert + body column, `app_events` metrics table, 90-day menu-photos Storage purge cron). New `/admin/menu` curation queue (link unmatched/low-confidence lines to dictionary dishes, reject, per-venue menu verify/reopen). Review submission live on place pages (pending moderation in `/admin/reviews`, which now shows review text). `useAnalytics` logs `menu_scan`/`place_view`/`review_submit` into `app_events`; dashboard shows queue size + scans (7d).
- CI was red on main since 2026-08-29: pgTAP 010 expected active-only cities (stale after 039) and the frontend test missed the `health` category. Both fixed; all 15 pgTAP suites verified PASS on hosted via `supabase db query --linked --file` (no-Docker method; `test db` needs Docker).
- Frontend gates green (lint, 48/48, typecheck, build); deployed to Cloudflare 2026-09-06, prod build stamp verified.

## Next Step

1. founder: confirm the new `iind-vps` host key (it changed; SSH validation path untouched until then), set `CLOUDFLARE_API_TOKEN` (auto-deploy is the only expected-red CI item), `SUPABASE_DB_URL` + R2 secrets for backups, rotate the Telegram bot token
2. founder: live Telegram walk-through - session exchange (5.5), submit a review on a place, scan a real menu; check `/admin/menu` queue fills with unmatched lines and curate a few
3. Closed pilot with metrics (next phase): decide the metric set from `app_events` data after the first pilot week
4. Backlog: guide authoring form, food category page for menu-decoder/drinks guides, freshness SLA in UI, R2 restore drill, offline phrase pack / venue QR deep link (Phase C)
