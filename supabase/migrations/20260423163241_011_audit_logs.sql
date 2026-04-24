-- Migration: 011_audit_logs
-- Purpose: Create append-only audit_logs table
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create table if not exists public.audit_logs (
	id bigint generated always as identity primary key,
	actor_profile_id uuid references public.profiles (id),
	actor_role public.app_role,
	action_type text not null,
	entity_table text not null,
	entity_id uuid,
	before_state jsonb,
	after_state jsonb,
	metadata jsonb not null default '{}'::jsonb,
	ip_hash text,
	created_at timestamptz not null default now()
);

create or replace function public.tamitut_prevent_audit_logs_mutation()
returns trigger
language plpgsql
as $$
begin
	raise exception 'audit_logs is append-only';
end;
$$;

drop trigger if exists trg_audit_logs_prevent_mutation on public.audit_logs;

create trigger trg_audit_logs_prevent_mutation
before update or delete on public.audit_logs
for each row
execute function public.tamitut_prevent_audit_logs_mutation();
