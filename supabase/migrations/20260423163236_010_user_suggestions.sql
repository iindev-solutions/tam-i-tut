-- Migration: 010_user_suggestions
-- Purpose: Create user_suggestions with resolution constraints
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create table if not exists public.user_suggestions (
	id uuid primary key default gen_random_uuid(),
	submitted_by_profile_id uuid references public.profiles (id),
	category_slug public.category_slug not null references public.categories (slug),
	language public.language_code not null default 'ru',
	title text not null,
	description text not null,
	contact_payload jsonb,
	source_payload jsonb,
	status public.suggestion_status not null default 'new',
	reviewer_profile_id uuid references public.profiles (id),
	review_notes text,
	linked_guide_entry_id uuid references public.guide_entries (id),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	resolved_at timestamptz,
	constraint user_suggestions_resolved_status_requires_timestamp check (
		status not in ('accepted', 'rejected', 'merged') or resolved_at is not null
	),
	constraint user_suggestions_merged_requires_linked_entry check (
		status <> 'merged' or linked_guide_entry_id is not null
	)
);
