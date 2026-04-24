-- Migration: 008_safety_cases_and_evidence
-- Purpose: Create safety_cases and safety_case_evidence tables
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create table if not exists public.safety_cases (
	id uuid primary key default gen_random_uuid(),
	title text not null,
	accused_label text not null,
	scheme_summary text not null,
	incident_date date,
	location_note text,
	status public.safety_case_status not null default 'under_review',
	source_note text not null,
	published_at timestamptz,
	retracted_at timestamptz,
	created_by_profile_id uuid not null references public.profiles (id),
	reviewed_by_profile_id uuid references public.profiles (id),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint safety_cases_published_requires_timestamp check (
		status <> 'published' or published_at is not null
	),
	constraint safety_cases_retracted_requires_timestamp check (
		status <> 'retracted' or retracted_at is not null
	)
);

create table if not exists public.safety_case_evidence (
	id uuid primary key default gen_random_uuid(),
	safety_case_id uuid not null references public.safety_cases (id) on delete cascade,
	evidence_type public.evidence_type not null,
	summary text not null,
	source_url text,
	storage_path text,
	submitted_by_profile_id uuid not null references public.profiles (id),
	created_at timestamptz not null default now(),
	constraint safety_case_evidence_source_or_storage_required check (
		source_url is not null or storage_path is not null
	)
);
