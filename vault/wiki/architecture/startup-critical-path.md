# Startup Critical Path — TAMITUT

## Why This Exists

Early-phase risk is not feature speed. Early-phase risk is trust model mismatch and backend policy mistakes.

This sequence is mandatory before broad feature implementation.

## Execution Order

1. **Supabase schema + migrations + RLS matrix**
   - output: initial schema files and role policy tests
   - planning artifacts:
     - `supabase-schema-rls-plan.md`
     - `supabase-migration-file-plan.md`
     - `supabase-rls-policy-matrix-v1.md`
2. **Trust state machine enforcement**
   - output: transition rules + guard checks + audit trail contract
3. **Telegram auth contract**
   - output: validation algorithm, error code map, replay controls
4. **Content seeding protocol**
   - output: 200+ seed backlog with evidence and freshness SLA
5. **CI quality gates**
   - output: required lint/type/test gates and DB policy checks
6. **Agent skill baseline**
   - output: locked skill stack and reproducible restore flow

## Gate to Start UI/Feature Expansion

Do not start broad UX scope until:

- schema + RLS + trust transition rules are testable
- Telegram auth contract is finalized
- seeding protocol and safety moderation process are operationally defined
