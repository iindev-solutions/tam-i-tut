# Sprint — TAMITUT Startup Critical Path Lock

## Goal

Finalize startup foundation so implementation work on Nuxt + Supabase + Telegram starts from explicit rules, not assumptions.

## Current Tasks

| # | Task | Status |
|---|---|---|
| 4.1 | Install project skill stack (Nuxt, Nuxt UI, Supabase, Vitest, Telegram) | DONE |
| 4.2 | Lock skill set reproducibility in `skills-lock.json` | DONE |
| 4.3 | Document startup critical path and companion specs in `vault/wiki/` | DONE |
| 4.4 | Convert schema/RLS plan into first SQL migration draft | TODO |
| 4.5 | Implement trust-state transition constraints in DB layer | TODO |
| 4.6 | Implement Telegram auth contract (signature + replay + error codes) | TODO |
| 4.7 | Create 200+ entry seeding backlog with evidence metadata | TODO |
| 4.8 | Wire CI quality gates (lint/type/test + DB policy tests) | TODO |

## Current Priority

1. first Supabase schema migration + RLS matrix tests
2. trust badge transition enforcement and audit events
3. Telegram auth endpoint contract implementation
4. seed backlog operations plan to avoid empty launch
