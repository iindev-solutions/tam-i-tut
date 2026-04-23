# Supabase Schema + RLS Plan — TAMITUT

## Objective

Define implementation-ready data model and row-level security policies for trust-first curated guide operations.

## Scope

- six category guide model
- trust evidence model
- trust badge state model
- blacklist/scam model
- user suggestions
- audit trail

## Core Tables (Draft)

1. `profiles` — user/staff identity and role assignment.
2. `categories` — fixed MVP categories (`housing`, `transport`, `money`, `food`, `events`, `safety`).
3. `guide_entries` — main curated entries.
4. `trusted_contacts` — contacts linked to guide entries.
5. `price_snapshots` — benchmark prices by location/date/source confidence.
6. `checklist_items` — practical checklists linked to category or entry.
7. `verification_evidence` — attached proof records.
8. `trusted_sources` — approved accounts allowed to submit confirmations.
9. `source_confirmations` — trusted-source confirmations per entry.
10. `trust_badge_events` — state transition history for trust badges.
11. `safety_cases` — blacklist case records with evidence.
12. `scam_patterns` — reusable anti-scam guidance.
13. `user_suggestions` — inbound suggestions queue.
14. `audit_logs` — immutable sensitive action log.

## Required Enums

- `app_role`: `user`, `curator`, `moderator`, `admin`, `trusted_source`
- `trust_badge`: `under_review`, `recommended_expats`, `verified_team`
- `entry_status`: `draft`, `published`, `archived`
- `evidence_type`: `team_check`, `photo`, `document`, `trusted_confirmation`, `external_reference`

## RLS Policy Matrix (Draft)

| Table Group | user | curator | moderator | admin | trusted_source |
|---|---|---|---|---|---|
| public published guide data | read | read | read/write | read/write | read |
| drafts (`guide_entries`) | no | own/team write | read/write | read/write | no |
| evidence | no | create/update draft-linked | read/write | read/write | create limited confirmation rows |
| trusted source registry | no | no | read/write | read/write | self-read |
| trust badge transitions | no | no | create | create | no |
| safety cases/blacklist | read published only | no | create/update | create/update | no |
| user suggestions | create own/read own | read | read/write | read/write | create own |
| audit logs | no | no | read own actions | full read | no |

## Hard Rules

1. No direct insert into published trusted state without evidence constraints.
2. `recommended_expats` requires >= 3 active confirmations from `trusted_sources`.
3. `verified_team` requires at least one valid team-check evidence row.
4. Blacklist rows require mandatory source + date + evidence reference.
5. Every trust/safety change writes an audit log row.

## Migration Order

1. create enums and base role function helpers
2. create core identity/category tables
3. create guide/evidence/contact tables
4. create trust transition + confirmation tables
5. create safety and suggestion tables
6. apply RLS policies and test each role path

## Verification Checklist

- each role can only perform expected operations
- trust badge transitions fail when preconditions are missing
- blacklist publish fails without evidence fields
- policy tests run in CI before merge
