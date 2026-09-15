-- Migration: 059_emergency_contacts_seed
-- Purpose: seed the Da Nang emergency numbers.
--
-- Migration 058 created the table, but `supabase db push` applies migrations
-- only and never runs seed.sql, so the table stayed empty on the hosted pilot
-- while the safety page read from it. Content seeds follow the same route as
-- the knowledge passes (043-046): an idempotent insert in a migration, mirrored
-- in seed.sql for fresh stacks.
--
-- Vietnam: 113 police, 114 fire, 115 ambulance. Country-level numbers, so they
-- are attached to the city row that carries the tenancy axis.

insert into public.emergency_contacts (city_slug, number, label_ru, label_en, sort_order)
values
	('da-nang', '113', 'Полиция', 'Police', 1),
	('da-nang', '114', 'Пожарная служба', 'Fire department', 2),
	('da-nang', '115', 'Скорая помощь', 'Ambulance', 3)
on conflict (city_slug, sort_order) do update
set
	number = excluded.number,
	label_ru = excluded.label_ru,
	label_en = excluded.label_en;
