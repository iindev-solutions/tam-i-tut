begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000401'),
	('00000000-0000-0000-0000-000000000402'),
	('00000000-0000-0000-0000-000000000403'),
	('00000000-0000-0000-0000-000000000404'),
	('00000000-0000-0000-0000-000000000405');

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000401', 'curator', 'Curator', 'ru', true),
	('00000000-0000-0000-0000-000000000402', 'moderator', 'Moderator', 'ru', true),
	('00000000-0000-0000-0000-000000000403', 'trusted_source', 'Trusted Source 1', 'ru', true),
	('00000000-0000-0000-0000-000000000404', 'trusted_source', 'Trusted Source 2', 'ru', true),
	('00000000-0000-0000-0000-000000000405', 'user', 'Owner', 'ru', true);

insert into public.guide_entries (
	id,
	category_slug,
	title,
	summary,
	language,
	status,
	trust_badge,
	under_review_note,
	owner_profile_id,
	created_by_profile_id,
	updated_by_profile_id,
	published_at
)
values
	(
		'00000000-0000-0000-0000-000000004001',
		'housing',
		'Entry One',
		'Published entry for confirmations',
		'ru',
		'published',
		'recommended_expats',
		null,
		'00000000-0000-0000-0000-000000000405',
		'00000000-0000-0000-0000-000000000402',
		'00000000-0000-0000-0000-000000000402',
		now()
	),
	(
		'00000000-0000-0000-0000-000000004002',
		'events',
		'Entry Two',
		'Second published entry for confirmations',
		'ru',
		'published',
		'recommended_expats',
		null,
		'00000000-0000-0000-0000-000000000405',
		'00000000-0000-0000-0000-000000000402',
		'00000000-0000-0000-0000-000000000402',
		now()
	);

insert into public.trusted_sources (
	id,
	profile_id,
	approved_by_profile_id,
	approved_at,
	is_active,
	notes
)
values
	(
		'00000000-0000-0000-0000-000000004101',
		'00000000-0000-0000-0000-000000000403',
		'00000000-0000-0000-0000-000000000402',
		now(),
		true,
		'ts1 approved'
	),
	(
		'00000000-0000-0000-0000-000000004102',
		'00000000-0000-0000-0000-000000000404',
		'00000000-0000-0000-0000-000000000402',
		now(),
		true,
		'ts2 approved'
	);

insert into public.source_confirmations (
	id,
	guide_entry_id,
	trusted_source_id,
	confirmation_note,
	confirmed_at,
	is_active
)
values
	(
		'00000000-0000-0000-0000-000000004201',
		'00000000-0000-0000-0000-000000004001',
		'00000000-0000-0000-0000-000000004101',
		'Initial confirmation by ts1',
		now(),
		true
	),
	(
		'00000000-0000-0000-0000-000000004202',
		'00000000-0000-0000-0000-000000004001',
		'00000000-0000-0000-0000-000000004102',
		'Initial confirmation by ts2',
		now(),
		true
	);

create or replace function pg_temp.exec_rows(sql text)
returns integer
language plpgsql
as $$
declare
	affected integer;
begin
	execute sql;
	get diagnostics affected = row_count;
	return affected;
end;
$$;

select plan(9);

set local role authenticated;

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000403';
select is(
	(select count(*) from public.source_confirmations),
	1::bigint,
	'trusted source can read only own confirmations'
);

select lives_ok(
	$$
	insert into public.source_confirmations (
		id,
		guide_entry_id,
		trusted_source_id,
		confirmation_note,
		is_active
	)
	values (
		'00000000-0000-0000-0000-000000004203',
		'00000000-0000-0000-0000-000000004002',
		'00000000-0000-0000-0000-000000004101',
		'TS1 own confirmation on entry two',
		true
	)
	$$,
	'trusted source can insert own confirmation'
);

select throws_like(
	$$
	insert into public.source_confirmations (
		id,
		guide_entry_id,
		trusted_source_id,
		confirmation_note,
		is_active
	)
	values (
		'00000000-0000-0000-0000-000000004204',
		'00000000-0000-0000-0000-000000004002',
		'00000000-0000-0000-0000-000000004102',
		'TS1 trying to write TS2 confirmation',
		true
	)
	$$,
	'%row-level security policy%',
	'trusted source cannot insert confirmations for another source id'
);

select lives_ok(
	$$
	update public.source_confirmations
	set confirmation_note = 'TS1 updated own confirmation note'
	where id = '00000000-0000-0000-0000-000000004201'
	$$,
	'trusted source can update own confirmation'
);

select is(
	pg_temp.exec_rows(
		$$
		update public.source_confirmations
		set confirmation_note = 'TS1 attempts to modify TS2 row'
		where id = '00000000-0000-0000-0000-000000004202'
		$$
	),
	0,
	'trusted source cannot update another source confirmation'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000401';
select is(
	(select count(*) from public.source_confirmations),
	3::bigint,
	'curator can read all confirmations'
);

select throws_like(
	$$
	insert into public.source_confirmations (
		id,
		guide_entry_id,
		trusted_source_id,
		confirmation_note,
		is_active
	)
	values (
		'00000000-0000-0000-0000-000000004205',
		'00000000-0000-0000-0000-000000004002',
		'00000000-0000-0000-0000-000000004101',
		'Curator should not insert source confirmations',
		true
	)
	$$,
	'%row-level security policy%',
	'curator cannot insert source confirmations'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000402';
select lives_ok(
	$$
	delete from public.source_confirmations
	where id = '00000000-0000-0000-0000-000000004202'
	$$,
	'moderator can delete any source confirmation'
);

select is(
	(select count(*) from public.source_confirmations),
	2::bigint,
	'moderator delete is reflected in confirmation rows'
);

select * from finish();
rollback;
