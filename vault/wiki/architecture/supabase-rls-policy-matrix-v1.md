# Supabase RLS Policy Matrix v1 — TAMITUT

## Goal

Define explicit role-by-table access before writing SQL RLS policies.

This matrix is normative for initial implementation.

## Roles

- `user`
- `curator`
- `moderator`
- `admin`
- `trusted_source`

## Access Matrix (v1)

Legend:
- `R` read/select
- `C` create/insert
- `U` update
- `D` delete
- `-` denied

### `profiles`

| Role | Access | Scope |
|---|---|---|
| user | R,U | self only (no role changes) |
| curator | R,U | self only |
| moderator | R,U | self + read all |
| admin | R,C,U,D | full |
| trusted_source | R,U | self only |

### `categories`

| Role | Access | Scope |
|---|---|---|
| user | R | active rows |
| curator | R | active rows |
| moderator | R,U | all |
| admin | R,C,U,D | all |
| trusted_source | R | active rows |

### `guide_entries`

| Role | Access | Scope |
|---|---|---|
| user | R | published only |
| curator | R,C,U | own drafts + published rows |
| moderator | R,C,U,D | all |
| admin | R,C,U,D | all |
| trusted_source | R | published only |

### `trusted_contacts`, `price_snapshots`, `checklist_items`

| Role | Access | Scope |
|---|---|---|
| user | R | linked to published entries |
| curator | R,C,U,D | linked to own drafts + published rows |
| moderator | R,C,U,D | all |
| admin | R,C,U,D | all |
| trusted_source | R | linked to published entries |

### `verification_evidence`

| Role | Access | Scope |
|---|---|---|
| user | - | denied |
| curator | R,C,U | evidence for own draft entries |
| moderator | R,C,U,D | all |
| admin | R,C,U,D | all |
| trusted_source | R | own confirmation-type evidence only |

### `trusted_sources`

| Role | Access | Scope |
|---|---|---|
| user | - | denied |
| curator | - | denied |
| moderator | R,C,U | all |
| admin | R,C,U,D | all |
| trusted_source | R | self row only |

### `source_confirmations`

| Role | Access | Scope |
|---|---|---|
| user | - | denied |
| curator | R | read only |
| moderator | R,C,U,D | all |
| admin | R,C,U,D | all |
| trusted_source | R,C,U | own confirmations only |

### `trust_badge_events`

| Role | Access | Scope |
|---|---|---|
| user | R | events for published entries only |
| curator | R | read only |
| moderator | R,C | all |
| admin | R,C | all |
| trusted_source | - | denied |

### `safety_cases` and `safety_case_evidence`

| Role | Access | Scope |
|---|---|---|
| user | R | published cases only |
| curator | R | read only |
| moderator | R,C,U,D | all |
| admin | R,C,U,D | all |
| trusted_source | - | denied |

### `scam_patterns`

| Role | Access | Scope |
|---|---|---|
| user | R | active rows |
| curator | R | active rows |
| moderator | R,C,U,D | all |
| admin | R,C,U,D | all |
| trusted_source | R | active rows |

### `user_suggestions`

| Role | Access | Scope |
|---|---|---|
| user | R,C,U | own rows (no status escalation) |
| curator | R,U | triage notes/status within allowed set |
| moderator | R,C,U,D | all |
| admin | R,C,U,D | all |
| trusted_source | R,C,U | own rows only |

### `audit_logs`

| Role | Access | Scope |
|---|---|---|
| user | - | denied |
| curator | - | denied |
| moderator | R | rows where `actor_profile_id = auth.uid()` |
| admin | R | full |
| trusted_source | - | denied |

## Mandatory Policy Guards

1. `guide_entries.status = 'published'` required for user/trusted_source reads.
2. Curator ownership checks on all draft-linked writes.
3. `trusted_source` cannot modify trust badge or publication state directly.
4. Safety publish requires evidence existence check.
5. Any trust/safety update path writes to `audit_logs`.
6. UPDATE policies must be paired with SELECT policies (Postgres RLS requirement).

## Policy Naming Convention

`<table>__<role_or_scope>__<action>`

Examples:
- `guide_entries__user__select_published`
- `guide_entries__curator__write_own_drafts`
- `safety_cases__moderator__write_all`
- `audit_logs__admin__select_all`

## RLS Test Suite Mapping

| Test File | Covers |
|---|---|
| `001_profiles_access.sql` | self-service profile access and admin override |
| `002_guide_entries_access.sql` | published-read and curator ownership rules |
| `003_evidence_access.sql` | evidence visibility/write boundaries |
| `004_trusted_source_confirmations.sql` | trusted source create/update/revoke rules |
| `005_safety_cases_access.sql` | published-only read and moderator publish paths |
| `006_user_suggestions_access.sql` | own-suggestion constraints and moderation actions |
| `007_audit_log_access.sql` | append-only and role-restricted reads |
| `008_trust_transition_guards.sql` | badge guard preconditions and failure cases |
| `009_safety_publish_guards.sql` | evidence-required safety publish controls |

## Out of Scope for v1

- anonymous public API access
- multi-tenant organization model
- row-level geo partitioning
