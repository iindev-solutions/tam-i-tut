-- Migration: 032_default_table_grants
-- Purpose: production hardening (CI parity fix).
--   The hosted Supabase project grants table privileges to anon/
--   authenticated/service_role through platform init scripts; a fresh
--   local stack (used by the CI pgTAP job) creates tables owned by
--   postgres with NO grants, so every RLS test that reads/writes as a
--   client role fails with "permission denied for table". Grant the
--   standard Supabase posture explicitly for all current tables and
--   future ones via ALTER DEFAULT PRIVILEGES.
-- Source Design: vault/wiki/architecture/admin-panel-and-prod-plan.md (Phase 3)

grant usage on schema public to anon, authenticated, service_role;

grant select, insert, update, delete on all tables in schema public to anon;
grant select, insert, update, delete on all tables in schema public to authenticated;
grant select, insert, update, delete on all tables in schema public to service_role;
grant execute on all functions in schema public to anon;
grant execute on all functions in schema public to authenticated;

alter default privileges in schema public grant select, insert, update, delete on tables to anon;
alter default privileges in schema public grant select, insert, update, delete on tables to authenticated;
alter default privileges in schema public grant execute on functions to anon;
alter default privileges in schema public grant execute on functions to authenticated;

comment on schema public is
	'Public app schema. Table/function grants mirror the hosted Supabase default posture; data access stays gated by RLS policies.';
