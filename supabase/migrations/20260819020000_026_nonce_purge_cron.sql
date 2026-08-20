-- Migration: 026_nonce_purge_cron
-- Purpose: Bound the telegram_bootstrap_nonces table with a nightly purge
-- (hashes older than 3 days are useless; migration 021 documented the need).
-- Uses pg_cron (available on Supabase hosted). Idempotent: unschedule first,
-- then schedule the named job.

create extension if not exists pg_cron;

-- Idempotent: unschedule only if the job exists (unschedule by jobname raises
-- when missing; by jobid it is a no-op for absent rows).
select cron.unschedule(jobid)
from cron.job
where jobname = 'tamitut-nonce-purge';

select cron.schedule(
	'tamitut-nonce-purge',
	'0 3 * * *',
	$$delete from public.telegram_bootstrap_nonces where created_at < now() - interval '3 days'$$
);
