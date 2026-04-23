# System Design — TAMITUT

## System Goal

Serve trusted, curated newcomer guidance for Da Nang with evidence-based publication and safety moderation.

## Product Surfaces

- **User surface:** Telegram-first bot/mini-app flow (plus web support where needed).
- **Ops surface:** internal tools for curators/moderators/admins.
- **Knowledge base:** `vault/` for product and engineering memory.

## Core Data Domains

1. `GuideEntry` — unit of curated content.
2. `Category` — one of six MVP areas.
3. `TrustedContact` — validated contact linked to entry.
4. `PriceSnapshot` — benchmark price with location/time context.
5. `ChecklistItem` — actionable checks for risky tasks.
6. `VerificationEvidence` — proof attached to entries.
7. `TrustBadge` — `verified_team`, `recommended_expats`, `under_review`.
8. `SafetyCase` — blacklist item with scheme/source/date/evidence.
9. `ScamPattern` — reusable prevention guidance.
10. `UserSuggestion` — inbound suggestion queue (not direct publication).
11. `AuditLog` — immutable moderation and publication history.

## Trust Enforcement Rules

- Content never bypasses evidence workflow.
- Badge assignment is rule-driven:
  - `verified_team`: direct team verification evidence required.
  - `recommended_expats`: >=3 confirmations from trusted sources.
  - `under_review`: structured and visible with warning, missing full threshold.
- Blacklist publication requires evidence, source, and moderation approval.
- All trust/safety state transitions are audit-logged.

## Data Flow

1. Curator creates or updates draft entry.
2. Evidence is attached (team proof and/or trusted confirmations).
3. Moderator reviews evidence and assigns trust badge.
4. Published entry becomes visible in user-facing flows.
5. Under-review entries are visible only with explicit warning state.
6. Safety updates (blacklist/scam patterns) are reviewed and published with evidence.

## UX Performance Constraints

- Search-first routing for core intents.
- Max 2 taps from intent to useful output in primary newcomer scenarios.
- Every visible item shows trust badge + last verification date.

## Access Boundaries

- `user`: read published guide/safety data and submit suggestions.
- `curator`: manage drafts and evidence attachments.
- `moderator`: approve, assign badges, publish safety cases.
- `admin`: role management, policy control, audit oversight.

## Operational Controls

- stale-entry detection for re-verification cycles
- moderation queue SLA for new suggestions/evidence updates
- incident process for disputed blacklist entries
- CI quality gates for lint/type/test and future DB policy checks

## Companion Specs

- `startup-critical-path.md`
- `supabase-schema-rls-plan.md`
- `trust-state-machine.md`
- `telegram-auth-contract.md`
- `../services/content-seeding-protocol.md`
- `../services/quality-gates-ci.md`

## Transitional Note

Repository still includes starter backend artifacts.
Implementation should follow this trust-first curated-guide design boundary.
