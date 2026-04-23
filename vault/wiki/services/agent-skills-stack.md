# Agent Skills Stack — TAMITUT

## Purpose

Reduce implementation drift when working with Nuxt 4, Nuxt UI, Supabase, testing, and Telegram integration.

This file defines the project-level skill baseline and how to keep it reproducible.

## Installed Project Skills

| Skill | Source | Primary Use |
|---|---|---|
| `nuxt` | `antfu/skills` | Nuxt 4 patterns, routing, data fetching, SSR/hydration safety |
| `nuxt-ui` | `nuxt/ui` | `@nuxt/ui` v4 components, theming, UI composition |
| `supabase` | `supabase/agent-skills` | Supabase Auth/DB/Storage/Edge/RLS workflows |
| `supabase-postgres-best-practices` | `supabase/agent-skills` | Postgres schema/query/index/performance guidance |
| `vitest` | `antfu/skills` | unit test patterns and test setup discipline |
| `vue-testing-best-practices` | `antfu/skills` | Vue component testing patterns with Vitest |
| `telegram-bot-builder` | `sickn33/antigravity-awesome-skills` | Telegram bot/mini-app integration workflows |

## Lock File

- `skills-lock.json` is the reproducibility source for installed skills.
- Commit lock updates whenever skill set changes.

## Bootstrap Commands

Install/restore skills for this project:

```bash
npx skills experimental_install -y
```

List currently available project skills:

```bash
npx skills ls --json
```

Update skills to latest lockable versions:

```bash
npx skills update -p -y
```

## Usage Policy

1. For Nuxt app logic, load `nuxt` first.
2. For UI component tasks, load `nuxt-ui` before implementation.
3. For any DB/Auth/storage task, load `supabase` + `supabase-postgres-best-practices`.
4. For test-writing tasks, load `vitest` + `vue-testing-best-practices`.
5. For Telegram transport/auth behavior, load `telegram-bot-builder`.

## Planned TAMITUT-Specific Local Skills

These are project-tailored skills planned next:

1. `tamitut-domain-guardrails` — enforce non-marketplace boundaries and trust-first product decisions.
2. `tamitut-trust-policy` — encode badge transitions and evidence publication rules.
3. `tamitut-supabase-rls-checklist` — fast RLS and policy review checklist.
4. `tamitut-telegram-auth` — strict Telegram auth contract checklist.
