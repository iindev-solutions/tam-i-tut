-- Migration: 053_visarun_category_step2
-- Purpose: step 2 (separate transaction). Registers the visarun category row,
-- moves the visa-run guide out of transport, and refreshes its content with
-- founder-reported 2026 facts: the bus now costs 500-600k VND and the
-- checkpoints ask ~50k VND per stamp (exit/entry, both sides) - ~200k total.

insert into public.categories (slug, title_ru, title_en, sort_order, is_active)
values ('visarun', 'Визаран', 'Visa run', 9, true)
on conflict (slug) do update
set title_ru = excluded.title_ru, title_en = excluded.title_en,
	sort_order = excluded.sort_order, is_active = excluded.is_active;

update public.guide_entries set category_slug = 'visarun'
where slug = 'transport-visarun';

update public.guide_entries
set summary = 'Виза или штамп на исходе - нужно выехать из Вьетнама и заехать заново. Ближайший вариант из Дананга - однодневный визаран на границу с Лаосом (КПП Лао-Бао). Дорога около 5 часов в одну сторону, вся поездка занимает день. Способа два: самостоятельно на автобусе или через сервис (~750-850 тыс. ₫, без хлопот).',
	note = 'Своими силами, шаг за шагом. | 1) Автобус Дананг - Лао-Бао с центрального автовокзала (гейт 1): сейчас 500-600 тыс. ₫, в пути ~5 ч. | 2) От автовокзала Лао-Бао до КПП ~1 км - пешком или на мототакси (~30 тыс. ₫). | 3) На каждом переходе просят ~50 тыс. ₫ «за штамп»: выход из Вьетнама, вход в Лаос, выход из Лаоса, вход во Вьетнам - в сумме закладывай ~200 тыс. ₫. Гражданам РФ виза Лаоса не нужна. | 4) Возвращаешься тем же маршрутом; свежий штамп Вьетнама ставят при въезде. | 5) Итого самостоятельно: ~700-800 тыс. ₫ на дорогу и переходы + цена новой визы. | Центральный автовокзал Дананга: https://www.google.com/maps/search/?api=1&query=Da+Nang+Central+Bus+Station | Сервис Lynn Visa: офис 14 Mạc Cửu, автобус вт и пт в 7:00, трансфер ~750-850 тыс. ₫, с новой 90-дневной e-visa - от ~2,75 млн ₫. | Щелкун и Innam: сервисы из русскоязычных чатов Дананга - ищи в Telegram-группах «Дананг», в вебе их нет. | Никаких предоплат непроверенным посредникам - см. гид про скам.',
	updated_at = now(), last_verified_at = now()
where slug = 'transport-visarun' and language = 'ru';

update public.guide_entries
set summary = 'When your visa or stamp runs out you must leave Vietnam and re-enter. The closest option from Da Nang is a one-day visa run to the Laos border (Lao Bao crossing). It is about 5 hours each way and takes the whole day. Two ways to do it: DIY by bus, or with a service (~750-850k VND, zero hassle).',
	note = 'DIY route, step by step. | 1) Da Nang - Lao Bao bus from the central bus station (gate 1): now 500-600k VND, about 5 h ride. | 2) From Lao Bao bus stop to the crossing ~1 km - on foot or by bike taxi (~30k VND). | 3) At every crossing they ask ~50k VND "for the stamp": exit Vietnam, enter Laos, exit Laos, enter Vietnam - budget ~200k VND in total. Russians do not need a Lao visa. | 4) Return the same way; the fresh Vietnam stamp is given at entry. | 5) DIY total: ~700-800k VND for transport and crossings + the price of the new visa. | Central bus station: https://www.google.com/maps/search/?api=1&query=Da+Nang+Central+Bus+Station | Lynn Visa service: office at 14 Mac Cuu, bus Tue/Fri 7:00, transfer ~750-850k VND, with a new 90-day e-visa from ~2.75M VND. | Shchelkun and Innam: services from the Russian-speaking Da Nang chats - look in the Telegram groups, they are not web-indexed. | No prepayments to unverified operators - see the scam guide.',
	updated_at = now(), last_verified_at = now()
where slug = 'transport-visarun' and language = 'en';
