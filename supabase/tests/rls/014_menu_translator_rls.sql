-- 014_menu_translator_rls.sql
-- pgTAP suite for the menu translator slice (migrations 036).
-- Reader posture (role=authenticated):
--   dishes              : only published rows
--   dish_localizations  : only rows whose parent dish is published
--   menus               : only menus whose venue is published
--   menu_items          : only items whose parent menu/venue is published
--                         AND status <> 'rejected'
-- Guards: reader cannot insert anywhere; a rejected item on a published
-- menu must not leak. Fixtures are unique test slugs/UUIDs so the suite is
-- safe to run after seed.sql; assertions scope to those fixtures.

begin;

insert into auth.users (id)
values ('00000000-0000-0000-0000-000000000321');

insert into public.profiles (id, role, display_name, locale, is_active)
values ('00000000-0000-0000-0000-000000000321', 'user', 'Menu Reader', 'ru', true);

-- Suites roll back, so the shared test city is created here (same as 010).
insert into public.cities (slug, name_en, name_ru, country_code, flag, is_active, sort_order)
values ('test-active-city', 'Test Active', 'Тест активный', 'VN', '🇻🇳', true, 50);

-- Venue fixtures: one published, one draft.
insert into public.places (id, city_slug, slug, place_type, price_level, verified, status)
values
	('00000000-0000-0000-0000-000000000441', 'test-active-city', 'test-menu-pub-place', 'street', 'budget', true, 'published'),
	('00000000-0000-0000-0000-000000000442', 'test-active-city', 'test-menu-draft-place', 'cafe', 'average', false, 'draft');

insert into public.dishes (id, slug, name_vi, verified, status)
values
	('00000000-0000-0000-0000-000000000451', 'test-dish-pub', 'Món thử', false, 'published'),
	('00000000-0000-0000-0000-000000000452', 'test-dish-draft', 'Món nháp', false, 'draft');

insert into public.dish_localizations (dish_id, language, name, summary)
values
	('00000000-0000-0000-0000-000000000451', 'ru', 'Тестовое блюдо', 'Описание'),
	('00000000-0000-0000-0000-000000000451', 'en', 'Test dish', 'Summary');

insert into public.menus (id, place_id, status)
values
	('00000000-0000-0000-0000-000000000461', '00000000-0000-0000-0000-000000000441', 'ai'),
	('00000000-0000-0000-0000-000000000462', '00000000-0000-0000-0000-000000000442', 'ai');

insert into public.menu_items (id, menu_id, raw_text_vi, price_vnd, dish_id, confidence, status, position)
values
	('00000000-0000-0000-0000-000000000471', '00000000-0000-0000-0000-000000000461', 'Phở bò', 50000, '00000000-0000-0000-0000-000000000451', 90, 'ai', 1),
	('00000000-0000-0000-0000-000000000472', '00000000-0000-0000-0000-000000000461', 'Món chờ xóa', 20000, null, 40, 'rejected', 2),
	('00000000-0000-0000-0000-000000000473', '00000000-0000-0000-0000-000000000462', 'Draft menu line', 10000, null, 50, 'ai', 1);

select plan(7);

set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000321';

select is(
	(select count(*) from public.dishes where slug like 'test-dish-%'),
	1::bigint,
	'reader sees only the published dictionary dish'
);

select is(
	(select count(*) from public.dish_localizations
	 where dish_id in ('00000000-0000-0000-0000-000000000451', '00000000-0000-0000-0000-000000000452')),
	2::bigint,
	'localizations are gated by the parent dish published status (ru+en of the published dish)'
);

select is(
	(select count(*) from public.menus
	 where id in ('00000000-0000-0000-0000-000000000461', '00000000-0000-0000-0000-000000000462')),
	1::bigint,
	'menus are gated by the parent place published status'
);

-- Child-table guard: only the non-rejected item of the visible menu leaks.
select is(
	(select count(*) from public.menu_items
	 where menu_id in ('00000000-0000-0000-0000-000000000461', '00000000-0000-0000-0000-000000000462')),
	1::bigint,
	'reader sees only the non-rejected item of the published venue menu'
);

select is(
	(select raw_text_vi from public.menu_items
	 where menu_id in ('00000000-0000-0000-0000-000000000461', '00000000-0000-0000-0000-000000000462')),
	'Phở bò',
	'the visible item is the AI item on the published menu'
);

-- No insert policies for readers on any menu-translator table (Phase B adds
-- curated admin writes; the Edge Function writes via service_role).
select throws_like(
	$$
	insert into public.dishes (id, slug, name_vi)
	values ('00000000-0000-0000-0000-000000000453', 'test-dish-new', 'Món mới')
	$$,
	'%row-level security policy%',
	'reader cannot insert dishes'
);

select throws_like(
	$$
	insert into public.menus (id, place_id)
	values ('00000000-0000-0000-0000-000000000463', '00000000-0000-0000-0000-000000000441')
	$$,
	'%row-level security policy%',
	'reader cannot insert menus'
);

select * from finish();
rollback;
