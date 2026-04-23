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

## Error Codes (Draft)

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

## Open Decisions

- final session TTL and refresh policy
- exact replay cache backend and retention
- fail-open vs fail-closed behavior during Telegram outage (recommended: fail-closed)
