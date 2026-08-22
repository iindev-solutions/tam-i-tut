-- 012_rate_limit_lockdown.sql
-- pgTAP tests for migration 030 (districts geometry validity + durable
-- rate limiting) and migration 031 (function privilege lockdown).
--
-- Rate-limit posture:
--   telegram_rate_limits: RLS enabled, no policies -> invisible to
--   anon/authenticated, service_role only.
--   check_rate_limit RPC: execute revoked from public/anon/authenticated,
--   granted to service_role (the Edge function path).
-- Districts geometry validity:
--   st_isvalid check rejects self-intersecting rings on insert/update.

begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000301'), -- reader (user)
	('00000000-0000-0000-0000-000000000302'); -- admin

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000301', 'user', 'Reader', 'ru', true),
	('00000000-0000-0000-0000-000000000302', 'admin', 'Admin', 'ru', true);

select plan(8);

-- ---- Rate limit table + RPC lockdown ----
set role authenticated;
set request.jwt.claim.sub = '00000000-0000-0000-0000-000000000301';

select is(
	(select count(*) from public.telegram_rate_limits),
	0::bigint,
	'authenticated cannot read telegram_rate_limits (RLS, no policies)'
);

select throws_ok(
	format(
		'select public.check_rate_limit(%L, 10, 60)',
		'bootstrap-ip:203.0.113.9'
	),
	42501,
	NULL,
	'authenticated cannot execute check_rate_limit'
);

set role anon;
reset request.jwt.claim.sub;

select is(
	(select count(*) from public.telegram_rate_limits),
	0::bigint,
	'anon cannot read telegram_rate_limits'
);

select throws_ok(
	format('select public.check_rate_limit(%L, 10, 60)', 'bootstrap-ip:anon'),
	42501,
	NULL,
	'anon cannot execute check_rate_limit'
);

-- ---- Service-role behavior of the limiter itself ----
-- The test connection owns the objects, so after switching back to the
-- superuser role the function is callable; this exercises the window math
-- that the Edge function depends on.

reset role;

select is(
	public.check_rate_limit('pgtap-key-a', 2, 60),
	0,
	'first call under max returns retry-after 0'
);

select is(
	public.check_rate_limit('pgtap-key-a', 2, 60),
	0,
	'second call at the limit still returns 0'
);

select isnt(
	public.check_rate_limit('pgtap-key-a', 2, 60),
	0,
	'call over the limit returns a positive retry-after'
);

-- ---- Districts geometry validity guard ----

insert into public.cities (slug, name_en, name_ru, country_code, flag, is_active, sort_order)
values
	('test-active-city', 'Test Active', 'Тест активный', 'VN', '🇻🇳', true, 60);

select lives_ok(
	format(
		'insert into public.districts (city_slug, slug, sort_order, price_level, geometry)
		 values (%L, %L, 1, %L::public.price_level, ST_GeomFromGeoJSON(%L))',
		'test-active-city',
		'valid-ring-district',
		'budget',
		'{"type":"Polygon","coordinates":[[[108.2,16.05],[108.21,16.05],[108.21,16.06],[108.2,16.06],[108.2,16.05]]]}'
	),
	'valid simple ring passes the districts_geometry_is_valid check'
);

select throws_ok(
	format(
		'insert into public.districts (city_slug, slug, sort_order, price_level, geometry)
		 values (%L, %L, 2, %L::public.price_level, ST_GeomFromGeoJSON(%L))',
		'test-active-city',
		'bowtie-district',
		'average',
		'{"type":"Polygon","coordinates":[[[108.2,16.05],[108.22,16.07],[108.21,16.05],[108.2,16.07],[108.2,16.05]]]}'
	),
	23514,
	NULL,
	'self-intersecting bow-tie ring rejected by st_isvalid check'
);

select * from finish();
rollback;
