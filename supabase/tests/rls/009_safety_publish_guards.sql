begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000901'),
	('00000000-0000-0000-0000-000000000902');

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000901', 'moderator', 'Moderator', 'ru', true),
	('00000000-0000-0000-0000-000000000902', 'user', 'Reporter', 'ru', true);

select plan(10);

set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000901';

select throws_ok(
	$$
	insert into public.safety_cases (
		id,
		title,
		accused_label,
		scheme_summary,
		status,
		source_note,
		published_at,
		created_by_profile_id,
		reviewed_by_profile_id
	)
	values (
		'00000000-0000-0000-0000-000000009001',
		'Illegal direct publish',
		'Bad actor',
		'Should fail before insert',
		'published',
		'direct publish attempt',
		now(),
		'00000000-0000-0000-0000-000000000901',
		'00000000-0000-0000-0000-000000000901'
	)
	$$,
	'safety case cannot be inserted as published before evidence review',
	'inserting safety case directly as published is blocked'
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
		'00000000-0000-0000-0000-000000009002',
		'Under-review case',
		'Suspicious identity',
		'Case starts under review',
		'under_review',
		'initial moderator report',
		'00000000-0000-0000-0000-000000000901'
	)
	$$,
	'moderator can create safety case in under_review state'
);

select throws_ok(
	$$
	update public.safety_cases
	set status = 'published',
		reviewed_by_profile_id = '00000000-0000-0000-0000-000000000901'
	where id = '00000000-0000-0000-0000-000000009002'
	$$,
	'publishing safety case requires >= 1 evidence record',
	'publishing without evidence is blocked'
);

select lives_ok(
	$$
	insert into public.safety_case_evidence (
		id,
		safety_case_id,
		evidence_type,
		summary,
		source_url,
		submitted_by_profile_id
	)
	values (
		'00000000-0000-0000-0000-000000009101',
		'00000000-0000-0000-0000-000000009002',
		'document',
		'Evidence for publish transition',
		'https://example.com/safety-evidence',
		'00000000-0000-0000-0000-000000000901'
	)
	$$,
	'moderator can add safety case evidence'
);

select lives_ok(
	$$
	update public.safety_cases
	set status = 'published',
		reviewed_by_profile_id = '00000000-0000-0000-0000-000000000901'
	where id = '00000000-0000-0000-0000-000000009002'
	$$,
	'publishing succeeds once evidence exists'
);

select ok(
	(
		select published_at is not null
		from public.safety_cases
		where id = '00000000-0000-0000-0000-000000009002'
	),
	'published_at is auto-populated when case is published'
);

select is(
	(
		select count(*)
		from public.audit_logs
		where entity_table = 'safety_cases'
			and entity_id = '00000000-0000-0000-0000-000000009002'
			and action_type = 'safety_cases.status_changed'
	),
	1::bigint,
	'publish transition writes one safety status audit log row'
);

select lives_ok(
	$$
	update public.safety_cases
	set status = 'retracted',
		reviewed_by_profile_id = '00000000-0000-0000-0000-000000000901'
	where id = '00000000-0000-0000-0000-000000009002'
	$$,
	'moderator can retract a published safety case'
);

select ok(
	(
		select retracted_at is not null
		from public.safety_cases
		where id = '00000000-0000-0000-0000-000000009002'
	),
	'retracted_at is auto-populated on retract transition'
);

select is(
	(
		select count(*)
		from public.audit_logs
		where entity_table = 'safety_cases'
			and entity_id = '00000000-0000-0000-0000-000000009002'
			and action_type = 'safety_cases.status_changed'
	),
	2::bigint,
	'publish and retract transitions write two safety status audit rows'
);

select * from finish();
rollback;
