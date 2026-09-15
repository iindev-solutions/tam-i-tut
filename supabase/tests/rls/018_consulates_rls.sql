-- 018_consulates_rls.sql
-- pgTAP suite for migration 062 (consular contacts moved out of i18n).
--
--   consulates : reader (authenticated) sees rows of ACTIVE cities only and
--     cannot write; moderator/admin can manage - the write path is the point
--     of the move, since the previous hardcoded address shipped wrong and no
--     admin could fix it.

begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000341'), -- reader (user)
	('00000000-0000-0000-0000-000000000342'); -- admin

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000341', 'user', 'Reader', 'ru', true),
	('00000000-0000-0000-0000-000000000342', 'admin', 'Admin', 'ru', true);

insert into public.cities (slug, name_en, name_ru, country_code, flag, is_active, sort_order)
values
	('test-active-city', 'Test Active', 'Тест активный', 'VN', '🇻🇳', true, 65),
	('test-inactive-city', 'Test Inactive', 'Тест неактивный', 'VN', '🇻🇳', false, 66);

insert into public.consulates (city_slug, country_code, name_ru, name_en, address, hours_ru, hours_en, phone, emergency_phone, source, sort_order)
values
	('test-active-city', 'RU', 'Тестовое консульство', 'Test consulate', '1 Test Street, Active', 'пн 9:00', 'Mon 9:00', '+84000000001', '+84000000002', 'test fixture', 1),
	('test-inactive-city', 'RU', 'Скрытое консульство', 'Hidden consulate', '2 Test Street, Inactive', 'пн 9:00', 'Mon 9:00', '+84000000003', '+84000000004', 'test fixture', 1);

select plan(9);

-- ---- Integrity ----
select throws_like(
	$$
	insert into public.consulates (city_slug, country_code, name_ru, name_en, address, source, sort_order)
	values ('test-active-city', 'RU', 'X', 'X', '   ', 'test fixture', 9)
	$$,
	'%consulates_address_not_empty%',
	'an empty address is rejected (that is the field that shipped wrong)'
);

select throws_like(
	$$
	insert into public.consulates (city_slug, country_code, name_ru, name_en, address, source, sort_order)
	values ('test-active-city', 'RU', 'X', 'X', '3 Test Street', '', 8)
	$$,
	'%consulates_source_not_empty%',
	'a consular row cannot be saved without a source'
);

-- ---- Reader (authenticated, role=user) ----
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000341';

select is(
	(select count(*) from public.consulates where address like '%Test Street%'),
	1::bigint,
	'reader sees only consulates of the active city'
);

select is(
	(select address from public.consulates where city_slug = 'test-active-city'),
	'1 Test Street, Active',
	'the visible consulate carries its address'
);

select is(
	(select emergency_phone from public.consulates where city_slug = 'test-active-city'),
	'+84000000002',
	'the round-the-clock line is readable (it is what a user needs at 3am)'
);

-- RLS denies the UPDATE by filtering the row out, NOT by throwing: with no
-- update policy the statement succeeds and changes 0 rows. Asserting a throw
-- here would be a false-confidence test - and would hide a real regression if
-- someone later added a permissive update policy.
with updated as (
	update public.consulates set address = 'wrong street' where city_slug = 'test-active-city'
	returning 1
)
select is(
	(select count(*) from updated),
	0::bigint,
	'reader cannot edit a consular fact (0 rows updated)'
);

select is(
	(select address from public.consulates where city_slug = 'test-active-city'),
	'1 Test Street, Active',
	'the address is unchanged after the reader attempt'
);

-- ---- Admin (authenticated, role=admin) ----
set local role none;
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000342';

select is(
	(select count(*) from public.consulates where address like '%Test Street%'),
	2::bigint,
	'admin sees consulates of every city (the list is maintained here)'
);

select lives_ok(
	$$
	update public.consulates
	set address = '1 Test Street, corrected', source = 'corrected by admin 2026-09-15'
	where city_slug = 'test-active-city'
	$$,
	'admin can correct an address - the capability the i18n string never had'
);

select * from finish();
rollback;
