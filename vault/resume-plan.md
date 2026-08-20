# Resume Plan

## Stop Point

- Live infra verified: hosted Supabase (23 migrations, seed, RLS proven live), `telegram-bootstrap` + `telegram-bot` deployed, TMA on Cloudflare Pages, bot @tamittutbot configured (menu button, webhook, emoji RU/EN description), frontend gates 32/32.
- Honest gap: NOT prod-ready - admin is a mock prototype (no real CRUD, no district polygon editor), housing data in frontend mocks, food-only seed, no keep-awake/backups/CI/cleanup.
- Full plan written: `vault/wiki/architecture/admin-panel-and-prod-plan.md` (Phases 0-4: foundations -> content admin -> map admin -> hardening -> content & launch). Awaiting founder approval + 3 decisions.

## Next Step

1. founder: create public GitHub repo, add secrets (CLOUDFLARE_API_TOKEN, CLOUDFLARE_ACCOUNT_ID, NUXT_PUBLIC_SUPABASE_URL/ANON_KEY, SUPABASE_DB_URL), enable R2 in the Cloudflare dashboard, push to main -> CI + auto-deploy + daily backups activate
2. after push: verify CI green + first auto-deploy + first backup; set R2 API token secrets
3. Phase 4: pilot seed (~80 high-value entries) + freshness SLA + closed pilot
4. Optional Phase 1 follow-up: full guide authoring form
5. Optional: R2 restore drill per backup runbook

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, vault/resume-plan.md, vault/design.md, and vault/wiki/architecture/admin-panel-and-prod-plan.md.
Current direction: live pilot infra is done; the real editorial admin + prod hardening plan (Phases 0-4) is in the vault, awaiting founder approval. Next is Phase 0 (PostGIS, districts migration, admin write RLS, founder admin identity, pg_cron nonce purge, district seed).
```

## Session Restart Prompt

```text
Read vault/master_index.md, vault/WORKFLOW.md, vault/sprint.md, vault/resume-plan.md, and vault/design.md.
Current direction: prototype feature-complete. Supabase cutover at the accepted food-slice scope: telegram-bootstrap Edge Function + schema v2 (cities/places/reviews) coded and unit-tested; Nuxt RLS-safe read layer (useDb + db-mappers) wired into home/food/city selector with a mock fallback; food seed and backup runbook done. Remaining: runtime validation on a Docker-capable host (RLS pgTAP, session exchange, live read path in browser), Studio editorial workflow check, remaining journey seeding, backup schedule standup.
```
