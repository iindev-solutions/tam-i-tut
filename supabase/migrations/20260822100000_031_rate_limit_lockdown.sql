-- Migration: 031_rate_limit_lockdown
-- Purpose: production hardening (plan item 3.6 follow-up).
--   The 030 rate-limit function was created with defaults: EXECUTE went to
--   PUBLIC, so any authenticated/anon caller could mint rows in
--   telegram_rate_limits (or burn another key's window) through PostgREST.
--   Revoke PUBLIC/anon/authenticated, grant execute to service_role only
--   (the Edge function calls it with the service role key), and pin the
--   search_path. The table itself stays service-role-only via RLS with no
--   policies (verified live: anon read returns an empty set).

revoke execute on function public.check_rate_limit(text, integer, integer) from public;
revoke execute on function public.check_rate_limit(text, integer, integer) from anon;
revoke execute on function public.check_rate_limit(text, integer, integer) from authenticated;

alter function public.check_rate_limit(text, integer, integer)
	set search_path = public, pg_temp;

grant execute on function public.check_rate_limit(text, integer, integer) to service_role;

comment on function public.check_rate_limit(text, integer, integer) is
	'Per-key fixed-window rate limiter for edge functions. Execute granted to service_role only; see migration 031.';
