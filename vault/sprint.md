# Sprint — TAMITUT Startup Critical Path Lock

## Goal

Finalize startup foundation so implementation work on Nuxt + Supabase + Telegram starts from explicit rules, not assumptions.

## Current Tasks

| # | Task | Status |
|---|---|---|
| 4.1 | Install project skill stack (Nuxt, Nuxt UI, Supabase, Vitest, Telegram) | DONE |
| 4.2 | Lock skill set reproducibility in `skills-lock.json` | DONE |
| 4.3 | Document startup critical path and companion specs in `vault/wiki/` | DONE |
| 4.4 | Lock schema contract v1 in `supabase-schema-rls-plan.md` | DONE |
| 4.5 | Draft migration file plan + RLS policy matrix v1 | DONE |
| 4.6 | Scaffold `supabase/` project + ordered migration/test files | DONE |
| 4.7 | Implement base schema SQL migrations (`001`–`013`) | DONE |
| 4.8 | Implement RLS helpers/policies (`014`–`018`) + role tests | IN_PROGRESS |
| 4.9 | Implement trust/safety guards (`019`–`020`) | DONE |
| 4.10 | Implement Telegram auth contract (signature + replay + error codes) | TODO |
| 4.11 | Create 200+ entry seeding backlog with evidence metadata | TODO |
| 4.12 | Wire CI quality gates (lint/type/test + DB policy tests) | TODO |
| 4.13 | Enable VPS Docker runtime validation (Supabase services) | TODO |

## Current Priority

1. complete role-policy SQL tests for `014`–`018`
2. enable Docker + run local Supabase migration/test validation
3. implement Telegram auth endpoint contract
4. create 200+ content seeding backlog and ownership
