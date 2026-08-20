# Schema v2 — City-Aware Cutover Design

## Status

Accepted (2026-08-18). One end-to-end slice first: **food** (cities + categories + places + reviews), then the remaining categories follow the same pattern.

## Goal

Replace the in-browser `useMockDb()` (frontend/mocks/*.ts) with RLS-safe Supabase reads so a local `supabase start` stack serves real data to the Nuxt UI — no mock content in the working path. This is the production data boundary for the Supabase-only pilot.

## Scope of the first slice

Prove the full path on one category and the home screen:

- `cities` (tenancy axis) + `categories` -> home page
- `places` + `reviews` -> `/categories/food` page
- Supabase Auth session via `telegram-bootstrap` Edge Function

## Key decisions

### 1. Language model = rows-per-language (schema-native)

Existing migrations already model localized content as separate rows with a `language` column (`guide_entries.language`, `title`, `summary`). We keep that model rather than introducing `JSONB {ru,en}` columns.

The frontend composable (`useDb()`) selects the row for the active locale and maps it to the existing `LocalizedText {ru, en}` UI contract, so page components keep rendering unchanged.

Rationale: keeps SQL/RLS/indexes simple, matches the approved schema style, avoids dual model (no second convention beside the existing one).

### 2. City tenancy = `city_slug` FK on content tables

New `cities` table (`slug` PK). Content tables that are city-scoped get a `city_slug` column referencing it. Da Nang (`da-nang`) is the active pilot city; other cities are seeded inactive for the selector.

Listed per-table so each migration is explicit:

| Table | city column | note |
|---|---|---|
| `categories` | none (categories are global; entries carry the city) | category list is the same across cities |
| `places` (new) | `city_slug` | food slice |
| `reviews` (new) | (`place_id` carries city indirectly) | belongs to a place, not a city directly |

### 3. New tables for the slice: `places` and `reviews`

The existing schema has `guide_entries` (universal typed content) but no dedicated `places`/`reviews` tables, and the food UI needs place type, price level, verified flag, and approved-review counts. Rather than overloading `guide_entries` with shape-specific columns, we add purpose-built tables:

- `places` — id, city_slug, slug, place_type ENUM, price_level ENUM, name (localized rows), area (localized), summary (localized), verified, status, updated_at. Localized strings live in a companion `place_translations` table keyed by (place_id, language) OR as rows-per-language. **Chosen: title/summary/area as columns on a normalized `place_localizations` child table** to match the existing `guide_entries` single-row-per-language precedent in spirit but keep one logical place row (status/verified shared across languages).

  - Mirror the existing schema convention: one row per `(place_id, language)` in `place_localizations`; `places` holds non-localized state (verified, status, price_level, place_type, city_slug). This keeps "publish state" single-sourced (one row) unlike `guide_entries` which duplicates status per language row.
  - `place_localizations.language` ENUM `language_code`; `UNIQUE (place_id, language)`.

- `reviews` — id, place_id FK, author, rating (1..5 check), content localized via `review_localizations` (or single content + language), status ENUM `suggestion_status`-like -> new `review_status` ENUM (`pending`/`approved`/`rejected`).

### 4. RLS: authenticated read of published rows (match existing model)

Existing read policies require `is_authenticated()` AND `status = 'published'`. New tables get the same posture:

- `places`: SELECT where `is_authenticated()` and `status = 'published'::content_status`. No anon read (consistent with the existing policies — TMA users are authenticated after bootstrap).
- `place_localizations`: SELECT where the parent place is published.
- `reviews`: SELECT where `status = 'approved'::review_status` (only approved reviews are shown publicly; matches the food UI which counts approved).

Admin/curation writes stay out of scope for this slice (Studio / privileged Edge Functions), so we add write policies later with the admin path.

### 5. `security_invoker = true` on any view

If a read-view is introduced it must be `WITH (security_invoker = true)` so underlying RLS still applies. The food slice avoids views and reads tables directly; this rule is recorded for any future view.

## Enums added

- `content_status` ENUM (`draft`, `published`, `archived`) — `entry_status` already exists; reuse it for `places.status` to avoid a second status enum.
- `review_status` ENUM (`pending`, `approved`, `rejected`).
- `place_type` ENUM (`cafe`, `street`, `market`, `restaurant`).
- `price_level` ENUM (`budget`, `average`, `above`).

## Seed (first slice)

- `cities`: da-nang (active), nha-trang / pattaya / phuket (inactive) — from the current mock, labelled so the home city selector shows real rows.
- `categories`: seed already exists in migration 002 (6 rows). Kept.
- `places`: 10 real Da Nang venues from `frontend/app/mocks/db.ts`, both ru/en localizations, status `published`, verified flags copied.
- `reviews`: none. The mock has `reviews: []` and we have no sourced, attributable review records, so no review rows are seeded — the food UI correctly shows zero approved counts until real reviews exist. (No invented "demo" data under a real-data label.)

The seed lives in `supabase/seed.sql` (local deterministic data; `db.seed.sql_paths = ["./seed.sql"]`). Real per-city editorial data is a later content-seeding task.

## Frontend cutover

- Add `supabase-js` client (done).
- `supabase/` local config + `NUXT_PUBLIC_SUPABASE_URL`/`NUXT_PUBLIC_SUPABASE_ANON_KEY` from local `supabase start` env for the running app.
- New composable `useDb()`:
  - builds a `createClient(supabaseUrl, anonKey)` from `runtimeConfig.public`;
  - `select` rows for the active locale;
  - maps rows -> existing `MockDb` shape (`Place[]`, `Review[]`, `CityEntry[]`, `CategoryEntry[]`) so page components are unchanged;
  - reads `categories` + `cities` for home, `places` + `reviews` for food.
- Keep `useMockDb()` only for the `/admin` prototype (it is explicitly a prototype surface per architecture); user-facing routes swap to `useDb()`.

## Validation gates (need Docker)

- `supabase start`, `supabase migration up`, `supabase db lint` — schema/RLS clean.
- `supabase test db` — extending `supabase/tests/rls` with `places`/`reviews`/`place_localizations` policy tests.
- `supabase functions serve` — `telegram-bootstrap` live against the local stack.
- Browser: home lists real cities/categories; food lists real places with approved-review counts; no mock fallback in this path.

## Out of scope this slice

- transport / money / safety / culture / housing content cutover (same pattern, later iterations).
- Admin write path via RLS/Edge Functions (later).
- Production deployment (user runs `supabase start` locally; data moves to prod VPS later).