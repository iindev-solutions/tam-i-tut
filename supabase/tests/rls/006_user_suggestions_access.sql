begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000601'),
	('00000000-0000-0000-0000-000000000602'),
	('00000000-0000-0000-0000-000000000603'),
	('00000000-0000-0000-0000-000000000604');

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000601', 'user', 'User One', 'ru', true),
	('00000000-0000-0000-0000-000000000602', 'user', 'User Two', 'ru', true),
	('00000000-0000-0000-0000-000000000603', 'curator', 'Curator', 'ru', true),
	('00000000-0000-0000-0000-000000000604', 'moderator', 'Moderator', 'ru', true);

insert into public.user_suggestions (
	id,
	submitted_by_profile_id,
	category_slug,
	language,
	title,
	description,
	status,
	reviewer_profile_id,
	linked_guide_entry_id,
	resolved_at
)
values
	(
		'00000000-0000-0000-0000-000000006001',
		'00000000-0000-0000-0000-000000000601',
		'housing',
		'ru',
		'User one suggestion',
		'First user suggestion',
		'new',
		null,
		null,
		null
	),
	(
		'00000000-0000-0000-0000-000000006002',
		'00000000-0000-0000-0000-000000000602',
		'food',
		'ru',
		'User two suggestion',
		'Second user suggestion',
		'new',
		null,
		null,
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

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000601';
select is(
	(select count(*) from public.user_suggestions),
	1::bigint,
	'user sees only own suggestions'
);

select lives_ok(
	$$
	insert into public.user_suggestions (
		id,
		submitted_by_profile_id,
		category_slug,
		language,
		title,
		description,
		status,
		reviewer_profile_id,
		linked_guide_entry_id,
		resolved_at
	)
	values (
		'00000000-0000-0000-0000-000000006003',
		'00000000-0000-0000-0000-000000000601',
		'transport',
		'ru',
		'User one new idea',
		'Insert allowed only in new status',
		'new',
		null,
		null,
		null
	)
	$$,
	'user can insert own new suggestion'
);

select throws_like(
	$$
	update public.user_suggestions
	set status = 'triaged'
	where id = '00000000-0000-0000-0000-000000006001'
	$$,
	'%row-level security policy%',
	'user cannot triage own suggestion'
);

select is(
	pg_temp.exec_rows(
		$$
		update public.user_suggestions
		set title = 'Unauthorized edit'
		where id = '00000000-0000-0000-0000-000000006002'
		$$
	),
	0,
	'user cannot update another user suggestion'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000603';
select is(
	(select count(*) from public.user_suggestions),
	3::bigint,
	'curator can read all suggestions'
);

select lives_ok(
	$$
	update public.user_suggestions
	set status = 'triaged',
		reviewer_profile_id = '00000000-0000-0000-0000-000000000603',
		review_notes = 'Curator triage complete'
	where id = '00000000-0000-0000-0000-000000006001'
	$$,
	'curator can triage suggestion when reviewer is self'
);

select throws_like(
	$$
	update public.user_suggestions
	set status = 'triaged',
		reviewer_profile_id = '00000000-0000-0000-0000-000000000601'
	where id = '00000000-0000-0000-0000-000000006002'
	$$,
	'%row-level security policy%',
	'curator cannot set reviewer_profile_id to another user'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000604';
select lives_ok(
	$$
	delete from public.user_suggestions
	where id = '00000000-0000-0000-0000-000000006002'
	$$,
	'moderator can delete suggestions'
);

select is(
	(select count(*) from public.user_suggestions),
	2::bigint,
	'moderator delete is reflected in suggestion rows'
);

select * from finish();
rollback;
