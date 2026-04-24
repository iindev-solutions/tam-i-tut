-- Migration: 017_rls_policies_curation_write
-- Purpose: Create curator write policies for draft/evidence scope
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

drop policy if exists profiles__self__update_no_role_escalation on public.profiles;
create policy profiles__self__update_no_role_escalation
on public.profiles
for update
using (
	app_private.is_authenticated()
	and app_private.is_self(id)
)
with check (
	app_private.is_authenticated()
	and app_private.is_self(id)
	and role = app_private.current_role()
);

drop policy if exists guide_entries__curator__select_own_drafts on public.guide_entries;
create policy guide_entries__curator__select_own_drafts
on public.guide_entries
for select
using (
	app_private.is_curator()
	and owner_profile_id = auth.uid()
	and status = 'draft'::public.entry_status
);

drop policy if exists guide_entries__curator__insert_own_drafts on public.guide_entries;
create policy guide_entries__curator__insert_own_drafts
on public.guide_entries
for insert
with check (
	app_private.is_curator()
	and owner_profile_id = auth.uid()
	and created_by_profile_id = auth.uid()
	and updated_by_profile_id = auth.uid()
	and status = 'draft'::public.entry_status
	and trust_badge = 'under_review'::public.trust_badge
);

drop policy if exists guide_entries__curator__update_own_drafts on public.guide_entries;
create policy guide_entries__curator__update_own_drafts
on public.guide_entries
for update
using (
	app_private.is_curator()
	and owner_profile_id = auth.uid()
	and status = 'draft'::public.entry_status
)
with check (
	app_private.is_curator()
	and owner_profile_id = auth.uid()
	and updated_by_profile_id = auth.uid()
	and status = 'draft'::public.entry_status
	and trust_badge = 'under_review'::public.trust_badge
);

drop policy if exists trusted_contacts__curator__select_manageable_entries on public.trusted_contacts;
create policy trusted_contacts__curator__select_manageable_entries
on public.trusted_contacts
for select
using (
	app_private.is_curator()
	and app_private.can_curator_manage_entry(guide_entry_id)
);

drop policy if exists trusted_contacts__curator__write_manageable_entries on public.trusted_contacts;
create policy trusted_contacts__curator__write_manageable_entries
on public.trusted_contacts
for all
using (
	app_private.is_curator()
	and app_private.can_curator_manage_entry(guide_entry_id)
)
with check (
	app_private.is_curator()
	and app_private.can_curator_manage_entry(guide_entry_id)
);

drop policy if exists price_snapshots__curator__select_manageable_scope on public.price_snapshots;
create policy price_snapshots__curator__select_manageable_scope
on public.price_snapshots
for select
using (
	app_private.is_curator()
	and (
		guide_entry_id is null
		or app_private.can_curator_manage_entry(guide_entry_id)
	)
);

drop policy if exists price_snapshots__curator__write_manageable_scope on public.price_snapshots;
create policy price_snapshots__curator__write_manageable_scope
on public.price_snapshots
for all
using (
	app_private.is_curator()
	and (
		guide_entry_id is null
		or app_private.can_curator_manage_entry(guide_entry_id)
	)
)
with check (
	app_private.is_curator()
	and (
		guide_entry_id is null
		or app_private.can_curator_manage_entry(guide_entry_id)
	)
);

drop policy if exists checklist_items__curator__select_manageable_scope on public.checklist_items;
create policy checklist_items__curator__select_manageable_scope
on public.checklist_items
for select
using (
	app_private.is_curator()
	and (
		guide_entry_id is null
		or app_private.can_curator_manage_entry(guide_entry_id)
	)
);

drop policy if exists checklist_items__curator__write_manageable_scope on public.checklist_items;
create policy checklist_items__curator__write_manageable_scope
on public.checklist_items
for all
using (
	app_private.is_curator()
	and (
		guide_entry_id is null
		or app_private.can_curator_manage_entry(guide_entry_id)
	)
)
with check (
	app_private.is_curator()
	and (
		guide_entry_id is null
		or app_private.can_curator_manage_entry(guide_entry_id)
	)
);

drop policy if exists verification_evidence__curator__select_own_draft_entries on public.verification_evidence;
create policy verification_evidence__curator__select_own_draft_entries
on public.verification_evidence
for select
using (
	app_private.is_curator()
	and app_private.can_curator_manage_draft_entry(guide_entry_id)
);

drop policy if exists verification_evidence__curator__write_own_draft_entries on public.verification_evidence;
create policy verification_evidence__curator__write_own_draft_entries
on public.verification_evidence
for all
using (
	app_private.is_curator()
	and app_private.can_curator_manage_draft_entry(guide_entry_id)
)
with check (
	app_private.is_curator()
	and app_private.can_curator_manage_draft_entry(guide_entry_id)
	and submitted_by_profile_id = auth.uid()
);

drop policy if exists verification_evidence__trusted_source__select_own_confirmations on public.verification_evidence;
create policy verification_evidence__trusted_source__select_own_confirmations
on public.verification_evidence
for select
using (
	app_private.is_trusted_source()
	and submitted_by_profile_id = auth.uid()
	and evidence_type = 'trusted_confirmation'::public.evidence_type
);

drop policy if exists trusted_sources__trusted_source__select_self on public.trusted_sources;
create policy trusted_sources__trusted_source__select_self
on public.trusted_sources
for select
using (
	app_private.is_trusted_source()
	and profile_id = auth.uid()
);

drop policy if exists source_confirmations__curator__select_all on public.source_confirmations;
create policy source_confirmations__curator__select_all
on public.source_confirmations
for select
using (
	app_private.is_curator()
);

drop policy if exists source_confirmations__trusted_source__select_own on public.source_confirmations;
create policy source_confirmations__trusted_source__select_own
on public.source_confirmations
for select
using (
	app_private.is_trusted_source()
	and trusted_source_id = app_private.current_trusted_source_id()
);

drop policy if exists source_confirmations__trusted_source__insert_own on public.source_confirmations;
create policy source_confirmations__trusted_source__insert_own
on public.source_confirmations
for insert
with check (
	app_private.is_trusted_source()
	and trusted_source_id = app_private.current_trusted_source_id()
);

drop policy if exists source_confirmations__trusted_source__update_own on public.source_confirmations;
create policy source_confirmations__trusted_source__update_own
on public.source_confirmations
for update
using (
	app_private.is_trusted_source()
	and trusted_source_id = app_private.current_trusted_source_id()
)
with check (
	app_private.is_trusted_source()
	and trusted_source_id = app_private.current_trusted_source_id()
);

drop policy if exists trust_badge_events__curator__select_all on public.trust_badge_events;
create policy trust_badge_events__curator__select_all
on public.trust_badge_events
for select
using (
	app_private.is_curator()
);

drop policy if exists safety_cases__curator__select_all on public.safety_cases;
create policy safety_cases__curator__select_all
on public.safety_cases
for select
using (
	app_private.is_curator()
);

drop policy if exists safety_case_evidence__curator__select_all on public.safety_case_evidence;
create policy safety_case_evidence__curator__select_all
on public.safety_case_evidence
for select
using (
	app_private.is_curator()
);

drop policy if exists user_suggestions__owner__insert_new on public.user_suggestions;
create policy user_suggestions__owner__insert_new
on public.user_suggestions
for insert
with check (
	app_private.is_authenticated()
	and submitted_by_profile_id = auth.uid()
	and status = 'new'::public.suggestion_status
	and reviewer_profile_id is null
	and linked_guide_entry_id is null
	and resolved_at is null
);

drop policy if exists user_suggestions__owner__update_own_new on public.user_suggestions;
create policy user_suggestions__owner__update_own_new
on public.user_suggestions
for update
using (
	app_private.is_authenticated()
	and submitted_by_profile_id = auth.uid()
)
with check (
	app_private.is_authenticated()
	and submitted_by_profile_id = auth.uid()
	and status = 'new'::public.suggestion_status
	and reviewer_profile_id is null
	and linked_guide_entry_id is null
	and resolved_at is null
);

drop policy if exists user_suggestions__curator__select_all on public.user_suggestions;
create policy user_suggestions__curator__select_all
on public.user_suggestions
for select
using (
	app_private.is_curator()
);

drop policy if exists user_suggestions__curator__update_triage on public.user_suggestions;
create policy user_suggestions__curator__update_triage
on public.user_suggestions
for update
using (
	app_private.is_curator()
)
with check (
	app_private.is_curator()
	and reviewer_profile_id = auth.uid()
	and status in (
		'triaged'::public.suggestion_status,
		'accepted'::public.suggestion_status,
		'rejected'::public.suggestion_status,
		'merged'::public.suggestion_status
	)
);
