# Sprint - TAMITUT Supabase-Only Pilot

## Goal

Ship lean Da Nang pilot with one Telegram Bot, one Telegram Mini App, Supabase Edge Functions/Auth/Postgres/Storage, and Supabase Studio for private pilot operations. No Laravel, VPS backend, separate admin frontend, inline mode, public web, payments, or multi-city work in first release.

Nuxt UI + Tailwind remain the frontend UI standard.

## Current Tasks

| # | Task | Status |
|---|---|---|
| 5.1 | Lock Supabase-only runtime boundary | DONE |
| 5.2 | Remove Laravel transitional backend from active repository path | DONE |
| 5.3 | Align Nuxt public runtime config with Supabase | DONE |
| 5.4 | Implement Telegram bootstrap Edge Function | TODO |
| 5.5 | Validate Supabase Auth session exchange for Telegram identity | TODO |
| 5.6 | Connect Nuxt client with RLS-safe Supabase queries | TODO |
| 5.7 | Validate Supabase Studio editorial workflow | TODO |
| 5.8 | Approve city-aware schema v2 before content seeding | TODO |
| 5.9 | Seed first Da Nang newcomer journeys | TODO |
| 5.10 | Add off-site database and Storage backup runbook | TODO |

## Current Priority

1. implement and test `telegram-bootstrap` Edge Function
2. establish Supabase Auth session for Telegram users
3. connect Nuxt to RLS-safe Supabase data access
4. operate first editorial content through restricted Supabase Studio
5. seed only content needed for first Da Nang newcomer journeys
