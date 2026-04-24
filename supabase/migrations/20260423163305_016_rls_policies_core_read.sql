-- Migration: 016_rls_policies_core_read
-- Purpose: Create published/read policies for public-facing data
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

drop policy if exists profiles__self__select on public.profiles;
create policy profiles__self__select
on public.profiles
for select
using (
	app_private.is_authenticated()
	and app_private.is_self(id)
);

drop policy if exists categories__authenticated__select_active on public.categories;
create policy categories__authenticated__select_active
on public.categories
for select
using (
	app_private.is_authenticated()
	and is_active = true
);

drop policy if exists guide_entries__authenticated__select_published on public.guide_entries;
create policy guide_entries__authenticated__select_published
on public.guide_entries
for select
using (
	app_private.is_authenticated()
	and status = 'published'::public.entry_status
);

drop policy if exists trusted_contacts__authenticated__select_published_entries on public.trusted_contacts;
create policy trusted_contacts__authenticated__select_published_entries
on public.trusted_contacts
for select
using (
	app_private.is_authenticated()
	and app_private.is_entry_published(guide_entry_id)
);

drop policy if exists price_snapshots__authenticated__select_public_scope on public.price_snapshots;
create policy price_snapshots__authenticated__select_public_scope
on public.price_snapshots
for select
using (
	app_private.is_authenticated()
	and (
		guide_entry_id is null
		or app_private.is_entry_published(guide_entry_id)
	)
);

drop policy if exists checklist_items__authenticated__select_public_scope on public.checklist_items;
create policy checklist_items__authenticated__select_public_scope
on public.checklist_items
for select
using (
	app_private.is_authenticated()
	and (
		guide_entry_id is null
		or app_private.is_entry_published(guide_entry_id)
	)
);

drop policy if exists trust_badge_events__authenticated__select_published_entries on public.trust_badge_events;
create policy trust_badge_events__authenticated__select_published_entries
on public.trust_badge_events
for select
using (
	app_private.is_authenticated()
	and app_private.is_entry_published(guide_entry_id)
);

drop policy if exists safety_cases__authenticated__select_published on public.safety_cases;
create policy safety_cases__authenticated__select_published
on public.safety_cases
for select
using (
	app_private.is_authenticated()
	and status = 'published'::public.safety_case_status
);

drop policy if exists safety_case_evidence__authenticated__select_published_cases on public.safety_case_evidence;
create policy safety_case_evidence__authenticated__select_published_cases
on public.safety_case_evidence
for select
using (
	app_private.is_authenticated()
	and exists (
		select 1
		from public.safety_cases sc
		where sc.id = safety_case_id
			and sc.status = 'published'::public.safety_case_status
	)
);

drop policy if exists scam_patterns__authenticated__select_active on public.scam_patterns;
create policy scam_patterns__authenticated__select_active
on public.scam_patterns
for select
using (
	app_private.is_authenticated()
	and is_active = true
);

drop policy if exists user_suggestions__owner__select_own on public.user_suggestions;
create policy user_suggestions__owner__select_own
on public.user_suggestions
for select
using (
	app_private.is_authenticated()
	and submitted_by_profile_id = auth.uid()
);
