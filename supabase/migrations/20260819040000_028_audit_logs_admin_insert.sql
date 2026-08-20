-- Migration: 028_audit_logs_admin_insert
-- Purpose: Allow moderator/admin to write audit rows from the admin panel.
-- audit_logs stays append-only (the mutation trigger blocks UPDATE/DELETE);
-- this policy only permits INSERT by staff roles.

drop policy if exists audit_logs__moderator_admin__insert on public.audit_logs;
create policy audit_logs__moderator_admin__insert
on public.audit_logs
for insert
with check (
	app_private.is_moderator_or_admin()
);
