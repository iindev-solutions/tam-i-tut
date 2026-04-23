# TamITut

Trust-first digital infrastructure for expats in Da Nang.

TamITut focuses on one core problem: expats need reliable housing, transport, and local services, but current channels are fragmented and risky. This project provides one trusted entry point with verification and moderation.

## Product Direction

- **Verified listings:** housing, bikes, jobs, local services
- **Safety layer:** public scam blacklist + evidence-based reporting
- **Fast access:** Telegram Mini App first, responsive web fallback
- **Search-first UX:** quick filters over deep category trees

## MVP Scope

1. Unified auth (Telegram in TMA, email on web)
2. Curated listing creation + browsing
3. Verification badges for trusted providers
4. Ratings and moderated reviews
5. Blacklist/reporting workflow
6. Admin moderation dashboard

## Planned Stack

- Frontend: Nuxt 4 + Nuxt UI + Tailwind
- Backend platform: Supabase (Postgres/Auth/Storage/Realtime)
- Integrations: Telegram Mini App + initData verification
- Deployment: Vercel or Cloudflare

## Repository Notes

This repository started from a vault-first starter template.

- `frontend/` contains working Nuxt starter baseline
- `backend/` still contains Laravel-oriented template artifacts and will be replaced/adapted as Supabase-based services are implemented
- `vault/` is the operational source of truth for planning and handoff

## Session Protocol

At session start read:

1. `vault/master_index.md`
2. `vault/WORKFLOW.md`
3. `vault/sprint.md`
4. `vault/resume-plan.md`
