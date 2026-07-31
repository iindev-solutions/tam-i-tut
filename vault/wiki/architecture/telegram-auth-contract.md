# Telegram Auth Contract — TAMITUT

## Goal

Define a strict, testable contract for Telegram-based user authentication in bot/mini-app contexts.

## Inputs

- Telegram `initData` payload
- client timestamp
- optional device/session metadata for abuse controls

## Validation Rules

1. validate Telegram signature exactly per official algorithm
2. enforce max payload age window (default target: 5 minutes)
3. reject replayed payload hashes within TTL window
4. require stable user identifier mapping (`telegram_user_id`)
5. deny authentication if payload is malformed or required fields missing

## Session Output

On success:

- issue internal session token
- upsert profile by `telegram_user_id`
- assign role `user` by default
- attach locale hint (`ru` default, `en` optional)

On failure:

- return typed error code (no ambiguous generic failures)

## Error Codes

- `TG_AUTH_INVALID_SIGNATURE`
- `TG_AUTH_EXPIRED_PAYLOAD`
- `TG_AUTH_REPLAY_DETECTED`
- `TG_AUTH_MALFORMED_PAYLOAD`
- `TG_AUTH_INTERNAL_ERROR`

## Security Controls

- rate-limit by IP + telegram user id + device fingerprint
- log auth failures with minimal PII
- never trust client role claims
- no privileged role assignment via Telegram auth endpoint

## Required Tests

1. valid payload passes and creates session
2. tampered payload fails signature check
3. expired payload rejected
4. same payload replay rejected
5. malformed payload rejected with correct error code

## Current Implementation Snapshot (Transitional Backend)

- endpoint: `POST /api/auth/telegram`
- replay guard: payload-hash cache key with 5-minute TTL
- profile persistence: Supabase profile lookup/upsert by `telegram_user_id`
- role assignment: forced `user`
- session token mode: opaque random bearer token, cache-backed lookup (`3600s` TTL)

## Target Production Decision

- Laravel BFF owns all TMA data access; Nuxt does not call RLS-protected Supabase APIs with the opaque Laravel token.
- Replace the transitional bearer response with a Redis-backed secure HttpOnly same-origin session.
- Make repeated exchange of the same valid `initData` idempotent for compatible retry context instead of rejecting every retry as replay.
- Keep fail-closed behavior for invalid/stale Telegram data and configuration failures.

## Remaining Parameters

- exact user session TTL, idle renewal, and absolute lifetime
- Redis availability/eviction policy and session revocation operations
- compatible-context rules for idempotent exchange retries
