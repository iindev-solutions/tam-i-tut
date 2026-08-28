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
