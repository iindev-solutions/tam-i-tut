-- Migration: 009_scam_patterns
-- Purpose: Create scam_patterns with JSON array guards
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create table if not exists public.scam_patterns (
	id uuid primary key default gen_random_uuid(),
	title text not null,
	category_slug public.category_slug not null references public.categories (slug),
	pattern_text text not null,
	red_flags jsonb not null default '[]'::jsonb,
	prevention_steps jsonb not null default '[]'::jsonb,
	report_channel text,
	is_active boolean not null default true,
	created_by_profile_id uuid not null references public.profiles (id),
	updated_by_profile_id uuid not null references public.profiles (id),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint scam_patterns_red_flags_array check (
		jsonb_typeof(red_flags) = 'array'
	),
	constraint scam_patterns_prevention_steps_array check (
		jsonb_typeof(prevention_steps) = 'array'
	)
);
