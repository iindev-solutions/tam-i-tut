-- Migration: 006_trusted_sources_and_confirmations
-- Purpose: Create trusted source registry and confirmations
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create table if not exists public.trusted_sources (
	id uuid primary key default gen_random_uuid(),
	profile_id uuid not null unique references public.profiles (id) on delete cascade,
	approved_by_profile_id uuid not null references public.profiles (id),
	approved_at timestamptz not null default now(),
	is_active boolean not null default true,
	revoked_by_profile_id uuid references public.profiles (id),
	revoked_at timestamptz,
	revoke_reason text,
	notes text,
	created_at timestamptz not null default now(),
	constraint trusted_sources_revoke_consistency check (
		(
			is_active = true
			and revoked_by_profile_id is null
			and revoked_at is null
			and revoke_reason is null
		)
		or
		(
			is_active = false
			and revoked_by_profile_id is not null
			and revoked_at is not null
			and revoke_reason is not null
		)
	)
);

create table if not exists public.source_confirmations (
	id uuid primary key default gen_random_uuid(),
	guide_entry_id uuid not null references public.guide_entries (id) on delete cascade,
	trusted_source_id uuid not null references public.trusted_sources (id),
	confirmation_note text not null,
	confirmed_at timestamptz not null default now(),
	is_active boolean not null default true,
	revoked_by_profile_id uuid references public.profiles (id),
	revoked_at timestamptz,
	revoke_reason text,
	created_at timestamptz not null default now(),
	constraint source_confirmations_revoke_consistency check (
		(
			is_active = true
			and revoked_by_profile_id is null
			and revoked_at is null
			and revoke_reason is null
		)
		or
		(
			is_active = false
			and revoked_by_profile_id is not null
			and revoked_at is not null
			and revoke_reason is not null
		)
	)
);
