begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000201'),
	('00000000-0000-0000-0000-000000000202'),
	('00000000-0000-0000-0000-000000000203'),
	('00000000-0000-0000-0000-000000000204'),
	('00000000-0000-0000-0000-000000000205');

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000201', 'user', 'User', 'ru', true),
	('00000000-0000-0000-0000-000000000202', 'curator', 'Curator', 'ru', true),
	('00000000-0000-0000-0000-000000000203', 'moderator', 'Moderator', 'ru', true),
	('00000000-0000-0000-0000-000000000204', 'admin', 'Admin', 'ru', true),
	('00000000-0000-0000-0000-000000000205', 'user', 'Other User', 'ru', true);

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
		'00000000-0000-0000-0000-000000002001',
		'housing',
		'Published Entry',
		'Visible to authenticated users',
		'ru',
		'published',
		'recommended_expats',
		null,
		'00000000-0000-0000-0000-000000000205',
		'00000000-0000-0000-0000-000000000203',
		'00000000-0000-0000-0000-000000000203',
		now()
	),
	(
		'00000000-0000-0000-0000-000000002002',
		'food',
		'Curator Draft Entry',
		'Owned by curator',
		'ru',
		'draft',
		'under_review',
		'pending evidence',
		'00000000-0000-0000-0000-000000000202',
		'00000000-0000-0000-0000-000000000202',
		'00000000-0000-0000-0000-000000000202',
		null
	),
	(
		'00000000-0000-0000-0000-000000002003',
		'events',
		'Other Draft Entry',
		'Not owned by curator',
		'ru',
		'draft',
		'under_review',
		'pending review',
		'00000000-0000-0000-0000-000000000205',
		'00000000-0000-0000-0000-000000000205',
		'00000000-0000-0000-0000-000000000205',
		null
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

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000201';
select is(
	(select count(*) from public.guide_entries),
	1::bigint,
	'user can read published entries only'
);

select throws_like(
	$$
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
		updated_by_profile_id
	)
	values (
		'00000000-0000-0000-0000-000000002010',
		'transport',
		'User Draft',
		'User should not be able to insert',
		'ru',
		'draft',
		'under_review',
		'needs curation',
		'00000000-0000-0000-0000-000000000201',
		'00000000-0000-0000-0000-000000000201',
		'00000000-0000-0000-0000-000000000201'
	)
	$$,
	'%row-level security policy%',
	'user cannot insert guide entries'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000202';
select is(
	(select count(*) from public.guide_entries),
	2::bigint,
	'curator can read published entries plus own drafts'
);

select lives_ok(
	$$
	update public.guide_entries
	set summary = 'Curator draft updated summary'
	where id = '00000000-0000-0000-0000-000000002002'
	$$,
	'curator can update own draft entry'
);

select throws_like(
	$$
	update public.guide_entries
	set trust_badge = 'recommended_expats',
		under_review_note = null
	where id = '00000000-0000-0000-0000-000000002002'
	$$,
	'%recommended_expats requires >= 3 active trusted-source confirmations%',
	'curator trust badge escalation is blocked by transition guard'
);

select is(
	pg_temp.exec_rows(
		$$
		update public.guide_entries
		set summary = 'Attempt update of foreign draft'
		where id = '00000000-0000-0000-0000-000000002003'
		$$
	),
	0,
	'curator cannot update draft they do not own'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000203';
select is(
	(select count(*) from public.guide_entries),
	3::bigint,
	'moderator can read all guide entries'
);

select lives_ok(
	$$
	delete from public.guide_entries
	where id = '00000000-0000-0000-0000-000000002003'
	$$,
	'moderator can delete any guide entry'
);

select is(
	(select count(*) from public.guide_entries),
	2::bigint,
	'moderator delete is reflected in visible rows'
);

select * from finish();
rollback;
