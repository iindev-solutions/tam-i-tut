begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000501'),
	('00000000-0000-0000-0000-000000000502'),
	('00000000-0000-0000-0000-000000000503'),
	('00000000-0000-0000-0000-000000000504');

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000501', 'user', 'User', 'ru', true),
	('00000000-0000-0000-0000-000000000502', 'curator', 'Curator', 'ru', true),
	('00000000-0000-0000-0000-000000000503', 'moderator', 'Moderator', 'ru', true),
	('00000000-0000-0000-0000-000000000504', 'trusted_source', 'Trusted Source', 'ru', true);

insert into public.safety_cases (
	id,
	title,
	accused_label,
	scheme_summary,
	status,
	source_note,
	created_by_profile_id,
	reviewed_by_profile_id
)
values
	(
		'00000000-0000-0000-0000-000000005001',
		'Published safety case',
		'Known scammer',
		'Will be published after evidence insertion',
		'under_review',
		'team moderation note',
		'00000000-0000-0000-0000-000000000503',
		null
	),
	(
		'00000000-0000-0000-0000-000000005002',
		'Under-review safety case',
		'Suspicious actor',
		'Case pending publication',
		'under_review',
		'pending evidence review',
		'00000000-0000-0000-0000-000000000503',
		null
	);

insert into public.safety_case_evidence (
	id,
	safety_case_id,
	evidence_type,
	summary,
	source_url,
	submitted_by_profile_id
)
values
	(
		'00000000-0000-0000-0000-000000005101',
		'00000000-0000-0000-0000-000000005001',
		'document',
		'Published case evidence',
		'https://example.com/published',
		'00000000-0000-0000-0000-000000000503'
	),
	(
		'00000000-0000-0000-0000-000000005102',
		'00000000-0000-0000-0000-000000005002',
		'photo',
		'Under-review case evidence',
		'https://example.com/review',
		'00000000-0000-0000-0000-000000000503'
	);

update public.safety_cases
set status = 'published',
	reviewed_by_profile_id = '00000000-0000-0000-0000-000000000503'
where id = '00000000-0000-0000-0000-000000005001';

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

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000501';
select is(
	(select count(*) from public.safety_cases),
	1::bigint,
	'user can read published safety cases only'
);

select is(
	(select count(*) from public.safety_case_evidence),
	1::bigint,
	'user can read evidence for published safety cases only'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000504';
select is(
	(select count(*) from public.safety_cases),
	1::bigint,
	'trusted source can read published safety cases via authenticated read policy'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000502';
select is(
	(select count(*) from public.safety_cases),
	2::bigint,
	'curator can read all safety cases'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000501';
select is(
	pg_temp.exec_rows(
		$$
		update public.safety_cases
		set status = 'retracted'
		where id = '00000000-0000-0000-0000-000000005001'
		$$
	),
	0,
	'user cannot update safety case status'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000503';
select lives_ok(
	$$
	update public.safety_cases
	set status = 'published',
		reviewed_by_profile_id = '00000000-0000-0000-0000-000000000503'
	where id = '00000000-0000-0000-0000-000000005002'
	$$,
	'moderator can publish under-review case that has evidence'
);

select ok(
	(select published_at is not null from public.safety_cases where id = '00000000-0000-0000-0000-000000005002'),
	'published_at is set after moderator publish'
);

select lives_ok(
	$$
	insert into public.safety_cases (
		id,
		title,
		accused_label,
		scheme_summary,
		status,
		source_note,
		created_by_profile_id
	)
	values (
		'00000000-0000-0000-0000-000000005003',
		'Fresh under-review safety case',
		'Unknown actor',
		'Newly reported pattern',
		'under_review',
		'community report',
		'00000000-0000-0000-0000-000000000503'
	)
	$$,
	'moderator can create safety cases'
);

select is(
	(select count(*) from public.safety_cases),
	3::bigint,
	'moderator can read all safety cases including newly created row'
);

select * from finish();
rollback;
