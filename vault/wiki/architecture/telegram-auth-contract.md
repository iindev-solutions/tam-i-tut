# Telegram Auth Contract - TAMITUT

## Goal

Define a strict, testable Telegram authentication contract implemented by a Supabase Edge Function.

## Inputs

- Telegram `initData` payload from `Telegram.WebApp.initData`.
- Optional device/session metadata for abuse controls.

## Validation

1. Parse the raw payload.
2. Validate Telegram signature exactly per the official HMAC algorithm.
3. Enforce payload freshness (target: 5 minutes).
4. Reject replayed payload hashes within the TTL window.
5. Require stable `telegram_user_id` mapping.
6. Reject malformed payloads and missing required fields.
7. Never trust client role claims.

## Session Output

- Map or create a Supabase Auth user/profile by `telegram_user_id`.
- Assign `user` role by default.
- Preserve locale hint (`ru` default, `en` optional).
- Establish the Supabase session contract for the Mini App.

## Error Codes

- `TG_AUTH_INVALID_SIGNATURE`
- `TG_AUTH_EXPIRED_PAYLOAD`
- `TG_AUTH_REPLAY_DETECTED`
- `TG_AUTH_MALFORMED_PAYLOAD`
- `TG_AUTH_INTERNAL_ERROR`

## Security Controls

- Telegram bot token exists only in Supabase Edge Function secrets.
- Apply rate limits by IP, Telegram user id, and device context where available.
- Log auth failures with minimal PII.
- Fail closed for invalid, stale, replayed, or misconfigured requests.
- Do not expose `service_role` or database credentials to Nuxt.

## Implementation Target

- Edge Function: `telegram-bootstrap`.
- Client input: raw `Telegram.WebApp.initData`.
- Database persistence: Supabase Auth/profile tables and application profile records.
- Authorization: Supabase Auth session plus Postgres RLS.
- Tests: signature, freshness, replay, malformed payload, profile mapping, role default, and session establishment.
