begin;

insert into auth.users (id)
values
	('00000000-0000-0000-0000-000000000801'),
	('00000000-0000-0000-0000-000000000802'),
	('00000000-0000-0000-0000-000000000803'),
	('00000000-0000-0000-0000-000000000804'),
	('00000000-0000-0000-0000-000000000805');

insert into public.profiles (id, role, display_name, locale, is_active)
values
	('00000000-0000-0000-0000-000000000801', 'moderator', 'Moderator', 'ru', true),
	('00000000-0000-0000-0000-000000000802', 'curator', 'Owner Curator', 'ru', true),
	('00000000-0000-0000-0000-000000000803', 'trusted_source', 'Trusted Source 1', 'ru', true),
	('00000000-0000-0000-0000-000000000804', 'trusted_source', 'Trusted Source 2', 'ru', true),
	('00000000-0000-0000-0000-000000000805', 'trusted_source', 'Trusted Source 3', 'ru', true);

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
		'00000000-0000-0000-0000-000000008101',
		'00000000-0000-0000-0000-000000000803',
		'00000000-0000-0000-0000-000000000801',
		now(),
		true,
		'ts1 active'
	),
	(
		'00000000-0000-0000-0000-000000008102',
		'00000000-0000-0000-0000-000000000804',
		'00000000-0000-0000-0000-000000000801',
		now(),
		true,
		'ts2 active'
	),
	(
		'00000000-0000-0000-0000-000000008103',
		'00000000-0000-0000-0000-000000000805',
		'00000000-0000-0000-0000-000000000801',
		now(),
		true,
		'ts3 active'
	);

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
		'00000000-0000-0000-0000-000000008001',
		'housing',
		'Trust Transition Entry',
		'Entry used to test trust badge guard transitions',
		'ru',
		'published',
		'under_review',
		'waiting for confirmations',
		'00000000-0000-0000-0000-000000000802',
		'00000000-0000-0000-0000-000000000802',
		'00000000-0000-0000-0000-000000000801',
		now()
	);

select plan(9);

set local role authenticated;
set local request.jwt.claim.sub = '00000000-0000-0000-0000-000000000801';

select throws_like(
	$$
	update public.guide_entries
	set trust_badge = 'recommended_expats',
		under_review_note = null,
		updated_by_profile_id = '00000000-0000-0000-0000-000000000801'
	where id = '00000000-0000-0000-0000-000000008001'
	$$,
	'%recommended_expats requires >= 3 active trusted-source confirmations%',
	'promotion to recommended_expats fails without three active confirmations'
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
	values
		(
			'00000000-0000-0000-0000-000000008201',
			'00000000-0000-0000-0000-000000008001',
			'00000000-0000-0000-0000-000000008101',
			'confirmation 1',
			true
		),
		(
			'00000000-0000-0000-0000-000000008202',
			'00000000-0000-0000-0000-000000008001',
			'00000000-0000-0000-0000-000000008102',
			'confirmation 2',
			true
		),
		(
			'00000000-0000-0000-0000-000000008203',
			'00000000-0000-0000-0000-000000008001',
			'00000000-0000-0000-0000-000000008103',
			'confirmation 3',
			true
		)
	$$,
	'moderator can add confirmations needed for recommended_expats threshold'
);

select lives_ok(
	$$
	update public.guide_entries
	set trust_badge = 'recommended_expats',
		under_review_note = null,
		updated_by_profile_id = '00000000-0000-0000-0000-000000000801'
	where id = '00000000-0000-0000-0000-000000008001'
	$$,
	'promotion to recommended_expats succeeds with three active confirmations'
);

select is(
	(
		select count(*)
		from public.trust_badge_events
		where guide_entry_id = '00000000-0000-0000-0000-000000008001'
	),
	1::bigint,
	'trust badge event is written after first successful transition'
);

select throws_like(
	$$
	update public.guide_entries
	set trust_badge = 'verified_team',
		updated_by_profile_id = '00000000-0000-0000-0000-000000000801'
	where id = '00000000-0000-0000-0000-000000008001'
	$$,
	'%verified_team requires >= 1 valid team_check evidence%',
	'promotion to verified_team fails without valid team_check evidence'
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
		'00000000-0000-0000-0000-000000008301',
		'00000000-0000-0000-0000-000000008001',
		'team_check',
		'Valid team verification evidence',
		'00000000-0000-0000-0000-000000000801',
		true
	)
	$$,
	'moderator can add team_check evidence'
);

select lives_ok(
	$$
	update public.guide_entries
	set trust_badge = 'verified_team',
		updated_by_profile_id = '00000000-0000-0000-0000-000000000801'
	where id = '00000000-0000-0000-0000-000000008001'
	$$,
	'promotion to verified_team succeeds after team_check evidence exists'
);

select is(
	(
		select count(*)
		from public.trust_badge_events
		where guide_entry_id = '00000000-0000-0000-0000-000000008001'
	),
	2::bigint,
	'two successful trust transitions produce two trust_badge_events'
);

select is(
	(
		select count(*)
		from public.audit_logs
		where entity_table = 'guide_entries'
			and entity_id = '00000000-0000-0000-0000-000000008001'
			and action_type = 'guide_entries.trust_badge_changed'
	),
	2::bigint,
	'two successful trust transitions produce two audit log rows'
);

select * from finish();
rollback;
