# System Design — TamITut

## High-Level Structure

- **Frontend:** Nuxt 4 app serving Telegram Mini App shell and responsive web fallback.
- **Backend platform:** Supabase (Postgres, Auth, Storage, Realtime, Edge Functions).
- **Moderation tooling:** Admin-facing flows for approvals, reports, and blacklist updates.
- **Knowledge base:** `vault/` as operational memory and planning source of truth.

## Core Domains

1. Listings (housing, transport, jobs, services)
2. Providers (identity, verification status, reputation)
3. Reviews (ratings + moderated text)
4. Reports (evidence-backed abuse/scam submissions)
5. Blacklist entries (public safety visibility)

## Data Flow (Target)

1. Client authenticates (Telegram initData or web email flow).
2. Client requests listings/search via Supabase APIs/Edge Functions.
3. User actions (create listing, review, report) write to Postgres with RLS enforcement.
4. Moderator actions update status and publish trust signals.
5. Public views consume approved listings + blacklist metadata.

## Security Boundaries

- Strict RLS by role and ownership.
- Moderation actions restricted to staff roles.
- Evidence assets in controlled storage buckets.
- Telegram initData signature verification before session minting.

## Transitional Note

Repository still includes Laravel template artifacts under `backend/`.
These are non-authoritative for final architecture and should be replaced/adapted during Phase 1.
