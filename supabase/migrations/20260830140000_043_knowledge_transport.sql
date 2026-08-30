-- Migration: 043_knowledge_transport
-- Purpose: founder's knowledge-dump pass #1 (source: data/knowledge-dump.md,
-- analog bot Inside Danang). Content REWRITTEN in TAMITUT voice (not verbatim
-- copy), facts kept, bilingual ru/en, same trust posture as the 029 seed
-- (published + under_review until editorial verification).
-- Mapping:
--   traffic etiquette block      -> NEW guide transport-traffic
--   taxi price + airport center  -> UPDATE transport-airport
--   intercity buses + bus station-> UPDATE transport-bus

insert into auth.users (id) values ('00000000-0000-0000-0000-0000000000aa') on conflict (id) do nothing;
insert into public.profiles (id, role, display_name, locale, is_active)
values ('00000000-0000-0000-0000-0000000000aa', 'curator', 'Seed Editor', 'ru', true)
on conflict (id) do nothing;

-- NEW: traffic etiquette
insert into public.guide_entries
	(id, category_slug, slug, title, summary, note, icon, language, status,
	 trust_badge, under_review_note, owner_profile_id, created_by_profile_id,
	 updated_by_profile_id, published_at, last_verified_at)
values
	('00000000-0000-0000-0000-000000000017', 'transport', 'transport-traffic', 'Трафик и байки', 'Главный транспорт Дананга - байки: едут плотно, сигналят и почти не тормозят на зебрах. Туристы ходят пешком и ездят в Grab, экспаты чаще арендуют байк.', 'Переходя дорогу, иди ровно и предсказуемо - поток объедет сам. Не делай резких рывков.', 'i-lucide-traffic-cone', 'ru', 'published', 'under_review', 'Контент из knowledge-dump, ждёт проверки', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000018', 'transport', 'transport-traffic', 'Traffic and bikes', 'Da Nang runs on bikes: dense traffic, constant honking, crosswalks are advisory. Tourists walk and use Grab; expats usually rent or buy a bike.', 'Cross the road by walking steadily and predictably - the flow will route around you. No sudden stops.', 'i-lucide-traffic-cone', 'en', 'published', 'under_review', 'Knowledge-dump content, pending verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now())
on conflict (category_slug, slug, language) do update
set title = excluded.title, summary = excluded.summary, note = excluded.note,
	updated_at = now(), last_verified_at = now();

-- UPDATE: airport (taxi price refined + map links)
insert into public.guide_entries
	(id, category_slug, slug, title, summary, note, icon, language, status,
	 trust_badge, under_review_note, owner_profile_id, created_by_profile_id,
	 updated_by_profile_id, published_at, last_verified_at)
values
	('00000000-0000-0000-0000-000000000007', 'transport', 'transport-airport', 'Из аэропорта', 'Аэропорт и ж/д вокзал - в центре города: до моря ехать недолго. Такси до моря 120-160 тыс. ₫, приложение Grab обычно дешевле стойки.', '📍 Аэропорт на карте: https://maps.app.goo.gl/d3hrGmU3jFB8bNho6 | 📍 Ж/д вокзал на карте: https://maps.app.goo.gl/m1cLwnivTqgjhHRG9', 'i-lucide-plane-landing', 'ru', 'published', 'under_review', 'Обновлено из knowledge-dump', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000008', 'transport', 'transport-airport', 'From the airport', 'The airport and train station sit in the city center - the beach is a short ride. Taxi to the beach costs 120-160k VND; the Grab app is usually cheaper than the taxi desk.', '📍 Airport map: https://maps.app.goo.gl/d3hrGmU3jFB8bNho6 | 📍 Train station map: https://maps.app.goo.gl/m1cLwnivTqgjhHRG9', 'i-lucide-plane-landing', 'en', 'published', 'under_review', 'Updated from knowledge-dump', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now())
on conflict (category_slug, slug, language) do update
set title = excluded.title, summary = excluded.summary, note = excluded.note,
	updated_at = now(), last_verified_at = now();

-- UPDATE: buses (city + intercity from the remote bus station)
insert into public.guide_entries
	(id, category_slug, slug, title, summary, note, icon, language, status,
	 trust_badge, under_review_note, owner_profile_id, created_by_profile_id,
	 updated_by_profile_id, published_at, last_verified_at)
values
	('00000000-0000-0000-0000-000000000005', 'transport', 'transport-bus', 'Городские автобусы и межгород', 'Городские маршруты идут вдоль пляжа и через центр, оплата наличными при входе (5-10 тыс. ₫). Автовокзал - вдали от туристических районов: оттуда рейсы до Хюэ и Лао-Бао (погранпереход для визарана).', '📍 Автовокзал на карте: https://maps.app.goo.gl/xbDUbdLbGpc2pLyDA', 'i-lucide-bus', 'ru', 'published', 'under_review', 'Обновлено из knowledge-dump', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000006', 'transport', 'transport-bus', 'City buses and intercity', 'City routes run along the beach and through the center; pay cash on boarding (5-10k VND). The bus station is far from tourist areas: buses to Hue and Lao Bao (the border crossing for visa runs) leave from there.', '📍 Bus station map: https://maps.app.goo.gl/xbDUbdLbGpc2pLyDA', 'i-lucide-bus', 'en', 'published', 'under_review', 'Updated from knowledge-dump', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now())
on conflict (category_slug, slug, language) do update
set title = excluded.title, summary = excluded.summary, note = excluded.note,
	updated_at = now(), last_verified_at = now();
