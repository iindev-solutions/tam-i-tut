-- Migration: 038_global_menu_scan
-- Purpose: founder UX change - menu scanning becomes a global one-tap action
-- from the home screen; the venue is optional. Scans without a venue are
-- persisted (scan history + future venue attachment) and readable by any
-- authenticated user, exactly like venue-bound menus.

alter table public.menus alter column place_id drop not null;

drop policy if exists menus__authenticated__select_published_place on public.menus;
create policy menus__authenticated__select_published_place
on public.menus
for select
using (
	app_private.is_authenticated()
	and (
		place_id is null
		or exists (
			select 1 from public.places p
			where p.id = place_id
				and p.status = 'published'::public.entry_status
		)
	)
);

drop policy if exists menu_items__authenticated__select_visible on public.menu_items;
create policy menu_items__authenticated__select_visible
on public.menu_items
for select
using (
	app_private.is_authenticated()
	and status <> 'rejected'
	and exists (
		select 1 from public.menus m
		left join public.places p on p.id = m.place_id
		where m.id = menu_id
			and (m.place_id is null or p.status = 'published'::public.entry_status)
	)
);
