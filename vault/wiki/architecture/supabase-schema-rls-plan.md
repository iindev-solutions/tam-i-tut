# Supabase Schema + RLS Plan — TAMITUT

## Status

Schema contract **v1 locked** for implementation planning.

This is the source-of-truth contract for table/enums/constraints before SQL migration drafting.

## Assumptions

1. Supabase Postgres is primary data store.
2. UUID is default PK type (`gen_random_uuid()`) except append-only audit IDs.
3. `profiles.id` is mapped 1:1 to `auth.users.id`.
4. Product languages for MVP are `ru` and `en`.
5. Trust model is fixed: `under_review`, `recommended_expats`, `verified_team`.

## Required Extensions

- `pgcrypto` (UUID generation)

## Enums (Locked)

- `app_role`: `user`, `curator`, `moderator`, `admin`, `trusted_source`
- `language_code`: `ru`, `en`
- `category_slug`: `housing`, `transport`, `money`, `food`, `events`, `safety`
- `trust_badge`: `under_review`, `recommended_expats`, `verified_team`
- `entry_status`: `draft`, `published`, `archived`
- `evidence_type`: `team_check`, `photo`, `document`, `trusted_confirmation`, `external_reference`
- `suggestion_status`: `new`, `triaged`, `accepted`, `rejected`, `merged`
- `safety_case_status`: `under_review`, `published`, `retracted`
- `trust_reason_code`: `initial_publish`, `evidence_threshold_met`, `team_verified`, `evidence_revoked`, `periodic_recheck_failed`, `dispute_opened`, `dispute_resolved`, `manual_moderation`

## Tables (Locked Contract)

### 1) `profiles`

Purpose: role and identity mapping for all actors.

Columns:
- `id uuid primary key references auth.users(id) on delete cascade`
- `role app_role not null default 'user'`
- `display_name text null`
- `telegram_user_id bigint unique null`
- `locale language_code not null default 'ru'`
- `is_active boolean not null default true`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Constraints:
- `telegram_user_id` must be `> 0` when present.

---

### 2) `categories`

Purpose: fixed MVP category registry.

Columns:
- `slug category_slug primary key`
- `title_ru text not null`
- `title_en text not null`
- `sort_order smallint not null unique`
- `is_active boolean not null default true`
- `created_at timestamptz not null default now()`

Seed rows (required):
- housing, transport, money, food, events, safety

---

### 3) `guide_entries`

Purpose: curated public guide entities.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `category_slug category_slug not null references categories(slug)`
- `title text not null`
- `summary text not null`
- `district text null`
- `language language_code not null default 'ru'`
- `status entry_status not null default 'draft'`
- `trust_badge trust_badge not null default 'under_review'`
- `under_review_note text null`
- `owner_profile_id uuid not null references profiles(id)`
- `created_by_profile_id uuid not null references profiles(id)`
- `updated_by_profile_id uuid not null references profiles(id)`
- `published_at timestamptz null`
- `archived_at timestamptz null`
- `last_verified_at timestamptz null`
- `verification_due_at timestamptz null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Constraints:
- if `status = 'published'` -> `published_at is not null`
- if `status = 'archived'` -> `archived_at is not null`
- if `trust_badge = 'under_review'` -> `under_review_note is not null`
- if `trust_badge <> 'under_review'` -> `under_review_note is null`
- if both set: `verification_due_at >= last_verified_at`

---

### 4) `trusted_contacts`

Purpose: verified contact channels for guide entries.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `guide_entry_id uuid not null references guide_entries(id) on delete cascade`
- `contact_type text not null` (allowed: `phone`, `telegram`, `email`, `website`, `address`, `other`)
- `label text null`
- `value text not null`
- `is_primary boolean not null default false`
- `notes text null`
- `verified_at timestamptz null`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Constraints:
- one primary contact max per entry (partial unique index on `guide_entry_id` where `is_primary = true`)

---

### 5) `price_snapshots`

Purpose: benchmark pricing references.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `category_slug category_slug not null references categories(slug)`
- `guide_entry_id uuid null references guide_entries(id) on delete set null`
- `district text null`
- `item_label text not null`
- `currency_code char(3) not null default 'VND'`
- `min_price numeric(12,2) not null`
- `max_price numeric(12,2) not null`
- `typical_price numeric(12,2) null`
- `unit_label text not null`
- `captured_on date not null`
- `source_note text not null`
- `confidence_score numeric(3,2) not null default 0.50`
- `verified_by_profile_id uuid null references profiles(id)`
- `created_at timestamptz not null default now()`

Constraints:
- `min_price >= 0`
- `max_price >= min_price`
- `typical_price` null or between min/max
- `confidence_score` between `0` and `1`

---

### 6) `checklist_items`

Purpose: practical action checklist content.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `category_slug category_slug not null references categories(slug)`
- `guide_entry_id uuid null references guide_entries(id) on delete cascade`
- `language language_code not null default 'ru'`
- `position integer not null`
- `item_text text not null`
- `is_required boolean not null default false`
- `created_by_profile_id uuid null references profiles(id)`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Constraints:
- `position > 0`
- unique `(guide_entry_id, language, position)` when `guide_entry_id is not null`
- unique `(category_slug, language, position)` when `guide_entry_id is null`

---

### 7) `verification_evidence`

Purpose: proof records for trust decisions.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `guide_entry_id uuid not null references guide_entries(id) on delete cascade`
- `evidence_type evidence_type not null`
- `summary text not null`
- `source_url text null`
- `storage_path text null`
- `captured_at timestamptz null`
- `submitted_by_profile_id uuid not null references profiles(id)`
- `is_valid boolean not null default true`
- `invalidated_by_profile_id uuid null references profiles(id)`
- `invalidated_at timestamptz null`
- `invalidation_reason text null`
- `created_at timestamptz not null default now()`

Constraints:
- if `is_valid = false` -> invalidation fields required
- if `is_valid = true` -> invalidation fields must be null

---

### 8) `trusted_sources`

Purpose: approved source registry for recommendation confirmations.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `profile_id uuid not null unique references profiles(id) on delete cascade`
- `approved_by_profile_id uuid not null references profiles(id)`
- `approved_at timestamptz not null default now()`
- `is_active boolean not null default true`
- `revoked_by_profile_id uuid null references profiles(id)`
- `revoked_at timestamptz null`
- `revoke_reason text null`
- `notes text null`
- `created_at timestamptz not null default now()`

Constraints:
- if `is_active = false` -> revoke fields required
- if `is_active = true` -> revoke fields must be null

---

### 9) `source_confirmations`

Purpose: per-entry trusted-source confirmations.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `guide_entry_id uuid not null references guide_entries(id) on delete cascade`
- `trusted_source_id uuid not null references trusted_sources(id)`
- `confirmation_note text not null`
- `confirmed_at timestamptz not null default now()`
- `is_active boolean not null default true`
- `revoked_by_profile_id uuid null references profiles(id)`
- `revoked_at timestamptz null`
- `revoke_reason text null`
- `created_at timestamptz not null default now()`

Constraints:
- one active confirmation per `(guide_entry_id, trusted_source_id)`
- if `is_active = false` -> revoke fields required

---

### 10) `trust_badge_events`

Purpose: immutable trust badge transition history.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `guide_entry_id uuid not null references guide_entries(id) on delete cascade`
- `from_badge trust_badge null`
- `to_badge trust_badge not null`
- `reason_code trust_reason_code not null`
- `actor_profile_id uuid not null references profiles(id)`
- `evidence_snapshot jsonb not null default '[]'::jsonb`
- `notes text null`
- `created_at timestamptz not null default now()`

Constraints:
- `from_badge is null` (initial event) OR `from_badge <> to_badge`

---

### 11) `safety_cases`

Purpose: blacklist and safety incident records.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `title text not null`
- `accused_label text not null`
- `scheme_summary text not null`
- `incident_date date null`
- `location_note text null`
- `status safety_case_status not null default 'under_review'`
- `source_note text not null`
- `published_at timestamptz null`
- `retracted_at timestamptz null`
- `created_by_profile_id uuid not null references profiles(id)`
- `reviewed_by_profile_id uuid null references profiles(id)`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Constraints:
- if `status = 'published'` -> `published_at is not null`
- if `status = 'retracted'` -> `retracted_at is not null`

---

### 12) `safety_case_evidence`

Purpose: evidence package for safety/blacklist records.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `safety_case_id uuid not null references safety_cases(id) on delete cascade`
- `evidence_type evidence_type not null`
- `summary text not null`
- `source_url text null`
- `storage_path text null`
- `submitted_by_profile_id uuid not null references profiles(id)`
- `created_at timestamptz not null default now()`

Constraints:
- at least one of `source_url` or `storage_path` must be present

---

### 13) `scam_patterns`

Purpose: reusable anti-scam playbooks.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `title text not null`
- `category_slug category_slug not null references categories(slug)`
- `pattern_text text not null`
- `red_flags jsonb not null default '[]'::jsonb`
- `prevention_steps jsonb not null default '[]'::jsonb`
- `report_channel text null`
- `is_active boolean not null default true`
- `created_by_profile_id uuid not null references profiles(id)`
- `updated_by_profile_id uuid not null references profiles(id)`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`

Constraints:
- `jsonb_typeof(red_flags) = 'array'`
- `jsonb_typeof(prevention_steps) = 'array'`

---

### 14) `user_suggestions`

Purpose: user-submitted candidate content queue.

Columns:
- `id uuid primary key default gen_random_uuid()`
- `submitted_by_profile_id uuid null references profiles(id)`
- `category_slug category_slug not null references categories(slug)`
- `language language_code not null default 'ru'`
- `title text not null`
- `description text not null`
- `contact_payload jsonb null`
- `source_payload jsonb null`
- `status suggestion_status not null default 'new'`
- `reviewer_profile_id uuid null references profiles(id)`
- `review_notes text null`
- `linked_guide_entry_id uuid null references guide_entries(id)`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()`
- `resolved_at timestamptz null`

Constraints:
- if `status in ('accepted','rejected','merged')` -> `resolved_at is not null`
- if `status = 'merged'` -> `linked_guide_entry_id is not null`

---

### 15) `audit_logs`

Purpose: append-only log for trust/safety sensitive actions.

Columns:
- `id bigint primary key generated always as identity`
- `actor_profile_id uuid null references profiles(id)`
- `actor_role app_role null`
- `action_type text not null`
- `entity_table text not null`
- `entity_id uuid null`
- `before_state jsonb null`
- `after_state jsonb null`
- `metadata jsonb not null default '{}'::jsonb`
- `ip_hash text null`
- `created_at timestamptz not null default now()`

Rules:
- no UPDATE/DELETE allowed (append-only)

## Relationship Summary

- `profiles` is root actor table (FK target for ownership and moderation actions).
- `categories` is fixed taxonomy for guide/safety/suggestion records.
- `guide_entries` links to contacts, checklists, price snapshots, evidence, confirmations, and trust events.
- `trusted_sources` + `source_confirmations` support `recommended_expats` threshold logic.
- `safety_cases` + `safety_case_evidence` enforce blacklist evidence requirements.
- `audit_logs` records every trust/safety state-changing action.

## Required Index Set (v1)

- `guide_entries(category_slug, status, trust_badge, published_at desc)`
- `guide_entries(language, status)`
- `guide_entries(verification_due_at)`
- `trusted_contacts(guide_entry_id)`
- partial unique `trusted_contacts(guide_entry_id)` where `is_primary = true`
- `price_snapshots(category_slug, district, captured_on desc)`
- `verification_evidence(guide_entry_id, is_valid, evidence_type)`
- `source_confirmations(guide_entry_id, is_active)`
- partial unique `source_confirmations(guide_entry_id, trusted_source_id)` where `is_active = true`
- `trust_badge_events(guide_entry_id, created_at desc)`
- `safety_cases(status, published_at desc)`
- `safety_case_evidence(safety_case_id)`
- `user_suggestions(status, created_at desc)`
- `audit_logs(entity_table, entity_id, created_at desc)`

## RLS Anchors for Step 2

Policy-critical columns (must exist exactly as named):

- ownership: `owner_profile_id`, `created_by_profile_id`, `submitted_by_profile_id`
- moderation: `reviewed_by_profile_id`, `reviewer_profile_id`, `actor_profile_id`
- publication state: `status`, `trust_badge`
- source trust controls: `is_active`, `approved_by_profile_id`, `revoked_by_profile_id`

## Hard Rules (Locked)

1. `recommended_expats` requires >= 3 active rows in `source_confirmations` for entry.
2. `verified_team` requires >= 1 valid `team_check` row in `verification_evidence`.
3. Published safety case requires >= 1 row in `safety_case_evidence`.
4. Any trust/safety transition must write `trust_badge_events` and `audit_logs`.
5. No direct client-side writes to publication state columns.

## Implementation Sequence

1. create enums + extensions
2. create base tables (`profiles`, `categories`)
3. create guide content tables
4. create trust/evidence tables
5. create safety and suggestion tables
6. create audit table + append-only guard
7. apply RLS policies and role test matrix

## Verification Checklist

- no schema placeholders remain
- every FK target exists in contract
- every trust rule maps to concrete table/column
- index set covers trust/safety hot paths
- contract ready for SQL migration drafting
