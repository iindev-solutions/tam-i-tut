-- Migration: 027_cities_admin_select
-- Purpose: Fix a real RLS gap found by pgTAP 011: cities had moderator/admin
-- UPDATE/INSERT/DELETE policies but NO SELECT-all, so admins could not see
-- inactive cities, and `update cities set is_active = false` failed with
-- 42501 (the updated row must remain visible under a policy applying to the
-- user). Mirrors the existing `categories__moderator_admin__select_all` from
-- migration 018.

drop policy if exists cities__moderator_admin__select_all on public.cities;
create policy cities__moderator_admin__select_all
on public.cities
for select
using (
	app_private.is_moderator_or_admin()
);
