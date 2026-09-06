-- Migration: 054_far_districts
-- Purpose: founder request - the far districts belong on the housing map:
-- Hòa Vang (the rural west/south, incl. Hòa Phước/Hòa Tiến communes) and the
-- FPT City quarter (Hòa Quý/Hòa Hải, around FPT University) where many expats
-- rent. Polygons are hand-drawn to fill the empty areas around the existing
-- six districts without overlapping them.

insert into public.districts (id, city_slug, slug, sort_order, price_level, geometry)
values
	('00000000-0000-0000-0000-000000000610', 'da-nang', 'hoa-vang', 7, 'budget',
	 st_geomfromgeojson('{"type":"Polygon","coordinates":[[[107.980,16.200],[108.100,16.200],[108.100,16.055],[108.150,15.988],[108.234,15.988],[108.234,15.940],[107.980,15.940],[107.980,16.200]]]}')),
	('00000000-0000-0000-0000-000000000611', 'da-nang', 'fpt-city', 8, 'average',
	 st_geomfromgeojson('{"type":"Polygon","coordinates":[[[108.238,16.018],[108.251,16.005],[108.270,15.995],[108.283,15.988],[108.283,15.955],[108.238,15.955],[108.238,16.018]]]}'))
on conflict (city_slug, slug) do nothing;

insert into public.district_localizations (district_id, language, name, area, rent_range, distance_to_beach, summary, best_for)
values
	('00000000-0000-0000-0000-000000000610', 'ru', 'Хоа Ванг', 'запад и юг за городской чертой', '3-6 млн ₫', '10-25 мин на байке',
	 'Сельская часть Дананга: рисовые поля, деревенская тишина, самые низкие цены. Южные коммуны у моря (Хоа Фуок, Хоа Тьен) - тихая жизнь у пляжа без туристической суеты. До центра 20-40 минут, нужен свой байк.', '{quiet,budget}'),
	('00000000-0000-0000-0000-000000000610', 'en', 'Hoa Vang', 'west and south beyond the city', '3-6M VND', '10-25 min by bike',
	 'The rural side of Da Nang: rice fields, village quiet, the lowest prices around. Southern coastal communes (Hoa Phuoc, Hoa Tien) offer beach life without the tourist noise. 20-40 minutes to the center - you want your own bike here.', '{quiet,budget}'),
	('00000000-0000-0000-0000-000000000611', 'ru', 'FPT City', 'юго-восток, квартал у FPT University', '6-12 млн ₫', '5 мин пешком до моря',
	 'Современный квартал вокруг FPT University: новые дома и квартиры, студенты и айтишники, недорогие комнаты и апарты. Спокойно, зелено, своя инфраструктура - хороший компромисс между ценой и новизной.', '{budget,quiet,expat}'),
	('00000000-0000-0000-0000-000000000611', 'en', 'FPT City', 'south-east, the FPT University quarter', '6-12M VND', '5 min walk to the beach',
	 'A modern quarter around FPT University: new buildings, students and IT crowd, affordable rooms and apartments. Calm, green, with its own infrastructure - a good price-to-newness compromise.', '{budget,quiet,expat}')
on conflict (district_id, language) do update
set name = excluded.name, area = excluded.area, rent_range = excluded.rent_range,
	distance_to_beach = excluded.distance_to_beach, summary = excluded.summary, best_for = excluded.best_for;
