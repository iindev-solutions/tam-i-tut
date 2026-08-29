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
