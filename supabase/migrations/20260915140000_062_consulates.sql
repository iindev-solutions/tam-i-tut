-- Migration: 062_consulates
-- Purpose: move consular facts out of i18n copy into the city-scoped data layer.
--
-- The consulate address lived in `i18n/locales/{ru,en}.json` as a static string.
-- It was WRONG (it said Trần Hưng Đạo; the consulate is at 22 Trần Phú), and the
-- structural problem is bigger than the typo: a fact in a locale file cannot be
-- corrected by an admin, cannot carry its source, and cannot be re-checked -
-- while the emergency numbers rendered directly above it are DB rows with
-- moderator/admin write policies. Same class of data, two different lifetimes.
--
-- Source of record: the consulate's own site, rusconsdanang.mid.ru (contacts
-- page), read 2026-09-15. That is the issuing authority, so it also settles the
-- earlier "which street" question rather than a third-party guide.

create table if not exists public.consulates (
	id uuid primary key default gen_random_uuid(),
	city_slug text not null references public.cities (slug) on delete cascade,
	country_code text not null,
	name_ru text not null,
	name_en text not null,
	-- Street address stays in the Vietnamese form on purpose: it is what a
	-- taxi driver reads, so it is not localized.
	address text not null,
	hours_ru text not null default '',
	hours_en text not null default '',
	phone text,
	-- The round-the-clock line for emergencies, distinct from the office line.
	emergency_phone text,
	-- Where the row came from, so a reader can audit it and an editor knows
	-- what to re-check.
	source text not null,
	sort_order smallint not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint consulates_name_ru_not_empty check (btrim(name_ru) <> ''),
	constraint consulates_address_not_empty check (btrim(address) <> ''),
	constraint consulates_source_not_empty check (btrim(source) <> ''),
	constraint consulates_city_sort_unique unique (city_slug, sort_order)
);

create index if not exists consulates_city_sort_idx
	on public.consulates (city_slug, sort_order);

alter table public.consulates enable row level security;

-- Read: authenticated users see consulates of ACTIVE cities only (same posture
-- as districts 024, emergency_contacts 058, clinics 061).
drop policy if exists consulates__authenticated__select_active_city on public.consulates;
create policy consulates__authenticated__select_active_city
on public.consulates
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

-- Write: moderator/admin manage the list - this is the whole point of the move.
drop policy if exists consulates__moderator_admin__all on public.consulates;
create policy consulates__moderator_admin__all
on public.consulates
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

insert into public.consulates (
	city_slug, country_code, name_ru, name_en, address,
	hours_ru, hours_en, phone, emergency_phone, source, sort_order
)
values (
	'da-nang',
	'RU',
	'Генконсульство России',
	'Russian Consulate General',
	'22 Trần Phú, Thạch Thang, Hải Châu, Đà Nẵng',
	'пн, вт, чт, пт 9:00-11:30',
	'Mon, Tue, Thu, Fri 9:00-11:30',
	'+84 236 382 23 80',
	'+84 94 720-00-94',
	'rusconsdanang.mid.ru, 2026-09-15',
	1
)
on conflict (city_slug, sort_order) do update
set
	name_ru = excluded.name_ru,
	name_en = excluded.name_en,
	address = excluded.address,
	hours_ru = excluded.hours_ru,
	hours_en = excluded.hours_en,
	phone = excluded.phone,
	emergency_phone = excluded.emergency_phone,
	source = excluded.source,
	updated_at = now();
