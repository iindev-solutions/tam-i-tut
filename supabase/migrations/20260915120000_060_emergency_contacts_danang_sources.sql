-- Migration: 060_emergency_contacts_danang_sources
-- Purpose: complete the Da Nang emergency set with cross-source-verified numbers
-- and fix a factual error the safety page shipped.
--
-- Provenance (research pass 2026-09-15; every row below is corroborated by at
-- least two independent sources, and the consulate by the official MFA site):
--
--   112  search and rescue - maritime, mountain, jungle, disasters, missing
--        persons. Corroborated: vietnamkb.com (table + "at sea" section),
--        vietnamvisacorp.com, entryvn.com. NOTE: a competing guide describes
--        112 as a "single SOS number that works like 911" - that is wrong and
--        is exactly the kind of claim this project must not repeat, so the
--        label here names the actual service.
--   0236 355 0111  Da Nang tourism support line, English-speaking, 24/7.
--        Corroborated: vietnamkb.com ("Da Nang tourism support") and
--        vietnamspot.ru (same number as the city round-the-clock line).
--
-- Deliberately NOT added: the competitor lists 1039 as a national "tourist
-- police" number. It could not be corroborated - the independent source gives
-- only city-specific tourist-police numbers (Hanoi, HCMC, Hoi An, Nha Trang)
-- and does not mention 1039 at all. Publishing an unverified emergency number
-- is worse than omitting it: a user would dial it in a crisis.
--
-- The consulate correction (22 Tran Phu, not Tran Hung Dao) lives in the i18n
-- copy because the safety page renders it as a static note; see the changelog
-- entry for the same date.

insert into public.emergency_contacts (city_slug, number, label_ru, label_en, sort_order)
values
	('da-nang', '112', 'Поиск и спасение', 'Search and rescue', 4),
	('da-nang', '0236 355 0111', 'Туристическая поддержка', 'Tourism support', 5)
on conflict (city_slug, sort_order) do update
set
	number = excluded.number,
	label_ru = excluded.label_ru,
	label_en = excluded.label_en;
