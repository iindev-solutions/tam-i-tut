-- Migration: 019_trust_guard_functions_and_triggers
-- Purpose: Create trust transition guard functions and triggers
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create or replace function app_private.tamitut_validate_guide_entry_trust_transition()
returns trigger
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
	active_confirmations integer;
	valid_team_checks integer;
begin
	if new.trust_badge is distinct from old.trust_badge then
		if new.trust_badge = 'recommended_expats'::public.trust_badge then
			select count(*)
			into active_confirmations
			from public.source_confirmations sc
			join public.trusted_sources ts on ts.id = sc.trusted_source_id
			where sc.guide_entry_id = new.id
				and sc.is_active = true
				and ts.is_active = true;

			if active_confirmations < 3 then
				raise exception 'recommended_expats requires >= 3 active trusted-source confirmations (found %)', active_confirmations;
			end if;
		end if;

		if new.trust_badge = 'verified_team'::public.trust_badge then
			select count(*)
			into valid_team_checks
			from public.verification_evidence ve
			where ve.guide_entry_id = new.id
				and ve.is_valid = true
				and ve.evidence_type = 'team_check'::public.evidence_type;

			if valid_team_checks < 1 then
				raise exception 'verified_team requires >= 1 valid team_check evidence (found %)', valid_team_checks;
			end if;
		end if;
	end if;

	return new;
end;
$$;

create or replace function app_private.tamitut_log_guide_entry_transitions()
returns trigger
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
	active_confirmations integer;
	valid_team_checks integer;
	actor_id uuid;
	reason public.trust_reason_code;
begin
	actor_id := coalesce(auth.uid(), new.updated_by_profile_id);

	if new.trust_badge is distinct from old.trust_badge then
		select count(*)
		into active_confirmations
		from public.source_confirmations sc
		join public.trusted_sources ts on ts.id = sc.trusted_source_id
		where sc.guide_entry_id = new.id
			and sc.is_active = true
			and ts.is_active = true;

		select count(*)
		into valid_team_checks
		from public.verification_evidence ve
		where ve.guide_entry_id = new.id
			and ve.is_valid = true
			and ve.evidence_type = 'team_check'::public.evidence_type;

		reason := case
			when old.trust_badge is null then 'initial_publish'::public.trust_reason_code
			when new.trust_badge = 'recommended_expats'::public.trust_badge then 'evidence_threshold_met'::public.trust_reason_code
			when new.trust_badge = 'verified_team'::public.trust_badge then 'team_verified'::public.trust_reason_code
			when new.trust_badge = 'under_review'::public.trust_badge then 'evidence_revoked'::public.trust_reason_code
			else 'manual_moderation'::public.trust_reason_code
		end;

		insert into public.trust_badge_events (
			guide_entry_id,
			from_badge,
			to_badge,
			reason_code,
			actor_profile_id,
			evidence_snapshot,
			notes
		)
		values (
			new.id,
			old.trust_badge,
			new.trust_badge,
			reason,
			actor_id,
			jsonb_build_array(
				jsonb_build_object(
					'active_confirmations', active_confirmations,
					'valid_team_checks', valid_team_checks
				)
			),
			null
		);

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
			'guide_entries.trust_badge_changed',
			'guide_entries',
			new.id,
			jsonb_build_object('trust_badge', old.trust_badge),
			jsonb_build_object('trust_badge', new.trust_badge),
			jsonb_build_object('reason_code', reason)
		);
	end if;

	if new.status is distinct from old.status then
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
			'guide_entries.status_changed',
			'guide_entries',
			new.id,
			jsonb_build_object('status', old.status),
			jsonb_build_object('status', new.status),
			'{}'::jsonb
		);
	end if;

	return new;
end;
$$;

grant execute on function app_private.tamitut_validate_guide_entry_trust_transition() to postgres, anon, authenticated, service_role;
grant execute on function app_private.tamitut_log_guide_entry_transitions() to postgres, anon, authenticated, service_role;

drop trigger if exists trg_guide_entries_validate_trust_transition on public.guide_entries;
create trigger trg_guide_entries_validate_trust_transition
before update on public.guide_entries
for each row
execute function app_private.tamitut_validate_guide_entry_trust_transition();

drop trigger if exists trg_guide_entries_log_transitions on public.guide_entries;
create trigger trg_guide_entries_log_transitions
after update on public.guide_entries
for each row
execute function app_private.tamitut_log_guide_entry_transitions();
