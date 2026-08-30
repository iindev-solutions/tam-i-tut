-- Migration: 044_knowledge_health_districts
-- Purpose: knowledge-dump pass #2 (source: data/knowledge-dump.md, analog bot
-- Inside Danang). Rewritten in TAMITUT voice, facts kept, bilingual.
-- Mapping:
--   My An / Son Tra / Khue My-Hoa Hai / FPT City blocks -> district summaries
--     enriched (ngu-hanh-son gains the expat tag; My An is inside it)
--   Hai Chau block -> district summary (center, malls, offices)
--   hospitals + checkup + emergency -> NEW guide safety-hospitals
--   pharmacies tips -> NEW guide safety-pharmacies
--   insurance recommendations -> NEW guide safety-insurance
--   dentist recommendations -> NEW guide safety-dentist
--   menu vocabulary -> NEW guide food-menu-decoder (category food; UI slot
--     arrives with the scanner/food-guides section)
--   drinks vocabulary -> NEW guide food-drinks

insert into auth.users (id) values ('00000000-0000-0000-0000-0000000000aa') on conflict (id) do nothing;
insert into public.profiles (id, role, display_name, locale, is_active)
values ('00000000-0000-0000-0000-0000000000aa', 'curator', 'Seed Editor', 'ru', true)
on conflict (id) do nothing;

-- Districts enrichment -------------------------------------------------------

update public.district_localizations set best_for = '{beach,expat,family}' where district_id = 'b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f02';

update public.district_localizations set
	summary = 'Внутри - My An, самый популярный у экспатов район: всё близко пешком, сотни кафе и ресторанов мировых кухонь, коворкинги, спа, персонал говорит по-английски. Апартаментов много, но цены выше. Khue My и Hoa Hai тише: резорты у моря, местные кафе, несколько выходов к пляжу. FPT City - новые дома вокруг кампуса FPT, заметно спокойнее и дешевле, лучше с байком.',
	area = 'My An - Khue My - Hoa Hai - FPT City'
where district_id = 'b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f02' and language = 'ru';

update public.district_localizations set
	summary = 'Home to My An - the most popular expat area: everything walkable, hundreds of cafes and world-cuisine restaurants, coworkings and spas, English-speaking staff. Plenty of apartments, but prices run higher. Khue My and Hoa Hai are quieter: seaside resorts, local cafes, several beach access points. FPT City - new housing around the FPT campus, notably calmer and cheaper, best with a bike.',
	area = 'My An - Khue My - Hoa Hai - FPT City'
where district_id = 'b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f02' and language = 'en';

update public.district_localizations set
	summary = 'Пляжный район от My An до Леди Будды: туристические кварталы плавно переходят в местную жизнь. Кафе, бары и спа у моря; рынки, Vincom Plaza, супермаркеты Coopmart и VinMart. Апартаментов много. Чем дальше к горе - тем меньше иностранцев и туристической инфраструктуры. Удобен и для отпуска, и для долгой жизни, особенно с байком.',
	area = 'Побережье Mỹ Khê - Sơn Trà'
where district_id = 'b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f01' and language = 'ru';

update public.district_localizations set
	summary = 'Beach district from My An up to the Lady Buddha: tourist blocks fade into local life. Seaside cafes, bars and spas; markets, Vincom Plaza, Coopmart and VinMart supermarkets. Plenty of apartments. The closer to the mountain, the fewer foreigners and tourist infrastructure. Works both for a holiday and long-term living, especially with a bike.',
	area = 'My Khe coast - Son Tra'
where district_id = 'b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f01' and language = 'en';

update public.district_localizations set
	summary = 'Центр за рекой Хан: офисы, музеи, консульства, аэропорт и ж/д вокзал. Настоящий местный Дананг - суетно и много байков, поэтому новожилам бывает непривычно; чаще выбирают те, кто уже пожил в городе. Супермаркеты GO! (Big C), Lotte Mart, MM Mega Market.',
	area = 'Центр за рекой Хан'
where district_id = 'b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f03' and language = 'ru';

update public.district_localizations set
	summary = 'The center across the Han river: offices, museums, consulates, the airport and train station. Real local Da Nang - busy and bike-heavy, which can overwhelm newcomers; usually picked by those who have already lived here a while. Supermarkets: GO! (Big C), Lotte Mart, MM Mega Market.',
	area = 'Center across the Han river'
where district_id = 'b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f03' and language = 'en';

-- New guides -----------------------------------------------------------------

insert into public.guide_entries
	(id, category_slug, slug, title, summary, note, icon, language, status,
	 trust_badge, under_review_note, owner_profile_id, created_by_profile_id,
	 updated_by_profile_id, published_at, last_verified_at)
values
	('00000000-0000-0000-0000-000000000019', 'food', 'food-menu-decoder', 'Как читать вьетнамское меню', 'Названия блюд = ингредиенты + способ готовки. Cơm - рис, Bún - тонкая рисовая лапша, Mì - пшеничная, Bánh - изделия из теста. Gà - курица, Bò - говядина, Tôm - креветки, Cá - рыба, Mực - кальмар. Chiên - жареное, Nướng - гриль, Xào - жарка в воке, Chay - вегетарианское.', 'Cơm gà - рис с курицей, Bún cá - лапша с рыбой, Mì xào bò - жареная лапша с говядиной. Слово Chay на вывеске = готовят без мяса.', 'i-lucide-scroll-text', 'ru', 'published', 'under_review', 'Контент из knowledge-dump, ждёт проверки', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000001a', 'food', 'food-menu-decoder', 'How to read a Vietnamese menu', 'Dish names = ingredients + cooking method. Cơm - rice, Bún - thin rice noodles, Mì - wheat noodles, Bánh - dough items. Gà - chicken, Bò - beef, Tôm - shrimp, Cá - fish, Mực - squid. Chiên - fried, Nướng - grilled, Xào - stir-fried, Chay - vegetarian.', 'Cơm gà - chicken rice, Bún cá - fish noodle soup, Mì xào bò - stir-fried noodles with beef. The word Chay on a sign = no meat.', 'i-lucide-scroll-text', 'en', 'published', 'under_review', 'Knowledge-dump content, pending verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000001b', 'food', 'food-drinks', 'Напитки и вывески', 'Почти все напитки здесь делают с сахаром; в кафе часто бесплатный зелёный чай со льдом (Trà đá). Nước ép - свежевыжатый сок, Sinh tố - смузи, Cà phê sữa đá - кофе со сгущёнкой и льдом, Cà phê muối - солёный кофе.', 'Вывески: Cam - апельсин, Thơm/Dứa - ананас, Xoài - манго, Bơ - авокадо, Trà tắc - кумкватовый чай, Nước dừa - кокосовая вода, Nước mía - тростниковый сок.', 'i-lucide-cup-soda', 'ru', 'published', 'under_review', 'Контент из knowledge-dump, ждёт проверки', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000001c', 'food', 'food-drinks', 'Drinks and signs', 'Almost every drink here comes with sugar; cafes often serve free iced green tea (Trà đá). Nước ép - fresh juice, Sinh tố - smoothie, Cà phê sữa đá - iced coffee with condensed milk, Cà phê muối - salt coffee.', 'Signs: Cam - orange, Thơm/Dứa - pineapple, Xoài - mango, Bơ - avocado, Trà tắc - kumquat tea, Nước dừa - coconut water, Nước mía - sugarcane juice.', 'i-lucide-cup-soda', 'en', 'published', 'under_review', 'Knowledge-dump content, pending verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000001d', 'safety', 'safety-hospitals', 'Больницы, чекап и скорая', 'Для иностранцев: Family Hospital, 199 Hospital и Vinmec. Приём 200-400 тыс. ₫ и выше; чекап в Family/199 - около 2 млн ₫. Экстренные отделения работают 24/7, скорая - 115 (лучше попросить местного позвонить).', '🗺 Family Hospital: https://maps.app.goo.gl/K7uGjs56u5psQbco9 | 199 Hospital: https://maps.app.goo.gl/KNYN9Kbok48GS88H6 | Vinmec: https://maps.app.goo.gl/3MGmQFRRJL8pQRhA8', 'i-lucide-hospital', 'ru', 'published', 'under_review', 'Контент из knowledge-dump, ждёт проверки', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000001e', 'safety', 'safety-hospitals', 'Hospitals, checkups and emergencies', 'For foreigners: Family Hospital, 199 Hospital and Vinmec. A visit runs 200-400k VND and up; a checkup at Family/199 is around 2M VND. Emergency rooms work 24/7; the ambulance number is 115 - better ask a local to call.', '🗺 Family Hospital: https://maps.app.goo.gl/K7uGjs56u5psQbco9 | 199 Hospital: https://maps.app.goo.gl/KNYN9Kbok48GS88H6 | Vinmec: https://maps.app.goo.gl/3MGmQFRRJL8pQRhA8', 'i-lucide-hospital', 'en', 'published', 'under_review', 'Knowledge-dump content, pending verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-00000000001f', 'safety', 'safety-pharmacies', 'Аптеки', 'Сети с большим выбором: Pharmacity и FPT Long Chau. На картах аптеку ищи по словам «Nhà thuốc» или «Pharmacy». Таблетки продают поштучно - целую упаковку брать не обязательно (кроме сиропов и неделимых форм).', 'Смотри действующее вещество в составе, а не бренд - покажи его фармацевту.', 'i-lucide-pill', 'ru', 'published', 'under_review', 'Контент из knowledge-dump, ждёт проверки', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000020', 'safety', 'safety-pharmacies', 'Pharmacies', 'Well-stocked chains: Pharmacity and FPT Long Chau. On maps, search for «Nhà thuốc» or «Pharmacy». Pills are sold per-piece - no need to buy a whole box (except syrups and non-divisible forms).', 'Check the active ingredient rather than the brand name - show it to the pharmacist.', 'i-lucide-pill', 'en', 'published', 'under_review', 'Knowledge-dump content, pending verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000021', 'safety', 'safety-insurance', 'Страховка', 'В экспат-чатах советуют страховки Тинькофф и Genki; также смотрят агрегаторы «Черепаха» и «Полис 812». При болезни или травме сначала свяжись со страховой - они подскажут, в какую клинику ехать.', 'Без страховки приём в Family/199 - 200-400 тыс. ₫ и выше.', 'i-lucide-shield-plus', 'ru', 'published', 'under_review', 'Контент из knowledge-dump, ждёт проверки', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000022', 'safety', 'safety-insurance', 'Insurance', 'Expat chats usually recommend Tinkoff and Genki insurance; people also check the aggregators Cherepakha and Polis 812. If you get sick or injured, contact your insurer first - they will tell you which clinic to go to.', 'Without insurance a visit to Family/199 runs 200-400k VND and up.', 'i-lucide-shield-plus', 'en', 'published', 'under_review', 'Knowledge-dump content, pending verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000023', 'safety', 'safety-dentist', 'Стоматолог', 'По отзывам экспатов: Nha khoa Dr. Bão и Dana Dental. Ориентир по пломбам: простая ~400 тыс. ₫, сложная ~600 тыс. ₫; более сложные процедуры - от 1 млн ₫.', '🗺 Nha khoa Dr. Bão: https://maps.app.goo.gl/SFQFCQMa3iH4KFwL8 | Dana Dental: https://maps.app.goo.gl/BxsnxnMFEtUbET576', 'i-lucide-plus', 'ru', 'published', 'under_review', 'Контент из knowledge-dump, ждёт проверки', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now()),
	('00000000-0000-0000-0000-000000000024', 'safety', 'safety-dentist', 'Dentist', 'Expat favorites: Nha khoa Dr. Bão and Dana Dental. Ballpark filling prices: simple ~400k VND, complex ~600k VND; advanced procedures from 1M VND.', '🗺 Nha khoa Dr. Bão: https://maps.app.goo.gl/SFQFCQMa3iH4KFwL8 | Dana Dental: https://maps.app.goo.gl/BxsnxnMFEtUbET576', 'i-lucide-plus', 'en', 'published', 'under_review', 'Knowledge-dump content, pending verification', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', '00000000-0000-0000-0000-0000000000aa', now(), now())
on conflict (category_slug, slug, language) do update
set title = excluded.title, summary = excluded.summary, note = excluded.note,
	updated_at = now(), last_verified_at = now();
