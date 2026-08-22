-- Migration: 030_district_validity_and_rate_limits
-- Purpose: production hardening.
--   1) Server-side polygon validity guard: the Leaflet.draw editor allows
--      self-intersecting rings (allowIntersection was removed to fix the
--      3-vertex freeze), so the database must reject invalid geometry.
--   2) Durable per-IP rate limiting for telegram-bootstrap: Supabase Edge
--      Runtime does not persist isolate state between requests (verified
--      live: a burst never tripped the in-memory counter), so the counter
--      lives in Postgres behind an atomic upsert RPC called with the
--      service role key.
-- Source Design: vault/wiki/architecture/admin-panel-and-prod-plan.md (3.6 + Phase 2 note)

alter table public.districts
	add constraint districts_geometry_is_valid check (st_isvalid(geometry));

create table if not exists public.telegram_rate_limits (
	key text primary key,
	window_start timestamptz not null default now(),
	count integer not null default 0
);

alter table public.telegram_rate_limits enable row level security;

-- One row per key: expired windows reset in place, so the table does not
-- grow with traffic and needs no purge job.

create or replace function public.check_rate_limit(
	p_key text,
	p_max integer,
	p_window_seconds integer
)
returns integer
language plpgsql
as $$
declare
	v_retry_after integer;
begin
	insert into public.telegram_rate_limits as rl (key, window_start, count)
	values (p_key, now(), 1)
	on conflict (key) do update
		set count = case
				when rl.window_start + make_interval(secs => p_window_seconds) <= now() then 1
				else rl.count + 1
			end,
			window_start = case
				when rl.window_start + make_interval(secs => p_window_seconds) <= now() then now()
				else rl.window_start
			end
	returning case
		when count > p_max then greatest(1, ceil(extract(epoch from
			window_start + make_interval(secs => p_window_seconds) - now()))::integer)
		else 0
	end
	into v_retry_after;

	return v_retry_after;
end;
$$;
