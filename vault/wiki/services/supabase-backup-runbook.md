# Supabase Backup Runbook (off-site)

Off-site backup procedure for the Supabase-only pilot (database + Storage objects).
Required before any production data is seeded (sprint 5.10).

## Service

Postgres database (schema, RLS, auth) and Storage objects of the Supabase project,
copied off-site so a project loss or region incident does not lose pilot data.

## Responsibilities

- Daily logical backup of the Postgres database (schema + data + auth).
- Daily copy of Storage object changes.
- Off-site destination: different cloud/region than the primary project.
- Retention: 14 daily backups; monthly snapshot kept for 6 months.
- Monthly restore drill proving the backup can actually restore.

## Scope (what is backed up)

- Database: all `public` tables, `auth` schema (users/sessions/identities), `storage` metadata.
  - `telegram_bootstrap_nonces` is transient (3-day purge) but is included for completeness.
- Storage: every bucket/object used by the pilot (e.g. evidence/photo uploads).
- Not backed up (regenerated): Edge Function source (lives in git), secrets (kept in
  `supabase secrets` + a password manager), config.toml (git).

## Destination

- Primary: object storage in a different provider/region (S3-compatible bucket, e.g.
  Backblaze B2 / AWS S3 in another region) with server-side encryption (SSE) or
  client-side encryption before upload.
- Bucket is versioned; lifecycle rule deletes versions older than the retention window.
- Access via dedicated service account with write-only access to the backup bucket only.

## Database backup (logical dump)

Managed hosting:

```bash
# Daily, from a CI cron or a small runner (not from a laptop):
supabase db dump --db-url "$PROD_DB_URL" -f "backups/$(date +%F)/db.sql" --data-only=false

# Auth schema must be included for full recovery (users, sessions):
pg_dump "$PROD_DB_URL" \
  --format=custom \
  --file="backups/$(date +%F)/db.dump" \
  --no-owner --no-privileges
```

Self-hosted VPS (dockerized Postgres):

```bash
docker exec <pg-container> pg_dump -U postgres -Fc postgres \
  > "backups/$(date +%F)/db.dump"
```

- Prefer `pg_dump` custom format (`-Fc`) for restore flexibility and compression.
- Run `pg_dump` against a replica or during low traffic; hold no long locks.
- Verify the dump file size is non-trivial (>1 MB for the seeded pilot) before uploading.

## Storage backup

```bash
# S3-protocol sync from the Supabase Storage endpoint to the off-site bucket:
rclone sync :s3,provider=Supabase,access_key_id=...,secret_access_key=... : \
  :s3,provider=BackblazeB2,account=...,key=...:<backup-bucket>/storage/$(date +%F)/ \
  --config=backup-rclone.conf
```

- First run: full sync. Subsequent runs: incremental (`rclone sync` copies only changes).
- Keep at least one full snapshot per week (copy the day's directory to a `weekly/` prefix
  and rely on bucket versioning for the rest).

## Off-site copy + encryption

- Encrypt the dump before upload when the bucket is not SSE-enabled:
  `gpg --symmetric --cipher-algo AES256 backups/$(date +%F)/db.dump`
- Upload both the dump and the Storage sync to the off-site bucket (different cloud/region).
- The off-site bucket must NOT be in the same region as the Supabase project.

## Restore drill (monthly)

1. Create a scratch Supabase project or local `supabase start` stack.
2. `supabase db reset` then `pg_restore` the latest dump into the scratch DB.
3. Verify: row counts of `places`/`cities` match production; one published place renders
   in the Nuxt app pointed at the scratch project; Storage objects listable.
4. Record the drill result in `vault/logs/changelog.md`.

## Schedule

| What | When | Where |
|---|---|---|
| DB dump + upload | daily 03:00 | CI cron / runner |
| Storage sync | daily 03:30 | same runner |
| Retention cleanup | daily after upload | bucket lifecycle rule |
| Restore drill | monthly 1st | scratch project |
| Secrets check | monthly | `supabase secrets list` vs password manager |

## Verification checklist

- [ ] Dump file exists today and is non-trivial in size.
- [ ] Off-site bucket shows today's prefix with versioning on.
- [ ] Restore drill succeeded within the last 30 days.
- [ ] Backup service account has write-only access (no read of primary project).

## Operational Notes

- Secrets: `SUPABASE_DB_URL` (pooler/read-replica URL), rclone/gpg keys live in the
  runner's secret store, never in git (`.env.example` keeps placeholders only).
- If the primary project is lost: restore the dump into a fresh Supabase project, point
  `NUXT_PUBLIC_SUPABASE_URL`/`NUXT_PUBLIC_SUPABASE_ANON_KEY` at it, re-set Edge Function
  secrets, and re-deploy functions from git.
- The local `supabase start` stack is NOT a backup destination; it is dev/test only.
