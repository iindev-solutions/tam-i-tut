-- Migration: 033_food_expansion_seed
-- Purpose: Phase 4 sourced food expansion - 13 new published Da Nang venues
-- (rows-per-language ru/en), continuing the deterministic place id prefix.
-- Every venue is externally sourced (Michelin Guide 2025/2026, Tripadvisor,
-- official site/social); prices/hours appear only where a source states them.
-- Skipped as already seeded: banh-xeo-ba-duong, bun-cha-ca-ba-lu, cong-cafe.
-- places has no coordinates column; street addresses live in area text.
-- Mirrored into supabase/seed.sql for local/CI parity.

insert into public.places (id, city_slug, slug, place_type, price_level, verified, status)
values
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0b', 'da-nang', 'bun-cha-ca-ba-hoa', 'street', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0c', 'da-nang', 'mi-quang-sua-hong-van', 'street', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0d', 'da-nang', 'com-ga-lan', 'street', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0e', 'da-nang', 'bun-mam-ba-dong', 'street', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0f', 'da-nang', 'mi-quang-ech-bep-trang', 'restaurant', 'average', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f10', 'da-nang', 'nhang-nuong', 'restaurant', 'average', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f11', 'da-nang', 'be-loan', 'street', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f12', 'da-nang', 'burger-bros', 'restaurant', 'average', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f13', 'da-nang', 'ganesh-da-nang', 'restaurant', 'average', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f14', 'da-nang', 'cardi-pizzeria', 'restaurant', 'above', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f15', 'da-nang', 'rioni-georgian', 'restaurant', 'above', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f16', 'da-nang', 'xliii-coffee', 'cafe', 'above', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f17', 'da-nang', 'banh-mi-co-tien', 'street', 'budget', true, 'published')
on conflict (id) do update
set
	city_slug = excluded.city_slug,
	slug = excluded.slug,
	place_type = excluded.place_type,
	price_level = excluded.price_level,
	verified = excluded.verified,
	status = excluded.status;

insert into public.place_localizations (place_id, language, name, area, summary)
values
	-- Bún Chả Cá Bà Hoa (Michelin Guide; Lê Hồng Phong - bún chả cá street)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0b', 'ru', 'Bún chả cá Bà Hoa', 'Hải Châu, Lê Hồng Phong', 'Рыбный суп с фрикадельками - главный завтрак Дананга. Улица Lê Hồng Phong - его родина: рядом ещё несколько таких же. С раннего утра до вечера.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0b', 'en', 'Bún chả cá Bà Hoa', 'Hai Chau, Le Hong Phong', 'Fish cake noodle soup - Da Nang''s signature breakfast. Le Hong Phong street is its home: several more like it nearby. Early morning to evening.'),
	-- Mỳ Quảng Sứa Hồng Vân (Michelin Bib Gourmand; mornings only)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0c', 'ru', 'Mỳ Quảng Sứa Hồng Vân', 'Hải Châu, Lê Hồng Phong', 'Мискуанг с медузой - редкий данангский специалитет, в списке Michelin Bib Gourmand. Работает только утром - приходи до полудня.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0c', 'en', 'Mỳ Quảng Sứa Hồng Vân', 'Hai Chau, Le Hong Phong', 'Mi Quang with jellyfish - a rare Da Nang specialty, Michelin Bib Gourmand listed. Mornings only - come before noon.'),
	-- Cơm Gà Lan (Michelin Guide 2026; one dish, three preparations)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0d', 'ru', 'Cơm Gà Lan', 'Hải Châu, Trưng Nữ Vương', 'Рис с курицей - одно блюдо, три варианта (гриль/варёная/рваная). От 35 тыс. ₫. В списке Michelin 2026. Заказывать просто - идеален в первый день.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0d', 'en', 'Cơm Gà Lan', 'Hai Chau, Trung Nu Vuong', 'Chicken rice - one dish, three ways (grilled/poached/shredded). From 35k VND. Michelin Guide 2026. Zero ordering stress - perfect for day one.'),
	-- Bún mắm Bà Đông (Michelin Guide; adventurous pick)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0e', 'ru', 'Bún mắm Bà Đông', 'Hải Châu, Huỳnh Thúc Kháng', 'Суп бунмам на ферментированной рыбной пасте - самый смелый вкус города, в списке Michelin. Бюджетно. Для любителей сильных впечатлений.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0e', 'en', 'Bún mắm Bà Đông', 'Hai Chau, Huynh Thuc Khang', 'Fermented fish paste noodle soup - the boldest flavor in town, Michelin listed. Budget friendly. For adventurous eaters only.'),
	-- Mì Quảng Ếch Bếp Trang (Tripadvisor; sit-down chain, riverside branch)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0f', 'ru', 'Mỳ Quảng Ếch Bếp Trang', 'Hải Châu, Bạch Đằng', 'Мискуанг с лягушкой в сидячей кафе с кондиционером прямо на набережной. От 59 тыс. ₫. Хороший «переход» от уличных точек к ресторанам.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0f', 'en', 'Mỳ Quảng Ếch Bếp Trang', 'Hai Chau, Bach Dang', 'Frog mi Quang at a proper sit-down place with AC on the riverside. From 59k VND. A good step up from street stalls.'),
	-- Nhắng Nướng (Ghiền Đà Nẵng 2025; evening BBQ)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f10', 'ru', 'Nhắng Nướng', 'Sơn Trà, Ngô Quyền', 'Угольный гриль: местная рыбка нханг и морепродукты на углях. Блюда 35-100 тыс. ₫. Работает с 16:00 до полуночи - вечерний вариант без туристических цен.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f10', 'en', 'Nhắng Nướng', 'Son Tra, Ngo Quyen', 'Charcoal grill: local nhang fish and seafood over coals. Dishes 35-100k VND. Open 16:00 to midnight - an evening option at local prices.'),
	-- Bé Loan (Kala Kala guide 2025; Huế-style rice cakes)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f11', 'ru', 'Bé Loan', 'Hải Châu, Trưng Nữ Vương', 'Хуэские рисовые пирожные: bánh bèo, bánh nậm, bánh lọc. От 20 тыс. ₫. С 6:30 до 21:30. Лёгкая закуска между делом.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f11', 'en', 'Bé Loan', 'Hai Chau, Trung Nu Vuong', 'Hue-style rice cakes: banh beo, banh nam, banh loc. From 20k VND. Open 6:30-21:30. A light snack between stops.'),
	-- Burger Bros (Tripadvisor 4.3/1639; real shops: NCT + An Thuong)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f12', 'ru', 'Burger Bros', 'Hải Châu, Nguyễn Chí Thanh', 'Смэш-бургеры у экспатов - около 100 тыс. ₫ за бургер. Настоящие точки: NCT (4 Nguyễn Chí Thanh) и пляжная ветка на An Thượng - у бренда много подражателей.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f12', 'en', 'Burger Bros', 'Hai Chau, Nguyen Chi Thanh', 'Expat-famous smash burgers - around 100k VND each. Real shops: NCT (4 Nguyen Chi Thanh) and the beach branch on An Thuong - the brand has many imitators.'),
	-- Ganesh Da Nang (Tripadvisor; North Indian, veg/vegan)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f13', 'ru', 'Ganesh Da Nang', 'Ngũ Hành Sơn, Lê Quang Đạo', 'Северная индийская кухня: карри, тандыр, много веган/вегетарианского. Филиал известной вьетнамской сети Ganesh, в экспатском районе An Thượng.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f13', 'en', 'Ganesh Da Nang', 'Ngu Hanh Son, Le Quang Dao', 'North Indian: curries, tandoor, plenty of veg/vegan. A branch of the well-known Ganesh Vietnam chain, in the An Thuong expat area.'),
	-- Cardi Pizzeria (Tripadvisor 4.9; wood-fired, riverside)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f14', 'ru', 'Cardi Pizzeria', 'Hải Châu, Bạch Đằng', 'Неаполитанская пицца из дровяной печи 400°C на набережной. Tripadvisor 4.9 - экспаты называют лучшей пиццей города.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f14', 'en', 'Cardi Pizzeria', 'Hai Chau, Bach Dang', 'Neapolitan pizza from a 400°C wood-fired oven on the riverside. Tripadvisor 4.9 - expats call it the best pizza in town.'),
	-- RIONI Georgian (official Instagram; khinkali/khachapuri)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f15', 'ru', 'RIONI Georgian', 'Ngũ Hành Sơn, Đỗ Bí', 'Первая грузинская в Дананге: хинкали 55 тыс. ₫, хачапури 240 тыс. ₫. Знакомый вкус «как дома» для русскоязычных.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f15', 'en', 'RIONI Georgian', 'Ngu Hanh Son, Do Bi', 'The first Georgian restaurant in Da Nang: khinkali 55k VND, khachapuri 240k VND. A taste of home for Russian speakers.'),
	-- XLIII Coffee (official site; specialty roastery near My Khe)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f16', 'ru', 'XLIII Coffee', 'Ngũ Hành Sơn, Ngô Thì Sỹ', 'Спешелти обжарка недалеко от пляжа Mỹ Khê (бывший 43 Factory). Напитки 60-120 тыс. ₫, премиальные пуроверы дороже. Открытие в 6:30, можно с ноутбуком.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f16', 'en', 'XLIII Coffee', 'Ngu Hanh Son, Ngo Thi Sy', 'Specialty roastery near My Khe beach (the former 43 Factory). Drinks 60-120k VND, premium pour-overs higher. Opens 6:30, laptop friendly.'),
	-- Bánh Mì Cô Tiên (Tripadvisor 4.8; spare bánh mì pick)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f17', 'ru', 'Bánh Mì Cô Tiên', 'Hải Châu, Trần Phú', 'Банхми с высокой оценкой (Tripadvisor 4.8) в центре. Быстро, дёшево, с собой - классический уличный перекус.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f17', 'en', 'Bánh Mì Cô Tiên', 'Hai Chau, Tran Phu', 'Highly rated banh mi (Tripadvisor 4.8) in the center. Fast, cheap, to go - the classic street snack.')
on conflict (place_id, language) do update
set
	name = excluded.name,
	area = excluded.area,
	summary = excluded.summary;
