-- Migration: 014_rls_helpers
-- Purpose: Create reusable role/ownership helper functions for RLS
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create schema if not exists app_private;

create or replace function app_private.current_user_id()
returns uuid
language sql
stable
as $$
	select auth.uid();
$$;

create or replace function app_private.current_role()
returns public.app_role
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
	select coalesce(
		(
			select p.role
			from public.profiles p
			where p.id = auth.uid()
				and p.is_active = true
		),
		'user'::public.app_role
	);
$$;

create or replace function app_private.is_authenticated()
returns boolean
language sql
stable
as $$
	select auth.uid() is not null;
$$;

create or replace function app_private.is_admin()
returns boolean
language sql
stable
as $$
	select app_private.current_role() = 'admin'::public.app_role;
$$;

create or replace function app_private.is_moderator()
returns boolean
language sql
stable
as $$
	select app_private.current_role() = 'moderator'::public.app_role;
$$;

create or replace function app_private.is_curator()
returns boolean
language sql
stable
as $$
	select app_private.current_role() = 'curator'::public.app_role;
$$;

create or replace function app_private.is_trusted_source()
returns boolean
language sql
stable
as $$
	select app_private.current_role() = 'trusted_source'::public.app_role;
$$;

create or replace function app_private.is_moderator_or_admin()
returns boolean
language sql
stable
as $$
	select app_private.current_role() in ('moderator'::public.app_role, 'admin'::public.app_role);
$$;

create or replace function app_private.is_curator_or_higher()
returns boolean
language sql
stable
as $$
	select app_private.current_role() in ('curator'::public.app_role, 'moderator'::public.app_role, 'admin'::public.app_role);
$$;

create or replace function app_private.is_self(profile_id uuid)
returns boolean
language sql
stable
as $$
	select auth.uid() is not null and profile_id = auth.uid();
$$;

create or replace function app_private.current_trusted_source_id()
returns uuid
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
	select ts.id
	from public.trusted_sources ts
	where ts.profile_id = auth.uid()
		and ts.is_active = true
	limit 1;
$$;

create or replace function app_private.is_entry_published(entry_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
	select exists(
		select 1
		from public.guide_entries ge
		where ge.id = entry_id
			and ge.status = 'published'::public.entry_status
	);
$$;

create or replace function app_private.is_entry_owner(entry_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
	select exists(
		select 1
		from public.guide_entries ge
		where ge.id = entry_id
			and ge.owner_profile_id = auth.uid()
	);
$$;

create or replace function app_private.can_curator_manage_entry(entry_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
	select exists(
		select 1
		from public.guide_entries ge
		where ge.id = entry_id
			and ge.owner_profile_id = auth.uid()
			and ge.status in ('draft'::public.entry_status, 'published'::public.entry_status)
	);
$$;

create or replace function app_private.can_curator_manage_draft_entry(entry_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, auth, pg_temp
as $$
	select exists(
		select 1
		from public.guide_entries ge
		where ge.id = entry_id
			and ge.owner_profile_id = auth.uid()
			and ge.status = 'draft'::public.entry_status
	);
$$;

grant usage on schema app_private to postgres, anon, authenticated, service_role;
grant execute on all functions in schema app_private to postgres, anon, authenticated, service_role;
