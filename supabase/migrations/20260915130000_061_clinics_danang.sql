-- Migration: 061_clinics_danang
-- Purpose: a city-scoped Da Nang clinic directory with prices.
--
-- The health category covered hospitals in one guide naming three venues and
-- no prices, while this is the highest-value gap for a newcomer who falls ill
-- abroad (see vault/logs/changelog.md, 2026-09-15 (3)).
--
-- PROVENANCE - READ BEFORE TRUSTING A PRICE
-- Every row below was transcribed 2026-09-15 from a single third-party guide
-- (vietnamspot.ru, itself advertising a paid medical-translator service). That
-- source's own claims were NOT reliable: it describes 112 as "a single SOS
-- number like 911" (it is search and rescue) and lists an uncorroboratable
-- national tourist-police number. So these prices are LEADS, not facts.
--
-- Therefore every row lands as trust_badge = 'under_review' with
-- last_verified_at = null and keeps its `source` string, and the UI renders the
-- level plus the source line. Promotion to a trusted level happens only after
-- someone verifies on site (the same gates that apply to guides and places).
-- Two of these venues ARE independently corroborated (Family Medical Practice
-- and Vinmec, seen in a second source) but are not promoted here, because the
-- corroboration covers the venue, not the price.
--
-- Only the neutral facts travel: venue name, specialisation, 24/7 flag and the
-- price as quoted. The source's editorial one-liners ("неоправданно дорого",
-- "долго, грустно, грязно") are deliberately NOT reproduced - they are opinion
-- and third-party expression, and this repository is public.

create table if not exists public.clinics (
	id uuid primary key default gen_random_uuid(),
	city_slug text not null references public.cities (slug) on delete cascade,
	slug text not null,
	kind text not null,
	open_24_7 boolean not null default false,
	trust_badge public.trust_badge not null default 'under_review',
	last_verified_at timestamptz,
	-- Where the row came from. Kept on the row, not in a doc, so the UI can
	-- always show it next to the price it applies to.
	source text not null,
	sort_order smallint not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint clinics_slug_not_empty check (btrim(slug) <> ''),
	constraint clinics_source_not_empty check (btrim(source) <> ''),
	constraint clinics_kind_valid check (kind in (
		'hospital', 'dental', 'ophthalmology', 'dermatology',
		'diagnostics', 'oncology', 'ent', 'veterinary'
	)),
	constraint clinics_slug_unique_per_city unique (city_slug, slug),
	constraint clinics_city_sort_unique unique (city_slug, sort_order),
	-- Same rule as places (058): a trusted row must carry when it was checked.
	constraint clinics_trust_requires_verified_at check (
		trust_badge = 'under_review' or last_verified_at is not null
	)
);

create table if not exists public.clinic_localizations (
	clinic_id uuid not null references public.clinics (id) on delete cascade,
	language public.language_code not null,
	name text not null,
	-- The quoted price note is localized because its qualifiers are
	-- ("с переводчиком" / "без"), while the figures are not.
	price_note text not null default '',
	constraint clinic_localizations_pk primary key (clinic_id, language),
	constraint clinic_localizations_name_not_empty check (btrim(name) <> '')
);

create index if not exists clinics_city_kind_idx
	on public.clinics (city_slug, kind, sort_order);

alter table public.clinics enable row level security;
alter table public.clinic_localizations enable row level security;

-- Read: authenticated users see clinics of ACTIVE cities only (same posture as
-- districts 024 and emergency_contacts 058).
drop policy if exists clinics__authenticated__select_active_city on public.clinics;
create policy clinics__authenticated__select_active_city
on public.clinics
for select
using (
	app_private.is_authenticated()
	and exists (
		select 1
		from public.cities c
		where c.slug = city_slug
			and c.is_active = true
	)
);

drop policy if exists clinic_localizations__authenticated__select_active_city on public.clinic_localizations;
create policy clinic_localizations__authenticated__select_active_city
on public.clinic_localizations
for select
using (
	app_private.is_authenticated()
	and exists (
		select 1
		from public.clinics cl
		join public.cities c on c.slug = cl.city_slug
		where cl.id = clinic_id
			and c.is_active = true
	)
);

-- Write: moderator/admin manage the directory.
drop policy if exists clinics__moderator_admin__all on public.clinics;
create policy clinics__moderator_admin__all
on public.clinics
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

drop policy if exists clinic_localizations__moderator_admin__all on public.clinic_localizations;
create policy clinic_localizations__moderator_admin__all
on public.clinic_localizations
for all
using (
	app_private.is_moderator_or_admin()
)
with check (
	app_private.is_moderator_or_admin()
);

-- Seed: 20 Da Nang venues. `source` is identical on every row on purpose - it
-- is the honest answer to "where did this price come from".
insert into public.clinics (id, city_slug, slug, kind, open_24_7, source, sort_order)
values
	('c1a00000-0000-4000-8000-000000000001', 'da-nang', 'hoan-my', 'hospital', true, 'vietnamspot.ru, 2026-09-15', 1),
	('c1a00000-0000-4000-8000-000000000002', 'da-nang', 'thien-nhan', 'hospital', false, 'vietnamspot.ru, 2026-09-15', 2),
	('c1a00000-0000-4000-8000-000000000003', 'da-nang', 'tam-tri', 'hospital', true, 'vietnamspot.ru, 2026-09-15', 3),
	('c1a00000-0000-4000-8000-000000000004', 'da-nang', 'phan-chau-trinh', 'hospital', true, 'vietnamspot.ru, 2026-09-15', 4),
	('c1a00000-0000-4000-8000-000000000005', 'da-nang', 'vinmec', 'hospital', true, 'vietnamspot.ru, 2026-09-15', 5),
	('c1a00000-0000-4000-8000-000000000006', 'da-nang', 'family-hospital', 'hospital', true, 'vietnamspot.ru, 2026-09-15', 6),
	('c1a00000-0000-4000-8000-000000000007', 'da-nang', '199-hospital', 'hospital', true, 'vietnamspot.ru, 2026-09-15', 7),
	('c1a00000-0000-4000-8000-000000000008', 'da-nang', 'da-nang-hospital', 'hospital', true, 'vietnamspot.ru, 2026-09-15', 8),
	('c1a00000-0000-4000-8000-000000000009', 'da-nang', 'mat-sai-gon-song-han', 'ophthalmology', false, 'vietnamspot.ru, 2026-09-15', 9),
	('c1a00000-0000-4000-8000-000000000010', 'da-nang', 'mat-vo-viet-hien', 'ophthalmology', false, 'vietnamspot.ru, 2026-09-15', 10),
	('c1a00000-0000-4000-8000-000000000011', 'da-nang', 'mat-viet-an', 'ophthalmology', false, 'vietnamspot.ru, 2026-09-15', 11),
	('c1a00000-0000-4000-8000-000000000012', 'da-nang', 'da-nang-dermatology', 'dermatology', false, 'vietnamspot.ru, 2026-09-15', 12),
	('c1a00000-0000-4000-8000-000000000013', 'da-nang', 'akina-da-lieu', 'dermatology', false, 'vietnamspot.ru, 2026-09-15', 13),
	('c1a00000-0000-4000-8000-000000000014', 'da-nang', 'hi-lab', 'diagnostics', false, 'vietnamspot.ru, 2026-09-15', 14),
	('c1a00000-0000-4000-8000-000000000015', 'da-nang', 'medilab', 'diagnostics', false, 'vietnamspot.ru, 2026-09-15', 15),
	('c1a00000-0000-4000-8000-000000000016', 'da-nang', 'da-nang-oncology', 'oncology', true, 'vietnamspot.ru, 2026-09-15', 16),
	('c1a00000-0000-4000-8000-000000000017', 'da-nang', 'nha-khoa-peace', 'dental', false, 'vietnamspot.ru, 2026-09-15', 17),
	('c1a00000-0000-4000-8000-000000000018', 'da-nang', 'lotus-smile-dental', 'dental', false, 'vietnamspot.ru, 2026-09-15', 18),
	('c1a00000-0000-4000-8000-000000000019', 'da-nang', 'tai-mui-hong-nguyen-trung-nghia', 'ent', false, 'vietnamspot.ru, 2026-09-15', 19),
	('c1a00000-0000-4000-8000-000000000020', 'da-nang', 'paws-international', 'veterinary', false, 'vietnamspot.ru, 2026-09-15', 20)
on conflict (id) do update
set
	kind = excluded.kind,
	open_24_7 = excluded.open_24_7,
	source = excluded.source,
	sort_order = excluded.sort_order,
	updated_at = now();

insert into public.clinic_localizations (clinic_id, language, name, price_note)
values
	('c1a00000-0000-4000-8000-000000000001', 'ru', 'Hoan My Da Nang Hospital', 'Приём терапевта 418 000 ₫'),
	('c1a00000-0000-4000-8000-000000000001', 'en', 'Hoan My Da Nang Hospital', 'GP visit 418,000 ₫'),
	('c1a00000-0000-4000-8000-000000000002', 'ru', 'Thiện Nhân Hospital', 'Приём терапевта 165 000 ₫ с переводчиком · 350 000 ₫ без'),
	('c1a00000-0000-4000-8000-000000000002', 'en', 'Thiện Nhân Hospital', 'GP visit 165,000 ₫ with a translator · 350,000 ₫ without'),
	('c1a00000-0000-4000-8000-000000000003', 'ru', 'Bệnh viện Đa khoa Tâm Trí Đà Nẵng', 'Приём терапевта 85 000 ₫ с переводчиком · 200 000 ₫ без'),
	('c1a00000-0000-4000-8000-000000000003', 'en', 'Bệnh viện Đa khoa Tâm Trí Đà Nẵng', 'GP visit 85,000 ₫ with a translator · 200,000 ₫ without'),
	('c1a00000-0000-4000-8000-000000000004', 'ru', 'Bệnh Viện Đại học Y khoa Phan Châu Trinh', 'Приём терапевта 66 000 ₫'),
	('c1a00000-0000-4000-8000-000000000004', 'en', 'Bệnh Viện Đại học Y khoa Phan Châu Trinh', 'GP visit 66,000 ₫'),
	('c1a00000-0000-4000-8000-000000000005', 'ru', 'Vinmec Da Nang International Hospital', 'Приём терапевта 690 000 ₫ с записью · 1 100 000 ₫ без записи'),
	('c1a00000-0000-4000-8000-000000000005', 'en', 'Vinmec Da Nang International Hospital', 'GP visit 690,000 ₫ booked · 1,100,000 ₫ walk-in'),
	('c1a00000-0000-4000-8000-000000000006', 'ru', 'Family Hospital', 'Регистрационный сбор отсутствует, стоимость зависит от услуги. Есть репродукция'),
	('c1a00000-0000-4000-8000-000000000006', 'en', 'Family Hospital', 'No registration fee, cost depends on the service. Fertility services available'),
	('c1a00000-0000-4000-8000-000000000007', 'ru', '199 Hospital', 'Регистрационный сбор отсутствует, стоимость зависит от услуги'),
	('c1a00000-0000-4000-8000-000000000007', 'en', '199 Hospital', 'No registration fee, cost depends on the service'),
	('c1a00000-0000-4000-8000-000000000008', 'ru', 'Da Nang Hospital', 'Приём терапевта 120 000 ₫'),
	('c1a00000-0000-4000-8000-000000000008', 'en', 'Da Nang Hospital', 'GP visit 120,000 ₫'),
	('c1a00000-0000-4000-8000-000000000009', 'ru', 'Bệnh viện Mắt Sài Gòn Sông Hàn', 'Первичный осмотр офтальмолога + проверка зрения 213 000 ₫'),
	('c1a00000-0000-4000-8000-000000000009', 'en', 'Bệnh viện Mắt Sài Gòn Sông Hàn', 'First ophthalmologist visit + eye test 213,000 ₫'),
	('c1a00000-0000-4000-8000-000000000010', 'ru', 'Phòng khám Mắt Bác sĩ Võ Việt Hiền', 'Приём офтальмолога 120 000 – 190 000 ₫'),
	('c1a00000-0000-4000-8000-000000000010', 'en', 'Phòng khám Mắt Bác sĩ Võ Việt Hiền', 'Ophthalmologist visit 120,000 – 190,000 ₫'),
	('c1a00000-0000-4000-8000-000000000011', 'ru', 'Bệnh Viện Mắt Việt An Đà Nẵng', 'Приём офтальмолога 500 000 ₫'),
	('c1a00000-0000-4000-8000-000000000011', 'en', 'Bệnh Viện Mắt Việt An Đà Nẵng', 'Ophthalmologist visit 500,000 ₫'),
	('c1a00000-0000-4000-8000-000000000012', 'ru', 'Da Nang Dermatology & Venereology Hospital', 'Приём дерматолога 250 000 ₫'),
	('c1a00000-0000-4000-8000-000000000012', 'en', 'Da Nang Dermatology & Venereology Hospital', 'Dermatologist visit 250,000 ₫'),
	('c1a00000-0000-4000-8000-000000000013', 'ru', 'AKINA - Phòng khám da liễu Cao Nguyên', 'Приём дерматолога 100 000 ₫, далее зависит от состояния кожи'),
	('c1a00000-0000-4000-8000-000000000013', 'en', 'AKINA - Phòng khám da liễu Cao Nguyên', 'Dermatologist visit 100,000 ₫, then depends on the condition'),
	('c1a00000-0000-4000-8000-000000000014', 'ru', 'Xét nghiệm y khoa Hi-Lab', 'Общий анализ крови: зависит от вида анализа'),
	('c1a00000-0000-4000-8000-000000000014', 'en', 'Xét nghiệm y khoa Hi-Lab', 'Blood test: depends on the type of test'),
	('c1a00000-0000-4000-8000-000000000015', 'ru', 'Medilab Blood Testing', 'Общий анализ крови 50 000 ₫ в составе чек-апа'),
	('c1a00000-0000-4000-8000-000000000015', 'en', 'Medilab Blood Testing', 'Blood test 50,000 ₫ as part of a check-up package'),
	('c1a00000-0000-4000-8000-000000000016', 'ru', 'Da Nang Oncology Hospital', 'Приём 50 000 – 200 000 ₫. Химиотерапия, хирургия, диагностика рака'),
	('c1a00000-0000-4000-8000-000000000016', 'en', 'Da Nang Oncology Hospital', 'Visit 50,000 – 200,000 ₫. Chemotherapy, surgery, cancer diagnostics'),
	('c1a00000-0000-4000-8000-000000000017', 'ru', 'Nha Khoa Peace Đà Nẵng', 'Пломба 300 000 – 450 000 ₫'),
	('c1a00000-0000-4000-8000-000000000017', 'en', 'Nha Khoa Peace Đà Nẵng', 'Filling 300,000 – 450,000 ₫'),
	('c1a00000-0000-4000-8000-000000000018', 'ru', 'Lotus Smile Dental', 'Пломба около 1 000 000 ₫'),
	('c1a00000-0000-4000-8000-000000000018', 'en', 'Lotus Smile Dental', 'Filling around 1,000,000 ₫'),
	('c1a00000-0000-4000-8000-000000000019', 'ru', 'Phòng khám Tai Mũi Họng Nguyễn Trung Nghĩa', 'Приём ЛОРа 300 000 ₫'),
	('c1a00000-0000-4000-8000-000000000019', 'en', 'Phòng khám Tai Mũi Họng Nguyễn Trung Nghĩa', 'ENT visit 300,000 ₫'),
	('c1a00000-0000-4000-8000-000000000020', 'ru', 'PAWS International Clinic Da Nang', 'Консультация 90 000 – 300 000 ₫ / расширенная 450 000 – 550 000 ₫'),
	('c1a00000-0000-4000-8000-000000000020', 'en', 'PAWS International Clinic Da Nang', 'Consultation 90,000 – 300,000 ₫ / extended 450,000 – 550,000 ₫')
on conflict (clinic_id, language) do update
set
	name = excluded.name,
	price_note = excluded.price_note;
