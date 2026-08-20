-- 011_districts_and_admin_writes.sql
-- pgTAP tests for migration 024 (districts + localizations RLS) and
-- migration 025 (moderator/admin write policies on places/reviews/cities).
--
-- Reader (authenticated, role=user):
--   districts only of ACTIVE cities; localizations gated by active city;
--   writes blocked everywhere.
-- Admin (authenticated, profile role=admin):
--   full write access to districts, places, place_localizations, reviews,
--   cities (update), categories (already covered by 018).
-- Anon: nothing.

begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000301'), -- reader (user)
	('00000000-0000-0000-0000-000000000302'); -- admin

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000301', 'user', 'Reader', 'ru', true),
	('00000000-0000-0000-0000-000000000302', 'admin', 'Admin', 'ru', true);

insert into public.cities (slug, name_en, name_ru, country_code, flag, is_active, sort_order)
values
	('test-active-city', 'Test Active', 'Тест активный', 'VN', '🇻🇳', true, 60),
	('test-inactive-city', 'Test Inactive', 'Тест неактивный', 'VN', '🇻🇳', false, 61);

insert into public.districts (id, city_slug, slug, sort_order, price_level, geometry)
values
	('00000000-0000-0000-0000-000000000601', 'test-active-city', 'test-district-a', 1, 'budget', ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[108.2,16.05],[108.21,16.05],[108.21,16.06],[108.2,16.06],[108.2,16.05]]]}')),
	('00000000-0000-0000-0000-000000000602', 'test-inactive-city', 'test-district-b', 2, 'average', ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[108.2,16.05],[108.21,16.05],[108.21,16.06],[108.2,16.06],[108.2,16.05]]]}'));

insert into public.district_localizations (district_id, language, name, area, rent_range, distance_to_beach, summary, best_for)
values
	('00000000-0000-0000-0000-000000000601', 'ru', 'Район А', 'Район', '5-10 млн', '5 мин', 'Описание', '{budget}'),
	('00000000-0000-0000-0000-000000000601', 'en', 'District A', 'Area', '5-10M', '5 min', 'Summary', '{budget}'),
	('00000000-0000-0000-0000-000000000602', 'ru', 'Район Б', 'Район', '5-10 млн', '5 мин', 'Описание', '{quiet}');

-- places fixture for admin-write tests (city-aware slice).
insert into public.places (id, city_slug, slug, place_type, price_level, verified, status)
values
	('00000000-0000-0000-0000-000000000403', 'test-active-city', 'test-admin-place', 'cafe', 'average', false, 'draft');

insert into public.place_localizations (place_id, language, name, area, summary)
values
	('00000000-0000-0000-0000-000000000403', 'ru', 'Тест', 'Район', 'Описание'),
	('00000000-0000-0000-0000-000000000403', 'en', 'Test', 'Area', 'Summary');

insert into public.reviews (id, place_id, author, rating, status)
values
	('00000000-0000-0000-0000-000000000505', '00000000-0000-0000-0000-000000000403', 'Alice', 5, 'pending');

select plan(11);

-- ---- Reader (authenticated, role=user) ----
set role authenticated;
set request.jwt.claim.sub = '00000000-0000-0000-0000-000000000301';

select is(
	(select count(*) from public.districts where slug like 'test-%'),
	1::bigint,
	'reader sees districts only of the ACTIVE city'
);

select is(
	(select count(*) from public.district_localizations
	 where district_id in ('00000000-0000-0000-0000-000000000601', '00000000-0000-0000-0000-000000000602')),
	2::bigint,
	'reader sees localizations only of districts in the ACTIVE city'
);

select throws_like(
	$$
	insert into public.districts (id, city_slug, slug, sort_order, price_level, geometry)
	values ('00000000-0000-0000-0000-000000000603', 'test-active-city', 'test-district-c', 3, 'budget',
		ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[108.2,16.05],[108.21,16.05],[108.21,16.06],[108.2,16.06],[108.2,16.05]]]}'))
	$$,
	'%row-level security policy%',
	'reader cannot insert districts (no insert policy)'
);

-- RLS UPDATE/DELETE blocks are SILENT (0 rows affected, no exception), so the
-- correct assertion is a row count, not throws_like.
with updated as (
	update public.places set status = 'published'
	where id = '00000000-0000-0000-0000-000000000403'
	returning 1
)
select is(
	(select count(*) from updated),
	0::bigint,
	'reader cannot publish places (0 rows affected)'
);

with updated as (
	update public.reviews set status = 'approved'
	where id = '00000000-0000-0000-0000-000000000505'
	returning 1
)
select is(
	(select count(*) from updated),
	0::bigint,
	'reader cannot moderate reviews (0 rows affected)'
);

-- ---- Admin (authenticated, profile role=admin) ----
set request.jwt.claim.sub = '00000000-0000-0000-0000-000000000302';

select is(
	(select role from public.profiles where id = auth.uid()),
	'admin'::public.app_role,
	'admin profile role resolves for the write tests'
);

-- Top-level data-modifying CTEs verify the EFFECT (1 row affected). Wrapping
-- UPDATE/INSERT in lives_ok/throws_like (subtransactions) is avoided here:
-- RLS policy checks can misbehave inside subtransactions in this environment.
with inserted as (
	insert into public.districts (id, city_slug, slug, sort_order, price_level, geometry)
	values ('00000000-0000-0000-0000-000000000604', 'test-active-city', 'test-district-d', 4, 'budget',
		ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[108.2,16.05],[108.21,16.05],[108.21,16.06],[108.2,16.06],[108.2,16.05]]]}'))
	returning 1
)
select is(
	(select count(*) from inserted),
	1::bigint,
	'admin can insert districts'
);

with updated as (
	update public.places set status = 'published'
	where id = '00000000-0000-0000-0000-000000000403'
	returning 1
)
select is(
	(select count(*) from updated),
	1::bigint,
	'admin can publish a place'
);

with updated as (
	update public.reviews set status = 'approved'
	where id = '00000000-0000-0000-0000-000000000505'
	returning 1
)
select is(
	(select count(*) from updated),
	1::bigint,
	'admin can approve a review'
);

with updated as (
	update public.cities set is_active = false
	where slug = 'test-active-city'
	returning 1
)
select is(
	(select count(*) from updated),
	1::bigint,
	'admin (moderator_admin) can deactivate a city'
);

-- ---- Anon ----
set role anon;
reset request.jwt.claim.sub;

select is(
	(select count(*) from public.districts where slug like 'test-%'),
	0::bigint,
	'anon sees no districts'
);

select * from finish();
rollback;
