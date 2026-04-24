-- Migration: 018_rls_policies_moderation_admin
-- Purpose: Create moderator/admin policies
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

drop policy if exists profiles__moderator_admin__select_all on public.profiles;
create policy profiles__moderator_admin__select_all
on public.profiles
for select
using (
	app_private.is_moderator_or_admin()
);

drop policy if exists profiles__admin__insert_all on public.profiles;
create policy profiles__admin__insert_all
on public.profiles
for insert
with check (
	app_private.is_admin()
);

drop policy if exists profiles__admin__update_all on public.profiles;
create policy profiles__admin__update_all
on public.profiles
for update
using (
	app_private.is_admin()
)
with check (
	app_private.is_admin()
);

drop policy if exists profiles__admin__delete_all on public.profiles;
create policy profiles__admin__delete_all
on public.profiles
for delete
using (
	app_private.is_admin()
);

drop policy if exists categories__moderator_admin__select_all on public.categories;
create policy categories__moderator_admin__select_all
on public.categories
for select
using (
	app_private.is_moderator_or_admin()
);

drop policy if exists categories__moderator_admin__update_all on public.categories;
create policy categories__moderator_admin__update_all
on public.categories
for update
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists categories__admin__insert_all on public.categories;
create policy categories__admin__insert_all
on public.categories
for insert
with check (
	app_private.is_admin()
);

drop policy if exists categories__admin__delete_all on public.categories;
create policy categories__admin__delete_all
on public.categories
for delete
using (
	app_private.is_admin()
);

drop policy if exists guide_entries__moderator_admin__select_all on public.guide_entries;
create policy guide_entries__moderator_admin__select_all
on public.guide_entries
for select
using (
	app_private.is_moderator_or_admin()
);

drop policy if exists guide_entries__moderator_admin__insert_all on public.guide_entries;
create policy guide_entries__moderator_admin__insert_all
on public.guide_entries
for insert
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists guide_entries__moderator_admin__update_all on public.guide_entries;
create policy guide_entries__moderator_admin__update_all
on public.guide_entries
for update
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists guide_entries__moderator_admin__delete_all on public.guide_entries;
create policy guide_entries__moderator_admin__delete_all
on public.guide_entries
for delete
using (
	app_private.is_moderator_or_admin()
);

drop policy if exists trusted_contacts__moderator_admin__all on public.trusted_contacts;
create policy trusted_contacts__moderator_admin__all
on public.trusted_contacts
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists price_snapshots__moderator_admin__all on public.price_snapshots;
create policy price_snapshots__moderator_admin__all
on public.price_snapshots
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists checklist_items__moderator_admin__all on public.checklist_items;
create policy checklist_items__moderator_admin__all
on public.checklist_items
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists verification_evidence__moderator_admin__all on public.verification_evidence;
create policy verification_evidence__moderator_admin__all
on public.verification_evidence
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists trusted_sources__moderator_admin__select_all on public.trusted_sources;
create policy trusted_sources__moderator_admin__select_all
on public.trusted_sources
for select
using (
	app_private.is_moderator_or_admin()
);

drop policy if exists trusted_sources__moderator_admin__insert_all on public.trusted_sources;
create policy trusted_sources__moderator_admin__insert_all
on public.trusted_sources
for insert
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists trusted_sources__moderator_admin__update_all on public.trusted_sources;
create policy trusted_sources__moderator_admin__update_all
on public.trusted_sources
for update
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists trusted_sources__admin__delete_all on public.trusted_sources;
create policy trusted_sources__admin__delete_all
on public.trusted_sources
for delete
using (
	app_private.is_admin()
);

drop policy if exists source_confirmations__moderator_admin__all on public.source_confirmations;
create policy source_confirmations__moderator_admin__all
on public.source_confirmations
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists trust_badge_events__moderator_admin__select_all on public.trust_badge_events;
create policy trust_badge_events__moderator_admin__select_all
on public.trust_badge_events
for select
using (
	app_private.is_moderator_or_admin()
);

drop policy if exists trust_badge_events__moderator_admin__insert_all on public.trust_badge_events;
create policy trust_badge_events__moderator_admin__insert_all
on public.trust_badge_events
for insert
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists safety_cases__moderator_admin__all on public.safety_cases;
create policy safety_cases__moderator_admin__all
on public.safety_cases
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists safety_case_evidence__moderator_admin__all on public.safety_case_evidence;
create policy safety_case_evidence__moderator_admin__all
on public.safety_case_evidence
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists scam_patterns__moderator_admin__all on public.scam_patterns;
create policy scam_patterns__moderator_admin__all
on public.scam_patterns
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists user_suggestions__moderator_admin__all on public.user_suggestions;
create policy user_suggestions__moderator_admin__all
on public.user_suggestions
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists audit_logs__moderator__select_own on public.audit_logs;
create policy audit_logs__moderator__select_own
on public.audit_logs
for select
using (
	app_private.is_moderator()
	and actor_profile_id = auth.uid()
);

drop policy if exists audit_logs__admin__select_all on public.audit_logs;
create policy audit_logs__admin__select_all
on public.audit_logs
for select
using (
	app_private.is_admin()
);
