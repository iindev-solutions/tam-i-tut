-- Migration: 049_menu_curation_reviews_events
-- Purpose: Menu translator Phase B + user review submission + pilot metrics.
--   1) moderator/admin write access on the menu translator tables (curation
--      queue: verify/reject items, link dictionary dishes, verify menus);
--   2) authenticated users submit reviews (pending moderation) + a free-text
--      body column on reviews (the original schema shipped rating-only);
--   3) app_events metrics table: authenticated inserts, moderator/admin reads;
--   4) nightly purge of menu-photos Storage objects older than 90 days
--      (spec section 8; menus.photo_path is nulled in the same run so no
--      reader ever points at a purged object).

-- 1) Curation write access ---------------------------------------------------
-- FOR ALL policies are permissive and OR'ed with the reader policies from 036,
-- so admins also see rejected items and menus of draft venues (the curation
-- queue needs both; readers stay restricted by the 036 policies).
drop policy if exists menu_items__moderator_admin__all on public.menu_items;
create policy menu_items__moderator_admin__all
on public.menu_items
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists menus__moderator_admin__all on public.menus;
create policy menus__moderator_admin__all
on public.menus
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

-- Dictionary growth: admins link unmatched lines to dishes and edit entries.
drop policy if exists dishes__moderator_admin__all on public.dishes;
create policy dishes__moderator_admin__all
on public.dishes
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists dish_localizations__moderator_admin__all on public.dish_localizations;
create policy dish_localizations__moderator_admin__all
on public.dish_localizations
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

-- 2) User review submission ---------------------------------------------------
-- Free-text body: the pilot review UI collects rating + optional text.
alter table public.reviews
	add column if not exists body text
	constraint reviews_body_not_empty check (body is null or btrim(body) <> '');

drop policy if exists reviews__authenticated__insert_pending on public.reviews;
create policy reviews__authenticated__insert_pending
on public.reviews
for insert
with check (
	app_private.is_authenticated()
	and status = 'pending'::public.review_status
	and exists (
		select 1
		from public.places p
		where p.id = place_id
			and p.status = 'published'::public.entry_status
	)
);

-- 3) Pilot metrics -------------------------------------------------------------
create table if not exists public.app_events (
	id uuid primary key default gen_random_uuid(),
	user_id uuid references auth.users (id) on delete set null default auth.uid(),
	event text not null,
	metadata jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now(),
	constraint app_events_event_not_empty check (btrim(event) <> '')
);

create index if not exists app_events_event_created_idx
	on public.app_events (event, created_at desc);

alter table public.app_events enable row level security;

-- Users log their own events (user_id is forced to the session identity or null).
drop policy if exists app_events__authenticated__insert on public.app_events;
create policy app_events__authenticated__insert
on public.app_events
for insert
with check (
	app_private.is_authenticated()
	and (user_id is null or user_id = (auth.uid()))
);

-- Events are ops data: readable by moderators/admins only.
drop policy if exists app_events__moderator_admin__select on public.app_events;
create policy app_events__moderator_admin__select
on public.app_events
for select
using (
	app_private.is_moderator_or_admin()
);

-- 4) Storage retention (spec section 8: 90 days) --------------------------------
-- Runs nightly after the nonce purge. The DO block keeps the two statements
-- (null the pointer, then drop the object) atomic per run.
select cron.unschedule(jobid)
from cron.job
where jobname = 'tamitut-menu-photos-purge';

select cron.schedule(
	'tamitut-menu-photos-purge',
	'30 3 * * *',
	$cron$
	do $$
	begin
		update public.menus
		set photo_path = null
		where photo_path is not null
			and created_at < now() - interval '90 days';
		delete from storage.objects
		where bucket_id = 'menu-photos'
			and created_at < now() - interval '90 days';
	end $$;
	$cron$
);
