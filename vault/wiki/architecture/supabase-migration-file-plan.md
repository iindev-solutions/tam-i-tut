# Supabase Migration File Plan — TAMITUT

## Goal

Convert locked schema contract into deterministic, reviewable SQL migrations with clear ordering and small blast radius per migration.

## Scaffold Status

Completed:

1. Supabase project initialized (`npx supabase init`).
2. Ordered migration stubs generated with `npx supabase migration new <name>`.
3. RLS test stub files created under `supabase/tests/rls/`.
4. Migration templates annotated with purpose and source references.

Notes:

- Global `supabase` binary is not required; use `npx supabase ...` commands.
- Timestamp prefixes are CLI-generated and expected to differ across environments.

## Execution Progress

- `001`–`013`: implemented (base schema SQL complete)
- `014`–`018`: implemented (RLS helpers + policies complete)
- `019`–`020`: implemented (trust/safety guard functions + triggers complete)
- `tests/rls 001`–`009`: implemented with concrete pgTAP assertions
- runtime validation status (VPS): migrations/lint/tests passing (`Files=9, Tests=80`)
- remaining work: wire CI execution and continue feature-layer implementation

## Target Repository Tree

```text
supabase/
  config.toml
  seed.sql
  migrations/
    <timestamp>_001_extensions_and_enums.sql
    <timestamp>_002_profiles_and_categories.sql
    <timestamp>_003_guide_entries.sql
    <timestamp>_004_contacts_prices_checklists.sql
    <timestamp>_005_verification_evidence.sql
    <timestamp>_006_trusted_sources_and_confirmations.sql
    <timestamp>_007_trust_badge_events.sql
    <timestamp>_008_safety_cases_and_evidence.sql
    <timestamp>_009_scam_patterns.sql
    <timestamp>_010_user_suggestions.sql
    <timestamp>_011_audit_logs.sql
    <timestamp>_012_updated_at_triggers.sql
    <timestamp>_013_performance_indexes.sql
    <timestamp>_014_rls_helpers.sql
    <timestamp>_015_enable_rls.sql
    <timestamp>_016_rls_policies_core_read.sql
    <timestamp>_017_rls_policies_curation_write.sql
    <timestamp>_018_rls_policies_moderation_admin.sql
    <timestamp>_019_trust_guard_functions_and_triggers.sql
    <timestamp>_020_safety_publish_guards.sql
  tests/
    rls/
      001_profiles_access.sql
      002_guide_entries_access.sql
      003_evidence_access.sql
      004_trusted_source_confirmations.sql
      005_safety_cases_access.sql
      006_user_suggestions_access.sql
      007_audit_log_access.sql
      008_trust_transition_guards.sql
      009_safety_publish_guards.sql
```

## Migration Creation Commands (Order)

```bash
npx supabase migration new 001_extensions_and_enums
npx supabase migration new 002_profiles_and_categories
npx supabase migration new 003_guide_entries
npx supabase migration new 004_contacts_prices_checklists
npx supabase migration new 005_verification_evidence
npx supabase migration new 006_trusted_sources_and_confirmations
npx supabase migration new 007_trust_badge_events
npx supabase migration new 008_safety_cases_and_evidence
npx supabase migration new 009_scam_patterns
npx supabase migration new 010_user_suggestions
npx supabase migration new 011_audit_logs
npx supabase migration new 012_updated_at_triggers
npx supabase migration new 013_performance_indexes
npx supabase migration new 014_rls_helpers
npx supabase migration new 015_enable_rls
npx supabase migration new 016_rls_policies_core_read
npx supabase migration new 017_rls_policies_curation_write
npx supabase migration new 018_rls_policies_moderation_admin
npx supabase migration new 019_trust_guard_functions_and_triggers
npx supabase migration new 020_safety_publish_guards
```

## Per-Migration Responsibility

### `001_extensions_and_enums`

- `pgcrypto` extension
- all locked enums from schema contract

### `002_profiles_and_categories`

- `profiles`
- `categories`
- seed 6 category rows

### `003_guide_entries`

- `guide_entries`
- state-related check constraints

### `004_contacts_prices_checklists`

- `trusted_contacts`
- `price_snapshots`
- `checklist_items`

### `005_verification_evidence`

- `verification_evidence`
- invalidation constraints

### `006_trusted_sources_and_confirmations`

- `trusted_sources`
- `source_confirmations`
- active-confirmation uniqueness constraints

### `007_trust_badge_events`

- `trust_badge_events`
- immutable transition-event structure

### `008_safety_cases_and_evidence`

- `safety_cases`
- `safety_case_evidence`

### `009_scam_patterns`

- `scam_patterns`
- JSON array constraints

### `010_user_suggestions`

- `user_suggestions`
- resolution constraints

### `011_audit_logs`

- `audit_logs`
- append-only shape

### `012_updated_at_triggers`

- generic `set_updated_at()` trigger function
- attach triggers to mutable tables

### `013_performance_indexes`

- all indexes listed in schema contract

### `014_rls_helpers`

- helper functions for role checks and ownership checks
- avoid policy logic duplication

### `015_enable_rls`

- enable RLS on all exposed operational tables

### `016_rls_policies_core_read`

- published/read policies for user-facing tables

### `017_rls_policies_curation_write`

- curator write policies (draft/evidence scope)

### `018_rls_policies_moderation_admin`

- moderator/admin policies
- trusted source registry management

### `019_trust_guard_functions_and_triggers`

- enforce trust transitions (`recommended_expats` and `verified_team` guards)
- write to `trust_badge_events` + `audit_logs`

### `020_safety_publish_guards`

- require evidence before safety case publish
- audit safety publish/retract actions

## RLS and Trigger Safety Notes

1. Never mix table creation and policy logic in one migration when avoidable.
2. Keep guard triggers after base policies exist.
3. Every security-sensitive trigger must fail with explicit reason text.
4. Every migration should be idempotent where practical (`if exists` / `if not exists` guarded objects).

## Verification Checklist (Plan-Level)

- migration sequence covers every object in schema contract
- security objects are split from base schema for review clarity
- guard triggers come after tables + policies
- RLS tests map 1:1 to policy groups
- no migration has mixed unrelated responsibilities
