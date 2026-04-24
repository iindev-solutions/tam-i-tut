begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000101'),
	('00000000-0000-0000-0000-000000000102'),
	('00000000-0000-0000-0000-000000000103'),
	('00000000-0000-0000-0000-000000000104');

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000101', 'user', 'Regular User', 'ru', true),
	('00000000-0000-0000-0000-000000000102', 'admin', 'Admin User', 'ru', true),
	('00000000-0000-0000-0000-000000000103', 'moderator', 'Moderator User', 'ru', true),
	('00000000-0000-0000-0000-000000000104', 'user', 'Target User', 'ru', true);

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

select plan(8);

set local role authenticated;

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000101';
select is(
	(select count(*) from public.profiles),
	1::bigint,
	'user can read only own profile'
);

select lives_ok(
	$$
	update public.profiles
	set display_name = 'Regular User Updated'
	where id = '00000000-0000-0000-0000-000000000101'
	$$,
	'user can update own profile non-role fields'
);

select throws_like(
	$$
	update public.profiles
	set role = 'admin'
	where id = '00000000-0000-0000-0000-000000000101'
	$$,
	'%row-level security policy%',
	'user cannot escalate own role'
);

select is(
	(select role::text from public.profiles where id = '00000000-0000-0000-0000-000000000101'),
	'user',
	'role remains unchanged after escalation attempt'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000103';
select is(
	(select count(*) from public.profiles),
	4::bigint,
	'moderator can read all profiles'
);

select is(
	pg_temp.exec_rows(
		$$
		delete from public.profiles
		where id = '00000000-0000-0000-0000-000000000104'
		$$
	),
	0,
	'moderator cannot delete profiles'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000102';
select lives_ok(
	$$
	update public.profiles
	set role = 'curator'
	where id = '00000000-0000-0000-0000-000000000104'
	$$,
	'admin can update other profile role'
);

select is(
	(select role::text from public.profiles where id = '00000000-0000-0000-0000-000000000104'),
	'curator',
	'admin role update is applied'
);

select * from finish();
rollback;
