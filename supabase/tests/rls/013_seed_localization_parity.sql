-- 013_seed_localization_parity.sql
-- Content-integrity suite (not an RLS test; lives here because the CI pgTAP
-- runner iterates supabase/tests/rls/*.sql).
-- Invariant: every place visible to an authenticated reader (published, in an
-- active city) carries exactly one ru and one en localization. This is the
-- rows-per-language contract the UI's LocalizedText mapping relies on; a
-- missing or extra language row would render an empty card or duplicated
-- content. Runs after db reset (migrations + seed.sql), so it also proves the
-- seed loaded non-empty. All assertions are global but rely on each suite's
-- fixtures being rolled back, so only migration+seed rows exist here.

begin;

insert into auth.users (id)
values ('00000000-0000-0000-0000-000000000311');

insert into public.profiles (id, role, display_name, locale, is_active)
values ('00000000-0000-0000-0000-000000000311', 'user', 'Parity Reader', 'ru', true);

select plan(4);

set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000311';

-- Sanity: the seeded content actually loaded.
select isnt(
	(select count(*) from public.places),
	0::bigint,
	'seed content is present (published places visible)'
);

-- Every visible place has an ru localization.
select is(
	(select count(*) from public.places p
	 where not exists (
		select 1 from public.place_localizations l
		where l.place_id = p.id and l.language = 'ru'
	 )),
	0::bigint,
	'every visible place has an ru localization'
);

-- Every visible place has an en localization.
select is(
	(select count(*) from public.places p
	 where not exists (
		select 1 from public.place_localizations l
		where l.place_id = p.id and l.language = 'en'
	 )),
	0::bigint,
	'every visible place has an en localization'
);

-- No place has extra/duplicate localization rows (PK allows one row per
-- language, so anything other than exactly 2 rows is a bug).
select is(
	(select count(*) from (
		select place_id from public.place_localizations
		group by place_id
		having count(*) <> 2
	) bad),
	0::bigint,
	'every visible place has exactly two localizations (ru+en)'
);

select * from finish();
rollback;
