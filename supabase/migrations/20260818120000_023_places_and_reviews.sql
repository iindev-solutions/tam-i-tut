-- Migration: 023_places_and_reviews
-- Purpose: Food-slice tables for the city-aware schema v2: places (state),
-- place_localizations (rows-per-language), reviews + review_localizations.
-- Source Design: vault/wiki/architecture/schema-v2-city-aware.md
--
-- Localized text follows the existing schema-native rows-per-language model
-- (guide_entries.language), while non-localized publish state lives once on
-- the parent row so status/verified are single-sourced across languages.

create table if not exists public.places (
	id uuid primary key default gen_random_uuid(),
	city_slug text not null references public.cities (slug) on delete cascade,
	slug text not null,
	place_type public.place_type not null,
	price_level public.price_level not null default 'average',
	verified boolean not null default false,
	status public.entry_status not null default 'draft',
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint places_slug_not_empty check (btrim(slug) <> ''),
	constraint places_slug_unique_per_city unique (city_slug, slug)
);

create table if not exists public.place_localizations (
	place_id uuid not null references public.places (id) on delete cascade,
	language public.language_code not null,
	name text not null,
	area text not null,
	summary text not null,
	constraint place_localizations_pk primary key (place_id, language),
	constraint place_localizations_name_not_empty check (btrim(name) <> ''),
	constraint place_localizations_summary_not_empty check (btrim(summary) <> '')
);

create table if not exists public.reviews (
	id uuid primary key default gen_random_uuid(),
	place_id uuid not null references public.places (id) on delete cascade,
	author text not null,
	rating smallint not null,
	status public.review_status not null default 'pending',
	created_at timestamptz not null default now(),
	constraint reviews_rating_bounds check (rating between 1 and 5),
	constraint reviews_author_not_empty check (btrim(author) <> '')
);
-- `review_localizations` is intentionally not created yet: the food UI only
-- shows approved reviews and we seed none. It will be added with the first
-- sourced, attributable review record or the admin authoring path.

alter table public.places enable row level security;
alter table public.place_localizations enable row level security;
alter table public.reviews enable row level security;

-- RLS: authenticated users read only published places, their localizations,
-- and only approved reviews (the UI counts approved reviews).
drop policy if exists places__authenticated__select_published on public.places;
create policy places__authenticated__select_published
on public.places
for select
using (
	app_private.is_authenticated()
	and status = 'published'::public.entry_status
);

drop policy if exists place_localizations__authenticated__select_published_place on public.place_localizations;
create policy place_localizations__authenticated__select_published_place
on public.place_localizations
for select
using (
	app_private.is_authenticated()
	and exists (
		select 1
		from public.places p
		where p.id = place_id
			and p.status = 'published'::public.entry_status
	)
);

drop policy if exists reviews__authenticated__select_approved on public.reviews;
create policy reviews__authenticated__select_approved
on public.reviews
for select
using (
	app_private.is_authenticated()
	and status = 'approved'::public.review_status
	and exists (
		select 1
		from public.places p
		where p.id = place_id
			and p.status = 'published'::public.entry_status
	)
);

-- Performance indexes for the read path.
create index if not exists places_city_status_idx
	on public.places (city_slug, status);
create index if not exists places_type_status_idx
	on public.places (place_type) where status = 'published'::public.entry_status;
create index if not exists place_localizations_place_language_idx
	on public.place_localizations (place_id, language);
create index if not exists reviews_place_status_idx
	on public.reviews (place_id, status);