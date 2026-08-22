begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000701'),
	('00000000-0000-0000-0000-000000000702'),
	('00000000-0000-0000-0000-000000000703'),
	('00000000-0000-0000-0000-000000000704');

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000701', 'moderator', 'Moderator One', 'ru', true),
	('00000000-0000-0000-0000-000000000702', 'moderator', 'Moderator Two', 'ru', true),
	('00000000-0000-0000-0000-000000000703', 'admin', 'Admin', 'ru', true),
	('00000000-0000-0000-0000-000000000704', 'user', 'User', 'ru', true);

insert into public.audit_logs (
	actor_profile_id,
	actor_role,
	action_type,
	entity_table,
	entity_id,
	before_state,
	after_state,
	metadata
)
values
	(
		'00000000-0000-0000-0000-000000000701',
		'moderator',
		'moderator.one.action',
		'guide_entries',
		'00000000-0000-0000-0000-000000007001',
		null,
		null,
		'{}'::jsonb
	),
	(
		'00000000-0000-0000-0000-000000000702',
		'moderator',
		'moderator.two.action',
		'guide_entries',
		'00000000-0000-0000-0000-000000007002',
		null,
		null,
		'{}'::jsonb
	),
	(
		'00000000-0000-0000-0000-000000000704',
		'user',
		'user.action',
		'user_suggestions',
		'00000000-0000-0000-0000-000000007003',
		null,
		null,
		'{}'::jsonb
	);

select plan(8);

set local role authenticated;

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000701';
select is(
	(select count(*) from public.audit_logs),
	1::bigint,
	'moderator can read only own audit log rows'
);

select is(
	(
		select count(*)
		from public.audit_logs
		where actor_profile_id = '00000000-0000-0000-0000-000000000702'
	),
	0::bigint,
	'moderator cannot read another moderator audit rows'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000703';
select is(
	(select count(*) from public.audit_logs),
	3::bigint,
	'admin can read all audit logs'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000704';
select is(
	(select count(*) from public.audit_logs),
	0::bigint,
	'user cannot read audit logs'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000701';
-- Migration 028 allows moderator/admin audit inserts (the admin panel
-- writes them); the append-only trigger remains the mutation guard.
select lives_ok(
	$$
	insert into public.audit_logs (
		actor_profile_id,
		actor_role,
		action_type,
		entity_table,
		metadata
	)
	values (
		'00000000-0000-0000-0000-000000000701',
		'moderator',
		'test.insert',
		'test',
		'{}'::jsonb
	)
	$$,
	'moderator can insert an audit log row (policy 028)'
);

reset role;
select throws_like(
	$$
	update public.audit_logs
	set action_type = 'forbidden.update'
	where actor_profile_id = '00000000-0000-0000-0000-000000000701'
		and action_type = 'moderator.one.action'
	$$,
	'%append-only%',
	'audit_logs update is blocked by append-only trigger'
);

select throws_like(
	$$
	delete from public.audit_logs
	where actor_profile_id = '00000000-0000-0000-0000-000000000702'
		and action_type = 'moderator.two.action'
	$$,
	'%append-only%',
	'audit_logs delete is blocked by append-only trigger'
);

set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000703';
select is(
	(select count(*) from public.audit_logs),
	4::bigint,
	'audit log row count reflects the allowed staff insert only'
);

select * from finish();
rollback;
