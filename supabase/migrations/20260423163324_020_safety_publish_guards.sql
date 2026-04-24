-- Migration: 020_safety_publish_guards
-- Purpose: Create safety publish evidence guards and audit hooks
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create or replace function app_private.tamitut_validate_safety_case_status_change()
returns trigger
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
	evidence_count integer;
begin
	if tg_op = 'INSERT' then
		if new.status = 'published'::public.safety_case_status then
			raise exception 'safety case cannot be inserted as published before evidence review';
		end if;
		return new;
	end if;

	if new.status is distinct from old.status then
		if new.status = 'published'::public.safety_case_status then
			select count(*)
			into evidence_count
			from public.safety_case_evidence sce
			where sce.safety_case_id = new.id;

			if evidence_count < 1 then
				raise exception 'publishing safety case requires >= 1 evidence record';
			end if;

			new.published_at := coalesce(new.published_at, now());
		end if;

		if new.status = 'retracted'::public.safety_case_status then
			new.retracted_at := coalesce(new.retracted_at, now());
		end if;
	end if;

	return new;
end;
$$;

create or replace function app_private.tamitut_log_safety_case_status_change()
returns trigger
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
	actor_id uuid;
begin
	if new.status is distinct from old.status then
		actor_id := coalesce(auth.uid(), new.reviewed_by_profile_id, new.created_by_profile_id);

		insert into public.audit_logs (
			actor_profile_id,
			actor_role,
			action_type,
			entity_table,
			entity_id,
			before_state,
			after_state,
			metadata
		)
		values (
			actor_id,
			app_private.current_role(),
			'safety_cases.status_changed',
			'safety_cases',
			new.id,
			jsonb_build_object('status', old.status),
			jsonb_build_object('status', new.status),
			jsonb_build_object(
				'published_at', new.published_at,
				'retracted_at', new.retracted_at
			)
		);
	end if;

	return new;
end;
$$;

grant execute on function app_private.tamitut_validate_safety_case_status_change() to postgres, anon, authenticated, service_role;
grant execute on function app_private.tamitut_log_safety_case_status_change() to postgres, anon, authenticated, service_role;

drop trigger if exists trg_safety_cases_validate_status_change_insert on public.safety_cases;
create trigger trg_safety_cases_validate_status_change_insert
before insert on public.safety_cases
for each row
execute function app_private.tamitut_validate_safety_case_status_change();

drop trigger if exists trg_safety_cases_validate_status_change_update on public.safety_cases;
create trigger trg_safety_cases_validate_status_change_update
before update on public.safety_cases
for each row
execute function app_private.tamitut_validate_safety_case_status_change();

drop trigger if exists trg_safety_cases_log_status_change on public.safety_cases;
create trigger trg_safety_cases_log_status_change
after update on public.safety_cases
for each row
execute function app_private.tamitut_log_safety_case_status_change();
