-- Migration: 007_trust_badge_events
-- Purpose: Create trust badge transition event log table
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create table if not exists public.trust_badge_events (
	id uuid primary key default gen_random_uuid(),
	guide_entry_id uuid not null references public.guide_entries (id) on delete cascade,
	from_badge public.trust_badge,
	to_badge public.trust_badge not null,
	reason_code public.trust_reason_code not null,
	actor_profile_id uuid not null references public.profiles (id),
	evidence_snapshot jsonb not null default '[]'::jsonb,
	notes text,
	created_at timestamptz not null default now(),
	constraint trust_badge_events_badge_transition check (
		from_badge is null or from_badge <> to_badge
	),
	constraint trust_badge_events_evidence_snapshot_array check (
		jsonb_typeof(evidence_snapshot) = 'array'
	)
);
