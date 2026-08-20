-- 021: replay protection for the telegram-bootstrap Edge Function.
-- The function inserts one row per accepted initData hash (service role only);
-- a unique conflict means the same initData was already consumed.

create table if not exists public.telegram_bootstrap_nonces (
  init_data_hash text primary key,
  telegram_user_id bigint not null,
  created_at timestamptz not null default now()
);

alter table public.telegram_bootstrap_nonces enable row level security;

-- No client policies: only the service role (Edge Function) touches this table.

create index if not exists telegram_bootstrap_nonces_created_at_idx
  on public.telegram_bootstrap_nonces (created_at);

-- Keep the table bounded; hashes older than 3 days are useless.
-- Run periodically (pg_cron or manual) until a scheduled job exists:
--   delete from public.telegram_bootstrap_nonces where created_at < now() - interval '3 days';
