-- Migration: 050_visarun_rewrite
-- Purpose: founder feedback - the visa-run guide read as a dense run-on and
-- was unclear. Rewritten ru/en as a crisp summary + step-by-step plan in the
-- "row | row" note format that GuideText renders as bullets and tappable
-- links. Facts unchanged from migration 046 (WebSearch 2026-08-30); added a
-- Google Maps search link for the central bus station.

insert into public.guide_entries
	(id, category_slug, slug, title, summary, note, icon, language, status,
	 trust_badge, under_review_note, owner_profile_id, created_by_profile_id,
	 updated_by_profile_id, published_at, last_verified_at)
values
	('00000000-0000-0000-0000-000000000031', 'transport', 'transport-visarun',
	 'Визаран: Дананг - Лао-Бао',
	 'Виза или штамп на исходе - нужно выехать из Вьетнама и заехать заново. Ближайший вариант из Дананга - однодневный визаран на границу с Лаосом (КПП Лао-Бао). Дорога около 5 часов в одну сторону, вся поездка занимает день. Способа два: самостоятельно на автобусе ($40-120 всего) или через сервис (~750-850 тыс. ₫, без хлопот).',
	 'Своими силами, шаг за шагом. | 1) Утренний автобус с центрального автовокзала (гейт 1): билет ~250 тыс. ₫, в пути ~5 ч. | 2) От автовокзала Лао-Бао до КПП ~1 км - пешком или на мототакси (~30 тыс. ₫). | 3) Два чекпоинта: выход из Вьетнама и вход в Лаос, по ~1 час каждый. Гражданам РФ виза Лаоса не нужна. | 4) Возвращаешься тем же маршрутом; свежий штамп Вьетнама ставят при въезде. | 5) Итого самостоятельно: $40-120 в зависимости от типа новой визы. | Центральный автовокзал Дананга: https://www.google.com/maps/search/?api=1&query=Da+Nang+Central+Bus+Station | Сервис Lynn Visa: офис 14 Mạc Cửu, автобус вт и пт в 7:00, трансфер ~750-850 тыс. ₫, с новой 90-дневной e-visa - от ~2,75 млн ₫. | Щелкун и Innam: сервисы из русскоязычных чатов Дананга - ищи в Telegram-группах «Дананг», в вебе их нет. | Никаких предоплат непроверенным посредникам - см. гид про скам.',
	 'i-lucide-plane-takeoff', 'ru', 'published', 'under_review', 'Rewritten for clarity per founder feedback', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000032', 'transport', 'transport-visarun',
	 'Visa run: Da Nang - Lao Bao',
	 'When your visa or stamp runs out you must leave Vietnam and re-enter. The closest option from Da Nang is a one-day visa run to the Laos border (Lao Bao crossing). It is about 5 hours each way and takes the whole day. Two ways to do it: DIY by bus ($40-120 total) or with a service (~750-850k VND, zero hassle).',
	 'DIY route, step by step. | 1) Morning bus from the central bus station (gate 1): ticket ~250k VND, about 5 h ride. | 2) From Lao Bao bus stop to the crossing ~1 km - on foot or by bike taxi (~30k VND). | 3) Two checkpoints: exit Vietnam, enter Laos, about an hour each. Russians do not need a Lao visa. | 4) Return the same way; the fresh Vietnam stamp is given at entry. | 5) DIY total: $40-120 depending on the new visa type. | Central bus station: https://www.google.com/maps/search/?api=1&query=Da+Nang+Central+Bus+Station | Lynn Visa service: office at 14 Mac Cuu, bus Tue/Fri 7:00, transfer ~750-850k VND, with a new 90-day e-visa from ~2.75M VND. | Shchelkun and Innam: services from the Russian-speaking Da Nang chats - look in the Telegram groups, they are not web-indexed. | No prepayments to unverified operators - see the scam guide.',
	 'i-lucide-plane-takeoff', 'en', 'published', 'under_review', 'Rewritten for clarity per founder feedback', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now())
on conflict (category_slug, slug, language) do update
set title = excluded.title, summary = excluded.summary, note = excluded.note, icon = excluded.icon,
	updated_at = now(), last_verified_at = now();
