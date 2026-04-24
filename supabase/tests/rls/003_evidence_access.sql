begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000301'),
	('00000000-0000-0000-0000-000000000302'),
	('00000000-0000-0000-0000-000000000303'),
	('00000000-0000-0000-0000-000000000304'),
	('00000000-0000-0000-0000-000000000305');

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000301', 'user', 'User', 'ru', true),
	('00000000-0000-0000-0000-000000000302', 'curator', 'Curator', 'ru', true),
	('00000000-0000-0000-0000-000000000303', 'moderator', 'Moderator', 'ru', true),
	('00000000-0000-0000-0000-000000000304', 'trusted_source', 'Trusted Source', 'ru', true),
	('00000000-0000-0000-0000-000000000305', 'user', 'Other User', 'ru', true);

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
		'00000000-0000-0000-0000-000000003001',
		'housing',
		'Curator Draft',
		'Draft entry for curator evidence access',
		'ru',
		'draft',
		'under_review',
		'pending verification',
		'00000000-0000-0000-0000-000000000302',
		'00000000-0000-0000-0000-000000000302',
		'00000000-0000-0000-0000-000000000302',
		null
	),
	(
		'00000000-0000-0000-0000-000000003002',
		'food',
		'Curator Published',
		'Published entry for trusted source evidence access',
		'ru',
		'published',
		'recommended_expats',
		null,
		'00000000-0000-0000-0000-000000000302',
		'00000000-0000-0000-0000-000000000303',
		'00000000-0000-0000-0000-000000000303',
		now()
	),
	(
		'00000000-0000-0000-0000-000000003003',
		'events',
		'Other Draft',
		'Foreign draft',
		'ru',
		'draft',
		'under_review',
		'needs check',
		'00000000-0000-0000-0000-000000000305',
		'00000000-0000-0000-0000-000000000305',
		'00000000-0000-0000-0000-000000000305',
		null
	);

insert into public.verification_evidence (
	id,
	guide_entry_id,
	evidence_type,
	summary,
	submitted_by_profile_id,
	is_valid
)
values
	(
		'00000000-0000-0000-0000-000000003101',
		'00000000-0000-0000-0000-000000003001',
		'team_check',
		'Curator draft evidence',
		'00000000-0000-0000-0000-000000000302',
		true
	),
	(
		'00000000-0000-0000-0000-000000003102',
		'00000000-0000-0000-0000-000000003002',
		'external_reference',
		'Published evidence by curator',
		'00000000-0000-0000-0000-000000000302',
		true
	),
	(
		'00000000-0000-0000-0000-000000003103',
		'00000000-0000-0000-0000-000000003002',
		'trusted_confirmation',
		'Trusted source confirmation',
		'00000000-0000-0000-0000-000000000304',
		true
	),
	(
		'00000000-0000-0000-0000-000000003104',
		'00000000-0000-0000-0000-000000003002',
		'photo',
		'Trusted source photo evidence',
		'00000000-0000-0000-0000-000000000304',
		true
	);

select plan(9);

set local role authenticated;

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000301';
select is(
	(select count(*) from public.verification_evidence),
	0::bigint,
	'user cannot read verification evidence rows'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000302';
select is(
	(select count(*) from public.verification_evidence),
	1::bigint,
	'curator reads evidence for own draft entries only'
);

select lives_ok(
	$$
	insert into public.verification_evidence (
		id,
		guide_entry_id,
		evidence_type,
		summary,
		submitted_by_profile_id,
		is_valid
	)
	values (
		'00000000-0000-0000-0000-000000003105',
		'00000000-0000-0000-0000-000000003001',
		'document',
		'Additional curator draft evidence',
		'00000000-0000-0000-0000-000000000302',
		true
	)
	$$,
	'curator can insert evidence for own draft entry'
);

select throws_like(
	$$
	insert into public.verification_evidence (
		id,
		guide_entry_id,
		evidence_type,
		summary,
		submitted_by_profile_id,
		is_valid
	)
	values (
		'00000000-0000-0000-0000-000000003106',
		'00000000-0000-0000-0000-000000003002',
		'document',
		'Curator should not write evidence for published entry',
		'00000000-0000-0000-0000-000000000302',
		true
	)
	$$,
	'%row-level security policy%',
	'curator cannot insert evidence for published entries'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000304';
select is(
	(select count(*) from public.verification_evidence),
	1::bigint,
	'trusted source can read own trusted_confirmation evidence only'
);

select throws_like(
	$$
	insert into public.verification_evidence (
		id,
		guide_entry_id,
		evidence_type,
		summary,
		submitted_by_profile_id,
		is_valid
	)
	values (
		'00000000-0000-0000-0000-000000003107',
		'00000000-0000-0000-0000-000000003002',
		'trusted_confirmation',
		'Trusted source insert should be denied',
		'00000000-0000-0000-0000-000000000304',
		true
	)
	$$,
	'%row-level security policy%',
	'trusted source cannot insert verification evidence'
);

set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000303';
select is(
	(select count(*) from public.verification_evidence),
	5::bigint,
	'moderator can read all evidence rows'
);

select lives_ok(
	$$
	delete from public.verification_evidence
	where id = '00000000-0000-0000-0000-000000003102'
	$$,
	'moderator can delete any evidence row'
);

select is(
	(select count(*) from public.verification_evidence),
	4::bigint,
	'moderator delete is reflected in visible evidence rows'
);

select * from finish();
rollback;
