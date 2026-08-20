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
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0a', 'da-nang', 'an-thuong-street', 'street', 'budget', false, 'published')
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
	('b937c18f-2b7e-4a5a-8f3d-9a1c5d6e7f0a', 'en', 'An Thượng food street', 'Son Tra, An Thuong street', 'Pedestrian food street two blocks from the sea: grills, smoothies, late-night coffee.')
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
