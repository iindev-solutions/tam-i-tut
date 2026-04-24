# Quality Gates and CI Baseline — TAMITUT

## Goal

Prevent drift and enforce minimum engineering quality before implementation scales.

## Required Gates (Initial)

1. Frontend lint
2. Frontend typecheck
3. Frontend unit tests
4. SQL migration checks (when schema lands)
5. RLS policy tests (role-matrix regression)

## Baseline Commands

```bash
# frontend
npm --prefix frontend run lint
npm --prefix frontend run typecheck
npm --prefix frontend run test
```

When Supabase migrations are added:

```bash
# database (placeholder)
npx supabase db lint
npx supabase db test
```

## Merge Policy

- no direct merge to `main` if required gate fails
- schema/RLS changes require policy test updates in same PR
- trust-state transitions require regression tests before merge

## Test Priority Queue

1. Telegram auth validation tests
2. trust badge transition tests
3. blacklist publication guard tests
4. role-based RLS access tests

## Definition of Done (Engineering)

A task is done only if:

- feature behavior implemented
- relevant tests added/updated
- all required gates pass
- vault changelog/resume updated
