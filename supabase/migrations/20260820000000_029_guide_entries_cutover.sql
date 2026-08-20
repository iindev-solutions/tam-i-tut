-- Migration: 029_guide_entries_cutover
-- Purpose: Guide cutover (transport/money/safety) - add the pairing/shape
-- columns needed to map rows-per-language guide_entries into the UI's
-- LocalizedText contract (slug pairs ru/en rows; note and icon carry the rest
-- of the GuideEntry shape), and seed the accepted mock guide content.
-- Source Design: vault/wiki/architecture/admin-panel-and-prod-plan.md (later slices)

alter table public.guide_entries add column if not exists slug text;
alter table public.guide_entries add column if not exists note text;
alter table public.guide_entries add column if not exists icon text;

-- The table is empty at this point (0 rows on both local and remote).
update public.guide_entries set slug = id::text where slug is null;
alter table public.guide_entries alter column slug set not null;
alter table public.guide_entries add constraint guide_entries_slug_not_empty check (btrim(slug) <> '');
alter table public.guide_entries add constraint guide_entries_slug_unique_per_language
	unique (category_slug, slug, language);

-- Seed owner auth user + profile (fixed id) so guide_entries FKs resolve
-- deterministically on any environment (remote admin has a runtime id).
insert into auth.users (id)
values ('00000000-0000-0000-0000-0000000000aa')
on conflict (id) do nothing;

insert into public.profiles (id, role, display_name, locale, is_active)
values ('00000000-0000-0000-0000-0000000000aa', 'curator', 'Seed Editor', 'ru', true)
on conflict (id) do nothing;

-- Accepted mock guide content (frontend mocks/db.ts), rows-per-language.
insert into public.guide_entries
	(id, category_slug, slug, title, summary, note, icon, language, status,
	 trust_badge, under_review_note, owner_profile_id, created_by_profile_id,
	 updated_by_profile_id, published_at, last_verified_at)
values
	-- Transport
	('00000000-0000-0000-0000-000000000001', 'transport', 'transport-grab', 'Grab и Xanh SM', 'Такси через приложение: цена известна заранее, оплата картой или наличными. Из аэропорта до центра 100-150 тыс. ₫.', 'байк 15-30 тыс. ₫, авто 40-80 тыс. ₫', 'i-lucide-car-taxi-front', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000002', 'transport', 'transport-grab', 'Grab and Xanh SM', 'App taxis: price fixed before the ride, pay by card or cash. Airport to center is 100-150k VND.', 'bike 15-30k, car 40-80k VND', 'i-lucide-car-taxi-front', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000003', 'transport', 'transport-bike', 'Аренда байка', 'Депозит 1-3 млн ₫ или паспорт. Проверь тормоза и свет, сфотографируй царапины до подписания.', 'от 900 000 - 1 500 000 ₫ в месяц', 'i-lucide-bike', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000004', 'transport', 'transport-bike', 'Bike rental', 'Deposit 1-3M VND or a passport. Check brakes and lights, photograph scratches before signing.', '900,000-1,500,000 VND per month', 'i-lucide-bike', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000005', 'transport', 'transport-bus', 'Городские автобусы', 'Маршруты идут вдоль пляжной линии и через центр. Оплата наличными при входе, кондиционер есть.', '5 000-10 000 ₫ за поездку', 'i-lucide-bus', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000006', 'transport', 'transport-bus', 'City buses', 'Routes run along the beach line and through the center. Pay cash on boarding, air-con included.', '5,000-10,000 VND per ride', 'i-lucide-bus', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000007', 'transport', 'transport-airport', 'Из аэропорта', 'Аэропорт внутри города: до центра 10 минут на Grab. Стойка такси дороже приложения.', 'аэропорт в 3 км от центра', 'i-lucide-plane-landing', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000008', 'transport', 'transport-airport', 'From the airport', 'The airport sits inside the city: 10 minutes to the center by Grab. The taxi desk costs more than the app.', 'airport is 3 km from the center', 'i-lucide-plane-landing', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	-- Money
	('00000000-0000-0000-0000-000000000009', 'money', 'money-cash', 'Наличные', 'Рынки, уличная еда и автобусы - только наличные. Держи мелкие купюры отдельно от крупных.', 'вьетнамский донг - основная валюта', 'i-lucide-banknote', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000000a', 'money', 'money-cash', 'Cash', 'Markets, street food, and buses are cash only. Keep small bills separate from large ones.', 'Vietnamese dong is the main currency', 'i-lucide-banknote', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000000b', 'money', 'money-card', 'Карты', 'Принимают в ТЦ, сетевых кафе и аптеках. В маленьких quánах и на рынках - нет.', 'Visa и Mastercard', 'i-lucide-credit-card', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000000c', 'money', 'money-card', 'Cards', 'Accepted in malls, chain cafes, and pharmacies. Not in small family shops or markets.', 'Visa and Mastercard', 'i-lucide-credit-card', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000000d', 'money', 'money-qr', 'Оплата по QR', 'В ресторанах часто принимают перевод по QR через местное банковское приложение. Туристу удобнее наличные или Grab.', 'VietQR - везде у местных', 'i-lucide-qr-code', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000000e', 'money', 'money-qr', 'QR payments', 'Restaurants often take QR transfers via local bank apps. For visitors, cash or Grab is simpler.', 'VietQR - used by locals everywhere', 'i-lucide-qr-code', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000000f', 'money', 'money-atm', 'Банкоматы', 'Снимай в банкоматах при отделениях Vietcombank или Techcombank: комиссия ниже, лимит выше.', 'лимит 2-5 млн ₫, комиссия 22-55 тыс. ₫', 'i-lucide-landmark', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000010', 'money', 'money-atm', 'ATMs', 'Withdraw at Vietcombank or Techcombank branch ATMs: lower fees, higher limits.', '2-5M VND limit, 22-55k VND fee', 'i-lucide-landmark', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	-- Safety
	('00000000-0000-0000-0000-000000000011', 'safety', 'safety-helmet', 'Шлем на байке', 'Шлем обязателен для водителя и пассажира. Проверки на дорогах - обычное дело, без шлема штрафуют.', 'штраф до 600 000 ₫', 'i-lucide-hard-hat', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000012', 'safety', 'safety-helmet', 'Helmet on a bike', 'A helmet is required for rider and passenger. Road checks are routine; no helmet means a fine.', 'fine up to 600,000 VND', 'i-lucide-hard-hat', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000013', 'safety', 'safety-numbers', 'Номера заранее', 'Сохрани 113, 114 и 115 до первой поездки. Местные вызовы работают без интернета.', 'доступны офлайн', 'i-lucide-phone', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000014', 'safety', 'safety-numbers', 'Numbers in advance', 'Save 113, 114, and 115 before your first ride. Local calls work without internet.', 'available offline', 'i-lucide-phone', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000015', 'safety', 'safety-bags', 'Сумки на виду', 'Держи сумку дальше от проезжей части: мото-кражи сумок редки, но случаются вечером.', 'не вешай на плечо к дороге', 'i-lucide-backpack', 'ru', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000016', 'safety', 'safety-bags', 'Bags in sight', 'Keep your bag away from the road: moto bag-snatching is rare but happens at night.', 'do not hang it road-side', 'i-lucide-backpack', 'en', 'published', 'under_review', 'Seed content, pending editorial verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now())
on conflict (id) do nothing;
