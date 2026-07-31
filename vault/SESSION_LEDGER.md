# Session Ledger

Short record of durable project decisions and handoffs. Detailed history lives in `vault/logs/changelog.md`.

## 2026-07-31 - Supabase-Only Cutover

- Removed Laravel transitional backend from active repository path.
- Locked Supabase as only backend platform: Edge Functions, Auth, Postgres/PostGIS, Storage, Realtime, and RLS.
- Nuxt exposes only public Supabase client configuration.
- Supabase Studio is private pilot admin; Studio membership is restricted and database constraints/triggers protect invariants because privileged Studio edits can bypass client RLS.
- Next: implement Telegram bootstrap Edge Function and validate Supabase Auth session exchange.
