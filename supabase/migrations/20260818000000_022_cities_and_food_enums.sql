-- Migration: 022_cities_and_food_enums
-- Purpose: Add the city tenancy axis and food-slice enums (schema v2).
-- Source Design: vault/wiki/architecture/schema-v2-city-aware.md

-- Cities (tenancy axis for city-scoped content).
create table if not exists public.cities (
	slug text primary key,
	name_en text not null,
	name_ru text not null,
	country_code char(2) not null default 'VN',
	flag text not null default '🇻🇳',
	is_active boolean not null default false,
	sort_order smallint not null unique,
	created_at timestamptz not null default now(),
	constraint cities_slug_not_empty check (btrim(slug) <> ''),
	constraint cities_name_en_not_empty check (btrim(name_en) <> ''),
	constraint cities_name_ru_not_empty check (btrim(name_ru) <> ''),
	constraint cities_sort_order_positive check (sort_order > 0)
);

alter table public.cities enable row level security;

create index if not exists cities_active_sort_idx
	on public.cities (is_active, sort_order);

-- Food slice enums (schema v2).
DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'place_type') THEN
		CREATE TYPE public.place_type AS ENUM ('cafe', 'street', 'market', 'restaurant');
	END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'price_level') THEN
		CREATE TYPE public.price_level AS ENUM ('budget', 'average', 'above');
	END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'review_status') THEN
		CREATE TYPE public.review_status AS ENUM ('pending', 'approved', 'rejected');
	END IF;
END$$;

-- RLS: authenticated users may read active cities (consistent with the
-- existing read posture which requires an authenticated session).
drop policy if exists cities__authenticated__select_active on public.cities;
create policy cities__authenticated__select_active
on public.cities
for select
using (
	app_private.is_authenticated()
	and is_active = true
);