-- Migration: 005_verification_evidence
-- Purpose: Create verification_evidence and invalidation constraints
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create table if not exists public.verification_evidence (
	id uuid primary key default gen_random_uuid(),
	guide_entry_id uuid not null references public.guide_entries (id) on delete cascade,
	evidence_type public.evidence_type not null,
	summary text not null,
	source_url text,
	storage_path text,
	captured_at timestamptz,
	submitted_by_profile_id uuid not null references public.profiles (id),
	is_valid boolean not null default true,
	invalidated_by_profile_id uuid references public.profiles (id),
	invalidated_at timestamptz,
	invalidation_reason text,
	created_at timestamptz not null default now(),
	constraint verification_evidence_invalidation_consistency check (
		(
			is_valid = true
			and invalidated_by_profile_id is null
			and invalidated_at is null
			and invalidation_reason is null
		)
		or
		(
			is_valid = false
			and invalidated_by_profile_id is not null
			and invalidated_at is not null
			and invalidation_reason is not null
		)
	)
);
