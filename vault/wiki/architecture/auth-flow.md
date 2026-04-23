# Auth Flow — TAMITUT (Target)

## Auth Modes

1. **End users:** Telegram identity session for guide consumption and suggestions.
2. **Ops users:** staff login for curation/moderation/admin workflows.
3. **Trusted source registry:** controlled accounts used for recommendation confirmations.

## End-User Flow (Telegram)

1. User opens TAMITUT in Telegram.
2. Telegram identity/session payload is validated.
3. Internal profile is mapped or created with `user` role.
4. User can browse published entries and submit suggestions.

## Ops Flow (Internal)

1. Staff signs in via internal auth path.
2. Role grants scoped access (`curator`, `moderator`, `admin`).
3. Staff actions require role checks and are audit-logged.

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

## Open Decisions

- exact technical stack for staff auth hardening
- session TTL and renewal policy by role
- trusted-source lifecycle process (activation/revocation cadence)
