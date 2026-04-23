# Content Seeding Protocol — TAMITUT

## Objective

Launch with enough trusted depth to avoid empty-product failure.

Target before broad launch: **200+ entries** across six MVP categories.

## Category Allocation Baseline

| Category | Minimum Seed Count |
|---|---|
| Housing | 50 |
| Transport | 35 |
| Money | 25 |
| Food & Cafes | 45 |
| Events | 20 |
| Safety | 25 |

## Entry Minimum Fields

- title and short practical summary
- category and district/location context
- trust badge (`under_review`, `recommended_expats`, `verified_team`)
- last verification date
- contact/source metadata
- evidence references

## Evidence Requirements

- `verified_team`: at least one direct team-check proof
- `recommended_expats`: at least 3 trusted confirmations
- `under_review`: structured entry + warning flag + pending evidence task

## Seeding Workflow

1. Collect candidate entries from team + trusted network.
2. Normalize and deduplicate records.
3. Attach evidence and assign initial trust badge.
4. Moderator reviews and publishes.
5. Run QA spot-check sample each batch.

## Quality Gates per Batch

- no missing mandatory fields
- trust badge rules satisfied
- date/source fields present
- blacklist entries include evidence package
- random 10% manual re-check each batch

## Freshness SLA

- transport/money data: re-check every 14 days
- housing/food/events: re-check every 30 days
- safety cases: event-driven immediate updates + weekly review

## Success Signal

User can resolve first-week newcomer needs without leaving TAMITUT for core trust-critical information.
