# Auth Flow - TAMITUT (Target)

## Auth Modes

1. **End users:** Telegram identity session for guide consumption and suggestions.
2. **Ops users:** staff login for curation/moderation/admin workflows.
3. **Trusted source registry:** controlled accounts used for recommendation confirmations.

## End-User Flow (Telegram Mini App)

1. User opens TAMITUT on the canonical Telegram Mini App origin.
2. Nuxt sends raw `Telegram.WebApp.initData` to Laravel's exchange endpoint.
3. Laravel validates the Telegram signature, payload age, required user fields, and exchange context.
4. Laravel maps or creates an application-owned profile with the `user` role.
5. Laravel issues a server-side Redis session through a secure HttpOnly cookie.
6. Nuxt calls only Laravel for protected data and mutations.

## Ops Flow (Internal)

1. Staff signs in through a separate admin auth/session namespace with mandatory MFA.
2. Role grants scoped access (`curator`, `moderator`, `admin`).
3. Staff actions require Laravel policy checks and are audit-logged.

## Trusted Source Confirmation Flow

1. Moderator marks account/contact as trusted source.
2. Trusted source confirmations can be attached to entries.
3. Rule engine counts confirmations for `recommended_expats` threshold (>=3).
4. Moderator can revoke invalid confirmations.

## Role Matrix

- `user`: consume published data, submit suggestions.
- `curator`: draft/edit entries, attach evidence.
- `moderator`: approve entries, assign badges, publish blacklist/safety updates.
- `admin`: manage roles, policy settings, and audits.
- `trusted_source`: provide confirmations only (no publish rights).

## Security Constraints

- No public role can publish or change trust badge states.
- Trust badge transitions require evidence checks.
- Blacklist actions require moderator+ privilege and mandatory evidence fields.
- Every sensitive action is written to immutable audit log.
- Nuxt never receives a Supabase service key and never sends the opaque Laravel session to Supabase APIs.
- Privileged Laravel database/PostgREST access bypasses Supabase RLS; Laravel policies plus database constraints/state-machine triggers enforce BFF requests.

## Remaining Decisions

- exact user and staff session TTL/renewal policy
- TOTP-only versus passkey-capable staff MFA implementation
- trusted-source lifecycle process (activation/revocation cadence)

## Companion Spec

See `telegram-auth-contract.md` for validation/error/replay details.
