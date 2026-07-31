# TAMITUT Architecture

## Product

TAMITUT is a Russian-first Telegram Bot + Telegram Mini App guide for newcomers. Da Nang is the only active city. Content is curated, evidence-backed, and trust-first; future cities are configuration, not city-specific code.

## First-release scope

- Telegram Bot: `/start`, launches the Mini App, sends notifications and deep links.
- Telegram Mini App: city context, search, categories, guide entries, newcomer journeys, map/contact actions.
- Laravel admin: server-rendered editorial CRUD, moderation, evidence, trust badges, and audit history.
- No inline mode, public web, separate Nuxt admin, payments, sponsored placements, or second city in first release.

## Runtime boundary

```text
Telegram Bot -> Telegram Mini App (Nuxt 4 + Nuxt UI/Tailwind)
                         -> Laravel API/BFF
                              -> PostgreSQL/PostGIS + Storage (Supabase)
                              -> Redis (sessions, cache, queues, rate limits)
```

Laravel is the only client-facing API and authorization boundary. Nuxt never calls Supabase directly and never receives privileged credentials. Supabase provides managed PostgreSQL/PostGIS and object storage; it is infrastructure, not a second application API. One modular Laravel monolith is sufficient; no microservices or Kubernetes for the pilot.

## Authentication

Telegram `initData` is validated server-side by Laravel using Telegram's HMAC rules, freshness window, and replay protection. Laravel maps `telegram_user_id` to an application profile and issues the production session contract. Keep session issuance and storage behind Laravel; do not build a second Supabase-auth path for the TMA.

## Content and trust

Core records: cities, districts/localizations, typed content items, translations, places, articles, events, contacts, prices, checklists, evidence, trust events, suggestions, safety cases, and audit logs. Every published recommendation has verification metadata and a trust state:

```text
Draft -> In review -> Published -> Reverification -> Archived
```

Trust badges never come from payment. Sponsored or affiliate inventory, when eventually enabled, is explicitly labeled and cannot alter organic ranking or trust state.

## Data rules

The existing SQL/RLS migrations and tests are the historical v1 baseline. Before production seeding, implement and approve a city-aware v2 cutover: normalized geography/localizations, typed content, application-owned profiles, and Laravel-aligned authorization. Do not seed 200+ records or expose the old schema as the final launch contract before that cutover.

## Delivery order

1. Finish Telegram Bot -> Mini App -> Laravel authenticated vertical slice.
2. Build Laravel editorial/admin CRUD and moderation.
3. Implement city-aware schema v2 and migrate trust/evidence rules.
4. Seed a small set of Da Nang newcomer journeys; expand toward 200+ verified entries.
5. Run a closed pilot and measure successful guide journeys, zero-result searches, freshness, and trust incidents.
6. Add monetization only after repeat usage: affiliate/referral, clearly labeled sponsored inventory, then Stars products or concierge/B2B.
7. Add another city only after the Da Nang content and operations model repeats reliably.

## Operational minimum

Cloudflare DNS/TLS/WAF/CDN, one VPS for Laravel/worker/scheduler/reverse proxy, managed Supabase, managed Redis, Telegram webhook, secrets outside the repository, backups, health checks, queue monitoring, rate limits, and audit logs. Scale components only after measured bottlenecks.

## Decision rule

When a new feature is proposed, verify: Does it help a newcomer complete a trusted city task in two actions? Does it fit Bot -> TMA -> Laravel? Does it preserve evidence, moderation, and auditability? If not, defer it.
