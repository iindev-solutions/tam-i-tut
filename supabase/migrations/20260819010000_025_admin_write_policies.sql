-- Migration: 025_admin_write_policies
-- Purpose: Admin write access for the editorial admin panel (Phase 1) on the
-- city-aware slice tables. Follows the 018 moderator_admin pattern; reads
-- stay restricted by the existing policies (published/approved/active).
-- Source Design: vault/wiki/architecture/admin-panel-and-prod-plan.md (Phase 0.3)

-- places: moderator/admin full write (create, edit, publish, archive, delete).
drop policy if exists places__moderator_admin__all on public.places;
create policy places__moderator_admin__all
on public.places
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

-- place_localizations: follows the parent place write access.
drop policy if exists place_localizations__moderator_admin__all on public.place_localizations;
create policy place_localizations__moderator_admin__all
on public.place_localizations
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

-- reviews: moderator/admin moderate and manage (approve/reject/delete).
drop policy if exists reviews__moderator_admin__all on public.reviews;
create policy reviews__moderator_admin__all
on public.reviews
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

-- cities: moderator/admin edit (activate/deactivate/rename); admin creates and deletes.
drop policy if exists cities__moderator_admin__update on public.cities;
create policy cities__moderator_admin__update
on public.cities
for update
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists cities__admin__insert on public.cities;
create policy cities__admin__insert
on public.cities
for insert
with check (
	app_private.is_admin()
);

drop policy if exists cities__admin__delete on public.cities;
create policy cities__admin__delete
on public.cities
for delete
using (
	app_private.is_admin()
);
