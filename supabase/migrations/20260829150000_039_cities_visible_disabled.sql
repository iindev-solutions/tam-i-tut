-- Migration: 039_cities_visible_disabled
-- Purpose: founder request - the city dropdown should show the upcoming
-- cities (nha-trang/pattaya/phuket) as visible-but-disabled entries instead
-- of hiding them. City rows carry only slug/name/flag - public info - so
-- authenticated readers now see every city; the UI keeps them
-- non-selectable with a "coming soon" label. Anon keeps active-only.

drop policy if exists cities__authenticated__select_active on public.cities;
create policy cities__authenticated__select_all
on public.cities
for select
using (
	app_private.is_authenticated()
);
