# Admin Panel + Production Readiness Plan

Status: **APPROVED 2026-08-18** (founder). Decisions: admin identity = desktop email+password user (role admin); district geometry = PostGIS; repo = public GitHub (CI + auto-deploy).
Context: the founder needs a real editorial admin (not raw Studio tables): create/edit content, draw district polygons on a map, add cities. Architecture.md allows a Nuxt `/admin` when Studio blocks editorial throughput - that trigger is met. This plan keeps the Supabase data boundary unchanged (RLS writes + privileged Edge Functions; Studio stays for schema/ops).

## Honest state assessment

- LIVE and verified: hosted Supabase project (migrations, seed, RLS proven), `telegram-bootstrap` + `telegram-bot` edge functions deployed, TMA deployed to Cloudflare Pages, bot configured, frontend gates green (32 tests).
- NOT prod-ready: admin is a mock prototype (in-browser, resets); housing/district data lives in frontend mocks; only the food slice is seeded (10 places); no keep-awake (free project pauses after 1 week); no backup execution; no CI on GitHub; test user + bot token file cleanup pending; no privacy page (Telegram requires one for bots handling user data).

## Key decisions (founder picks)

1. **Admin identity**: (a) email+password desktop admin user (recommended - drawing polygons on a phone is painful), or (b) Telegram-session-only admin. Recommend (a) + keep Telegram users as `user`.
2. **District geometry storage**: PostGIS `geometry` column (recommended - enables "which district is this point in", matches architecture's PostGIS mention) vs plain GeoJSON jsonb. Either way the admin draws with Leaflet.draw and the public map renders ST_AsGeoJSON.
3. **Repo visibility for CI**: public GitHub repo (unlimited Actions) vs private (2000 min/mo free). Recommend public - the code is the pilot's open base.

## Phase 0 - Foundations (no UI)

| # | Item | Deliverable | Verify | Effort |
|---|---|---|---|---|
| 0.1 | Enable PostGIS extension (free tier supported) | extension live | `select postgis_version()` | S |
| 0.2 | Migration 024: `districts` + `district_localizations` (rows-per-language: name, best_for tags, rent ranges ru/en, distance_to_beach, price_level, notes) + `districts` geometry + sort_order; RLS read-published, write by curator+ | tables + policies | pgTAP 024 suite | M |
| 0.3 | Admin write policies on existing tables (places/cities/reviews/guide_entries) for curator/moderator/admin roles (extend the 017/018 pattern) | RLS grants | pgTAP (insert/update as admin vs user) | M |
| 0.4 | Founder admin identity: create auth user (email+password) + `profiles` row role=admin; Telegram bootstrap stays role=user | admin can sign in, user cannot write | RLS role test | S |
| 0.5 | pg_cron: purge `telegram_bootstrap_nonces` older than 3 days | scheduled delete | job exists + runs | S |
| 0.6 | Migrate the 6 Da Nang district polygons + housing content from `mocks/housing.ts` into the DB (seed, on-conflict) | districts seeded, public map parity | housing page vs DB row count | M |

## Phase 1 - Content admin (places / reviews / cities / guides / categories)

Replace the mock store in `/admin` with real RLS-safe writes as the admin role; keep the AdminTable/StatusBadge components, drop the "prototype" badge.

| # | Item | Deliverable | Verify | Effort |
|---|---|---|---|---|
| 1.1 | Admin auth gate: `/admin` requires session + role in (admin, curator, moderator); redirect otherwise | route guard + login screen | sign in as admin vs user | M |
| 1.2 | `useAdminDb()` composable: RLS write layer over places/cities/reviews/guides (replace useMockDb in admin) | CRUD works against real DB | create/edit/publish a place, reload persists | L |
| 1.3 | Places editor: create/edit place + ru/en localizations (name/area/summary), place_type, price_level, verified, status transitions (draft/published/archived with guards) | full place CRUD | publish flow live on TMA food page | L |
| 1.4 | Reviews moderation: list pending, approve/reject; counts reflect on food page | moderation live | approve -> count updates | S |
| 1.5 | Cities manager: create city, ru/en names, flag, sort_order, activate/deactivate (activates in header selector via RLS) | city CRUD | add inactive city -> visible disabled; activate -> selectable | M |
| 1.6 | Guides editor: guide_entries CRUD (transport/money/safety), per-language rows, status, trust badge, last_verified_at | guide CRUD | guide pages render DB rows (schema-v2 pattern extension) | L |
| 1.7 | Audit wiring: sensitive mutations write `audit_logs` (who/when/what) | audit rows on publish/moderate | audit table populated | M |
| 1.8 | Admin UI polish per design.md + ui-ux-pro-max: desktop-first forms, labels, confirm dialogs, error feedback, empty states, 44px targets, no emoji icons | UI pass | design checklist + browser 1280px | M |

## Phase 2 - Map admin (district polygons + housing)

| # | Item | Deliverable | Verify | Effort |
|---|---|---|---|---|
| 2.1 | `DistrictMapEditor.client.vue`: Leaflet + CARTO tiles + Leaflet.draw - draw/edit/delete polygons, save GeoJSON -> PostGIS geometry (ST_GeomFromGeoJSON), per-district housing fields (ru/en) | polygon editor | draw polygon -> reload shows it; invalid ring rejected | L |
| 2.2 | Public housing cutover: `useHousingDb()` reads districts+localizations from DB (pattern from useDb); HousingTileMap + guide cards render DB data; remove mock dependency from housing page | housing page DB-driven | housing parity: 6 districts with rents render; edit in admin -> page updates | L |
| 2.3 | Disclaimer handling: keep "positions accurate, boundaries illustrative" until official GeoJSON is imported via the same editor | disclaimer stays data-driven | text present | S |

## Phase 3 - Production hardening

| # | Item | Deliverable | Verify | Effort |
|---|---|---|---|---|
| 3.1 | Keep-awake + uptime: Cloudflare Worker with cron trigger pings Supabase + TMA every 5 min; alerts the founder via bot if down (uses deployed infra, free) | worker + cron deployed | project never pauses; alert fires on kill test | M |
| 3.2 | Backups: GitHub Actions scheduled job runs `pg_dump` (DB URL secret) + Storage sync to an off-site bucket (R2 free / Backblaze) per runbook; monthly restore drill | automated backup + first drill | restore drill restores data | M |
| 3.3 | CI on GitHub: push repo; frontend gates + database-quality (Docker RLS pgTAP) green; `wrangler deploy` on push to main | CI green + auto-deploy | PR blocks broken builds | M |
| 3.4 | Cleanup: delete `bot-token.txt`, remove `pilot-test@tma.local` user, verify no secrets in repo/env files | clean repo | `git grep` secrets = 0 | S |
| 3.5 | Privacy: static privacy page (what data: telegram id, locale; why; no sharing) + link in bot description (Telegram requirement) + `/privacy` command | privacy page live | bot profile shows link | S |
| 3.6 | Rate limiting on `telegram-bootstrap` (in-function, per-IP simple counter) + verify webhook secret (done) | abuse resistance | burst test limited | S |
| 3.7 | Nonce table bound (0.5 done via pg_cron) + function logs review routine | ops routine documented | runbook entry | S |

## Phase 4 - Content & launch

| # | Item | Deliverable | Verify | Effort |
|---|---|---|---|---|
| 4.1 | Pilot seed target (before broad launch): housing 25, transport 15, money 10, food 15, safety 10, events 6 = ~80 high-value entries with trust badges + evidence refs (content-seeding-protocol rules) | seeded DB | QA spot-check 10% per batch | L (content) |
| 4.2 | Freshness SLA in admin: `verification_due_at` flags + overdue list (transport/money 14d, housing/food/events 30d) | SLA view | overdue shows after window | M |
| 4.3 | Closed pilot: founder + 3-5 testers; measure journey completions, zero-result searches, trust incidents | pilot report | metrics collected | M |
| 4.4 | Post-pilot: monetization prep (labeled premium/affiliate - never affects ranking or trust) and second city only after Da Nang ops repeat reliably (architecture rule) | decision doc | deferred | - |

## Dependencies

Phase 0 -> 1 -> 2 (admin needs write layer before map editor persists; map editor needs districts table). Phase 3 partially parallel (3.1/3.3/3.4 anytime; 3.2 after repo push). Phase 4 after 1-2 stable + pilot.

## Definition of done for the admin plan

- Founder can, without code: add a city, draw a district polygon, add/edit/publish a place (ru/en), moderate a review, publish a guide entry - and see it live in the TMA.
- All admin writes go through RLS with role gates; sensitive actions audited; invariants protected by constraints/triggers (Studio can still bypass RLS - invariants stay in DB, not the client).
- Gates: frontend test/lint/typecheck/build + pgTAP for new policies + browser verification (admin flows + TMA reflects changes).
