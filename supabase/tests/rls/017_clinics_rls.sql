-- 017_clinics_rls.sql
-- pgTAP suite for migration 061 (Da Nang clinic directory).
--
--   clinics / clinic_localizations : reader (authenticated) sees rows of
--     ACTIVE cities only, and cannot write; moderator/admin can manage.
--   trust gate : a trusted clinic must carry its verification date - the same
--     rule places got in 058 - because the whole point of these rows is that
--     an imported price may not masquerade as a confirmed one.

begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000331'), -- reader (user)
	('00000000-0000-0000-0000-000000000332'); -- admin

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000331', 'user', 'Reader', 'ru', true),
	('00000000-0000-0000-0000-000000000332', 'admin', 'Admin', 'ru', true);

insert into public.cities (slug, name_en, name_ru, country_code, flag, is_active, sort_order)
values
	('test-active-city', 'Test Active', 'Тест активный', 'VN', '🇻🇳', true, 63),
	('test-inactive-city', 'Test Inactive', 'Тест неактивный', 'VN', '🇻🇳', false, 64);

insert into public.clinics (id, city_slug, slug, kind, open_24_7, trust_badge, last_verified_at, source, sort_order)
values
	('00000000-0000-0000-0000-0000000007a1', 'test-active-city', 'test-clinic-visible', 'hospital', true, 'under_review', null, 'test fixture', 1),
	('00000000-0000-0000-0000-0000000007a2', 'test-inactive-city', 'test-clinic-hidden', 'dental', false, 'under_review', null, 'test fixture', 1);

insert into public.clinic_localizations (clinic_id, language, name, price_note)
values
	('00000000-0000-0000-0000-0000000007a1', 'ru', 'Видимая клиника', 'Приём 100 000 ₫'),
	('00000000-0000-0000-0000-0000000007a1', 'en', 'Visible clinic', 'Visit 100,000 ₫'),
	('00000000-0000-0000-0000-0000000007a2', 'ru', 'Скрытая клиника', 'Приём 200 000 ₫');

select plan(8);

-- ---- Trust gate ----
select throws_like(
	$$
	insert into public.clinics (city_slug, slug, kind, trust_badge, last_verified_at, source, sort_order)
	values ('test-active-city', 'test-clinic-trusted', 'hospital', 'verified_team', null, 'test fixture', 9)
	$$,
	'%clinics_trust_requires_verified_at%',
	'a trusted clinic cannot be saved without its verification date'
);

select throws_like(
	$$
	insert into public.clinics (city_slug, slug, kind, source, sort_order)
	values ('test-active-city', 'test-clinic-kind', 'nightclub', 'test fixture', 8)
	$$,
	'%clinics_kind_valid%',
	'an unknown specialisation is rejected'
);

-- ---- Reader (authenticated, role=user) ----
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000331';

select is(
	(select count(*) from public.clinics where slug like 'test-clinic-%'),
	1::bigint,
	'reader sees only clinics of the active city'
);

select is(
	(select count(*) from public.clinic_localizations
	 where clinic_id = '00000000-0000-0000-0000-0000000007a2'),
	0::bigint,
	'localizations of an inactive city clinic do not leak'
);

select is(
	(select name from public.clinic_localizations
	 where clinic_id = '00000000-0000-0000-0000-0000000007a1' and language = 'ru'),
	'Видимая клиника',
	'the visible clinic localizations are readable'
);

select throws_like(
	$$
	insert into public.clinics (city_slug, slug, kind, source, sort_order)
	values ('test-active-city', 'test-clinic-new', 'hospital', 'test fixture', 7)
	$$,
	'%row-level security policy%',
	'reader cannot add a clinic'
);

-- ---- Admin (authenticated, role=admin) ----
set local role none;
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000332';

select is(
	(select count(*) from public.clinics where slug like 'test-clinic-%'),
	2::bigint,
	'admin sees clinics of every city (the directory is edited here)'
);

select lives_ok(
	$$
	update public.clinics
	set trust_badge = 'verified_team', last_verified_at = now()
	where id = '00000000-0000-0000-0000-0000000007a1'
	$$,
	'admin can promote a clinic once someone has verified it'
);

select * from finish();
rollback;
