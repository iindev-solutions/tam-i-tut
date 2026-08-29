# Resume Plan

## Stop Point

- Phases 0-3 DONE. Phase 4 content shipped (23 venues/23 photos). Menu translator Phase A shipped per vault/wiki/architecture/menu-translator-spec.md: dictionary (50 dishes, 46 sourced photos), menu-translate Edge Function (Gemini 2.0 Flash, rate-limited, cache-first), scan page, pgTAP 014, contract tests (47 frontend tests). CI green on d757f3a (db + frontend); hosted has migrations + function. Feature is OFF until GEMINI_API_KEY secret is set (graceful not_configured today).
- Live UI: food list (23 photo cards) + /places/[slug] detail (map embed) + /places/[slug]/menu; back navigation is the native Telegram BackButton everywhere; slideover/modal animations restored; city select uses flagcdn images.

## Next Step

1. founder: create a Gemini API key (aistudio.google.com -> Get API key, free tier) then `supabase secrets set GEMINI_API_KEY=<key>` - this turns the menu translator on; test a scan on a real menu
2. founder: `CLOUDFLARE_API_TOKEN` repo secret (Deploy job is the only red CI item; local OAuth deploys work meanwhile), bot avatar via @BotFather, Telegram token rotation
3. founder: live Telegram test of the session exchange (5.5), then walk: food list -> detail -> map -> menu scan
4. Menu translator Phase B (curation admin): unmatched/low-confidence queue, verify/reject, menu status, Storage purge cron
5. Then: closed pilot with metrics; freshness SLA rollout; improvement backlog (mock-fallback UX, guide authoring form, review submission)
