# Auth Flow — TamITut (Target)

## Modes

1. **Telegram Mini App (primary):** authenticate using Telegram `initData`.
2. **Web fallback:** authenticate using email-based Supabase auth.

## Telegram Flow

1. Client opens TMA and receives `initData` from Telegram runtime.
2. Backend verification function validates signature + freshness window.
3. On success, user profile is created/updated and session token is issued.
4. Session maps to role model (`user`, `moderator`, `admin`).

## Web Flow

1. User starts email auth (magic link or OTP).
2. Supabase validates token and returns session.
3. Profile record is linked to same domain model as Telegram users.

## Session Model

- Short-lived access token + refresh strategy managed by Supabase.
- Client stores session securely per platform constraints.
- Role claims checked in RLS and function guards.

## Verification Rules

- Reject expired Telegram `initData` payloads.
- Reject invalid signatures.
- Normalize identity mapping to avoid duplicate accounts.
- Require moderation privileges for trust/safety actions.

## Open Decisions

- account linking rules for Telegram + email identities
- exact token lifetime and refresh policy
- fallback behavior when Telegram verification service degrades
