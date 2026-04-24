-- Migration: 003_guide_entries
-- Purpose: Create guide_entries with state and trust constraints
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create table if not exists public.guide_entries (
	id uuid primary key default gen_random_uuid(),
	category_slug public.category_slug not null references public.categories (slug),
	title text not null,
	summary text not null,
	district text,
	language public.language_code not null default 'ru',
	status public.entry_status not null default 'draft',
	trust_badge public.trust_badge not null default 'under_review',
	under_review_note text,
	owner_profile_id uuid not null references public.profiles (id),
	created_by_profile_id uuid not null references public.profiles (id),
	updated_by_profile_id uuid not null references public.profiles (id),
	published_at timestamptz,
	archived_at timestamptz,
	last_verified_at timestamptz,
	verification_due_at timestamptz,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint guide_entries_status_published_requires_timestamp check (
		status <> 'published' or published_at is not null
	),
	constraint guide_entries_status_archived_requires_timestamp check (
		status <> 'archived' or archived_at is not null
	),
	constraint guide_entries_under_review_requires_note check (
		trust_badge <> 'under_review' or under_review_note is not null
	),
	constraint guide_entries_non_under_review_requires_null_note check (
		trust_badge = 'under_review' or under_review_note is null
	),
	constraint guide_entries_verification_due_not_before_verified check (
		verification_due_at is null
		or last_verified_at is null
		or verification_due_at >= last_verified_at
	)
);
