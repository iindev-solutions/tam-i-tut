-- Migration: 024_districts
-- Purpose: Housing slice - districts with PostGIS geometry and per-language
-- localizations (rows-per-language model, matching places/guide_entries).
-- Source Design: vault/wiki/architecture/admin-panel-and-prod-plan.md (Phase 0.2)

create extension if not exists postgis;

create table if not exists public.districts (
	id uuid primary key default gen_random_uuid(),
	city_slug text not null references public.cities (slug) on delete cascade,
	slug text not null,
	geometry geometry(Polygon, 4326) not null,
	price_level public.price_level not null default 'average',
	sort_order smallint not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint districts_slug_not_empty check (btrim(slug) <> ''),
	constraint districts_slug_unique_per_city unique (city_slug, slug),
	constraint districts_sort_order_positive check (sort_order > 0)
);

create table if not exists public.district_localizations (
	district_id uuid not null references public.districts (id) on delete cascade,
	language public.language_code not null,
	name text not null,
	area text not null,
	rent_range text not null,
	distance_to_beach text not null,
	summary text not null,
	best_for text[] not null default '{}',
	constraint district_localizations_pk primary key (district_id, language),
	constraint district_localizations_name_not_empty check (btrim(name) <> ''),
	constraint district_localizations_area_not_empty check (btrim(area) <> ''),
	constraint district_localizations_rent_range_not_empty check (btrim(rent_range) <> ''),
	constraint district_localizations_distance_not_empty check (btrim(distance_to_beach) <> ''),
	constraint district_localizations_summary_not_empty check (btrim(summary) <> '')
);

alter table public.districts enable row level security;
alter table public.district_localizations enable row level security;

-- RLS read: authenticated users see districts of ACTIVE cities only
-- (consistent with the cities/categories read posture).
drop policy if exists districts__authenticated__select_active_city on public.districts;
create policy districts__authenticated__select_active_city
on public.districts
for select
using (
	app_private.is_authenticated()
	and exists (
		select 1
		from public.cities c
		where c.slug = city_slug
			and c.is_active = true
	)
);

drop policy if exists district_localizations__authenticated__select_active_city on public.district_localizations;
create policy district_localizations__authenticated__select_active_city
on public.district_localizations
for select
using (
	app_private.is_authenticated()
	and exists (
		select 1
		from public.districts d
		join public.cities c on c.slug = d.city_slug
		where d.id = district_id
			and c.is_active = true
	)
);

-- RLS write: moderator/admin manage district geometry and housing content.
drop policy if exists districts__moderator_admin__all on public.districts;
create policy districts__moderator_admin__all
on public.districts
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists district_localizations__moderator_admin__all on public.district_localizations;
create policy district_localizations__moderator_admin__all
on public.district_localizations
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

-- Read-path indexes (city sort for the page, gist for spatial queries).
create index if not exists districts_city_sort_idx
	on public.districts (city_slug, sort_order);
create index if not exists districts_geometry_gist_idx
	on public.districts using gist (geometry);
create index if not exists district_localizations_district_language_idx
	on public.district_localizations (district_id, language);
