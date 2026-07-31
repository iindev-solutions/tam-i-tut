# TAMITUT Architecture

## Product

TAMITUT is a Russian-first Telegram Bot + Telegram Mini App guide for newcomers. Da Nang is the only active city. Content is curated, evidence-backed, and trust-first; future cities are configuration, not city-specific code.

## First-release scope

- Telegram Bot: `/start`, launches the Mini App, sends notifications and deep links.
- Telegram Mini App: city context, categories, guide entries, newcomer journeys, map/contact actions.
- Supabase Studio: private pilot operations for content CRUD, moderation, evidence, trust badges, and audit review.
- No Laravel, no custom Laravel admin, no separate Nuxt admin, no inline mode, public web, payments, sponsored placements, or second city in first release.

## Runtime boundary

```text
Telegram Bot -> Supabase Edge Function (webhook/bootstrap)
Telegram Mini App (Nuxt 4 + Nuxt UI/Tailwind)
                 -> Supabase Edge Functions (privileged workflows)
                 -> Supabase Auth session
                 -> Supabase Postgres/PostGIS + Storage + Realtime
                 -> RLS policies
Supabase Studio -> private staff/editor operations
```

Supabase is the only backend platform. Nuxt uses the public Supabase URL and anon/publishable key only. `service_role`, database secrets, and Telegram bot token live only in Edge Function secrets. Direct client reads/writes are limited by RLS; privileged operations go through Edge Functions.

No VPS is required for the first Supabase-hosted pilot. A static Nuxt host and Supabase-hosted services are sufficient. A VPS may be added later for a dedicated worker, proxy, or self-hosted migration, but it is not part of MVP runtime.

## Authentication

The Telegram bootstrap Edge Function receives raw Telegram `initData`, validates Telegram HMAC, required fields, freshness, and replay protection, then establishes the Supabase session contract for the Mini App. Nuxt never trusts `initDataUnsafe` for authentication and never receives privileged secrets.

The exact Supabase Auth exchange implementation must be validated in the first auth slice. Do not invent a second Laravel-style opaque session system. Keep Telegram verification server-side in Edge Functions and use Supabase Auth/RLS as the client authorization boundary.

## Content and trust

Core records: cities, districts/localizations, typed content items, translations, places, articles, events, contacts, prices, checklists, evidence, trust events, suggestions, safety cases, and audit logs. Every published recommendation has verification metadata and a trust state:

```text
Draft -> In review -> Published -> Reverification -> Archived
```

Trust badges never come from payment. Sponsored or affiliate inventory, when eventually enabled, is explicitly labeled and cannot alter organic ranking or trust state.

## Admin boundary

For the pilot, Supabase Studio is the private operations surface. Restrict Studio/project membership to staff with least privilege. Studio operations use privileged access and can bypass client RLS, so publication/evidence/audit invariants must be enforced by database constraints, triggers, and guarded workflows. Studio is acceptable for a small technical team, but it is not a polished editorial product. If content operations outgrow it, add a Nuxt `/admin` later without changing the Supabase data boundary.

Required database controls remain:

- explicit role/profile fields;
- publish-state constraints and transition guards;
- evidence required before publication;
- audit rows for sensitive mutations;
- RLS policies for client access;
- Edge Functions for privileged multi-step operations.

## Data rules

The existing SQL migrations, RLS policies, and pgTAP tests remain the implementation baseline. Before production seeding, implement and approve a city-aware v2 cutover: normalized geography/localizations, typed content, application-owned profiles, and Supabase Auth-aligned authorization. Do not seed 200+ records or expose the old schema as the final launch contract before that cutover.

## Delivery order

1. Remove Laravel from the active product path and lock Supabase-only runtime.
2. Implement Telegram bootstrap Edge Function with signature, freshness, replay, and session tests.
3. Connect Nuxt to Supabase using public client config and RLS-safe queries.
4. Validate Supabase Studio editorial workflow with a small Da Nang dataset.
5. Seed a small set of Da Nang newcomer journeys; expand toward 200+ verified entries.
6. Run a closed pilot and measure successful guide journeys, zero-result searches, freshness, and trust incidents.
7. Add a custom Nuxt admin only if Studio blocks editorial throughput.
8. Add monetization only after repeat usage; add another city only after the Da Nang operations model repeats reliably.

## Operational minimum

Supabase-hosted project, Edge Functions, Telegram webhook, static Nuxt hosting, secrets in Supabase project secrets, database and Storage backups, health checks, rate limits, audit logs, and an off-site backup plan. Supabase database backups do not cover Storage objects; export both database and Storage according to the selected plan. Scale only after measured bottlenecks.

## Decision rule

When a new feature is proposed, verify: Does it help a newcomer complete a trusted city task in two actions? Does it fit Nuxt -> Supabase Edge Functions/Auth/RLS? Does it preserve evidence, moderation, and auditability? If not, defer it.

## TMA visual and search rules

- Visual system is mostly monochrome: white/near-black surfaces, zinc neutrals, and orange as a restrained action accent.
- Orange is reserved for one primary action, selected states, and small trust cues; category icons stay neutral.
- Locale control sits beside the city selector and theme control in the header. Russian is default; English is a deliberate toggle.
- Do not keep dead search inputs. When search is introduced, submit the query to Supabase through an RLS-safe query or Edge Function with `city_id`, locale, and optional category, then show ranked verified results and a clear zero-results state.
