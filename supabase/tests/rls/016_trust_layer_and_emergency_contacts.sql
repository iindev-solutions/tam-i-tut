-- 016_trust_layer_and_emergency_contacts.sql
-- pgTAP suite for migration 058 (trust layer + emergency contacts).
--
--   places              : trust_badge replaces the boolean; a trusted level
--                         requires last_verified_at (CHECK), under_review
--                         does not.
--   emergency_contacts  : reader sees contacts of ACTIVE cities only, cannot
--                         write; moderator/admin can manage the list.
--   reader visibility   : the safety page reads emergency_contacts through
--                         RLS, so a contact on an inactive city must not leak.
-- Fixtures reuse the shared 'test-active-city' slug; ids are unique here.

begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000311'), -- reader (user)
	('00000000-0000-0000-0000-000000000312'); -- admin

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000311', 'user', 'Reader', 'ru', true),
	('00000000-0000-0000-0000-000000000312', 'admin', 'Admin', 'ru', true);

insert into public.cities (slug, name_en, name_ru, country_code, flag, is_active, sort_order)
values
	('test-active-city', 'Test Active', 'Тест активный', 'VN', '🇻🇳', true, 61),
	('test-inactive-city', 'Test Inactive', 'Тест неактивный', 'VN', '🇻🇳', false, 62);

insert into public.emergency_contacts (city_slug, number, label_ru, label_en, sort_order)
values
	('test-active-city', '113', 'Полиция', 'Police', 1),
	('test-inactive-city', '191', 'Полиция (выкл. город)', 'Police (inactive city)', 2);

select plan(10);

-- ---- Trust model on places ----
select throws_like(
	$$
	insert into public.places (city_slug, slug, place_type, price_level, trust_badge, last_verified_at)
	values ('test-active-city', 'test-trust-no-date', 'cafe', 'average', 'verified_team', null)
	$$,
	'%places_trust_requires_verified_at%',
	'a trusted place cannot be saved without its verification date'
);

select lives_ok(
	$$
	insert into public.places (city_slug, slug, place_type, price_level, trust_badge, last_verified_at, status)
	values ('test-active-city', 'test-trust-dated', 'cafe', 'average', 'verified_team', now(), 'published')
	$$,
	'a trusted place saves with a verification date'
);

select lives_ok(
	$$
	insert into public.places (id, city_slug, slug, place_type, price_level, trust_badge, last_verified_at, status)
	values ('00000000-0000-0000-0000-0000000004a1', 'test-active-city', 'test-trust-pending', 'cafe', 'average', 'under_review', null, 'published')
	$$,
	'an under-review place needs no verification date'
);

-- ---- Reader (authenticated, role=user) ----
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000311';

select is(
	(select count(*) from public.emergency_contacts where city_slug like 'test-%'),
	1::bigint,
	'reader sees emergency contacts of the active city only'
);

select is(
	(select number from public.emergency_contacts where city_slug = 'test-active-city'),
	'113',
	'the visible contact is the active city number'
);

select throws_like(
	$$
	insert into public.emergency_contacts (city_slug, number, label_ru, label_en, sort_order)
	values ('test-active-city', '999', 'П', 'P', 9)
	$$,
	'%row-level security policy%',
	'reader cannot add emergency contacts'
);

-- The trust level reaches the client: a published place exposes its badge.
select is(
	(
		select trust_badge::text
		from public.places
		where slug = 'test-trust-pending'
	),
	'under_review',
	'reader reads the trust badge of a published place'
);

-- ---- Admin (authenticated, role=admin) ----
set local role none;
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000312';

select lives_ok(
	$$
	insert into public.emergency_contacts (city_slug, number, label_ru, label_en, sort_order)
	values ('test-active-city', '114', 'Пожарная', 'Fire', 9)
	$$,
	'admin can add an emergency contact'
);

select lives_ok(
	$$
	update public.places set trust_badge = 'recommended_expats', last_verified_at = now()
	where slug = 'test-trust-pending'
	$$,
	'admin can promote a place to a trusted level'
);

-- ---- Anon ----
set role anon;
reset request.jwt.claim.sub;

select is(
	(select count(*) from public.emergency_contacts),
	0::bigint,
	'anon sees no emergency contacts'
);

select * from finish();
rollback;
