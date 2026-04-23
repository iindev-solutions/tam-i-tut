# Trust State Machine — TAMITUT

## Purpose

Formalize trust badge transitions so publication decisions are deterministic and auditable.

## States

1. `under_review`
2. `recommended_expats`
3. `verified_team`
4. `archived` (non-public terminal state)

## Transition Graph

- `under_review -> recommended_expats`
- `under_review -> verified_team`
- `recommended_expats -> verified_team`
- `recommended_expats -> under_review` (evidence invalidated)
- `verified_team -> under_review` (verification expired/disputed)
- `* -> archived` (content withdrawn)

## Guard Conditions

### to `recommended_expats`

- at least 3 active confirmations from trusted sources
- no active moderation block
- entry has required core fields (summary, contact or source, last checked date)

### to `verified_team`

- at least 1 valid `team_check` evidence item
- verification date recorded
- moderator approval event recorded

### to `under_review` (downgrade)

- evidence expires, is revoked, or is disputed
- or moderator flags inconsistency

### to `archived`

- duplicate/stale/unresolvable trust issue
- explicit moderator/admin archival reason required

## SLA and Re-Validation

- `under_review` target decision SLA: 72h
- `recommended_expats` re-check cadence: every 30 days
- `verified_team` re-check cadence: every 60 days
- safety-related entries can trigger immediate re-check at any time

## Audit Requirements

Each transition must persist:

- actor id and role
- from-state / to-state
- reason code
- evidence references used
- timestamp

No silent state updates allowed.
