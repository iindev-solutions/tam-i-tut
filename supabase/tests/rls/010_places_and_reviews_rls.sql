-- 010_places_and_reviews_rls.sql
-- pgTAP tests for the city-aware food slice (schema v2), migration 023.
-- Asserts the RLS posture end-to-end as a reader (role=authenticated):
--   places         : only published rows visible
--   place_localizations: only rows whose parent place is published
--   reviews        : only approved rows whose parent place is published
--   cities         : only active cities visible
-- Includes the leak guard: an approved review on a draft/archived place is hidden.
--
-- This file must be safe to run after seed.sql (config.toml enables the seed),
-- so every fixture uses unique test slugs/UUIDs and every assertion is scoped
-- to those IDs rather than assuming an empty data set.

begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000301'),
	('00000000-0000-0000-0000-000000000302');

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000301', 'user', 'Reader', 'ru', true),
	('00000000-0000-0000-0000-000000000302', 'user', 'Second Reader', 'ru', true);

-- Unique test cities (seed also inserts da-nang/pattaya; we must not collide).
insert into public.cities (slug, name_en, name_ru, country_code, flag, is_active, sort_order)
values
	('test-active-city', 'Test Active', 'Тест активный', 'VN', '🇻🇳', true, 50),
	('test-inactive-city', 'Test Inactive', 'Тест неактивный', 'VN', '🇻🇳', false, 51);

insert into public.places (id, city_slug, slug, place_type, price_level, verified, status)
values
	('00000000-0000-0000-0000-000000000401', 'test-active-city', 'test-pub-place', 'street', 'budget', true, 'published'),
	('00000000-0000-0000-0000-000000000402', 'test-active-city', 'test-draft-place', 'cafe', 'average', false, 'draft'),
	('00000000-0000-0000-0000-000000000403', 'test-active-city', 'test-archived-place', 'market', 'budget', false, 'archived');

insert into public.place_localizations (place_id, language, name, area, summary)
values
	('00000000-0000-0000-0000-000000000401', 'ru', 'Published', 'Area', 'Published summary'),
	('00000000-0000-0000-0000-000000000402', 'ru', 'Draft', 'Area', 'Draft summary'),
	('00000000-0000-0000-0000-000000000403', 'ru', 'Archived', 'Area', 'Archived summary');

insert into public.reviews (id, place_id, author, rating, status)
values
	('00000000-0000-0000-0000-000000000501', '00000000-0000-0000-0000-000000000401', 'Alice', 5, 'approved'),
	('00000000-0000-0000-0000-000000000502', '00000000-0000-0000-0000-000000000402', 'Bob', 4, 'approved'),
	('00000000-0000-0000-0000-000000000503', '00000000-0000-0000-0000-000000000403', 'Carol', 3, 'approved'),
	('00000000-0000-0000-0000-000000000504', '00000000-0000-0000-0000-000000000401', 'Dave', 2, 'pending');

select plan(8);

set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000301';

-- Cities: only the active TEST city is read (seed cities do not affect this).
select is(
	(select count(*) from public.cities where slug like 'test-%'),
	1::bigint,
	'reader sees only the active test city'
);

-- Places: only the published TEST place is read.
select is(
	(select count(*) from public.places where slug like 'test-%'),
	1::bigint,
	'reader sees only the published test place'
);

-- Localizations: query the child table DIRECTLY (no join with places, whose
-- own RLS would mask a leak in the child policy). Only rows whose parent is
-- published may be seen by this reader.
select is(
	(select count(*) from public.place_localizations
	 where place_id in (
		'00000000-0000-0000-0000-000000000401',
		'00000000-0000-0000-0000-000000000402',
		'00000000-0000-0000-0000-000000000403'
	 )),
	1::bigint,
	'localizations are gated by parent place published status'
);

-- Reviews: query the child table directly. Only the approved review on the
-- published place is visible; approved reviews on the draft and archived
-- places must NOT leak, and the pending one stays hidden.
select is(
	(select count(*) from public.reviews
	 where place_id in (
		'00000000-0000-0000-0000-000000000401',
		'00000000-0000-0000-0000-000000000402',
		'00000000-0000-0000-0000-000000000403'
	 )),
	1::bigint,
	'only approved reviews on published places are visible'
);

-- The single visible review is the approved one on the published place.
select is(
	(select author from public.reviews
	 where place_id in (
		'00000000-0000-0000-0000-000000000401',
		'00000000-0000-0000-0000-000000000402',
		'00000000-0000-0000-0000-000000000403'
	 )),
	'Alice',
	'the visible review is the approved review on the published place'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000302';
select is(
	(select count(*) from public.places where slug like 'test-%'),
	1::bigint,
	'a second authenticated reader sees the same published places'
);

-- Writes are blocked under RLS (no insert policies on these tables yet).
select throws_like(
	$$
	insert into public.places (id, city_slug, slug, place_type, price_level, verified, status)
	values ('00000000-0000-0000-0000-000000000404', 'test-active-city', 'test-new-place', 'cafe', 'budget', true, 'published')
	$$,
	'%row-level security policy%',
	'reader cannot insert places (no insert policy)'
);

select throws_like(
	$$
	insert into public.reviews (id, place_id, author, rating, status)
	values ('00000000-0000-0000-0000-000000000505', '00000000-0000-0000-0000-000000000401', 'Eve', 5, 'approved')
	$$,
	'%row-level security policy%',
	'reader cannot insert reviews (no insert policy)'
);

select * from finish();
rollback;