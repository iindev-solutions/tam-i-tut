-- Migration: 057_fpt_city_prices
-- Purpose: founder fact-check - FPT City studios/duplexes rent from ~4M VND,
-- not the 6-12M range the district card claimed.

update public.district_localizations dl
set rent_range = 'студии и дюплексы от 4 млн ₫',
	summary = 'Современный квартал вокруг FPT University: новые дома, студенты и айтишники. Студии и дюплексы от 4 млн ₫ - редкое для города сочетание новизны и цены. Спокойно, зелено, своя инфраструктура; до моря 5 минут пешком.'
from public.districts d
where d.id = dl.district_id and d.slug = 'fpt-city' and dl.language = 'ru';

update public.district_localizations dl
set rent_range = 'studios and duplexes from 4M VND',
	summary = 'A modern quarter around FPT University: new buildings, students and IT folks. Studios and duplexes from 4M VND - a rare price-to-newness combination for this city. Calm, green, with its own infrastructure; the beach is a 5-minute walk.'
from public.districts d
where d.id = dl.district_id and d.slug = 'fpt-city' and dl.language = 'en';
