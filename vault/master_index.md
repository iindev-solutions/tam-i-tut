# Master Index - Project Vault

## Overview

`vault/` is the project memory system.

It is the canonical source of truth for:

- current state
- active work
- architecture decisions
- code map
- next step
- handoff notes

## Start Here

At the start of every session, read:

1. `vault/master_index.md`
2. `vault/WORKFLOW.md`
3. `vault/sprint.md`
4. `vault/resume-plan.md`

## Core Files

| File | Purpose |
|------|---------|
| `vault/WORKFLOW.md` | Mandatory operating protocol |
| `vault/SESSION_LEDGER.md` | Short session-by-session notes |
| `vault/sprint.md` | Current sprint and priorities |
| `vault/resume-plan.md` | Exact stop point and next action |
| `vault/CODE_MAP.md` | Code inventory |
| `vault/logs/changelog.md` | Change and verification history |

## Architecture

- `vault/architecture.md` - single current product, runtime, trust, data, and delivery architecture
- `vault/design.md` - TMA visual system rules and verification checklist
- `vault/wiki/architecture/auth-flow.md` - role/session auth details
- `vault/wiki/architecture/trust-state-machine.md` - trust transition rules
- `vault/wiki/architecture/telegram-auth-contract.md` - Telegram auth validation contract
- `vault/wiki/architecture/schema-v2-city-aware.md` - city-aware v2 cutover design (cities/places/reviews/RLS)
- `vault/wiki/services/` - operational runbooks and service-specific notes

## Rule

All new content inside `vault/` must be written in English.
