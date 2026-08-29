-- TAMITUT seed scaffold
-- Deterministic local seed data for development/test only.
-- Category canonical seed is defined in migration 002.
-- City-aware schema v2 seed (design: vault/wiki/architecture/schema-v2-city-aware.md).
--
-- Cities carry the tenancy axis; Da Nang is the only active pilot city.
-- Places are the real Da Nang venues sourced by the team (see frontend mock history);
-- the localized rows follow the rows-per-language model.

insert into public.cities (slug, name_en, name_ru, country_code, flag, is_active, sort_order)
values
	('da-nang', 'Da Nang', 'Дананг', 'VN', '🇻🇳', true, 1),
	('nha-trang', 'Nha Trang', 'Нячанг', 'VN', '🇻🇳', false, 2),
	('pattaya', 'Pattaya', 'Паттайя', 'TH', '🇹🇭', false, 3),
	('phuket', 'Phuket', 'Пхукет', 'TH', '🇹🇭', false, 4)
on conflict (slug) do update
set
	name_en = excluded.name_en,
	name_ru = excluded.name_ru,
	country_code = excluded.country_code,
	flag = excluded.flag,
	is_active = excluded.is_active,
	sort_order = excluded.sort_order;

-- Seed places (food slice). Canonical ids come from the accepted mock contract.
insert into public.places (id, city_slug, slug, place_type, price_level, verified, status)
values
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f01', 'da-nang', 'banh-mi-madam-khanh', 'street', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f02', 'da-nang', 'mi-quang-1a', 'street', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f03', 'da-nang', 'banh-xeo-ba-duong', 'street', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f04', 'da-nang', 'bun-cha-ca-ba-lu', 'street', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f05', 'da-nang', 'cho-con', 'market', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f06', 'da-nang', 'cho-han', 'market', 'budget', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f07', 'da-nang', 'highlands-beach', 'cafe', 'average', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f08', 'da-nang', 'cong-cafe', 'cafe', 'average', false, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f09', 'da-nang', 'be-man-seafood', 'restaurant', 'above', true, 'published'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0a', 'da-nang', 'an-thuong-street', 'street', 'budget', false, 'published'),
	-- Phase 4 sourced food expansion (migration 033; also applied to hosted)
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
	-- Bánh mì Madam Khanh
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f01', 'ru', 'Bánh mì Madam Khanh', 'Hải Châu, Trần Cao Vân', 'Банхми с начинками на выбор, 25-40 тыс. ₫. Работает с раннего утра, очередь к вечеру.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f01', 'en', 'Bánh mì Madam Khanh', 'Hai Chau, Tran Cao Van', 'Banh mi with fillings to pick, 25-40k VND. Opens early, expect a queue in the evening.'),
	-- Mì Quang 1A
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f02', 'ru', 'Mì Quang 1A', 'Thanh Khê, 1A Hải Phòng', 'Мискуанг - фирменный суп Дананга с рисовой лапшой и креветкой. 35-60 тыс. ₫.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f02', 'en', 'Mì Quang 1A', 'Thanh Khe, 1A Hai Phong', 'Mi quang - Da Nang signature rice noodle soup with shrimp. 35-60k VND.'),
	-- Bánh xèo Bà Dưỡng
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f03', 'ru', 'Bánh xèo Bà Dưỡng', 'Hải Châu, Hoàng Diệu', 'Хрустящие баншо с зеленью и арахисовым соусом. Легендарное место, 40-70 тыс. ₫.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f03', 'en', 'Bánh xèo Bà Dưỡng', 'Hai Chau, Hoang Dieu', 'Crispy banh xeo pancakes with herbs and peanut sauce. A local legend, 40-70k VND.'),
	-- Bún chả cá Bà Lữ
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f04', 'ru', 'Bún chả cá Bà Lữ', 'Hải Châu, центр', 'Рыбный суп бунчакка - завтрак местных. Идти до обеда, дальше закрывается. 30-50 тыс. ₫.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f04', 'en', 'Bún chả cá Bà Lữ', 'Hai Chau, city center', 'Fish cake noodle soup - a local breakfast. Go before noon, it closes after. 30-50k VND.'),
	-- Chợ Cồn
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f05', 'ru', 'Chợ Cồn', 'Hải Châu, Ông Ích Khiêm', 'Главный рынок города: фудкорт наверху, фрукты и хозяйственное внизу. Только наличные.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f05', 'en', 'Chợ Cồn', 'Hai Chau, Ong Ich Khiem', 'The main city market: food court upstairs, fruit and goods below. Cash only.'),
	-- Chợ Hàn
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f06', 'ru', 'Chợ Hàn', 'Hải Châu, Trần Phú', 'Рынок у набережной реки Хан. Фрукты, кофе, сухофрукты - цены ниже туристических.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f06', 'en', 'Chợ Hàn', 'Hai Chau, Tran Phu', 'Market by the Han river promenade. Fruit, coffee, dried fruit - cheaper than tourist spots.'),
	-- Highlands Coffee (Võ Nguyên Giáp)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f07', 'ru', 'Highlands Coffee (Võ Nguyên Giáp)', 'Sơn Trà, пляжная линия', 'Сетка кофеен прямо у пляжа Мỹкхе. Кофе 45-75 тыс. ₫, карта принимают, Wi-Fi.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f07', 'en', 'Highlands Coffee (Võ Nguyên Giáp)', 'Son Tra, beachfront', 'Chain cafe right on My Khe beach. Coffee 45-75k VND, cards accepted, Wi-Fi.'),
	-- Cộng Cà Phê (Bạch Đằng)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f08', 'ru', 'Cộng Cà Phê (Bạch Đằng)', 'Hải Châu, набережная', 'Кофейня в ретро-стиле с видом на реку Хан и мост Дракона. Есть розетки.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f08', 'en', 'Cộng Cà Phê (Bạch Đằng)', 'Hai Chau, riverside', 'Retro-style cafe with Han river and Dragon Bridge views. Power sockets available.'),
	-- Bé Mặn Seafood
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f09', 'ru', 'Bé Mặn Seafood', 'Ngũ Hành Sơn, Võ Nguyên Giáp', 'Морепродукты с витрины: вес подтверждают при тебе. 150-400 тыс. ₫ за блюдо.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f09', 'en', 'Bé Mặn Seafood', 'Ngu Hanh Son, Vo Nguyen Giap', 'Seafood from the display: weight confirmed in front of you. 150-400k VND per dish.'),
	-- An Thượng food street
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0a', 'ru', 'An Thượng food street', 'Sơn Trà, улица An Thượng', 'Пешеходная улица еды в двух кварталах от моря: гриль, смузи, кофе до поздна.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0a', 'en', 'An Thượng food street', 'Son Tra, An Thuong street', 'Pedestrian food street two blocks from the sea: grills, smoothies, late-night coffee.'),
	-- Phase 4 sourced food expansion (migration 033 mirror)
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0b', 'ru', 'Bún chả cá Bà Hoa', 'Hải Châu, Lê Hồng Phong', 'Рыбный суп с фрикадельками - главный завтрак Дананга. Улица Lê Hồng Phong - его родина: рядом ещё несколько таких же. С раннего утра до вечера.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0b', 'en', 'Bún chả cá Bà Hoa', 'Hai Chau, Le Hong Phong', 'Fish cake noodle soup - Da Nang''s signature breakfast. Le Hong Phong street is its home: several more like it nearby. Early morning to evening.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0c', 'ru', 'Mỳ Quảng Sứa Hồng Vân', 'Hải Châu, Lê Hồng Phong', 'Мискуанг с медузой - редкий данангский специалитет, в списке Michelin Bib Gourmand. Работает только утром - приходи до полудня.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0c', 'en', 'Mỳ Quảng Sứa Hồng Vân', 'Hai Chau, Le Hong Phong', 'Mi Quang with jellyfish - a rare Da Nang specialty, Michelin Bib Gourmand listed. Mornings only - come before noon.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0d', 'ru', 'Cơm Gà Lan', 'Hải Châu, Trưng Nữ Vương', 'Рис с курицей - одно блюдо, три варианта (гриль/варёная/рваная). От 35 тыс. ₫. В списке Michelin 2026. Заказывать просто - идеален в первый день.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0d', 'en', 'Cơm Gà Lan', 'Hai Chau, Trung Nu Vuong', 'Chicken rice - one dish, three ways (grilled/poached/shredded). From 35k VND. Michelin Guide 2026. Zero ordering stress - perfect for day one.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0e', 'ru', 'Bún mắm Bà Đông', 'Hải Châu, Huỳnh Thúc Kháng', 'Суп бунмам на ферментированной рыбной пасте - самый смелый вкус города, в списке Michelin. Бюджетно. Для любителей сильных впечатлений.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0e', 'en', 'Bún mắm Bà Đông', 'Hai Chau, Huynh Thuc Khang', 'Fermented fish paste noodle soup - the boldest flavor in town, Michelin listed. Budget friendly. For adventurous eaters only.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0f', 'ru', 'Mỳ Quảng Ếch Bếp Trang', 'Hải Châu, Bạch Đằng', 'Мискуанг с лягушкой в сидячей кафе с кондиционером прямо на набережной. От 59 тыс. ₫. Хороший «переход» от уличных точек к ресторанам.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0f', 'en', 'Mỳ Quảng Ếch Bếp Trang', 'Hai Chau, Bach Dang', 'Frog mi Quang at a proper sit-down place with AC on the riverside. From 59k VND. A good step up from street stalls.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f10', 'ru', 'Nhắng Nướng', 'Sơn Trà, Ngô Quyền', 'Угольный гриль: местная рыбка нханг и морепродукты на углях. Блюда 35-100 тыс. ₫. Работает с 16:00 до полуночи - вечерний вариант без туристических цен.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f10', 'en', 'Nhắng Nướng', 'Son Tra, Ngo Quyen', 'Charcoal grill: local nhang fish and seafood over coals. Dishes 35-100k VND. Open 16:00 to midnight - an evening option at local prices.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f11', 'ru', 'Bé Loan', 'Hải Châu, Trưng Nữ Vương', 'Хуэские рисовые пирожные: bánh bèo, bánh nậm, bánh lọc. От 20 тыс. ₫. С 6:30 до 21:30. Лёгкая закуска между делом.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f11', 'en', 'Bé Loan', 'Hai Chau, Trung Nu Vuong', 'Hue-style rice cakes: banh beo, banh nam, banh loc. From 20k VND. Open 6:30-21:30. A light snack between stops.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f12', 'ru', 'Burger Bros', 'Hải Châu, Nguyễn Chí Thanh', 'Смэш-бургеры у экспатов - около 100 тыс. ₫ за бургер. Настоящие точки: NCT (4 Nguyễn Chí Thanh) и пляжная ветка на An Thượng - у бренда много подражателей.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f12', 'en', 'Burger Bros', 'Hai Chau, Nguyen Chi Thanh', 'Expat-famous smash burgers - around 100k VND each. Real shops: NCT (4 Nguyen Chi Thanh) and the beach branch on An Thuong - the brand has many imitators.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f13', 'ru', 'Ganesh Da Nang', 'Ngũ Hành Sơn, Lê Quang Đạo', 'Северная индийская кухня: карри, тандыр, много веган/вегетарианского. Филиал известной вьетнамской сети Ganesh, в экспатском районе An Thượng.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f13', 'en', 'Ganesh Da Nang', 'Ngu Hanh Son, Le Quang Dao', 'North Indian: curries, tandoor, plenty of veg/vegan. A branch of the well-known Ganesh Vietnam chain, in the An Thuong expat area.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f14', 'ru', 'Cardi Pizzeria', 'Hải Châu, Bạch Đằng', 'Неаполитанская пицца из дровяной печи 400°C на набережной. Tripadvisor 4.9 - экспаты называют лучшей пиццей города.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f14', 'en', 'Cardi Pizzeria', 'Hai Chau, Bach Dang', 'Neapolitan pizza from a 400°C wood-fired oven on the riverside. Tripadvisor 4.9 - expats call it the best pizza in town.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f15', 'ru', 'RIONI Georgian', 'Ngũ Hành Sơn, Đỗ Bí', 'Первая грузинская в Дананге: хинкали 55 тыс. ₫, хачапури 240 тыс. ₫. Знакомый вкус «как дома» для русскоязычных.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f15', 'en', 'RIONI Georgian', 'Ngu Hanh Son, Do Bi', 'The first Georgian restaurant in Da Nang: khinkali 55k VND, khachapuri 240k VND. A taste of home for Russian speakers.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f16', 'ru', 'XLIII Coffee', 'Ngũ Hành Sơn, Ngô Thì Sỹ', 'Спешелти обжарка недалеко от пляжа Mỹ Khê (бывший 43 Factory). Напитки 60-120 тыс. ₫, премиальные пуроверы дороже. Открытие в 6:30, можно с ноутбуком.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f16', 'en', 'XLIII Coffee', 'Ngu Hanh Son, Ngo Thi Sy', 'Specialty roastery near My Khe beach (the former 43 Factory). Drinks 60-120k VND, premium pour-overs higher. Opens 6:30, laptop friendly.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f17', 'ru', 'Bánh Mì Cô Tiên', 'Hải Châu, Trần Phú', 'Банхми с высокой оценкой (Tripadvisor 4.8) в центре. Быстро, дёшево, с собой - классический уличный перекус.'),
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f17', 'en', 'Bánh Mì Cô Tiên', 'Hai Chau, Tran Phu', 'Highly rated banh mi (Tripadvisor 4.8) in the center. Fast, cheap, to go - the classic street snack.')
on conflict (place_id, language) do update
set
	name = excluded.name,
	area = excluded.area,
	summary = excluded.summary;

-- Reviews: intentionally none seeded. The mock had an empty reviews array and
-- we have no sourced, attributable review records; the food UI correctly
-- shows zero approved counts until real reviews are added.
-- Districts (housing slice) - seeded from the accepted frontend mock contract
-- Districts (housing slice): geometry from frontend mocks, text from locale files.
-- Sourced venue photos (mirror of migration 034; null renders a UI placeholder).
update public.places set image_url = 'https://upload.wikimedia.org/wikipedia/commons/d/df/Mi_Quang_1A_Danang.jpg' where slug = 'mi-quang-1a';
update public.places set image_url = 'https://mia.vn/media/uploads/blog-du-lich/thoa-man-voi-banh-xeo-ba-duong-ngon-nhat-da-nang-1636651211.jpg' where slug = 'banh-xeo-ba-duong';
update public.places set image_url = 'https://danangbest.com/upload_content/bun-cha-ca-da-nang-3.webp' where slug = 'bun-cha-ca-ba-lu';
update public.places set image_url = 'https://upload.wikimedia.org/wikipedia/commons/1/1d/Con_Market_at_sunset.jpg' where slug = 'cho-con';
update public.places set image_url = 'https://upload.wikimedia.org/wikipedia/commons/9/9b/Han_Market_Da_Nang.JPG' where slug = 'cho-han';
update public.places set image_url = 'https://upload.wikimedia.org/wikipedia/commons/d/dc/Highlands_Coffee_storefront_DN.JPG' where slug = 'highlands-beach';
update public.places set image_url = 'https://upload.wikimedia.org/wikipedia/commons/6/67/C%E1%BB%99ng_C%C3%A0_Ph%C3%AA_coffee_milk.jpg' where slug = 'cong-cafe';
update public.places set image_url = 'https://axwwgrkdco.cloudimg.io/v7/__gmpics3__/adc7acfaa0c04ac4ac201d3bcadc81e1.jpeg' where slug = 'bun-cha-ca-ba-hoa';
update public.places set image_url = 'https://cdn3.ivivu.com/2022/08/bun-mam-ba-dong-ivivu-3.jpg' where slug = 'bun-mam-ba-dong';
update public.places set image_url = 'https://mia.vn/media/uploads/blog-du-lich/mi-quang-ech-bep-trang-mon-ngon-ngo-cuong-khi-den-da-nang-1637316606.jpg' where slug = 'mi-quang-ech-bep-trang';
update public.places set image_url = 'https://vietnamlife.asia/wp-content/uploads/2024/09/Front-entrance-to-Indian-Restaurant-Ganesh-Da-Nang.jpg' where slug = 'ganesh-da-nang';
update public.places set image_url = 'https://www.pizzacardi.com/templates/yootheme/cache/a0/home-gallery-05-a0b66d50.jpeg' where slug = 'cardi-pizzeria';
update public.places set image_url = 'https://xliiicoffee.com/wp-content/uploads/2023/06/202306060712-43-factory-coffee-roaster-da-nang-vietnam-08.jpeg' where slug = 'xliii-coffee';
update public.places set image_url = 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEg1aQLnSUfqLxZpx7s_VmHJxM_p9mlNSDv093GKJUrDJ8d5koGnPIqVQWvdfnN-d-yv5zk2cPofgC1m5KF2vTnitAoWBtX_P8lKDcX2eTKt_yzFILaRdnS4xiYqHk0QsTqrKlRry1krNxqg50F037KsFle9nrMRH6RGgz4P21XFe06LaPl2nHug/s1640/09%20TWN_5807%20B%C3%A1nh%20M%C3%AC%20C%C3%B4%20Ti%C3%AAn%20@%20Da%20Nang%20in%20Vietnam.JPG' where slug = 'banh-mi-co-tien';
update public.places set image_url = 'https://hoiandaytrip.com/wp-content/uploads/2025/12/madam-khanh-1.jpg' where slug = 'banh-mi-madam-khanh';
update public.places set image_url = 'https://axwwgrkdco.cloudimg.io/v7/__gmpics3__/70695ae344e74b7ba42c132cca61ca84.jpeg?width=1000' where slug = 'be-man-seafood';
update public.places set image_url = 'https://hoiandaytrip.com/wp-content/uploads/2024/11/an-thuong-tourist-street-da-nang.jpg' where slug = 'an-thuong-street';
update public.places set image_url = 'https://axwwgrkdco.cloudimg.io/v7/__gmpics3__/8e802149bbea41adb30f5fb446eddb2f.jpeg?width=1000' where slug = 'mi-quang-sua-hong-van';
update public.places set image_url = 'https://prod-pics.guide.michelin.com/api/public/content/68cd514ddf784deca07fd6fbb910c825.jpeg?format=jpeg&w=1000&h=1000' where slug = 'com-ga-lan';
update public.places set image_url = 'https://ghiendanang.com/wp-content/uploads/2025/06/nhang-nuong-1.jpg' where slug = 'nhang-nuong';
update public.places set image_url = 'https://kalakalabeachclub.com/wp-content/uploads/2026/06/local-street-food-in-da-nang-7.jpg' where slug = 'be-loan';
update public.places set image_url = 'https://cdn.amebaowndme.com/madrid-prd/madrid-web/images/sites/55475/42a6424c88e80d47ab397b4beba5ca5e_dad62fbef639e5318e5aed87c84d48f0.jpg' where slug = 'burger-bros';
update public.places set image_url = 'https://ak-d.tripcdn.com/images/1mi1v224x99ckzi9c865E_R_600_400_R5_Q90.jpg?proc=source/trip' where slug = 'rioni-georgian';

insert into public.districts (id, city_slug, slug, sort_order, price_level, geometry)
values
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f01', 'da-nang', 'son-tra', 1, 'above', ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[108.235, 16.078], [108.245, 16.11], [108.26, 16.14], [108.3, 16.165], [108.33, 16.16], [108.315, 16.12], [108.28, 16.075], [108.255, 16.05], [108.235, 16.078]]]}')),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f02', 'da-nang', 'ngu-hanh-son', 2, 'average', ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[108.235, 16.045], [108.255, 16.05], [108.28, 16.07], [108.29, 16.045], [108.285, 16.01], [108.27, 15.995], [108.25, 16.005], [108.235, 16.02], [108.23, 16.035], [108.235, 16.045]]]}')),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f03', 'da-nang', 'hai-chau', 3, 'average', ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[108.185, 16.05], [108.215, 16.03], [108.235, 16.045], [108.23, 16.06], [108.22, 16.075], [108.19, 16.07], [108.185, 16.05]]]}')),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f04', 'da-nang', 'thanh-khe', 4, 'budget', ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[108.15, 16.065], [108.185, 16.06], [108.195, 16.08], [108.19, 16.105], [108.16, 16.115], [108.145, 16.09], [108.15, 16.065]]]}')),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f05', 'da-nang', 'lien-chieu', 5, 'budget', ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[108.105, 16.1], [108.145, 16.092], [108.158, 16.118], [108.135, 16.15], [108.11, 16.14], [108.105, 16.1]]]}')),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f06', 'da-nang', 'cam-le', 6, 'budget', ST_GeomFromGeoJSON('{"type": "Polygon", "coordinates": [[[108.18, 16.028], [108.215, 16.025], [108.232, 16.033], [108.235, 16.018], [108.22, 15.99], [108.195, 16.0], [108.18, 16.01], [108.18, 16.028]]]}'))
on conflict (city_slug, slug) do update
set
	sort_order = excluded.sort_order,
	price_level = excluded.price_level,
	geometry = excluded.geometry;

insert into public.district_localizations (district_id, language, name, area, rent_range, distance_to_beach, summary, best_for)
values
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f01', 'ru', 'Sơn Trà', 'Побережье Mỹ Khê и An Thượng', '7-15 млн ₫/мес', '5-10 мин пешком до моря', 'Пляж, кафе и спортзалы в шаге. Туристическое ядро: шумно в сезон, самые высокие цены.', '{beach,nightlife,expat}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f01', 'en', 'Sơn Trà', 'My Khe coast and An Thượng', '7-15M ₫/mo', '5-10 min walk to the sea', 'Beach, cafes, and gyms in walking distance. Tourist core: noisy in season, highest prices.', '{beach,nightlife,expat}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f02', 'ru', 'Ngũ Hành Sơn', 'Юго-восток: Bắc Mỹ An, Hòa Hải', '5-10 млн ₫/мес', '10-15 мин на байке до моря', 'Тише и дешевле побережья. Мраморные горы рядом, до моря на байке.', '{family,quiet}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f02', 'en', 'Ngũ Hành Sơn', 'Southeast: Bắc Mỹ An, Hòa Hải', '5-10M ₫/mo', '10-15 min by bike to the sea', 'Quieter and cheaper than the coast. Marble Mountains nearby, beach by bike.', '{family,quiet}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f03', 'ru', 'Hải Châu', 'Центр и набережная реки Хан', '5-8 млн ₫/мес', '15-20 мин на байке до моря', 'Даунтаун: рынки, банки, кафе для местных. Городская жизнь без моря за углом.', '{markets,transport}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f03', 'en', 'Hải Châu', 'Center and Han riverfront', '5-8M ₫/mo', '15-20 min by bike to the sea', 'Downtown: markets, banks, local cafes. City life without the sea next door.', '{markets,transport}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f04', 'ru', 'Thanh Khê', 'Запад от центра', '4-6 млн ₫/мес', '10-15 мин на байке до пляжа', 'Местная жизнь без туристов. Свой пляж - подальше от туристических толп.', '{budget,local}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f04', 'en', 'Thanh Khê', 'West of the center', '4-6M ₫/mo', '10-15 min by bike to the beach', 'Local life without tourists. Its own beach away from the crowds.', '{budget,local}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f05', 'ru', 'Liên Chiểu', 'Северо-запад, пляж Xuân Thiều', '4-7 млн ₫/мес', 'пляж рядом, до центра 20-30 мин', 'Тихо и дёшево, широкие пляжи без людей. Далеко от центра и кафе.', '{quiet,budget}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f05', 'en', 'Liên Chiểu', 'Northwest, Xuân Thiều beach', '4-7M ₫/mo', 'beach nearby, 20-30 min to the center', 'Quiet and cheap, wide empty beaches. Far from the center and cafes.', '{quiet,budget}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f06', 'ru', 'Cẩm Lệ', 'Юг, за центром', '4-6 млн ₫/мес', '20-25 мин на байке до моря', 'Новые дома и локальные цены. Для жизни с байком, не для отпуска у моря.', '{budget,family}'),
  ('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e8f06', 'en', 'Cẩm Lệ', 'South, behind the center', '4-6M ₫/mo', '20-25 min by bike to the sea', 'New buildings at local prices. For living with a bike, not a beach holiday.', '{budget,family}')
on conflict (district_id, language) do update
set
	name = excluded.name,
	area = excluded.area,
	rent_range = excluded.rent_range,
	distance_to_beach = excluded.distance_to_beach,
	summary = excluded.summary,
	best_for = excluded.best_for;

-- BEGIN dish dictionary seed (migration 037 mirror; generated)
-- Wikimedia Commons (46/50, hotlink-verified; heavy originals embedded as
-- 1280px thumbs). null photos render an honest UI placeholder. Entries ship
-- published but verified=false: curation flips that in Phase B. Mirrored
-- into seed.sql.

insert into public.dishes (id, slug, name_vi, photo_url, tags, verified, status)
values
	('d15ef00d-4a2b-4c9d-8e1f-000000000001', 'pho-bo', 'Phở bò', 'https://upload.wikimedia.org/wikipedia/commons/9/99/Ph%E1%BB%9F_b%C3%B2%2C_C%E1%BA%A7u_Gi%E1%BA%A5y%2C_H%C3%A0_N%E1%BB%99i.jpg', '{soup,noodle,beef}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000002', 'pho-ga', 'Phở gà', 'https://upload.wikimedia.org/wikipedia/commons/f/f3/Vietnamsk%C3%A1_ku%C5%99ec%C3%AD_pol%C3%A9vka_%E2%80%9Cph%E1%BB%9F_g%C3%A0%E2%80%9C_se_%C5%A1irok%C3%BDmi_r%C3%BD%C5%BEov%C3%BDmi_nudlemi_01.JPG', '{soup,noodle,chicken}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000003', 'banh-mi', 'Bánh mì', 'https://upload.wikimedia.org/wikipedia/commons/0/0c/B%C3%A1nh_m%C3%AC_th%E1%BB%8Bt_n%C6%B0%E1%BB%9Bng.png', '{street,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000004', 'banh-xeo', 'Bánh xèo', 'https://upload.wikimedia.org/wikipedia/commons/5/59/Banh_Xeo_with_fish_sauce_and_vegetables.jpg', '{street,pancake}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000005', 'banh-khoai', 'Bánh khoái', 'https://upload.wikimedia.org/wikipedia/commons/0/01/B%C3%A1nh_kho%C3%A1i.jpg', '{street,pancake}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000006', 'bun-cha-ca', 'Bún chả cá', 'https://upload.wikimedia.org/wikipedia/commons/3/32/B%C3%BAn_ch%E1%BA%A3_c%C3%A1%2C_th%C3%A1ng_8_n%C4%83m_2018.JPG', '{soup,noodle,fish}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000007', 'bun-cha', 'Bún chả', 'https://upload.wikimedia.org/wikipedia/commons/4/4d/B%C3%BAn_ch%E1%BA%A3_Vietnamese_food.jpg', '{noodle,pork,grill}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000008', 'bun-bo-hue', 'Bún bò Huế', 'https://upload.wikimedia.org/wikipedia/commons/0/04/B%C3%BAn_b%C3%B2_Hu%E1%BA%BF_-_Ch%E1%BB%A3_%C4%90%C3%B4ng_Ba_%282024%29_-_img_02.jpg', '{soup,noodle,spicy}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000009', 'mi-quang', 'Mỳ Quảng', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/M%C3%AC_Qu%E1%BA%A3ng%2C_Da_Nang%2C_Vietnam.jpg/1280px-M%C3%AC_Qu%E1%BA%A3ng%2C_Da_Nang%2C_Vietnam.jpg', '{noodle,pork}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000a', 'cao-lau', 'Cao lầu', 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Cao_l%E1%BA%A7u_H%E1%BB%99i_An_%282024%29.jpg', '{noodle,pork}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000b', 'com-ga', 'Cơm gà', 'https://upload.wikimedia.org/wikipedia/commons/8/89/C%C6%A1m_g%C3%A0_Tam_K%E1%BB%B3%2C_Qu%E1%BA%A3ng_Nam.JPG', '{rice,chicken}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000c', 'com-tam', 'Cơm tấm', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/C%C6%A1m_T%E1%BA%A5m%2C_Da_Nang%2C_Vietnam.jpg/1280px-C%C6%A1m_T%E1%BA%A5m%2C_Da_Nang%2C_Vietnam.jpg', '{rice,pork,grill}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000d', 'hu-tieu', 'Hủ tiếu', 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Hu_Tieu_Nam_Vang.jpg', '{soup,noodle}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000e', 'banh-canh-cha-ca', 'Bánh canh chả cá', null, '{soup,fish}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000f', 'banh-canh-tom', 'Bánh canh tôm', 'https://upload.wikimedia.org/wikipedia/commons/d/d5/M%C3%B3n_%C4%83n_T%E1%BA%BFt_2023_%28b%C3%A1nh_canh_t%C3%B4m_th%E1%BB%8Bt%29_%281%29.jpg', '{soup,shrimp}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000010', 'goi-cuon', 'Gỏi cuốn', 'https://upload.wikimedia.org/wikipedia/commons/1/1a/Homemade_spring_rolls_%287010969349%29.jpg', '{fresh,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000011', 'cha-gio', 'Chả giò', 'https://upload.wikimedia.org/wikipedia/commons/6/6b/Cha_gio.jpg', '{fried,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000012', 'nem-lui', 'Nem lụi', 'https://upload.wikimedia.org/wikipedia/commons/8/88/Nh%C3%A0_m%C3%ACnh_L%E1%BB%85_30th4n2023_%28ch%E1%BA%A1o_nem_l%E1%BB%A5i%29_%282%29.jpg', '{grill,street}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000013', 'banh-cuon', 'Bánh cuốn', 'https://upload.wikimedia.org/wikipedia/commons/b/b2/B%C3%A1nh_cu%E1%BB%91n_Thanh_Tr%C3%AC.jpg', '{fresh,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000014', 'banh-bao', 'Bánh bao', 'https://upload.wikimedia.org/wikipedia/commons/8/80/B%C3%A1nh_bao.jpg', '{snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000015', 'xoi', 'Xôi', 'https://upload.wikimedia.org/wikipedia/commons/f/f9/X%C3%B4i_x%C3%A9o.jpg', '{rice,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000016', 'chao-ga', 'Cháo gà', 'https://upload.wikimedia.org/wikipedia/commons/2/26/Ch%C3%A1o_g%C3%A0_x%C3%A9_phay_%28t%C3%B4_g%C3%A0_x%C3%A9_phay%29_%E1%BB%9F_P3_%C4%90%C3%B4ng_H%C3%A0_n%C4%83m_2018.jpg', '{soup,rice,chicken}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000017', 'lau-thai', 'Lẩu Thái', 'https://upload.wikimedia.org/wikipedia/commons/c/c6/MK_Suki_Siam_Square.jpg', '{hotpot,spicy,group}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000018', 'lau-ga', 'Lẩu gà', 'https://upload.wikimedia.org/wikipedia/commons/0/02/Newone_-_l%E1%BA%A9u_g%C3%A0%2C_s%C6%B0%E1%BB%9Dn_v%C3%A0_r%C6%B0%E1%BB%A3u_%C4%91inh_l%C4%83ng.jpg', '{hotpot,chicken,group}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000019', 'oc', 'Ốc', 'https://upload.wikimedia.org/wikipedia/commons/f/f5/%E1%BB%90c_x%C3%A0o_rau_mu%E1%BB%91ng_sn_2012_%281%29.JPG', '{seafood,snack,beer}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001a', 'tom-nuong', 'Tôm nướng', 'https://upload.wikimedia.org/wikipedia/commons/a/ab/T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%285%29.JPG', '{seafood,grill}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001b', 'ca-kho-to', 'Cá kho tộ', 'https://upload.wikimedia.org/wikipedia/commons/b/b4/C%C3%A1_kho_t%E1%BB%99.JPG', '{fish,rice}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001c', 'ga-xao-sa-ot', 'Gà xào sả ớt', 'https://upload.wikimedia.org/wikipedia/commons/d/d8/Lemongrass_Chicken_%287491346796%29.jpg', '{chicken,spicy}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001d', 'bo-luc-lac', 'Bò lúc lắc', 'https://upload.wikimedia.org/wikipedia/commons/7/78/Product_Shots_of_Food-Bo_Luc_Lac.jpg', '{beef}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001e', 'thit-nuong', 'Thịt nướng', null, '{grill,pork}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001f', 'banh-trang-tron', 'Bánh tráng trộn', 'https://upload.wikimedia.org/wikipedia/commons/6/63/Vietnamese_%22banh_trang_tron%22.JPG', '{street,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000020', 'goi', 'Gỏi', 'https://upload.wikimedia.org/wikipedia/commons/9/9f/G%E1%BB%8Fi_%C4%91u_%C4%91%E1%BB%A7_kh%C3%B4_b%C3%B2.jpg', '{fresh,salad}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000021', 'ca-phe-sua-da', 'Cà phê sữa đá', 'https://upload.wikimedia.org/wikipedia/commons/b/b7/Viet-coffee.jpg', '{coffee,drink}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000022', 'ca-phe-trung', 'Cà phê trứng', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng.jpg/1280px-C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng.jpg', '{coffee,drink}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000023', 'bac-xiu', 'Bạc xỉu', 'https://upload.wikimedia.org/wikipedia/commons/2/29/Ly_p%E1%BA%B7c_x%E1%BB%89u_s%E1%BB%AFa_%C4%91%C3%A1_%E1%BB%9F_Q1_ng18th8n2022.jpg', '{coffee,drink,sweet}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000024', 'tra-da', 'Trà đá', 'https://upload.wikimedia.org/wikipedia/commons/6/65/Qu%C3%A1n_m%C3%AC_qu%E1%BA%A3ng_Th%E1%BA%A3o_%E1%BB%9F_Q_T%C3%A2n_B%C3%ACnh_ng9th9n2022_%28ly_tr%C3%A0_%C4%91%C3%A1%29.jpg', '{drink,free}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000025', 'sinh-to', 'Sinh tố', 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Sinh_t%E1%BB%91_b%C6%A1.jpg', '{drink,fruit}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000026', 'nuoc-mia', 'Nước mía', 'https://upload.wikimedia.org/wikipedia/commons/6/63/Sugarcanejuice.jpg', '{drink}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000027', 'nuoc-chanh', 'Nước chanh', 'https://upload.wikimedia.org/wikipedia/commons/2/2b/Limeade.jpg', '{drink}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000028', 'bia', 'Bia', 'https://upload.wikimedia.org/wikipedia/commons/0/0a/Bia_hoi.jpg', '{drink,beer}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000029', 'banh-flan', 'Bánh flan', 'https://upload.wikimedia.org/wikipedia/commons/4/43/Homemade_Flan.jpg', '{dessert,sweet}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002a', 'che', 'Chè', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Ch%C3%A8_B%E1%BA%AFp.jpg/1280px-Ch%C3%A8_B%E1%BA%AFp.jpg', '{dessert,sweet}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002b', 'kem', 'Kem', 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Kem_sua_dua_Trang_Tien.jpg', '{dessert}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002c', 'banh-uot', 'Bánh ướt', 'https://upload.wikimedia.org/wikipedia/commons/3/3f/B%C3%A1nh_%C6%B0%E1%BB%9Bt.jpg', '{fresh,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002d', 'mi-xao', 'Mỳ xào', null, '{noodle,fried}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002e', 'com-rang', 'Cơm rang', 'https://upload.wikimedia.org/wikipedia/commons/e/e7/C%C6%A1m_rang.JPG', '{rice,fried}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002f', 'canh-chua', 'Canh chua', 'https://upload.wikimedia.org/wikipedia/commons/a/a0/Canhchua2.jpg', '{soup,sour,fish}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000030', 'tra-chanh', 'Trà chanh', null, '{drink,cheap}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000031', 'nuoc-ep', 'Nước ép', 'https://upload.wikimedia.org/wikipedia/commons/f/fd/Orange_juice_1.jpg', '{drink,fruit}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000032', 'cha-ca', 'Chả cá', 'https://upload.wikimedia.org/wikipedia/commons/2/20/Ch%E1%BA%A3_c%C3%A1.jpg', '{fish,grill}', false, 'published')

on conflict (slug) do update
set
	name_vi = excluded.name_vi,
	photo_url = excluded.photo_url,
	tags = excluded.tags,
	status = excluded.status;

insert into public.dish_localizations (dish_id, language, name, summary)
values
	('d15ef00d-4a2b-4c9d-8e1f-000000000001', 'ru', 'Фо бо', 'Рисовая лапша в говяжьем бульоне с говядиной и зеленью. Национальное блюдо - едят в любое время дня.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000001', 'en', 'Pho bo', 'Rice noodles in beef broth with beef slices and herbs. The national dish - eaten any time of day.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000002', 'ru', 'Фо га', 'Тот же фо, но с курицей - бульон светлее и мягче. Хороший первый шаг во вьетнамские супы.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000002', 'en', 'Pho ga', 'Pho with chicken - a lighter, gentler broth. A good first step into Vietnamese soups.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000003', 'ru', 'Банх ми', 'Вьетнамский багет с мясом, паштетом и маринованными овощами. Хрустящий, дешёвый, удобно с собой.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000003', 'en', 'Banh mi', 'Crispy Vietnamese baguette with meat, pate, and pickles. Cheap and perfect on the go.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000004', 'ru', 'Баншо', 'Хрустящий рисовый блинчик с креветкой или свининой - ешь руками, заворачивая в зелень.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000004', 'en', 'Banh xeo', 'Crispy turmeric rice pancake with shrimp or pork - wrap it in herbs and eat by hand.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000005', 'ru', 'Бань хуай', 'Хуэская версия баншо: толще, с яйцом и свининой.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000005', 'en', 'Banh khoai', 'Hue-style thicker banh xeo with egg and pork.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000006', 'ru', 'Бун ча ка', 'Лапша с рыбными фрикадельками - фирменный завтрак Дананга.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000006', 'en', 'Bun cha ca', 'Noodle soup with fish cakes - Da Nang signature breakfast.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000007', 'ru', 'Бун ча', 'Лапша с жареными свиными котлетами и травами - ханойская классика.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000007', 'en', 'Bun cha', 'Grilled pork patties over rice noodles with herbs - a Hanoi classic.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000008', 'ru', 'Бун бо хуэ', 'Острый суп из Хюэ с говядиной и колбасками. Для любителей поострее.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000008', 'en', 'Bun bo Hue', 'Spicy Hue-style beef noodle soup. For those who like heat.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000009', 'ru', 'Микуанг', 'Жёлтая рисовая лапша с минимальным количеством бульона - фирменное блюдо Дананга.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000009', 'en', 'Mi Quang', 'Turmeric rice noodles with just a splash of broth - the signature dish of Da Nang.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000a', 'ru', 'Каолау', 'Лапша Хойана со свининой и хрустящими сухариками.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000a', 'en', 'Cao lau', 'Hoi An noodles with pork and crispy croutons.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000b', 'ru', 'Ком га', 'Рис с курицей - просто, сытно, беспроигрышный выбор.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000b', 'en', 'Com ga', 'Chicken rice - simple, filling, always a safe choice.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000c', 'ru', 'Ком там', 'Дроблёный рис со свининой на гриле и яйцом.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000c', 'en', 'Com tam', 'Broken rice with a grilled pork chop and egg.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000d', 'ru', 'Ху тиу', 'Суп с прозрачной лапшой - лёгкая южная классика.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000d', 'en', 'Hu tieu', 'Clear noodle soup - a light southern classic.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000e', 'ru', 'Бань кань ча ка', 'Густая рисовая лапша с рыбными котлетами.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000e', 'en', 'Banh canh cha ca', 'Thick rice noodle soup with fish cakes.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000f', 'ru', 'Бань кань том', 'Та же густая лапша, но с креветками.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000f', 'en', 'Banh canh tom', 'The same thick rice noodles with shrimp.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000010', 'ru', 'Гой куон', 'Свежие спринг-роллы с креветкой и травами - лёгкая закуска.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000010', 'en', 'Goi cuon', 'Fresh spring rolls with shrimp and herbs. Light and healthy.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000011', 'ru', 'Ча зё', 'Жареные спринг-роллы - хрустящая классика уличной еды.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000011', 'en', 'Cha gio', 'Crispy fried spring rolls - the crunchy street classic.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000012', 'ru', 'Нем луй', 'Свининые шашлычки на лемонграссе - заворачивай в рисовую бумагу с зеленью.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000012', 'en', 'Nem lui', 'Lemongrass pork skewers - wrap them in rice paper with herbs.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000013', 'ru', 'Бань куон', 'Тонкие паровые рисовые блинчики с фаршем - нежный завтрак.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000013', 'en', 'Banh cuon', 'Delicate steamed rice rolls with minced pork.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000014', 'ru', 'Бань бао', 'Паровой пирожок с фаршем и яйцом - быстрый перекус.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000014', 'en', 'Banh bao', 'Steamed bun with pork and egg - a quick street snack.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000015', 'ru', 'Ксо', 'Клейкий рис с начинками - завтрак на бегу.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000015', 'en', 'Xoi', 'Sticky rice with toppings - breakfast on the go.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000016', 'ru', 'Чао га', 'Рисовая каша с курицей - комфортная еда.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000016', 'en', 'Chao ga', 'Chicken rice porridge - comfort food.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000017', 'ru', 'Лау тай', 'Тайский хотпот на компанию - варишь сам за столом.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000017', 'en', 'Lau Thai', 'Thai-style hotpot for a group - you cook it at the table.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000018', 'ru', 'Лау га', 'Куриный хотпот - мягче и дешевле тайского.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000018', 'en', 'Lau ga', 'Chicken hotpot - milder and cheaper than the Thai one.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000019', 'ru', 'Улитки', 'Улитки во всех видах - любимая пивная закуска у местных.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000019', 'en', 'Snails', 'Snails every way - the local beer snack.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001a', 'ru', 'Креветки на гриле', 'Креветки на углях - обычно продают на вес.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001a', 'en', 'Grilled shrimp', 'Charcoal-grilled prawns - usually sold by weight.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001b', 'ru', 'Ка хо то', 'Карамелизированная рыба в глиняном горшочке. Бери с рисом.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001b', 'en', 'Ca kho to', 'Caramelized fish in a clay pot. Order rice with it.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001c', 'ru', 'Курица с лемонграссом', 'Курица, обжаренная с лемонграссом и чили.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001c', 'en', 'Lemongrass chicken', 'Chicken stir-fried with lemongrass and chili.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001d', 'ru', 'Бо люк лак', 'Кубики говядины с луком, «трясёная говядина».'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001d', 'en', 'Shaking beef', 'Wok-tossed beef cubes with onion.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001e', 'ru', 'Свинина на гриле', 'Свинина на углях - основа многих блюд и роллов.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001e', 'en', 'Grilled pork', 'Charcoal-grilled pork - the base of many dishes and rolls.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001f', 'ru', 'Салат из рисовой бумаги', 'Измельчённая рисовая бумага с приправами - уличный фастфуд молодёжи.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001f', 'en', 'Rice paper salad', 'Shredded rice paper salad - street food for the young.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000020', 'ru', 'Гой (салат)', 'Вьетнамский салат: папайя или морковь, арахис, креветки.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000020', 'en', 'Vietnamese salad', 'Vietnamese salad: green papaya or carrot, peanuts, shrimp.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000021', 'ru', 'Кофе со сгущёнкой и льдом', 'Фильтр-кофе + сгущёнка + лёд. Крепко и сладко.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000021', 'en', 'Iced milk coffee', 'Filter coffee with condensed milk over ice. Strong and sweet.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000022', 'ru', 'Яичный кофе', 'Кофе со взбитой яично-сгущённой пеной - ханойский десерт.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000022', 'en', 'Egg coffee', 'Coffee with whipped egg-yolk custard foam - a Hanoi dessert.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000023', 'ru', 'Бак шиу', 'Почти молоко с каплей кофе - для тех, кто не любит горечь.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000023', 'en', 'Bac xiu', 'Mostly milk with a splash of coffee - for the non-bitter crowd.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000024', 'ru', 'Холодный чай', 'Бесплатный ледяной чай на каждом столе уличных заведений.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000024', 'en', 'Iced tea', 'The free iced tea on every street-food table.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000025', 'ru', 'Смузи', 'Фруктовый смузи, часто с йогуртом.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000025', 'en', 'Smoothie', 'Fruit smoothie, often with yogurt.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000026', 'ru', 'Тростниковый сок', 'Свежевыжатый сок сахарного тростника.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000026', 'en', 'Sugarcane juice', 'Fresh-pressed sugarcane juice.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000027', 'ru', 'Лаймовый лимонад', 'Сок лайма с сахаром и льдом.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000027', 'en', 'Limeade', 'Lime juice with sugar and ice.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000028', 'ru', 'Пиво', 'Местное разливное («bia hơi») или бутылочное.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000028', 'en', 'Beer', 'Local draft (bia hơi) or bottled beer.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000029', 'ru', 'Бан флан', 'Вьетнамский крем-карамель.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000029', 'en', 'Flan', 'Vietnamese creme caramel.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002a', 'ru', 'Че', 'Сладкий десерт из бобов, желе и кокосового молока.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002a', 'en', 'Che', 'Sweet dessert soup with beans, jelly, and coconut milk.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002b', 'ru', 'Мороженое', 'Мороженое или фруктовый лёд.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002b', 'en', 'Ice cream', 'Ice cream or fruit popsicles.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002c', 'ru', 'Бань уот', 'Мягкие паровые рисовые листы с начинкой.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002c', 'en', 'Wet rice sheets', 'Soft steamed rice sheets with filling.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002d', 'ru', 'Жареная лапша', 'Лапша, обжаренная с мясом или морепродуктами.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002d', 'en', 'Fried noodles', 'Stir-fried noodles with meat or seafood.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002e', 'ru', 'Жареный рис', 'Жареный рис с добавками (thập cẩm - ассорти).'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002e', 'en', 'Fried rice', 'Fried rice with mix-ins (thap cam = mixed).'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002f', 'ru', 'Кань чуа', 'Кислый суп с рыбой и ананасом - южная классика.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002f', 'en', 'Sour soup', 'Tamarind sour soup with fish and pineapple - a southern classic.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000030', 'ru', 'Лимонный чай', 'Лайм + зелёный чай + лёд - любимый напиток молодёжи.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000030', 'en', 'Lemon tea', 'Lime plus green tea plus ice - the youth favorite.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000031', 'ru', 'Свежевыжатый сок', 'Соки из свежих фруктов: манго, арбуз, ананас.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000031', 'en', 'Fresh juice', 'Fresh-pressed juices: mango, watermelon, pineapple.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000032', 'ru', 'Ча ка', 'Рыба, обжаренная с укропом и куркумой.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000032', 'en', 'Turmeric fish', 'Fish sauteed with dill and turmeric.')

on conflict (dish_id, language) do update
set
	name = excluded.name,
	summary = excluded.summary;

-- END dish dictionary seed

-- BEGIN dish dictionary seed (migration 037 mirror; generated)
-- Wikimedia Commons (46/50, hotlink-verified; heavy originals embedded as
-- 1280px thumbs). null photos render an honest UI placeholder. Entries ship
-- published but verified=false: curation flips that in Phase B. Mirrored
-- into seed.sql.

insert into public.dishes (id, slug, name_vi, photo_url, tags, verified, status)
values
	('d15ef00d-4a2b-4c9d-8e1f-000000000001', 'pho-bo', 'Phở bò', 'https://upload.wikimedia.org/wikipedia/commons/9/99/Ph%E1%BB%9F_b%C3%B2%2C_C%E1%BA%A7u_Gi%E1%BA%A5y%2C_H%C3%A0_N%E1%BB%99i.jpg', '{soup,noodle,beef}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000002', 'pho-ga', 'Phở gà', 'https://upload.wikimedia.org/wikipedia/commons/f/f3/Vietnamsk%C3%A1_ku%C5%99ec%C3%AD_pol%C3%A9vka_%E2%80%9Cph%E1%BB%9F_g%C3%A0%E2%80%9C_se_%C5%A1irok%C3%BDmi_r%C3%BD%C5%BEov%C3%BDmi_nudlemi_01.JPG', '{soup,noodle,chicken}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000003', 'banh-mi', 'Bánh mì', 'https://upload.wikimedia.org/wikipedia/commons/0/0c/B%C3%A1nh_m%C3%AC_th%E1%BB%8Bt_n%C6%B0%E1%BB%9Bng.png', '{street,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000004', 'banh-xeo', 'Bánh xèo', 'https://upload.wikimedia.org/wikipedia/commons/5/59/Banh_Xeo_with_fish_sauce_and_vegetables.jpg', '{street,pancake}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000005', 'banh-khoai', 'Bánh khoái', 'https://upload.wikimedia.org/wikipedia/commons/0/01/B%C3%A1nh_kho%C3%A1i.jpg', '{street,pancake}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000006', 'bun-cha-ca', 'Bún chả cá', 'https://upload.wikimedia.org/wikipedia/commons/3/32/B%C3%BAn_ch%E1%BA%A3_c%C3%A1%2C_th%C3%A1ng_8_n%C4%83m_2018.JPG', '{soup,noodle,fish}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000007', 'bun-cha', 'Bún chả', 'https://upload.wikimedia.org/wikipedia/commons/4/4d/B%C3%BAn_ch%E1%BA%A3_Vietnamese_food.jpg', '{noodle,pork,grill}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000008', 'bun-bo-hue', 'Bún bò Huế', 'https://upload.wikimedia.org/wikipedia/commons/0/04/B%C3%BAn_b%C3%B2_Hu%E1%BA%BF_-_Ch%E1%BB%A3_%C4%90%C3%B4ng_Ba_%282024%29_-_img_02.jpg', '{soup,noodle,spicy}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000009', 'mi-quang', 'Mỳ Quảng', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/M%C3%AC_Qu%E1%BA%A3ng%2C_Da_Nang%2C_Vietnam.jpg/1280px-M%C3%AC_Qu%E1%BA%A3ng%2C_Da_Nang%2C_Vietnam.jpg', '{noodle,pork}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000a', 'cao-lau', 'Cao lầu', 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Cao_l%E1%BA%A7u_H%E1%BB%99i_An_%282024%29.jpg', '{noodle,pork}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000b', 'com-ga', 'Cơm gà', 'https://upload.wikimedia.org/wikipedia/commons/8/89/C%C6%A1m_g%C3%A0_Tam_K%E1%BB%B3%2C_Qu%E1%BA%A3ng_Nam.JPG', '{rice,chicken}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000c', 'com-tam', 'Cơm tấm', 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/C%C6%A1m_T%E1%BA%A5m%2C_Da_Nang%2C_Vietnam.jpg/1280px-C%C6%A1m_T%E1%BA%A5m%2C_Da_Nang%2C_Vietnam.jpg', '{rice,pork,grill}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000d', 'hu-tieu', 'Hủ tiếu', 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Hu_Tieu_Nam_Vang.jpg', '{soup,noodle}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000e', 'banh-canh-cha-ca', 'Bánh canh chả cá', 'https://upload.wikimedia.org/wikipedia/commons/c/c4/Banh-Canh-Noodle-Soup.jpg', '{soup,fish}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000f', 'banh-canh-tom', 'Bánh canh tôm', 'https://upload.wikimedia.org/wikipedia/commons/d/d5/M%C3%B3n_%C4%83n_T%E1%BA%BFt_2023_%28b%C3%A1nh_canh_t%C3%B4m_th%E1%BB%8Bt%29_%281%29.jpg', '{soup,shrimp}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000010', 'goi-cuon', 'Gỏi cuốn', 'https://upload.wikimedia.org/wikipedia/commons/1/1a/Homemade_spring_rolls_%287010969349%29.jpg', '{fresh,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000011', 'cha-gio', 'Chả giò', 'https://upload.wikimedia.org/wikipedia/commons/6/6b/Cha_gio.jpg', '{fried,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000012', 'nem-lui', 'Nem lụi', 'https://upload.wikimedia.org/wikipedia/commons/8/88/Nh%C3%A0_m%C3%ACnh_L%E1%BB%85_30th4n2023_%28ch%E1%BA%A1o_nem_l%E1%BB%A5i%29_%282%29.jpg', '{grill,street}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000013', 'banh-cuon', 'Bánh cuốn', 'https://upload.wikimedia.org/wikipedia/commons/b/b2/B%C3%A1nh_cu%E1%BB%91n_Thanh_Tr%C3%AC.jpg', '{fresh,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000014', 'banh-bao', 'Bánh bao', 'https://upload.wikimedia.org/wikipedia/commons/8/80/B%C3%A1nh_bao.jpg', '{snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000015', 'xoi', 'Xôi', 'https://upload.wikimedia.org/wikipedia/commons/f/f9/X%C3%B4i_x%C3%A9o.jpg', '{rice,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000016', 'chao-ga', 'Cháo gà', 'https://upload.wikimedia.org/wikipedia/commons/2/26/Ch%C3%A1o_g%C3%A0_x%C3%A9_phay_%28t%C3%B4_g%C3%A0_x%C3%A9_phay%29_%E1%BB%9F_P3_%C4%90%C3%B4ng_H%C3%A0_n%C4%83m_2018.jpg', '{soup,rice,chicken}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000017', 'lau-thai', 'Lẩu Thái', 'https://upload.wikimedia.org/wikipedia/commons/c/c6/MK_Suki_Siam_Square.jpg', '{hotpot,spicy,group}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000018', 'lau-ga', 'Lẩu gà', 'https://upload.wikimedia.org/wikipedia/commons/0/02/Newone_-_l%E1%BA%A9u_g%C3%A0%2C_s%C6%B0%E1%BB%9Dn_v%C3%A0_r%C6%B0%E1%BB%A3u_%C4%91inh_l%C4%83ng.jpg', '{hotpot,chicken,group}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000019', 'oc', 'Ốc', 'https://upload.wikimedia.org/wikipedia/commons/f/f5/%E1%BB%90c_x%C3%A0o_rau_mu%E1%BB%91ng_sn_2012_%281%29.JPG', '{seafood,snack,beer}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001a', 'tom-nuong', 'Tôm nướng', 'https://upload.wikimedia.org/wikipedia/commons/a/ab/T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%285%29.JPG', '{seafood,grill}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001b', 'ca-kho-to', 'Cá kho tộ', 'https://upload.wikimedia.org/wikipedia/commons/b/b4/C%C3%A1_kho_t%E1%BB%99.JPG', '{fish,rice}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001c', 'ga-xao-sa-ot', 'Gà xào sả ớt', 'https://upload.wikimedia.org/wikipedia/commons/d/d8/Lemongrass_Chicken_%287491346796%29.jpg', '{chicken,spicy}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001d', 'bo-luc-lac', 'Bò lúc lắc', 'https://upload.wikimedia.org/wikipedia/commons/7/78/Product_Shots_of_Food-Bo_Luc_Lac.jpg', '{beef}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001e', 'thit-nuong', 'Thịt nướng', 'https://upload.wikimedia.org/wikipedia/commons/4/47/Bun_thit_nuong.jpg', '{grill,pork}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001f', 'banh-trang-tron', 'Bánh tráng trộn', 'https://upload.wikimedia.org/wikipedia/commons/6/63/Vietnamese_%22banh_trang_tron%22.JPG', '{street,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000020', 'goi', 'Gỏi', 'https://upload.wikimedia.org/wikipedia/commons/9/9f/G%E1%BB%8Fi_%C4%91u_%C4%91%E1%BB%A7_kh%C3%B4_b%C3%B2.jpg', '{fresh,salad}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000021', 'ca-phe-sua-da', 'Cà phê sữa đá', 'https://upload.wikimedia.org/wikipedia/commons/b/b7/Viet-coffee.jpg', '{coffee,drink}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000022', 'ca-phe-trung', 'Cà phê trứng', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng.jpg/1280px-C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng.jpg', '{coffee,drink}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000023', 'bac-xiu', 'Bạc xỉu', 'https://upload.wikimedia.org/wikipedia/commons/2/29/Ly_p%E1%BA%B7c_x%E1%BB%89u_s%E1%BB%AFa_%C4%91%C3%A1_%E1%BB%9F_Q1_ng18th8n2022.jpg', '{coffee,drink,sweet}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000024', 'tra-da', 'Trà đá', 'https://upload.wikimedia.org/wikipedia/commons/6/65/Qu%C3%A1n_m%C3%AC_qu%E1%BA%A3ng_Th%E1%BA%A3o_%E1%BB%9F_Q_T%C3%A2n_B%C3%ACnh_ng9th9n2022_%28ly_tr%C3%A0_%C4%91%C3%A1%29.jpg', '{drink,free}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000025', 'sinh-to', 'Sinh tố', 'https://upload.wikimedia.org/wikipedia/commons/a/a5/Sinh_t%E1%BB%91_b%C6%A1.jpg', '{drink,fruit}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000026', 'nuoc-mia', 'Nước mía', 'https://upload.wikimedia.org/wikipedia/commons/6/63/Sugarcanejuice.jpg', '{drink}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000027', 'nuoc-chanh', 'Nước chanh', 'https://upload.wikimedia.org/wikipedia/commons/2/2b/Limeade.jpg', '{drink}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000028', 'bia', 'Bia', 'https://upload.wikimedia.org/wikipedia/commons/0/0a/Bia_hoi.jpg', '{drink,beer}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000029', 'banh-flan', 'Bánh flan', 'https://upload.wikimedia.org/wikipedia/commons/4/43/Homemade_Flan.jpg', '{dessert,sweet}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002a', 'che', 'Chè', 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Ch%C3%A8_B%E1%BA%AFp.jpg/1280px-Ch%C3%A8_B%E1%BA%AFp.jpg', '{dessert,sweet}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002b', 'kem', 'Kem', 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Kem_sua_dua_Trang_Tien.jpg', '{dessert}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002c', 'banh-uot', 'Bánh ướt', 'https://upload.wikimedia.org/wikipedia/commons/3/3f/B%C3%A1nh_%C6%B0%E1%BB%9Bt.jpg', '{fresh,snack}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002d', 'mi-xao', 'Mỳ xào', 'https://upload.wikimedia.org/wikipedia/commons/e/ee/M%C3%AC_x%C3%A0o_tr%E1%BB%A9ng_%E1%BB%9F_B%C3%ACnh_T%C3%A2n_ng%C3%A0y_29_th%C3%A1ng_3_n%C4%83m_2020_%281%29.jpg', '{noodle,fried}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002e', 'com-rang', 'Cơm rang', 'https://upload.wikimedia.org/wikipedia/commons/e/e7/C%C6%A1m_rang.JPG', '{rice,fried}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002f', 'canh-chua', 'Canh chua', 'https://upload.wikimedia.org/wikipedia/commons/a/a0/Canhchua2.jpg', '{soup,sour,fish}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000030', 'tra-chanh', 'Trà chanh', 'https://upload.wikimedia.org/wikipedia/commons/8/81/Lemon_Iced_Tea_1.JPG', '{drink,cheap}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000031', 'nuoc-ep', 'Nước ép', 'https://upload.wikimedia.org/wikipedia/commons/f/fd/Orange_juice_1.jpg', '{drink,fruit}', false, 'published'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000032', 'cha-ca', 'Chả cá', 'https://upload.wikimedia.org/wikipedia/commons/2/20/Ch%E1%BA%A3_c%C3%A1.jpg', '{fish,grill}', false, 'published')

on conflict (slug) do update
set
	name_vi = excluded.name_vi,
	photo_url = excluded.photo_url,
	tags = excluded.tags,
	status = excluded.status;

insert into public.dish_localizations (dish_id, language, name, summary)
values
	('d15ef00d-4a2b-4c9d-8e1f-000000000001', 'ru', 'Фо бо', 'Рисовая лапша в говяжьем бульоне с говядиной и зеленью. Национальное блюдо - едят в любое время дня.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000001', 'en', 'Pho bo', 'Rice noodles in beef broth with beef slices and herbs. The national dish - eaten any time of day.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000002', 'ru', 'Фо га', 'Тот же фо, но с курицей - бульон светлее и мягче. Хороший первый шаг во вьетнамские супы.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000002', 'en', 'Pho ga', 'Pho with chicken - a lighter, gentler broth. A good first step into Vietnamese soups.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000003', 'ru', 'Банх ми', 'Вьетнамский багет с мясом, паштетом и маринованными овощами. Хрустящий, дешёвый, удобно с собой.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000003', 'en', 'Banh mi', 'Crispy Vietnamese baguette with meat, pate, and pickles. Cheap and perfect on the go.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000004', 'ru', 'Баншо', 'Хрустящий рисовый блинчик с креветкой или свининой - ешь руками, заворачивая в зелень.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000004', 'en', 'Banh xeo', 'Crispy turmeric rice pancake with shrimp or pork - wrap it in herbs and eat by hand.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000005', 'ru', 'Бань хуай', 'Хуэская версия баншо: толще, с яйцом и свининой.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000005', 'en', 'Banh khoai', 'Hue-style thicker banh xeo with egg and pork.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000006', 'ru', 'Бун ча ка', 'Лапша с рыбными фрикадельками - фирменный завтрак Дананга.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000006', 'en', 'Bun cha ca', 'Noodle soup with fish cakes - Da Nang signature breakfast.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000007', 'ru', 'Бун ча', 'Лапша с жареными свиными котлетами и травами - ханойская классика.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000007', 'en', 'Bun cha', 'Grilled pork patties over rice noodles with herbs - a Hanoi classic.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000008', 'ru', 'Бун бо хуэ', 'Острый суп из Хюэ с говядиной и колбасками. Для любителей поострее.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000008', 'en', 'Bun bo Hue', 'Spicy Hue-style beef noodle soup. For those who like heat.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000009', 'ru', 'Микуанг', 'Жёлтая рисовая лапша с минимальным количеством бульона - фирменное блюдо Дананга.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000009', 'en', 'Mi Quang', 'Turmeric rice noodles with just a splash of broth - the signature dish of Da Nang.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000a', 'ru', 'Каолау', 'Лапша Хойана со свининой и хрустящими сухариками.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000a', 'en', 'Cao lau', 'Hoi An noodles with pork and crispy croutons.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000b', 'ru', 'Ком га', 'Рис с курицей - просто, сытно, беспроигрышный выбор.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000b', 'en', 'Com ga', 'Chicken rice - simple, filling, always a safe choice.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000c', 'ru', 'Ком там', 'Дроблёный рис со свининой на гриле и яйцом.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000c', 'en', 'Com tam', 'Broken rice with a grilled pork chop and egg.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000d', 'ru', 'Ху тиу', 'Суп с прозрачной лапшой - лёгкая южная классика.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000d', 'en', 'Hu tieu', 'Clear noodle soup - a light southern classic.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000e', 'ru', 'Бань кань ча ка', 'Густая рисовая лапша с рыбными котлетами.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000e', 'en', 'Banh canh cha ca', 'Thick rice noodle soup with fish cakes.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000f', 'ru', 'Бань кань том', 'Та же густая лапша, но с креветками.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000000f', 'en', 'Banh canh tom', 'The same thick rice noodles with shrimp.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000010', 'ru', 'Гой куон', 'Свежие спринг-роллы с креветкой и травами - лёгкая закуска.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000010', 'en', 'Goi cuon', 'Fresh spring rolls with shrimp and herbs. Light and healthy.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000011', 'ru', 'Ча зё', 'Жареные спринг-роллы - хрустящая классика уличной еды.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000011', 'en', 'Cha gio', 'Crispy fried spring rolls - the crunchy street classic.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000012', 'ru', 'Нем луй', 'Свининые шашлычки на лемонграссе - заворачивай в рисовую бумагу с зеленью.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000012', 'en', 'Nem lui', 'Lemongrass pork skewers - wrap them in rice paper with herbs.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000013', 'ru', 'Бань куон', 'Тонкие паровые рисовые блинчики с фаршем - нежный завтрак.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000013', 'en', 'Banh cuon', 'Delicate steamed rice rolls with minced pork.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000014', 'ru', 'Бань бао', 'Паровой пирожок с фаршем и яйцом - быстрый перекус.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000014', 'en', 'Banh bao', 'Steamed bun with pork and egg - a quick street snack.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000015', 'ru', 'Ксо', 'Клейкий рис с начинками - завтрак на бегу.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000015', 'en', 'Xoi', 'Sticky rice with toppings - breakfast on the go.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000016', 'ru', 'Чао га', 'Рисовая каша с курицей - комфортная еда.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000016', 'en', 'Chao ga', 'Chicken rice porridge - comfort food.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000017', 'ru', 'Лау тай', 'Тайский хотпот на компанию - варишь сам за столом.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000017', 'en', 'Lau Thai', 'Thai-style hotpot for a group - you cook it at the table.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000018', 'ru', 'Лау га', 'Куриный хотпот - мягче и дешевле тайского.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000018', 'en', 'Lau ga', 'Chicken hotpot - milder and cheaper than the Thai one.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000019', 'ru', 'Улитки', 'Улитки во всех видах - любимая пивная закуска у местных.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000019', 'en', 'Snails', 'Snails every way - the local beer snack.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001a', 'ru', 'Креветки на гриле', 'Креветки на углях - обычно продают на вес.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001a', 'en', 'Grilled shrimp', 'Charcoal-grilled prawns - usually sold by weight.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001b', 'ru', 'Ка хо то', 'Карамелизированная рыба в глиняном горшочке. Бери с рисом.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001b', 'en', 'Ca kho to', 'Caramelized fish in a clay pot. Order rice with it.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001c', 'ru', 'Курица с лемонграссом', 'Курица, обжаренная с лемонграссом и чили.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001c', 'en', 'Lemongrass chicken', 'Chicken stir-fried with lemongrass and chili.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001d', 'ru', 'Бо люк лак', 'Кубики говядины с луком, «трясёная говядина».'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001d', 'en', 'Shaking beef', 'Wok-tossed beef cubes with onion.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001e', 'ru', 'Свинина на гриле', 'Свинина на углях - основа многих блюд и роллов.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001e', 'en', 'Grilled pork', 'Charcoal-grilled pork - the base of many dishes and rolls.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001f', 'ru', 'Салат из рисовой бумаги', 'Измельчённая рисовая бумага с приправами - уличный фастфуд молодёжи.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000001f', 'en', 'Rice paper salad', 'Shredded rice paper salad - street food for the young.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000020', 'ru', 'Гой (салат)', 'Вьетнамский салат: папайя или морковь, арахис, креветки.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000020', 'en', 'Vietnamese salad', 'Vietnamese salad: green papaya or carrot, peanuts, shrimp.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000021', 'ru', 'Кофе со сгущёнкой и льдом', 'Фильтр-кофе + сгущёнка + лёд. Крепко и сладко.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000021', 'en', 'Iced milk coffee', 'Filter coffee with condensed milk over ice. Strong and sweet.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000022', 'ru', 'Яичный кофе', 'Кофе со взбитой яично-сгущённой пеной - ханойский десерт.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000022', 'en', 'Egg coffee', 'Coffee with whipped egg-yolk custard foam - a Hanoi dessert.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000023', 'ru', 'Бак шиу', 'Почти молоко с каплей кофе - для тех, кто не любит горечь.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000023', 'en', 'Bac xiu', 'Mostly milk with a splash of coffee - for the non-bitter crowd.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000024', 'ru', 'Холодный чай', 'Бесплатный ледяной чай на каждом столе уличных заведений.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000024', 'en', 'Iced tea', 'The free iced tea on every street-food table.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000025', 'ru', 'Смузи', 'Фруктовый смузи, часто с йогуртом.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000025', 'en', 'Smoothie', 'Fruit smoothie, often with yogurt.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000026', 'ru', 'Тростниковый сок', 'Свежевыжатый сок сахарного тростника.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000026', 'en', 'Sugarcane juice', 'Fresh-pressed sugarcane juice.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000027', 'ru', 'Лаймовый лимонад', 'Сок лайма с сахаром и льдом.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000027', 'en', 'Limeade', 'Lime juice with sugar and ice.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000028', 'ru', 'Пиво', 'Местное разливное («bia hơi») или бутылочное.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000028', 'en', 'Beer', 'Local draft (bia hơi) or bottled beer.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000029', 'ru', 'Бан флан', 'Вьетнамский крем-карамель.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000029', 'en', 'Flan', 'Vietnamese creme caramel.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002a', 'ru', 'Че', 'Сладкий десерт из бобов, желе и кокосового молока.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002a', 'en', 'Che', 'Sweet dessert soup with beans, jelly, and coconut milk.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002b', 'ru', 'Мороженое', 'Мороженое или фруктовый лёд.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002b', 'en', 'Ice cream', 'Ice cream or fruit popsicles.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002c', 'ru', 'Бань уот', 'Мягкие паровые рисовые листы с начинкой.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002c', 'en', 'Wet rice sheets', 'Soft steamed rice sheets with filling.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002d', 'ru', 'Жареная лапша', 'Лапша, обжаренная с мясом или морепродуктами.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002d', 'en', 'Fried noodles', 'Stir-fried noodles with meat or seafood.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002e', 'ru', 'Жареный рис', 'Жареный рис с добавками (thập cẩm - ассорти).'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002e', 'en', 'Fried rice', 'Fried rice with mix-ins (thap cam = mixed).'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002f', 'ru', 'Кань чуа', 'Кислый суп с рыбой и ананасом - южная классика.'),
	('d15ef00d-4a2b-4c9d-8e1f-00000000002f', 'en', 'Sour soup', 'Tamarind sour soup with fish and pineapple - a southern classic.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000030', 'ru', 'Лимонный чай', 'Лайм + зелёный чай + лёд - любимый напиток молодёжи.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000030', 'en', 'Lemon tea', 'Lime plus green tea plus ice - the youth favorite.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000031', 'ru', 'Свежевыжатый сок', 'Соки из свежих фруктов: манго, арбуз, ананас.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000031', 'en', 'Fresh juice', 'Fresh-pressed juices: mango, watermelon, pineapple.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000032', 'ru', 'Ча ка', 'Рыба, обжаренная с укропом и куркумой.'),
	('d15ef00d-4a2b-4c9d-8e1f-000000000032', 'en', 'Turmeric fish', 'Fish sauteed with dill and turmeric.')

on conflict (dish_id, language) do update
set
	name = excluded.name,
	summary = excluded.summary;

-- END dish dictionary seed

-- BEGIN dish gallery mirror
alter table public.dishes add column if not exists gallery_urls text[] not null default '{}';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Beef_noodle_soup_%28Ph%E1%BB%9F_b%C3%B2%29_-_Pho_Hanoi_Authentic_2024-12-01.jpg/960px-Beef_noodle_soup_%28Ph%E1%BB%9F_b%C3%B2%29_-_Pho_Hanoi_Authentic_2024-12-01.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Ph%E1%BB%9F_b%C3%B2%2C_C%E1%BA%A7u_Gi%E1%BA%A5y%2C_H%C3%A0_N%E1%BB%99i.jpg/960px-Ph%E1%BB%9F_b%C3%B2%2C_C%E1%BA%A7u_Gi%E1%BA%A5y%2C_H%C3%A0_N%E1%BB%99i.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Pho_Bo_Ga_-_Pho_Dzung_AUD8.50_small.jpg/960px-Pho_Bo_Ga_-_Pho_Dzung_AUD8.50_small.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Beef_Pho_%28M%29_-_Milk_No_Sugar.jpg/960px-Beef_Pho_%28M%29_-_Milk_No_Sugar.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Ph%E1%BB%9F_b%C3%B2_in_a_German_restaurant_01.jpg/960px-Ph%E1%BB%9F_b%C3%B2_in_a_German_restaurant_01.jpg}' where slug = 'pho-bo';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Pho_ga_%28noodle_soup_with_chicken%29%2C_Hanoi_%286945821707%29.jpg/960px-Pho_ga_%28noodle_soup_with_chicken%29%2C_Hanoi_%286945821707%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Pho_ga_%2829741913464%29.jpg/960px-Pho_ga_%2829741913464%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Pho_ga_%28Mary%27s_chicken%29_%2825735388134%29.jpg/960px-Pho_ga_%28Mary%27s_chicken%29_%2825735388134%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/3/34/Chicken_Pho%2C_Pho_21%2C_Montparnasse%2C_Paris_001.jpg/960px-Chicken_Pho%2C_Pho_21%2C_Montparnasse%2C_Paris_001.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Vietnamsk%C3%A1_ku%C5%99ec%C3%AD_pol%C3%A9vka_%E2%80%9Cph%E1%BB%9F_g%C3%A0%E2%80%9C_se_%C5%A1irok%C3%BDmi_r%C3%BD%C5%BEov%C3%BDmi_nudlemi_01.JPG/960px-Vietnamsk%C3%A1_ku%C5%99ec%C3%AD_pol%C3%A9vka_%E2%80%9Cph%E1%BB%9F_g%C3%A0%E2%80%9C_se_%C5%A1irok%C3%BDmi_r%C3%BD%C5%BEov%C3%BDmi_nudlemi_01.JPG}' where slug = 'pho-ga';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/1/19/B%C3%A1nh_m%C3%AC.jpg/960px-B%C3%A1nh_m%C3%AC.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Vietnamese_B%C3%A1nh_m%C3%AC_%28Banh_Mi%29_Sandwich.jpg/960px-Vietnamese_B%C3%A1nh_m%C3%AC_%28Banh_Mi%29_Sandwich.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/B%C3%A1nh_m%C3%AC_th%E1%BB%8Bt_ngu%E1%BB%99i.jpg/960px-B%C3%A1nh_m%C3%AC_th%E1%BB%8Bt_ngu%E1%BB%99i.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/B%C3%A1nh_m%C3%AC_x%C3%ADu_m%E1%BA%A1i-meatball-sandwich.jpg/960px-B%C3%A1nh_m%C3%AC_x%C3%ADu_m%E1%BA%A1i-meatball-sandwich.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Special_Baguette_%28B%C3%A1nh_m%C3%AC%29_-_Banh_Mi_Ancient_Saigon_2024-12-20.jpg/960px-Special_Baguette_%28B%C3%A1nh_m%C3%AC%29_-_Banh_Mi_Ancient_Saigon_2024-12-20.jpg}' where slug = 'banh-mi';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/B%C3%A1nh_x%C3%A8o_1.jpg/960px-B%C3%A1nh_x%C3%A8o_1.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/B%C3%A1nh_x%C3%A8o_with_n%C6%B0%E1%BB%9Bc_m%E1%BA%AFm.jpg/960px-B%C3%A1nh_x%C3%A8o_with_n%C6%B0%E1%BB%9Bc_m%E1%BA%AFm.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/B%C3%A1nh_x%C3%A8o_nh%C3%A2n_M%E1%BB%B1c%2C_Nha_Trang.jpg/960px-B%C3%A1nh_x%C3%A8o_nh%C3%A2n_M%E1%BB%B1c%2C_Nha_Trang.jpg,https://upload.wikimedia.org/wikipedia/commons/5/59/Banh_Xeo_with_fish_sauce_and_vegetables.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/B%C3%A1nh_x%C3%A8o_%2815826153307%29.jpg/960px-B%C3%A1nh_x%C3%A8o_%2815826153307%29.jpg}' where slug = 'banh-xeo';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/0/01/B%C3%A1nh_kho%C3%A1i.jpg,https://upload.wikimedia.org/wikipedia/commons/3/34/Banh_Khoai_%284265580561%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Banh_khoai.JPG/960px-Banh_khoai.JPG}' where slug = 'banh-khoai';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/B%C3%BAn_ch%E1%BA%A3_c%C3%A1%2C_th%C3%A1ng_8_n%C4%83m_2018.JPG/960px-B%C3%BAn_ch%E1%BA%A3_c%C3%A1%2C_th%C3%A1ng_8_n%C4%83m_2018.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/B%C3%BAn_C%C3%A1_H%C3%A0_N%E1%BB%99i.jpg/960px-B%C3%BAn_C%C3%A1_H%C3%A0_N%E1%BB%99i.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Bun_cha_ca.jpg/960px-Bun_cha_ca.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/Bun_cha_ca_rau_can.jpg/960px-Bun_cha_ca_rau_can.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Bun_cha_ca_nha_trang.jpg/960px-Bun_cha_ca_nha_trang.jpg}' where slug = 'bun-cha-ca';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/B%C3%BAn_ch%E1%BA%A3_H%C3%A0ng_M%C3%A0nh.jpg/960px-B%C3%BAn_ch%E1%BA%A3_H%C3%A0ng_M%C3%A0nh.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Bun_cha_Hanoi.jpg/960px-Bun_cha_Hanoi.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/B%C3%BAn_ch%E1%BA%A3_Vietnamese_food.jpg/960px-B%C3%BAn_ch%E1%BA%A3_Vietnamese_food.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Bun-cha-hanoi.jpg/960px-Bun-cha-hanoi.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/B%C3%BAn_ch%E1%BA%A3_with_chili_peppers_and_fresh_garlic.jpg/960px-B%C3%BAn_ch%E1%BA%A3_with_chili_peppers_and_fresh_garlic.jpg}' where slug = 'bun-cha';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/B%C3%BAn_b%C3%B2_Hu%E1%BA%BF_minh28397.jpg/960px-B%C3%BAn_b%C3%B2_Hu%E1%BA%BF_minh28397.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Bun-Bo-Hue-from-Huong-Giang-2011.jpg/960px-Bun-Bo-Hue-from-Huong-Giang-2011.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/B%C3%BAn_b%C3%B2_Hu%E1%BA%BF_-_Ch%E1%BB%A3_%C4%90%C3%B4ng_Ba_%282024%29_-_img_02.jpg/960px-B%C3%BAn_b%C3%B2_Hu%E1%BA%BF_-_Ch%E1%BB%A3_%C4%90%C3%B4ng_Ba_%282024%29_-_img_02.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Bun_Bo_Hue_1.jpg/960px-Bun_Bo_Hue_1.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/0/01/B%C3%BAn_b%C3%B2_Hu%E1%BA%BF_%2820201109%29.jpg/960px-B%C3%BAn_b%C3%B2_Hu%E1%BA%BF_%2820201109%29.jpg}' where slug = 'bun-bo-hue';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Mi_Quang_1A_Danang.jpg/960px-Mi_Quang_1A_Danang.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Mi_Quang_at_Ngoc_Mai_%28with_noodles_uncovered%29.jpg/960px-Mi_Quang_at_Ngoc_Mai_%28with_noodles_uncovered%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/M%C3%AC_Qu%E1%BA%A3ng%2C_Da_Nang%2C_Vietnam.jpg/960px-M%C3%AC_Qu%E1%BA%A3ng%2C_Da_Nang%2C_Vietnam.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/1/16/Mi_Quang_Hoi_An_%282024%29.jpg/960px-Mi_Quang_Hoi_An_%282024%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/M%C3%AC_Qu%E1%BA%A3ng_chay%2C_th%C3%A1ng_9_n%C4%83m_2018_%281%29.jpg/960px-M%C3%AC_Qu%E1%BA%A3ng_chay%2C_th%C3%A1ng_9_n%C4%83m_2018_%281%29.jpg}' where slug = 'mi-quang';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Cao_l%E1%BA%A7u_H%E1%BB%99i_An_%282024%29.jpg/960px-Cao_l%E1%BA%A7u_H%E1%BB%99i_An_%282024%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Cao_l%E1%BA%A7u_in_Hoi_An.jpg/960px-Cao_l%E1%BA%A7u_in_Hoi_An.jpg,https://upload.wikimedia.org/wikipedia/commons/1/1f/Cao_l%E1%BA%A7u_2.jpg,https://upload.wikimedia.org/wikipedia/commons/c/c5/Cao_l%E1%BA%A7u.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Cao_Lau_Hoi_An.JPG/960px-Cao_Lau_Hoi_An.JPG}' where slug = 'cao-lau';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/C%C6%A1m_g%C3%A0_Tam_K%E1%BB%B3%2C_Qu%E1%BA%A3ng_Nam.JPG/960px-C%C6%A1m_g%C3%A0_Tam_K%E1%BB%B3%2C_Qu%E1%BA%A3ng_Nam.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/C%C6%A1m_g%C3%A0_s%C6%B0%E1%BB%9Dn_n%C6%B0%E1%BB%9Bng%2C_ng23th8n2022_%28%C4%90%C3%B9i_g%C3%A0_n%C6%B0%E1%BB%9Bng%29_%284%29.jpg/960px-C%C6%A1m_g%C3%A0_s%C6%B0%E1%BB%9Dn_n%C6%B0%E1%BB%9Bng%2C_ng23th8n2022_%28%C4%90%C3%B9i_g%C3%A0_n%C6%B0%E1%BB%9Bng%29_%284%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/d/d4/Hainanese_chicken_rice.jpg/960px-Hainanese_chicken_rice.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Hainanese_Chicken_Rice_on_Glass_Dish.jpg/960px-Hainanese_Chicken_Rice_on_Glass_Dish.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/9/94/Hainanese_chicken_rice_in_Singapore.jpg/960px-Hainanese_chicken_rice_in_Singapore.jpg}' where slug = 'com-ga';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/b/b0/C%C6%A1m_T%E1%BA%A5m%2C_Da_Nang%2C_Vietnam.jpg/960px-C%C6%A1m_T%E1%BA%A5m%2C_Da_Nang%2C_Vietnam.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Com-Tam-2008.jpg/960px-Com-Tam-2008.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/C%C6%A1m_t%E1%BA%A5m_b%C3%AC_ch%E1%BA%A3.jpg/960px-C%C6%A1m_t%E1%BA%A5m_b%C3%AC_ch%E1%BA%A3.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/C%C6%A1m_t%E1%BA%A5m_s%C6%B0%E1%BB%9Dn_c%C3%A2y.JPG/960px-C%C6%A1m_t%E1%BA%A5m_s%C6%B0%E1%BB%9Dn_c%C3%A2y.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/D%C4%A9a_c%C6%A1m_t%E1%BA%A5m_SG_ng1th5n2022_%282%29.jpg/960px-D%C4%A9a_c%C6%A1m_t%E1%BA%A5m_SG_ng1th5n2022_%282%29.jpg}' where slug = 'com-tam';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/H%E1%BB%A7_ti%E1%BA%BFu_Nam_Vang_S%C3%A0i_G%C3%B2n.jpg/960px-H%E1%BB%A7_ti%E1%BA%BFu_Nam_Vang_S%C3%A0i_G%C3%B2n.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/H%E1%BB%A7_ti%E1%BA%BFu.jpg/960px-H%E1%BB%A7_ti%E1%BA%BFu.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Hu-Tieu-Kho-2008.jpg/960px-Hu-Tieu-Kho-2008.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/H%E1%BB%A7_ti%E1%BA%BFu_kh%C3%B4.jpg/960px-H%E1%BB%A7_ti%E1%BA%BFu_kh%C3%B4.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/H%E1%BB%A7_ti%E1%BA%BFu_h%E1%BA%A3i_s%E1%BA%A3n_kh%C3%B4_h%C3%A0_ti%C3%AAn.jpg/960px-H%E1%BB%A7_ti%E1%BA%BFu_h%E1%BA%A3i_s%E1%BA%A3n_kh%C3%B4_h%C3%A0_ti%C3%AAn.jpg}' where slug = 'hu-tieu';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/B%C3%A1nh_canh_c%C3%A1_l%C3%B3c_%28b%C3%A1nh_canh_b%E1%BB%99t_m%C3%AC%29_%E1%BB%9F_P1_%C4%90%C3%B4ng_H%C3%A0%2C_T%E1%BA%BFt_n%C4%83m_2019_%281%29.jpg/960px-B%C3%A1nh_canh_c%C3%A1_l%C3%B3c_%28b%C3%A1nh_canh_b%E1%BB%99t_m%C3%AC%29_%E1%BB%9F_P1_%C4%90%C3%B4ng_H%C3%A0%2C_T%E1%BA%BFt_n%C4%83m_2019_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/B%C3%A1nh_canh_c%C3%A1_l%C3%B3c_S%C3%A0i_G%C3%B2n_2012-07-02_11.53.24.jpg/960px-B%C3%A1nh_canh_c%C3%A1_l%C3%B3c_S%C3%A0i_G%C3%B2n_2012-07-02_11.53.24.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/T%E1%BA%BFt_2024_nh%C3%A0_m%C3%ACnh_%28t%C3%B4_b%C3%A1nh_canh_c%C3%A1_l%C3%B3c_b%E1%BB%99t_m%C3%AC_%C4%90%C3%B4ng_H%C3%A0_ng15th2n2024%29_%285%29.jpg/960px-T%E1%BA%BFt_2024_nh%C3%A0_m%C3%ACnh_%28t%C3%B4_b%C3%A1nh_canh_c%C3%A1_l%C3%B3c_b%E1%BB%99t_m%C3%AC_%C4%90%C3%B4ng_H%C3%A0_ng15th2n2024%29_%285%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/B%C3%A1nh_canh_c%C3%A1_l%C3%B3c_S%C3%A0i_G%C3%B2n_%E1%BB%9F_T%C3%A2n_Ph%C3%BA_v%E1%BB%9Bi_eHy_n%C4%83m_2016_%282%29.jpg/960px-B%C3%A1nh_canh_c%C3%A1_l%C3%B3c_S%C3%A0i_G%C3%B2n_%E1%BB%9F_T%C3%A2n_Ph%C3%BA_v%E1%BB%9Bi_eHy_n%C4%83m_2016_%282%29.jpg}' where slug = 'banh-canh-cha-ca';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/M%C3%B3n_%C4%83n_T%E1%BA%BFt_2023_%28b%C3%A1nh_canh_t%C3%B4m_th%E1%BB%8Bt%29_%281%29.jpg/960px-M%C3%B3n_%C4%83n_T%E1%BA%BFt_2023_%28b%C3%A1nh_canh_t%C3%B4m_th%E1%BB%8Bt%29_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/82/M%C3%B3n_%C4%83n_T%E1%BA%BFt_2023_%28b%C3%A1nh_canh_t%C3%B4m_th%E1%BB%8Bt%29_%282%29.jpg/960px-M%C3%B3n_%C4%83n_T%E1%BA%BFt_2023_%28b%C3%A1nh_canh_t%C3%B4m_th%E1%BB%8Bt%29_%282%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/B%C3%A1nh_Canh_Cua.jpg/960px-B%C3%A1nh_Canh_Cua.jpg,https://upload.wikimedia.org/wikipedia/commons/c/c4/Banh-Canh-Noodle-Soup.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/B%C3%A1nh_canh_cua.jpg/960px-B%C3%A1nh_canh_cua.jpg}' where slug = 'banh-canh-tom';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/G%E1%BB%8Fi_cu%E1%BB%91n.jpg/960px-G%E1%BB%8Fi_cu%E1%BB%91n.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/G%E1%BB%8Fi_cu%E1%BB%91n_%2849358210697%29.jpg/960px-G%E1%BB%8Fi_cu%E1%BB%91n_%2849358210697%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Summer_roll.jpg/960px-Summer_roll.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/f2/Goi_cuon_Phuongnhu.JPG/960px-Goi_cuon_Phuongnhu.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/G%E1%BB%8Fi_Cu%E1%BB%91n_Chay_Vietnamese_Fresh_Vegetarian_Spring_Roll_2019-1599.jpg/960px-G%E1%BB%8Fi_Cu%E1%BB%91n_Chay_Vietnamese_Fresh_Vegetarian_Spring_Roll_2019-1599.jpg}' where slug = 'goi-cuon';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/6/6b/Cha_gio.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Ch%E1%BA%A3_gi%C3%B2_%28Vietnamese_Spring_Rolls%29_-_12.jpg/960px-Ch%E1%BA%A3_gi%C3%B2_%28Vietnamese_Spring_Rolls%29_-_12.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Nem_r%C3%A1n_gi%C3%B2n%2C_ng23th9n2022_%282%29.jpg/960px-Nem_r%C3%A1n_gi%C3%B2n%2C_ng23th9n2022_%282%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Ch%E1%BA%A3_gi%C3%B2_SG_%28nem_r%C3%A1n_gi%C3%B2n%29_%E1%BB%9F_qu%C3%A1n_b%C3%BAn_ri%C3%AAu_B%C3%A0_Ti_ng26th7n2023_%283%29.jpg/960px-Ch%E1%BA%A3_gi%C3%B2_SG_%28nem_r%C3%A1n_gi%C3%B2n%29_%E1%BB%9F_qu%C3%A1n_b%C3%BAn_ri%C3%AAu_B%C3%A0_Ti_ng26th7n2023_%283%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Cu%E1%BB%91n_nem_r%C3%A1n_%28%C4%91a_nem%29_3.JPG/960px-Cu%E1%BB%91n_nem_r%C3%A1n_%28%C4%91a_nem%29_3.JPG}' where slug = 'cha-gio';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/f/f6/Nem_l%E1%BB%A5i.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Nh%C3%A0_m%C3%ACnh_L%E1%BB%85_30th4n2023_%28ch%E1%BA%A1o_nem_l%E1%BB%A5i%29_%281%29.jpg/960px-Nh%C3%A0_m%C3%ACnh_L%E1%BB%85_30th4n2023_%28ch%E1%BA%A1o_nem_l%E1%BB%A5i%29_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Nh%C3%A0_m%C3%ACnh_L%E1%BB%85_30th4n2023_%28ch%E1%BA%A1o_nem_l%E1%BB%A5i%29_%282%29.jpg/960px-Nh%C3%A0_m%C3%ACnh_L%E1%BB%85_30th4n2023_%28ch%E1%BA%A1o_nem_l%E1%BB%A5i%29_%282%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/L%E1%BB%85_h%E1%BB%99i_%E1%BA%A9m_th%E1%BB%B1c_C%E1%BB%ADa_Vi%E1%BB%87t_th4n2023_%C4%91%E1%BA%B7c_s%E1%BA%A3n_nem_l%E1%BB%A5i_n%C6%B0%E1%BB%9Bng_Nha_Trang_%281%29.jpg/960px-L%E1%BB%85_h%E1%BB%99i_%E1%BA%A9m_th%E1%BB%B1c_C%E1%BB%ADa_Vi%E1%BB%87t_th4n2023_%C4%91%E1%BA%B7c_s%E1%BA%A3n_nem_l%E1%BB%A5i_n%C6%B0%E1%BB%9Bng_Nha_Trang_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/AE_li%C3%AAn_hoan%2C_Nem_l%E1%BB%A5i_%E1%BB%9F_B%C3%ACnh_T%C3%A2n%2C_ng8th2n2020_%282%29.jpg/960px-AE_li%C3%AAn_hoan%2C_Nem_l%E1%BB%A5i_%E1%BB%9F_B%C3%ACnh_T%C3%A2n%2C_ng8th2n2020_%282%29.jpg}' where slug = 'nem-lui';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/b/b2/B%C3%A1nh_cu%E1%BB%91n_Thanh_Tr%C3%AC.jpg/960px-B%C3%A1nh_cu%E1%BB%91n_Thanh_Tr%C3%AC.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Banh_cuon_nhan_thit_cha_lua%2C_Banh_Cuon_Thang_Long.jpg/960px-Banh_cuon_nhan_thit_cha_lua%2C_Banh_Cuon_Thang_Long.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/B%C3%A1nh_cu%E1%BB%91n.jpg/960px-B%C3%A1nh_cu%E1%BB%91n.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Banh-cuon-hanoi.jpg/960px-Banh-cuon-hanoi.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/B%C3%A1nh_cu%E1%BB%91n_Saigon.jpg/960px-B%C3%A1nh_cu%E1%BB%91n_Saigon.jpg}' where slug = 'banh-cuon';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/B%C3%A1nh_bao.jpg/960px-B%C3%A1nh_bao.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/5/58/B%C3%A1nh_bao_2.jpg/960px-B%C3%A1nh_bao_2.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/B%C3%A1nh_bao_3.jpg/960px-B%C3%A1nh_bao_3.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Banhbao.jpg/960px-Banhbao.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/B%C3%A1nh_bao_x%C3%A1_x%C3%ADu.jpeg/960px-B%C3%A1nh_bao_x%C3%A1_x%C3%ADu.jpeg}' where slug = 'banh-bao';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/f/fd/X%C3%B4i_ng%C5%A9_s%E1%BA%AFc.JPG/960px-X%C3%B4i_ng%C5%A9_s%E1%BA%AFc.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/X%C3%B4i_x%C3%A9o.jpg/960px-X%C3%B4i_x%C3%A9o.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/X%C3%B4i_%C4%91%E1%BB%97_xanh.jpg/960px-X%C3%B4i_%C4%91%E1%BB%97_xanh.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/X%C3%B4i_l%C3%A1_c%E1%BA%A9m_c%E1%BA%AFt_ngang.jpg/960px-X%C3%B4i_l%C3%A1_c%E1%BA%A9m_c%E1%BA%AFt_ngang.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/X%C3%B4i_G%C3%A0_Tr%E1%BB%A9ng_Non_L%E1%BA%A1p_X%C6%B0%E1%BB%9Bng_%28Sticky_rice_with_chicken_and_eggs%2C_and_chinese_sausages%29.jpg/960px-X%C3%B4i_G%C3%A0_Tr%E1%BB%A9ng_Non_L%E1%BA%A1p_X%C6%B0%E1%BB%9Bng_%28Sticky_rice_with_chicken_and_eggs%2C_and_chinese_sausages%29.jpg}' where slug = 'xoi';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Ch%C3%A1o_g%C3%A0_x%C3%A9_phay_%28t%C3%B4_g%C3%A0_x%C3%A9_phay%29_%E1%BB%9F_P3_%C4%90%C3%B4ng_H%C3%A0_n%C4%83m_2018.jpg/960px-Ch%C3%A1o_g%C3%A0_x%C3%A9_phay_%28t%C3%B4_g%C3%A0_x%C3%A9_phay%29_%E1%BB%9F_P3_%C4%90%C3%B4ng_H%C3%A0_n%C4%83m_2018.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/Ch%C3%A1o_g%C3%A0_x%C3%A9_phay_%E1%BB%9F_P3_%C4%90%C3%B4ng_H%C3%A0_n%C4%83m_2018.jpg/960px-Ch%C3%A1o_g%C3%A0_x%C3%A9_phay_%E1%BB%9F_P3_%C4%90%C3%B4ng_H%C3%A0_n%C4%83m_2018.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Ch%C3%A1o_g%C3%A0_nh%C3%A0_l%C3%A0m%2C_th%C3%A1ng_5_n%C4%83m_2020_%281%29.jpg/960px-Ch%C3%A1o_g%C3%A0_nh%C3%A0_l%C3%A0m%2C_th%C3%A1ng_5_n%C4%83m_2020_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Ch%C3%A1o_g%C3%A0_nh%C3%A0_l%C3%A0m%2C_th%C3%A1ng_5_n%C4%83m_2020_%282%29.jpg/960px-Ch%C3%A1o_g%C3%A0_nh%C3%A0_l%C3%A0m%2C_th%C3%A1ng_5_n%C4%83m_2020_%282%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Ch%C3%A1o_g%C3%A0_nh%C3%A0_l%C3%A0m%2C_th%C3%A1ng_5_n%C4%83m_2020_%283%29.jpg/960px-Ch%C3%A1o_g%C3%A0_nh%C3%A0_l%C3%A0m%2C_th%C3%A1ng_5_n%C4%83m_2020_%283%29.jpg}' where slug = 'chao-ga';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Thai_suki%2C_Thai_hot_pot_ingredients%2C_Bangkok%2C_Thailand.jpg/960px-Thai_suki%2C_Thai_hot_pot_ingredients%2C_Bangkok%2C_Thailand.jpg,https://upload.wikimedia.org/wikipedia/commons/f/fb/Thai_Suki_of_MK_Restaurant.JPG,https://upload.wikimedia.org/wikipedia/commons/6/66/Pictures_of_hot_pot_food.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Image_of_hot_pot_and_food.jpg/960px-Image_of_hot_pot_and_food.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/c/c8/2019_02_Suki_street_food_Korat_01.jpg/960px-2019_02_Suki_street_food_Korat_01.jpg}' where slug = 'lau-thai';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/0/02/Newone_-_l%E1%BA%A9u_g%C3%A0%2C_s%C6%B0%E1%BB%9Dn_v%C3%A0_r%C6%B0%E1%BB%A3u_%C4%91inh_l%C4%83ng.jpg/960px-Newone_-_l%E1%BA%A9u_g%C3%A0%2C_s%C6%B0%E1%BB%9Dn_v%C3%A0_r%C6%B0%E1%BB%A3u_%C4%91inh_l%C4%83ng.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/HK_TST_%E6%A0%BC%E8%98%AD%E4%B8%AD%E5%BF%83_Grand_Centre_%E5%AE%B6%E5%AB%82_%E9%9B%9E%E7%85%B2%E7%81%AB%E9%8D%8B_Home_Sister_Family_Hotpot_Restaurant_%E9%9B%9E%E7%85%B2_%E7%81%AB%E9%8D%8B_Chicken_March_2023_Px3_02.jpg/960px-HK_TST_%E6%A0%BC%E8%98%AD%E4%B8%AD%E5%BF%83_Grand_Centre_%E5%AE%B6%E5%AB%82_%E9%9B%9E%E7%85%B2%E7%81%AB%E9%8D%8B_Home_Sister_Family_Hotpot_Restaurant_%E9%9B%9E%E7%85%B2_%E7%81%AB%E9%8D%8B_Chicken_March_2023_Px3_02.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/HK_TST_%E6%A0%BC%E8%98%AD%E4%B8%AD%E5%BF%83_Grand_Centre_%E5%AE%B6%E5%AB%82_%E9%9B%9E%E7%85%B2%E7%81%AB%E9%8D%8B_Home_Sister_Family_Hotpot_Restaurant_%E9%9B%9E%E7%85%B2_%E7%81%AB%E9%8D%8B_Chicken_March_2023_Px3_03.jpg/960px-HK_TST_%E6%A0%BC%E8%98%AD%E4%B8%AD%E5%BF%83_Grand_Centre_%E5%AE%B6%E5%AB%82_%E9%9B%9E%E7%85%B2%E7%81%AB%E9%8D%8B_Home_Sister_Family_Hotpot_Restaurant_%E9%9B%9E%E7%85%B2_%E7%81%AB%E9%8D%8B_Chicken_March_2023_Px3_03.jpg}' where slug = 'lau-ga';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/M%C3%B3n_%E1%BB%91c_x%C3%A0o_%E1%BB%9F_qu%C3%A1n_%E1%BB%90c_La_C%C3%A0.JPG/960px-M%C3%B3n_%E1%BB%91c_x%C3%A0o_%E1%BB%9F_qu%C3%A1n_%E1%BB%90c_La_C%C3%A0.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/%E1%BB%90c_x%C3%A0o_rau_mu%E1%BB%91ng_sn_2012_%281%29.JPG/960px-%E1%BB%90c_x%C3%A0o_rau_mu%E1%BB%91ng_sn_2012_%281%29.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/%E1%BB%90c_x%C3%A0o_rau_mu%E1%BB%91ng_sn_2012_%282%29.JPG/960px-%E1%BB%90c_x%C3%A0o_rau_mu%E1%BB%91ng_sn_2012_%282%29.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/%E1%BB%90c_m%C3%B3ng_tay_x%C3%A0o_rau_mu%E1%BB%91ng_n%C4%83m_2016_%285%29.jpg/960px-%E1%BB%90c_m%C3%B3ng_tay_x%C3%A0o_rau_mu%E1%BB%91ng_n%C4%83m_2016_%285%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/%E1%BB%90c_m%C3%B3ng_tay_x%C3%A0o_rau_mu%E1%BB%91ng_n%C4%83m_2016_%286%29.jpg/960px-%E1%BB%90c_m%C3%B3ng_tay_x%C3%A0o_rau_mu%E1%BB%91ng_n%C4%83m_2016_%286%29.jpg}' where slug = 'oc';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/d/d1/T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%281%29.JPG/960px-T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%281%29.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%282%29.JPG/960px-T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%282%29.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/3/32/T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%283%29.JPG/960px-T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%283%29.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%284%29.JPG/960px-T%C3%B4m_n%C6%B0%E1%BB%9Bng_sn_2012_%284%29.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/T%C3%B4m_n%C6%B0%E1%BB%9Bng_Phan_X%C3%ADch_Long%2C_n%C4%83m_2017_%281%29.jpg/960px-T%C3%B4m_n%C6%B0%E1%BB%9Bng_Phan_X%C3%ADch_Long%2C_n%C4%83m_2017_%281%29.jpg}' where slug = 'tom-nuong';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/C%C3%A1_kho_t%E1%BB%99%2C_c%C3%A1_h%C3%BA.jpg/960px-C%C3%A1_kho_t%E1%BB%99%2C_c%C3%A1_h%C3%BA.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Ph%C3%BA_Qu%E1%BB%91c_2022_%28c%C3%A1_kho_t%E1%BB%99%29_%281%29.jpg/960px-Ph%C3%BA_Qu%E1%BB%91c_2022_%28c%C3%A1_kho_t%E1%BB%99%29_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/C%C3%A1_kho_t%E1%BB%99.JPG/960px-C%C3%A1_kho_t%E1%BB%99.JPG,https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/M%C3%B3n_c%C3%A1_r%C3%B4_kho_ng4th8n2023_%281%29.jpg/960px-M%C3%B3n_c%C3%A1_r%C3%B4_kho_ng4th8n2023_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Dia_c%C3%A1_h%C3%BA_kho_cua_Thu_Thao.jpg/960px-Dia_c%C3%A1_h%C3%BA_kho_cua_Thu_Thao.jpg}' where slug = 'ca-kho-to';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/%E3%82%B5%E3%82%A4%E3%82%B4%E3%83%B32%E3%81%AE%E5%9B%9B%E4%B8%87%E5%8D%81%E9%B6%8F%E3%81%AE%E8%89%B2%E3%80%85%E9%87%8E%E8%8F%9C%E3%81%A8%E3%82%AB%E3%82%B7%E3%83%A5%E3%83%BC%E3%83%8A%E3%83%83%E3%83%84%E3%81%AE%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%88%E3%83%81%E3%83%AA%E7%82%92%E3%82%81_02.jpg/960px-%E3%82%B5%E3%82%A4%E3%82%B4%E3%83%B32%E3%81%AE%E5%9B%9B%E4%B8%87%E5%8D%81%E9%B6%8F%E3%81%AE%E8%89%B2%E3%80%85%E9%87%8E%E8%8F%9C%E3%81%A8%E3%82%AB%E3%82%B7%E3%83%A5%E3%83%BC%E3%83%8A%E3%83%83%E3%83%84%E3%81%AE%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%88%E3%83%81%E3%83%AA%E7%82%92%E3%82%81_02.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/7/77/%E3%82%B5%E3%82%A4%E3%82%B4%E3%83%B32%E3%81%AE%E5%9B%9B%E4%B8%87%E5%8D%81%E9%B6%8F%E3%81%AE%E8%89%B2%E3%80%85%E9%87%8E%E8%8F%9C%E3%81%A8%E3%82%AB%E3%82%B7%E3%83%A5%E3%83%BC%E3%83%8A%E3%83%83%E3%83%84%E3%81%AE%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%88%E3%83%81%E3%83%AA%E7%82%92%E3%82%81_01.jpg/960px-%E3%82%B5%E3%82%A4%E3%82%B4%E3%83%B32%E3%81%AE%E5%9B%9B%E4%B8%87%E5%8D%81%E9%B6%8F%E3%81%AE%E8%89%B2%E3%80%85%E9%87%8E%E8%8F%9C%E3%81%A8%E3%82%AB%E3%82%B7%E3%83%A5%E3%83%BC%E3%83%8A%E3%83%83%E3%83%84%E3%81%AE%E3%82%B9%E3%82%A4%E3%83%BC%E3%83%88%E3%83%81%E3%83%AA%E7%82%92%E3%82%81_01.jpg}' where slug = 'ga-xao-sa-ot';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/Bo_Luc_Lac-_the_shaking_beef.jpg/960px-Bo_Luc_Lac-_the_shaking_beef.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/7/78/Product_Shots_of_Food-Bo_Luc_Lac.jpg/960px-Product_Shots_of_Food-Bo_Luc_Lac.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Qu%C3%A1n_Safia%2C_T%E1%BA%BFt_2022_%28m%C3%B3n_b%C3%B2_l%C3%BAc_l%E1%BA%AFc%29_%281%29.jpg/960px-Qu%C3%A1n_Safia%2C_T%E1%BA%BFt_2022_%28m%C3%B3n_b%C3%B2_l%C3%BAc_l%E1%BA%AFc%29_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/L%C3%B4c_lac_de_b%C5%93uf%2C_riz_tha%C3%AF_au_petits_l%C3%A9gumes_et_cacahu%C3%A8tes.jpg/960px-L%C3%B4c_lac_de_b%C5%93uf%2C_riz_tha%C3%AF_au_petits_l%C3%A9gumes_et_cacahu%C3%A8tes.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/6/66/Beef_Lok_Lak.jpg/960px-Beef_Lok_Lak.jpg}' where slug = 'bo-luc-lac';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Bun_thit_nuong.jpg/960px-Bun_thit_nuong.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/e5/Saigon_Bun_thit_nuong.jpg/960px-Saigon_Bun_thit_nuong.jpg,https://upload.wikimedia.org/wikipedia/commons/3/36/Vietnamese_bowl_of_grilled_pork%2C_bun_thit_nuong.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/B%C3%BAn_th%E1%BB%8Bt_n%C6%B0%E1%BB%9Bng_t%E1%BA%A1i_qu%C3%A1n_C%C6%A1m_t%E1%BA%A5m_Cali_%E1%BB%9F_Qu%E1%BA%ADn_4%2C_%C4%91%C6%B0%E1%BB%9Dng_Ho%C3%A0ng_Di%E1%BB%87u_%281%29.jpg/960px-B%C3%BAn_th%E1%BB%8Bt_n%C6%B0%E1%BB%9Bng_t%E1%BA%A1i_qu%C3%A1n_C%C6%A1m_t%E1%BA%A5m_Cali_%E1%BB%9F_Qu%E1%BA%ADn_4%2C_%C4%91%C6%B0%E1%BB%9Dng_Ho%C3%A0ng_Di%E1%BB%87u_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/e/eb/S%C6%B0%E1%BB%9Dn_n%C6%B0%E1%BB%9Bng.jpg}' where slug = 'thit-nuong';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Vietnamese_%22banh_trang_tron%22.JPG/960px-Vietnamese_%22banh_trang_tron%22.JPG,https://upload.wikimedia.org/wikipedia/commons/b/b3/Banhtrangtron.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Mixed_rice_paper.jpg/960px-Mixed_rice_paper.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Chi_ti%E1%BA%BFt_b%C3%A1nh_tr%C3%A1ng_tr%E1%BB%99n_C%C3%B4_Hai_Th%E1%BA%A3o_.jpg/960px-Chi_ti%E1%BA%BFt_b%C3%A1nh_tr%C3%A1ng_tr%E1%BB%99n_C%C3%B4_Hai_Th%E1%BA%A3o_.jpg}' where slug = 'banh-trang-tron';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/G%E1%BB%8Fi_%C4%91u_%C4%91%E1%BB%A7_kh%C3%B4_b%C3%B2.jpg/960px-G%E1%BB%8Fi_%C4%91u_%C4%91%E1%BB%A7_kh%C3%B4_b%C3%B2.jpg,https://upload.wikimedia.org/wikipedia/commons/d/db/G%E1%BB%8Fi_b%C6%B0%E1%BB%9Fi.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/G%E1%BB%8Fi_nh%E1%BB%87ch_1.jpg/960px-G%E1%BB%8Fi_nh%E1%BB%87ch_1.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/G%E1%BB%8Fi_C%C3%A1_Tr%C3%ADch.jpg/960px-G%E1%BB%8Fi_C%C3%A1_Tr%C3%ADch.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/Vietnamese_mango_salad_with_shrimp.jpg/960px-Vietnamese_mango_salad_with_shrimp.jpg}' where slug = 'goi';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Ca_Phe_Sua_Da.jpg/960px-Ca_Phe_Sua_Da.jpg,https://upload.wikimedia.org/wikipedia/commons/1/1b/C%C3%A0_ph%C3%AA_s%E1%BB%AFa_%C4%91%C3%A1.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/C%C3%A0_Ph%C3%AA_S%E1%BB%AFa_%C4%90%C3%A1_-_%C4%90%E1%BA%B7c_tr%C6%B0ng_c%E1%BB%A7a_Vi%E1%BB%87t_Nam.jpg/960px-C%C3%A0_Ph%C3%AA_S%E1%BB%AFa_%C4%90%C3%A1_-_%C4%90%E1%BA%B7c_tr%C6%B0ng_c%E1%BB%A7a_Vi%E1%BB%87t_Nam.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/C%C3%A0_ph%C3%AA_s%E1%BB%AFa_%C4%91%C3%A1_%28509309424%29.jpg/960px-C%C3%A0_ph%C3%AA_s%E1%BB%AFa_%C4%91%C3%A1_%28509309424%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Vietnamese_iced_coffee_-_Jan_31%2C_2018.jpg/960px-Vietnamese_iced_coffee_-_Jan_31%2C_2018.jpg}' where slug = 'ca-phe-sua-da';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng.jpg/960px-C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng.jpg,https://upload.wikimedia.org/wikipedia/commons/7/7f/C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng_%28egg_coffee%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Egg_Coffee_at_Cafe_Gi%E1%BA%A3ng%2C_H%C3%A0_N%E1%BB%99i%2C_Vietnam.jpg/960px-Egg_Coffee_at_Cafe_Gi%E1%BA%A3ng%2C_H%C3%A0_N%E1%BB%99i%2C_Vietnam.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/NewOne-egg_coffee_2.jpg/960px-NewOne-egg_coffee_2.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng_%E1%BB%9F_Q1_ng16th9n2022_%285%29.jpg/960px-C%C3%A0_ph%C3%AA_tr%E1%BB%A9ng_%E1%BB%9F_Q1_ng16th9n2022_%285%29.jpg}' where slug = 'ca-phe-trung';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Iced_B%E1%BA%A1c_X%E1%BB%89u_served_in_tall_glass_on_the_table_in_tha_cafe%2C_Danang_city%2C_2023.jpg/960px-Iced_B%E1%BA%A1c_X%E1%BB%89u_served_in_tall_glass_on_the_table_in_tha_cafe%2C_Danang_city%2C_2023.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Ly_p%E1%BA%B7c_x%E1%BB%89u_s%E1%BB%AFa_%C4%91%C3%A1_%E1%BB%9F_Q1_ng18th8n2022.jpg/960px-Ly_p%E1%BA%B7c_x%E1%BB%89u_s%E1%BB%AFa_%C4%91%C3%A1_%E1%BB%9F_Q1_ng18th8n2022.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/White_coffee_in_Vietnam.jpg/960px-White_coffee_in_Vietnam.jpg}' where slug = 'bac-xiu';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/6/6a/Iced_tea_with_ice_cubes.jpg/960px-Iced_tea_with_ice_cubes.jpg,https://upload.wikimedia.org/wikipedia/commons/f/f3/Glass_of_iced_tea_-_Evan_Swigart.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/NCI_iced_tea.jpg/960px-NCI_iced_tea.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Iced_Tea_from_flickr.jpg/960px-Iced_Tea_from_flickr.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Iced_tea_%2814245990527%29.jpg/960px-Iced_tea_%2814245990527%29.jpg}' where slug = 'tra-da';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Kiwi_Smoothie.jpg/960px-Kiwi_Smoothie.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Fresh-mango-smoothie_01.jpg/960px-Fresh-mango-smoothie_01.jpg,https://upload.wikimedia.org/wikipedia/commons/2/2b/Smoothie_%2814114450783%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/Green_Smoothie.jpg/960px-Green_Smoothie.jpg}' where slug = 'sinh-to';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/6/63/Sugarcanejuice.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Sugarcane_Juice.png/960px-Sugarcane_Juice.png,https://upload.wikimedia.org/wikipedia/commons/e/e7/Sugarcane_juice_%282108819084%29.jpg,https://upload.wikimedia.org/wikipedia/commons/3/3d/5litre_Sugarcane_Juice.jpg,https://upload.wikimedia.org/wikipedia/commons/7/72/Sugarcane_juice_fresh.jpg}' where slug = 'nuoc-mia';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/a/ad/Lemon_juice.jpg/960px-Lemon_juice.jpg,https://upload.wikimedia.org/wikipedia/commons/2/2b/Limeade.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/Fresh_limeade.jpg/960px-Fresh_limeade.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Koh_Mak%2C_Thailand%2C_Lime_juice_with_ice%2C_Lemonade%2C_Limeade.jpg/960px-Koh_Mak%2C_Thailand%2C_Lime_juice_with_ice%2C_Lemonade%2C_Limeade.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Lemon_juice_with_Straw.jpg/960px-Lemon_juice_with_Straw.jpg}' where slug = 'nuoc-chanh';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/Bia_hoi_in_Hoi_An%2C_Vietnam.jpg/960px-Bia_hoi_in_Hoi_An%2C_Vietnam.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/b4/Bia_Hoi_%28fresh_beer%29_in_Hanoi_%281344451343%29.jpg/960px-Bia_Hoi_%28fresh_beer%29_in_Hanoi_%281344451343%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Bia_Viet_bottle_with_beer_mug%2C_Ho_Chi_Minh_City%2C_2023_%2801%29.jpg/960px-Bia_Viet_bottle_with_beer_mug%2C_Ho_Chi_Minh_City%2C_2023_%2801%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Saigon_lager_beer_red_label.jpg/960px-Saigon_lager_beer_red_label.jpg}' where slug = 'bia';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Cr%C3%A8me_caramel_2.jpg/960px-Cr%C3%A8me_caramel_2.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Cr%C3%A8me_caramel_1.jpg/960px-Cr%C3%A8me_caramel_1.jpg,https://upload.wikimedia.org/wikipedia/commons/2/2e/Caramel_custard_PK020.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Leche_flan_%28Philippines%29_01.jpg/960px-Leche_flan_%28Philippines%29_01.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Homemade_Flan.jpg/960px-Homemade_Flan.jpg}' where slug = 'banh-flan';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Ch%C3%A8_b%C3%A0_ba.jpg/960px-Ch%C3%A8_b%C3%A0_ba.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Ch%C3%A8_B%E1%BA%AFp.jpg/960px-Ch%C3%A8_B%E1%BA%AFp.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Ch%C3%A8_Th%C6%B0ng.jpg/960px-Ch%C3%A8_Th%C6%B0ng.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Ch%C3%A8_%C4%91%E1%BB%97_xanh.jpg/960px-Ch%C3%A8_%C4%91%E1%BB%97_xanh.jpg}' where slug = 'che';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/6/6d/Ice_cream_cone_-_Summer_2018.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/6/62/Ice_cream_in_cones.jpg/960px-Ice_cream_in_cones.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/2_ice_cream_cones_2025-05-02.jpg/960px-2_ice_cream_cones_2025-05-02.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Bowl_~_Ice_cream.jpg/960px-Bowl_~_Ice_cream.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/ee/Ice_cream_in_cup_with_sprinkles_and_spoon.jpg/960px-Ice_cream_in_cup_with_sprinkles_and_spoon.jpg}' where slug = 'kem';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/B%C3%A1nh_%C6%B0%E1%BB%9Bt.jpg/960px-B%C3%A1nh_%C6%B0%E1%BB%9Bt.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/B%C3%A1nh_%C6%B0%E1%BB%9Bt_%28wet_cakes%29_%2823976854760%29.jpg/960px-B%C3%A1nh_%C6%B0%E1%BB%9Bt_%28wet_cakes%29_%2823976854760%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/Banh_Uot_Tom_Chay_Kim_Long.jpg/960px-Banh_Uot_Tom_Chay_Kim_Long.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/Nh%C3%A0_m%C3%ACnh_L%E1%BB%85_30th4n2023_%28b%C3%A1nh_%C6%B0%E1%BB%9Bt_Ph%C6%B0%C6%A1ng_Lang%29_%281%29.jpg/960px-Nh%C3%A0_m%C3%ACnh_L%E1%BB%85_30th4n2023_%28b%C3%A1nh_%C6%B0%E1%BB%9Bt_Ph%C6%B0%C6%A1ng_Lang%29_%281%29.jpg}' where slug = 'banh-uot';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/M%C3%AC_x%C3%A0o_kh%C3%B4_Vi%E1%BB%87t_Nam.jpg/960px-M%C3%AC_x%C3%A0o_kh%C3%B4_Vi%E1%BB%87t_Nam.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/d/d3/Nui_x%C3%A0o_b%C3%B2.jpg/960px-Nui_x%C3%A0o_b%C3%B2.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/e2/M%C3%AC_x%C3%A0o_h%C3%A0o_%E1%BB%9F_T%C3%A2n_Ph%C3%BA%2C_th%C3%A1ng_6_n%C4%83m_2018_%284%29.jpg/960px-M%C3%AC_x%C3%A0o_h%C3%A0o_%E1%BB%9F_T%C3%A2n_Ph%C3%BA%2C_th%C3%A1ng_6_n%C4%83m_2018_%284%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/7/7f/Prawn_Stir_Fry_Egg_Noodles_with_Dark_Soy_sauce_-_Tookta%27s_Thai_Food.jpg/960px-Prawn_Stir_Fry_Egg_Noodles_with_Dark_Soy_sauce_-_Tookta%27s_Thai_Food.jpg}' where slug = 'mi-xao';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/Fried_rice_in_home.jpg/960px-Fried_rice_in_home.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Fried_rice_with_chicken_and_egg.jpg/960px-Fried_rice_with_chicken_and_egg.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/3/33/Fried_rice_1.jpg/960px-Fried_rice_1.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/C%C6%A1m_rang_c%E1%BB%A7a_%C4%91%E1%BA%A7u_b%E1%BA%BFp_T%C3%A0n_Ki%E1%BA%BFm.jpg/960px-C%C6%A1m_rang_c%E1%BB%A7a_%C4%91%E1%BA%A7u_b%E1%BA%BFp_T%C3%A0n_Ki%E1%BA%BFm.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Hongkong_Fried_Rice_2.jpg/960px-Hongkong_Fried_Rice_2.jpg}' where slug = 'com-rang';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Canh_chua_%C4%90%C3%B4ng_H%C3%A0.jpg/960px-Canh_chua_%C4%90%C3%B4ng_H%C3%A0.jpg,https://upload.wikimedia.org/wikipedia/commons/a/a0/Canhchua2.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Canh_chua_c%C3%A1_l%C3%B3c_%E1%BB%9F_Th%E1%BB%A7y_Tr%C3%BAc_Qu%C3%A1n%2C_%C4%91%C6%B0%E1%BB%9Dng_Nguy%E1%BB%85n_Nh%E1%BB%AF_L%C3%A3m_%281%29.jpg/960px-Canh_chua_c%C3%A1_l%C3%B3c_%E1%BB%9F_Th%E1%BB%A7y_Tr%C3%BAc_Qu%C3%A1n%2C_%C4%91%C6%B0%E1%BB%9Dng_Nguy%E1%BB%85n_Nh%E1%BB%AF_L%C3%A3m_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Canh_chua_c%C3%A1_di%C3%AAu_h%E1%BB%93ng.jpg/960px-Canh_chua_c%C3%A1_di%C3%AAu_h%E1%BB%93ng.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/M%C3%B3n_%C4%83n_%E1%BB%9F_%C4%90%C3%A0_L%E1%BA%A1t%2C_ng20th2n2022_%28t%C3%B4_canh_chua%29.jpg/960px-M%C3%B3n_%C4%83n_%E1%BB%9F_%C4%90%C3%A0_L%E1%BA%A1t%2C_ng20th2n2022_%28t%C3%B4_canh_chua%29.jpg}' where slug = 'canh-chua';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Ly_tr%C3%A0_s%E1%BA%A3_chanh_ng2th9n2022_%281%29.jpg/960px-Ly_tr%C3%A0_s%E1%BA%A3_chanh_ng2th9n2022_%281%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Ly_tr%C3%A0_s%E1%BA%A3_chanh_ng2th9n2022_%282%29.jpg/960px-Ly_tr%C3%A0_s%E1%BA%A3_chanh_ng2th9n2022_%282%29.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/8/81/Lemon_Iced_Tea_1.JPG/960px-Lemon_Iced_Tea_1.JPG}' where slug = 'tra-chanh';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Orange_juice_1_edit1.jpg/960px-Orange_juice_1_edit1.jpg,https://upload.wikimedia.org/wikipedia/commons/8/8b/Orange_juice_in_a_glass.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cocktail_of_passion_fruit_juice_and_watermelon_juice_in_a_glass.jpg/960px-Cocktail_of_passion_fruit_juice_and_watermelon_juice_in_a_glass.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Pineapple_Juice_fruits-465832.jpg/960px-Pineapple_Juice_fruits-465832.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Mango_juice_at_Agasi%2C_Lajpat_Nagar%2C_Delhi_%282025-10-04%29.jpg/960px-Mango_juice_at_Agasi%2C_Lajpat_Nagar%2C_Delhi_%282025-10-04%29.jpg}' where slug = 'nuoc-ep';
update public.dishes set gallery_urls = '{https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Ch%E1%BA%A3_c%C3%A1_L%C3%A3_V%E1%BB%8Dng_H%C3%A0_N%E1%BB%99i.jpg/960px-Ch%E1%BA%A3_c%C3%A1_L%C3%A3_V%E1%BB%8Dng_H%C3%A0_N%E1%BB%99i.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Ch%E1%BA%A3_c%C3%A1_t%E1%BA%A1i_Ph%E1%BB%91_ch%E1%BA%A3_c%C3%A1_H%C3%A0_N%E1%BB%99i.jpg/960px-Ch%E1%BA%A3_c%C3%A1_t%E1%BA%A1i_Ph%E1%BB%91_ch%E1%BA%A3_c%C3%A1_H%C3%A0_N%E1%BB%99i.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Grilled_fish_%40_Cha_Ca_La_Vong.jpg/960px-Grilled_fish_%40_Cha_Ca_La_Vong.jpg,https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Ch%E1%BA%A3_c%C3%A1_L%C3%A3_V%E1%BB%8Dng_H%C3%A0_N%E1%BB%99i_th%C3%A1ng_2_n%C4%83m_2018_%281%29.jpg/960px-Ch%E1%BA%A3_c%C3%A1_L%C3%A3_V%E1%BB%8Dng_H%C3%A0_N%E1%BB%99i_th%C3%A1ng_2_n%C4%83m_2018_%281%29.jpg}' where slug = 'cha-ca';
-- END dish gallery mirror
