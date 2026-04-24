-- Migration: 015_enable_rls
-- Purpose: Enable RLS on exposed operational tables
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

alter table if exists public.profiles enable row level security;
alter table if exists public.categories enable row level security;
alter table if exists public.guide_entries enable row level security;
alter table if exists public.trusted_contacts enable row level security;
alter table if exists public.price_snapshots enable row level security;
alter table if exists public.checklist_items enable row level security;
alter table if exists public.verification_evidence enable row level security;
alter table if exists public.trusted_sources enable row level security;
alter table if exists public.source_confirmations enable row level security;
alter table if exists public.trust_badge_events enable row level security;
alter table if exists public.safety_cases enable row level security;
alter table if exists public.safety_case_evidence enable row level security;
alter table if exists public.scam_patterns enable row level security;
alter table if exists public.user_suggestions enable row level security;
alter table if exists public.audit_logs enable row level security;
