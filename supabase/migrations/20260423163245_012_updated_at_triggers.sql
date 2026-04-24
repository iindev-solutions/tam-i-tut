-- Migration: 012_updated_at_triggers
-- Purpose: Create and attach updated_at trigger helpers
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
	new.updated_at := now();
	return new;
end;
$$;

drop trigger if exists trg_profiles_set_updated_at on public.profiles;
create trigger trg_profiles_set_updated_at
before update on public.profiles
for each row
execute function public.set_updated_at();

drop trigger if exists trg_guide_entries_set_updated_at on public.guide_entries;
create trigger trg_guide_entries_set_updated_at
before update on public.guide_entries
for each row
execute function public.set_updated_at();

drop trigger if exists trg_trusted_contacts_set_updated_at on public.trusted_contacts;
create trigger trg_trusted_contacts_set_updated_at
before update on public.trusted_contacts
for each row
execute function public.set_updated_at();

drop trigger if exists trg_checklist_items_set_updated_at on public.checklist_items;
create trigger trg_checklist_items_set_updated_at
before update on public.checklist_items
for each row
execute function public.set_updated_at();

drop trigger if exists trg_safety_cases_set_updated_at on public.safety_cases;
create trigger trg_safety_cases_set_updated_at
before update on public.safety_cases
for each row
execute function public.set_updated_at();

drop trigger if exists trg_scam_patterns_set_updated_at on public.scam_patterns;
create trigger trg_scam_patterns_set_updated_at
before update on public.scam_patterns
for each row
execute function public.set_updated_at();

drop trigger if exists trg_user_suggestions_set_updated_at on public.user_suggestions;
create trigger trg_user_suggestions_set_updated_at
before update on public.user_suggestions
for each row
execute function public.set_updated_at();
