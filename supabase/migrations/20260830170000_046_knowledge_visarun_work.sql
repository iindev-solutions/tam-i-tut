-- Migration: 046_knowledge_visarun_work
-- Purpose: knowledge-dump pass #4 (founder task + expat-chat data).
--   visa run Da Nang -> Lao Bao (self-guided + services incl. Lynn Visa,
--   Щелкун/Innam from the RU community) -> NEW guide transport-visarun
--   work spots (HI4 free 24/7, paid coworkings, work cafes) -> NEW places
--   (place_type cafe; each summary states the work angle, address, hours).
-- Facts: WebSearch 2026-08-30 (lynnvisa.com, za7gorami.ru, vietnam-visa.ru,
-- Tripadvisor, acecoworking.vn, founder's own verdicts).

insert into public.guide_entries
	(id, category_slug, slug, title, summary, note, icon, language, status,
	 trust_badge, under_review_note, owner_profile_id, created_by_profile_id,
	 updated_by_profile_id, published_at, last_verified_at)
values
	('00000000-0000-0000-0000-000000000031', 'transport', 'transport-visarun', 'Визаран: Дананг - Лао-Бао', 'Однодневная поездка за новым штампом через границу с Лаосом (КПП Лао-Бао, ~5 часов пути). Самостоятельно: утренний автобус с автовокзала (гейт 1, ~250 тыс. ₫), от остановки до КПП ~1 км пешком или мототакси (30 тыс. ₫), два КПП проходятся за ~час. Гражданам РФ виза Лаоса не нужна. Итого самостоятельный вариант - $40-120 в зависимости от типа новой визы.', 'Проверенные сервисы: Lynn Visa (офис 14 Mạc Cửu, автобус вт/пт в 7:00, трансфер ~750-850 тыс. ₫, с новой 90-дневной e-visa от ~2,75 млн ₫), а также Щелкун и Innam - живые сервисы из русскоязычных чатов Дананга (в вебе не индексируются - ищи в чатах «Дананг»). Никаких предоплат непроверенным - см. гайд про скам.', 'i-lucide-plane-takeoff', 'ru', 'published', 'under_review', 'Контент из knowledge-dump, ждёт проверки', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000032', 'transport', 'transport-visarun', 'Visa run: Da Nang - Lao Bao', 'A one-day trip for a fresh stamp through the Laos border (Lao Bao crossing, ~5 hours each way). DIY: morning bus from the central bus station (gate 1, ~250k VND), ~1 km to the crossing on foot or by bike taxi (30k VND), both checkpoints take about an hour. Russians do not need a Lao visa. Total for the DIY option: $40-120 depending on the new visa type.', 'Trusted services: Lynn Visa (office at 14 Mac Cuu, bus Tue/Fri 7:00, transfer ~750-850k VND, with a new 90-day e-visa from ~2.75M VND), plus Shchelkun and Innam - live services from the Russian-speaking Da Nang chats (not web-indexed - look in the Da Nang groups). No prepayments to unverified operators - see the scam guide.', 'i-lucide-plane-takeoff', 'en', 'published', 'under_review', 'Knowledge-dump content, pending verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now())
on conflict (category_slug, slug, language) do update
set title = excluded.title, summary = excluded.summary, note = excluded.note,
	updated_at = now(), last_verified_at = now();

-- Work spots: coworkings + work cafes (founder-verified, addresses from maps)
insert into public.places (id, city_slug, slug, place_type, price_level, verified, status)
values
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000001', 'da-nang', 'hi4-coffee-workspace', 'cafe', 'budget', true, 'published'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000002', 'da-nang', 'coworking-danang', 'cafe', 'average', true, 'published'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000003', 'da-nang', 'seaview-coworking', 'cafe', 'average', true, 'published'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000004', 'da-nang', 'ace-coworking', 'cafe', 'average', true, 'published'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000005', 'da-nang', 'good-folks-cafe', 'cafe', 'average', true, 'published'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000006', 'da-nang', 'nu-arrows-cafe', 'cafe', 'average', true, 'published')
on conflict (id) do update
set city_slug = excluded.city_slug, slug = excluded.slug, place_type = excluded.place_type,
	price_level = excluded.price_level, verified = excluded.verified, status = excluded.status;

insert into public.place_localizations (place_id, language, name, area, summary)
values
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000001', 'ru', 'HI4 Coffee & Workspace', 'Ngu Hanh Son, 120-126 Mai Thuc Lan + Hai Chau, 02 Nguyen Van Troi', 'Коворкинг-кафе, работающее 24/7. Вход бесплатный, пространство огромное и живое - лучшая рабочая точка города. Вторая точка в Hai Chau у моста Tran Thi Ly. Кофе и еда на месте.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000001', 'en', 'HI4 Coffee & Workspace', 'Ngu Hanh Son, 120-126 Mai Thuc Lan + Hai Chau, 02 Nguyen Van Troi', 'A cafe-coworking open 24/7. Free entry, huge and lively - the best work spot in town. Second location in Hai Chau near the Tran Thi Ly bridge. Coffee and food on site.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000002', 'ru', 'Coworking Danang', 'My An', 'Платный коворкинг камерного формата - небольшая комната с рабочими местами. Тише HI4, подходит для фокуса; в таком окружении легко завести знакомства с экспатами. Локацию уточни в Google Maps по названию.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000002', 'en', 'Coworking Danang', 'My An', 'A paid coworking in an intimate format - one small room with desks. Quieter than HI4, good for focus; a good place to befriend other expats. Find the exact location on Google Maps by name.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000003', 'ru', 'Seaview Coworking', 'Son Tra, Waikiki Beach Hotel, 9 этаж, 32 Ha Chuong', 'Коворкинг на 9 этаже отеля у пляжа Mỹ Khê: вид на море, работает 24/7, вода, кофе и чай бесплатно. Камерный формат, живое комьюнити.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000003', 'en', 'Seaview Coworking', 'Son Tra, Waikiki Beach Hotel, 9th floor, 32 Ha Chuong', 'A coworking on the 9th floor of a beachfront hotel near My Khe: ocean view, open 24/7, free water, coffee and tea. Intimate format with an active community.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000004', 'ru', 'ACE Coworking', 'Ngu Hanh Son, 12 Tran Van Du, Bac My An', 'Трёхэтажный «лайфстайл»-коворкинг недалеко от западного квартала: техники много, проходят велнес-активности. Камернее и дороже HI4. WhatsApp: +84 932 574 121.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000004', 'en', 'ACE Coworking', 'Ngu Hanh Son, 12 Tran Van Du, Bac My An', 'A three-floor lifestyle coworking near the western quarter: plenty of tech, regular wellness activities. Smaller-scale and pricier than HI4. WhatsApp: +84 932 574 121.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000005', 'ru', 'Good Folks Cafe', 'My An, 84 Hoang Ke Viem', 'Кафе для работы у пляжа Mỹ Khê: 4,7 на Tripadvisor, любимое место диджитал-номадов. Работает 7:30-22:00.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000005', 'en', 'Good Folks Cafe', 'My An, 84 Hoang Ke Viem', 'A work-friendly cafe near My Khe beach: 4.7 on TripAdvisor, a digital-nomad favorite. Open 7:30-22:00.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000006', 'ru', 'Nu Arrows Cafe', 'My An, 51 Duong Tu Quan, Bac My An', 'Кафе с едой в районе My An/An Thuong, работает до 22:00. Хорошее рабочее место с ноутбуком.'),
	('f2a7c9d1-3e5b-4c7d-9e1f-000000000006', 'en', 'Nu Arrows Cafe', 'My An, 51 Duong Tu Quan, Bac My An', 'A cafe-with-food in the My An/An Thuong area, open until 22:00. A solid laptop-work spot.')
on conflict (place_id, language) do update
set name = excluded.name, area = excluded.area, summary = excluded.summary;
