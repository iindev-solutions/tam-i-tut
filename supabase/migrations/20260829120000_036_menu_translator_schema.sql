-- Migration: 036_menu_translator_schema
-- Purpose: Menu translator Phase A (spec: vault/wiki/architecture/menu-translator-spec.md).
-- Canonical dish dictionary + per-venue menu scans. Readers are authenticated
-- TMA sessions; all writes go through the menu-translate Edge Function
-- (service_role bypasses RLS) - user/admin write policies land with Phase B
-- curation. Also creates the private menu-photos Storage bucket (first
-- Storage usage; uploads are function-only).

-- Dictionary ---------------------------------------------------------------
create table if not exists public.dishes (
	id uuid primary key default gen_random_uuid(),
	slug text not null unique,
	name_vi text not null,
	photo_url text,
	tags text[] not null default '{}',
	verified boolean not null default false,
	status public.entry_status not null default 'draft',
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint dishes_slug_not_empty check (btrim(slug) <> ''),
	constraint dishes_name_vi_not_empty check (btrim(name_vi) <> '')
);

create table if not exists public.dish_localizations (
	dish_id uuid not null references public.dishes on delete cascade,
	language public.language_code not null,
	name text not null,
	summary text not null,
	primary key (dish_id, language),
	constraint dish_localizations_name_not_empty check (btrim(name) <> ''),
	constraint dish_localizations_summary_not_empty check (btrim(summary) <> '')
);

create index if not exists dishes_status_idx on public.dishes (status) where status = 'published';
create index if not exists dish_localizations_dish_language_idx
	on public.dish_localizations (dish_id, language);

-- Scans --------------------------------------------------------------------
create table if not exists public.menus (
	id uuid primary key default gen_random_uuid(),
	place_id uuid not null references public.places on delete cascade,
	photo_path text,
	status text not null default 'ai' check (status in ('ai', 'verified')),
	scanned_by uuid references auth.users on delete set null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create index if not exists menus_place_idx on public.menus (place_id, status);

create table if not exists public.menu_items (
	id uuid primary key default gen_random_uuid(),
	menu_id uuid not null references public.menus on delete cascade,
	raw_text_vi text not null,
	price_vnd integer check (price_vnd >= 0),
	dish_id uuid references public.dishes on delete set null,
	ai_name_ru text,
	ai_name_en text,
	ai_summary_ru text,
	ai_summary_en text,
	confidence smallint check (confidence between 0 and 100),
	status text not null default 'ai' check (status in ('ai', 'verified', 'rejected')),
	position smallint not null default 0,
	created_at timestamptz not null default now(),
	constraint menu_items_raw_not_empty check (btrim(raw_text_vi) <> '')
);

create index if not exists menu_items_menu_idx on public.menu_items (menu_id, position);

-- RLS ----------------------------------------------------------------------
alter table public.dishes enable row level security;
alter table public.dish_localizations enable row level security;
alter table public.menus enable row level security;
alter table public.menu_items enable row level security;

drop policy if exists dishes__authenticated__select_published on public.dishes;
create policy dishes__authenticated__select_published
on public.dishes
for select
using (
	app_private.is_authenticated()
	and status = 'published'::public.entry_status
);

drop policy if exists dish_localizations__authenticated__select_published_dish on public.dish_localizations;
create policy dish_localizations__authenticated__select_published_dish
on public.dish_localizations
for select
using (
	app_private.is_authenticated()
	and exists (
		select 1 from public.dishes d
		where d.id = dish_id
			and d.status = 'published'::public.entry_status
	)
);

-- Menus are public-facing content for signed-in readers; the parent place
-- must be published (same leak-guard shape as the place_localizations policy).
drop policy if exists menus__authenticated__select_published_place on public.menus;
create policy menus__authenticated__select_published_place
on public.menus
for select
using (
	app_private.is_authenticated()
	and exists (
		select 1 from public.places p
		where p.id = place_id
			and p.status = 'published'::public.entry_status
	)
);

-- Items follow the parent menu; rejected items never reach readers.
drop policy if exists menu_items__authenticated__select_visible on public.menu_items;
create policy menu_items__authenticated__select_visible
on public.menu_items
for select
using (
	app_private.is_authenticated()
	and status <> 'rejected'
	and exists (
		select 1 from public.menus m
		join public.places p on p.id = m.place_id
		where m.id = menu_id
			and p.status = 'published'::public.entry_status
	)
);

-- Storage ------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('menu-photos', 'menu-photos', false)
on conflict (id) do nothing;
