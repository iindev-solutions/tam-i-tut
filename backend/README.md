# Backend (Transitional)

This folder currently contains Laravel-oriented starter artifacts from template bootstrap.

TamITut target backend platform is **Supabase** (Postgres/Auth/Storage/Realtime).

Use this folder only as temporary reference for:

- API route/controller structure ideas
- validation/response shape examples
- baseline test style

Current transitional API endpoints:

- `GET /api/health`
- `POST /api/auth/telegram` (Telegram initData validation contract with typed error codes)
- `POST /api/auth/login` (deprecated placeholder)

Next backend milestone:

1. move Telegram auth implementation to Supabase Edge Functions or dedicated service layer
2. connect profile upsert/session issuance to final Supabase-backed auth persistence
3. document final architecture in `vault/wiki/architecture/`
