# Sprint - TAMITUT Startup Critical Path Lock

## Goal

Ship lean Da Nang pilot: one Telegram Bot that launches one Telegram Mini App, with Laravel API and a server-rendered admin. No inline mode, public web, separate Nuxt admin, or monetization in first release.

Nuxt UI + Tailwind are the frontend UI standard.

## Current Tasks

| # | Task | Status |
|---|---|---|
| 4.1 | Install project skill stack (Nuxt, Nuxt UI, Supabase, Vitest, Telegram) | DONE |
| 4.2 | Lock skill set reproducibility in `skills-lock.json` | DONE |
| 4.3 | Consolidate project architecture into `vault/architecture.md` | DONE |
| 4.4 | Implement schema/RLS migrations and tests | DONE |
| 4.6 | Scaffold `supabase/` project + ordered migration/test files | DONE |
| 4.7 | Implement base schema SQL migrations (`001`-`013`) | DONE |
| 4.8 | Implement RLS helpers/policies (`014`-`018`) + role tests | DONE |
| 4.9 | Implement trust/safety guards (`019`-`020`) | DONE |
| 4.10 | Implement Telegram auth contract (signature + replay + error codes) | IN_PROGRESS |
| 4.11 | Create 200+ entry seeding backlog with evidence metadata | TODO |
| 4.12 | Wire CI quality gates (lint/type/test + DB policy tests) | DONE |
| 4.13 | Enable VPS Docker runtime validation (Supabase services) | DONE |
| 4.14 | Document end-to-end product/system/monetization master plan | DONE |
| 4.15 | Lock Laravel-only BFF and production session contract | TODO |
| 4.16 | Design city-aware normalized schema v2 and migration reset | TODO |
| 4.17 | Complete full Laravel runtime and protected API smoke slice | TODO |
| 4.18 | Build lean Bot -> TMA vertical slice with Nuxt UI/Tailwind | TODO |

## Current Priority

1. finish lean Bot -> TMA -> Laravel flow
2. use Laravel server-rendered admin for editorial CRUD/moderation
3. verify Nuxt 4 + Nuxt UI/Tailwind structure and first mobile TMA screen
4. seed only the content needed for first Da Nang newcomer journeys
5. defer inline mode, separate admin frontend, public web, payments, and multi-city expansion
