# Session Ledger

Short record of durable project decisions and handoffs. Detailed history lives in `vault/logs/changelog.md`; current architecture lives in `vault/architecture.md`.

## 2026-07-31 — Lean TMA MVP

- Reduced first release to Telegram Bot -> Telegram Mini App -> Laravel.
- Nuxt 4 + Nuxt UI + Tailwind is the TMA frontend; Russian is default locale.
- Laravel remains the only client-facing API/auth boundary.
- Supabase provides managed PostgreSQL/PostGIS/Storage; Redis handles sessions/cache/queues/rate limits.
- Laravel server-rendered admin/editorial CRUD is planned; no separate Nuxt admin in first release.
- Da Nang is the only active city. Other cities remain disabled configuration options.
- Frontend checks passed: typecheck, lint, unit test, production build, and 390px browser smoke test.

## Next

1. Finish Telegram Bot -> TMA -> Laravel authenticated vertical slice.
2. Build Laravel editorial CRUD/moderation.
3. Approve city-aware schema v2 before bulk content seeding.
4. Seed and validate first Da Nang newcomer journeys.
