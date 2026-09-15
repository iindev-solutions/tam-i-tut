-- Migration: 058_trust_layer
-- Purpose: make the documented trust model reachable from the Mini App.
--
-- 1) emergency_contacts: city-scoped emergency numbers. The safety page read
--    its contact block from the frontend mock only, and mock fallback is
--    dev-only (useDb), so production rendered an empty block on the most
--    trust-critical screen. Numbers are per-country, so they hang off the
--    city tenancy axis like districts do.
--
-- 2) places.trust_badge + places.last_verified_at replace the boolean
--    `verified` column. A boolean cannot express the three documented levels
--    (under_review / recommended_expats / verified_team - README "Trust Model")
--    and carries no verification date, while the product promise is
--    "badge + verification date + evidence discipline". guide_entries already
--    uses this model (003); places now matches it instead of keeping a second
--    convention for the same fact.

-- 1) Emergency contacts ------------------------------------------------------

create table if not exists public.emergency_contacts (
	id uuid primary key default gen_random_uuid(),
	city_slug text not null references public.cities (slug) on delete cascade,
	number text not null,
	label_ru text not null,
	label_en text not null,
	sort_order smallint not null,
	constraint emergency_contacts_number_not_empty check (btrim(number) <> ''),
	constraint emergency_contacts_label_ru_not_empty check (btrim(label_ru) <> ''),
	constraint emergency_contacts_label_en_not_empty check (btrim(label_en) <> ''),
	constraint emergency_contacts_city_sort_unique unique (city_slug, sort_order)
);

create index if not exists emergency_contacts_city_sort_idx
	on public.emergency_contacts (city_slug, sort_order);

alter table public.emergency_contacts enable row level security;

-- Read: authenticated users see contacts of ACTIVE cities only (same posture
-- as districts/categories in 024).
drop policy if exists emergency_contacts__authenticated__select_active_city on public.emergency_contacts;
create policy emergency_contacts__authenticated__select_active_city
on public.emergency_contacts
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

-- Write: moderator/admin manage the list.
drop policy if exists emergency_contacts__moderator_admin__all on public.emergency_contacts;
create policy emergency_contacts__moderator_admin__all
on public.emergency_contacts
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

-- 2) Places trust model ------------------------------------------------------

alter table public.places
	add column if not exists trust_badge public.trust_badge not null default 'under_review';

alter table public.places
	add column if not exists last_verified_at timestamptz;

-- Backfill from the boolean: a row the team marked verified becomes
-- verified_team with the best available verification evidence (its last
-- update). Rows left unverified stay under_review with no date.
-- On a fresh stack this is a no-op: seed.sql runs after all migrations.
update public.places
set
	trust_badge = 'verified_team',
	last_verified_at = coalesce(updated_at, now())
where verified = true
	and trust_badge = 'under_review';

alter table public.places drop column if exists verified;

-- A trusted place must carry its verification date - the badge is only
-- meaningful together with when the team last checked it.
alter table public.places drop constraint if exists places_trust_requires_verified_at;
alter table public.places
	add constraint places_trust_requires_verified_at
	check (trust_badge = 'under_review' or last_verified_at is not null);

create index if not exists places_trust_badge_idx
	on public.places (trust_badge);
