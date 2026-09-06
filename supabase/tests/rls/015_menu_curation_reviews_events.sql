-- 015_menu_curation_reviews_events.sql
-- pgTAP suite for migration 049 (menu curation + review submission + metrics).
--
-- Reader (authenticated, role=user):
--   reviews          : can insert a pending review with body on a PUBLISHED
--                      venue; cannot insert on a draft venue; cannot insert
--                      with a pre-approved status; can read own profile.
--   app_events       : can insert own events; cannot insert under another
--                      user_id; cannot read events.
-- Admin (authenticated, profile role=admin):
--   menu_items       : sees rejected items and draft-venue items (036 reader
--                      policy hides both) and can verify/reject/link them.
--   menus            : can flip menu status to verified.
--   dishes           : can insert dictionary entries.
--   app_events       : can read the event log.

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
values ('test-active-city', 'Test Active', 'Тест активный', 'VN', '🇻🇳', true, 62);

insert into public.places (id, city_slug, slug, place_type, price_level, verified, status)
values
	('00000000-0000-0000-0000-000000000401', 'test-active-city', 'test-curation-pub', 'cafe', 'average', true, 'published'),
	('00000000-0000-0000-0000-000000000402', 'test-active-city', 'test-curation-draft', 'cafe', 'average', false, 'draft');

insert into public.menus (id, place_id, status)
values
	('00000000-0000-0000-0000-000000000461', '00000000-0000-0000-0000-000000000401', 'ai'),
	('00000000-0000-0000-0000-000000000462', '00000000-0000-0000-0000-000000000402', 'ai');

insert into public.menu_items (id, menu_id, raw_text_vi, price_vnd, dish_id, ai_name_ru, confidence, status, position)
values
	('00000000-0000-0000-0000-000000000471', '00000000-0000-0000-0000-000000000461', 'Món chờ duyệt', 40000, null, 'Блюдо', 45, 'ai', 1),
	('00000000-0000-0000-0000-000000000472', '00000000-0000-0000-0000-000000000461', 'Món bị từ chối', 20000, null, 'Отклонено', 30, 'rejected', 2),
	('00000000-0000-0000-0000-000000000473', '00000000-0000-0000-0000-000000000462', 'Draft menu line', 10000, null, 'Черновик', 50, 'ai', 1);

select plan(11);

-- ---- Reader (authenticated, role=user) ----
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000301';

-- Review submission: pending review with body on a published venue lands.
select lives_ok(
	$$
	insert into public.reviews (place_id, author, rating, body, status)
	values ('00000000-0000-0000-0000-000000000401', 'Reader', 4, 'Хорошее место', 'pending')
	$$,
	'authenticated user can submit a pending review with body on a published venue'
);

select throws_like(
	$$
	insert into public.reviews (place_id, author, rating, status)
	values ('00000000-0000-0000-0000-000000000402', 'Reader', 5, 'pending')
	$$,
	'%row-level security policy%',
	'reader cannot submit a review on a draft venue'
);

select throws_like(
	$$
	insert into public.reviews (place_id, author, rating, status)
	values ('00000000-0000-0000-0000-000000000401', 'Reader', 5, 'approved')
	$$,
	'%row-level security policy%',
	'reader cannot self-approve a review'
);

-- Metrics: own events insertable, foreign identity not, reads blocked.
select lives_ok(
	$$
	insert into public.app_events (event, metadata) values ('place_view', '{"slug":"test-curation-pub"}'::jsonb)
	$$,
	'authenticated user can log an event (user_id defaults to self)'
);

select throws_like(
	$$
	insert into public.app_events (user_id, event) values ('00000000-0000-0000-0000-000000000302', 'spoofed')
	$$,
	'%row-level security policy%',
	'reader cannot log an event under another user_id'
);

select is(
	(select count(*) from public.app_events),
	0::bigint,
	'reader cannot read the event log'
);

set local role none;

-- ---- Admin (authenticated, role=admin) ----
set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000302';

-- Curation queue visibility: rejected + draft-venue items reachable by admin.
select is(
	(select count(*) from public.menu_items
	 where id in ('00000000-0000-0000-0000-000000000471', '00000000-0000-0000-0000-000000000472', '00000000-0000-0000-0000-000000000473')),
	3::bigint,
	'admin sees rejected and draft-venue menu items (036 reader policy ORed with 049 admin policy)'
);

-- Curation actions: reject an item, then verify the menu.
select lives_ok(
	$$
	update public.menu_items set status = 'rejected' where id = '00000000-0000-0000-0000-000000000471'
	$$,
	'admin can reject a menu item'
);

select lives_ok(
	$$
	update public.menus set status = 'verified' where id = '00000000-0000-0000-0000-000000000461'
	$$,
	'admin can verify a menu'
);

-- Dictionary growth: admin can add a dish entry.
select lives_ok(
	$$
	insert into public.dishes (id, slug, name_vi, verified, status)
	values ('00000000-0000-0000-0000-000000000453', 'test-dish-admin', 'Món admin', true, 'published')
	$$,
	'admin can insert dictionary dishes'
);

select is(
	(select count(*) from public.app_events),
	1::bigint,
	'admin can read the event log'
);

select * from finish();
rollback;
