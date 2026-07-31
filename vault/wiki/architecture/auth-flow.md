# Auth Flow - TAMITUT

## Boundary

Supabase is the only backend platform. Nuxt uses the public Supabase client configuration; privileged secrets stay in Edge Function secrets.

## End-user Flow

1. User opens the Telegram Mini App.
2. Nuxt reads raw `Telegram.WebApp.initData`.
3. Nuxt sends raw `initData` to the Telegram bootstrap Edge Function.
4. The Edge Function validates Telegram HMAC, required fields, freshness, and replay protection.
5. The function maps the Telegram identity to a Supabase Auth user/profile.
6. The function establishes the Supabase session contract.
7. Nuxt uses the Supabase client with the public anon/publishable key and session.
8. Postgres RLS limits reads and writes to the authenticated role.

`initDataUnsafe` is UI data only; never use it as authentication input.

## Operations Flow

- Staff use Supabase Studio during the pilot.
- Studio/project membership is restricted to trusted operators.
- Studio uses privileged access and may bypass client RLS.
- Publication, evidence, trust, and audit invariants are enforced by database constraints, triggers, and guarded Edge Functions.
- A custom Nuxt `/admin` may replace Studio later without changing the data boundary.

## Security Rules

- Never expose `service_role`, database passwords, or Telegram bot token to Nuxt.
- Never call Supabase with privileged credentials from the browser.
- Keep client tables behind RLS.
- Keep multi-step privileged mutations in Edge Functions.
- Log sensitive mutations in append-only audit records.
- Restrict Supabase project membership and rotate secrets.

## Remaining Implementation

- Implement Telegram bootstrap Edge Function.
- Validate the exact Supabase Auth session exchange for Telegram identities.
- Add Edge Function tests for signature, stale payload, replay, and malformed data.
- Add browser auth smoke test inside Telegram-compatible launch context.
