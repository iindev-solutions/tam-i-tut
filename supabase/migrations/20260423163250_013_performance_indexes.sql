-- Migration: 013_performance_indexes
-- Purpose: Create required performance and uniqueness indexes
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create index if not exists idx_guide_entries_category_status_badge_published_at
	on public.guide_entries (category_slug, status, trust_badge, published_at desc);

create index if not exists idx_guide_entries_language_status
	on public.guide_entries (language, status);

create index if not exists idx_guide_entries_verification_due_at
	on public.guide_entries (verification_due_at);

create index if not exists idx_trusted_contacts_guide_entry_id
	on public.trusted_contacts (guide_entry_id);

create unique index if not exists uq_trusted_contacts_primary_per_entry
	on public.trusted_contacts (guide_entry_id)
	where is_primary = true;

create index if not exists idx_price_snapshots_category_district_captured_on
	on public.price_snapshots (category_slug, district, captured_on desc);

create index if not exists idx_verification_evidence_entry_valid_type
	on public.verification_evidence (guide_entry_id, is_valid, evidence_type);

create index if not exists idx_source_confirmations_entry_active
	on public.source_confirmations (guide_entry_id, is_active);

create unique index if not exists uq_source_confirmations_active_per_source_and_entry
	on public.source_confirmations (guide_entry_id, trusted_source_id)
	where is_active = true;

create index if not exists idx_trust_badge_events_entry_created_at
	on public.trust_badge_events (guide_entry_id, created_at desc);

create index if not exists idx_safety_cases_status_published_at
	on public.safety_cases (status, published_at desc);

create index if not exists idx_safety_case_evidence_safety_case_id
	on public.safety_case_evidence (safety_case_id);

create index if not exists idx_user_suggestions_status_created_at
	on public.user_suggestions (status, created_at desc);

create index if not exists idx_audit_logs_entity_table_entity_id_created_at
	on public.audit_logs (entity_table, entity_id, created_at desc);

create unique index if not exists uq_checklist_items_entry_language_position
	on public.checklist_items (guide_entry_id, language, position)
	where guide_entry_id is not null;

create unique index if not exists uq_checklist_items_category_language_position
	on public.checklist_items (category_slug, language, position)
	where guide_entry_id is null;
