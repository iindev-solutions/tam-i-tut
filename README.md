# TAMITUT

> **Arrived — Opened — Know**

TAMITUT is a companion bot for Russian-speaking expats and nomads landing in Da Nang.

It is not a marketplace, not a classifieds aggregator, not a social feed.
It is a curated, trust-first guide maintained by the team and a trusted local network.

## Philosophy

Reputation before profit.
Fully verified entries are published as trusted.
Partially verified entries can appear only as **Under review** with clear warning.

## Target Audience

| Segment | Priority | Why |
|---|---|---|
| Russian-speaking expats (long-stay) | Core | high repeat use, strong word-of-mouth |
| Digital nomads | Core | high relocation friction, strong need for trusted orientation |
| Newly arrived relocants | Core | highest pain in first days, highest trust impact |
| Tourists (1–30 days) | Secondary | lower retention, still useful for organic spread |
| English-speaking expats | Secondary | expansion layer after RU-first experience is stable |

**Language strategy:** Russian is primary. English is a parallel content layer (not literal translation only).

## MVP Categories (All Included)

| Section | What is included | Why in MVP |
|---|---|---|
| 🏠 Housing | rent/subrent/coliving, district benchmarks, inspection checklist, scam patterns, verified contacts | highest pain + highest scam risk |
| 🛵 Transport | bike rent/buy, mechanics, price benchmarks, purchase checks, hidden practical spots | second-highest newcomer pain |
| 💱 Money | trusted exchange points, real rates, commissions, visa/insurance/notary basics | trust and loss-risk critical |
| 🍜 Food & Cafes | trusted places, average check, hidden locations, home-style options | improves retention and daily use |
| 🎉 Events | today/weekly events, guides, activities, social entry points | makes product useful beyond landing day |
| ⚠️ Safety | blacklist, common scam schemes, prevention steps, report channels | core differentiation and trust moat |

## UX Principles

- Main actions: **Find**, **Verified**, **Suggest place**, **Blacklist**, **Map** (web surface).
- Search-first behavior; avoid deep category trees.
- Max **2 taps** from intent to useful answer.

Examples:
- "bike" → transport guidance + trusted options
- "eat" → food guide + budget context
- "apartment near beach" → housing suggestions + checklist + benchmark prices

## Trust Model (Chosen: 3 Levels)

| Badge | Meaning | Publish Criteria |
|---|---|---|
| ✅ Verified by team | highest confidence | team personal check with proof, contact, and verification date |
| ⭐ Recommended by expats | medium-high confidence | at least **3 confirmations** from trusted local sources |
| 🆕 Under review | visible with warning | submitted and structured, but evidence threshold not fully met yet |

**Blacklist policy:** no evidence = no publication. False accusations destroy trust and must be prevented.

## Differentiators

- Benchmark prices to reduce newcomer overpaying
- Hidden places beyond obvious Google Maps top results
- Verified contacts instead of open ad-board noise
- Practical checklists for high-risk actions (rent, bike, exchange)
- Trust and safety before monetization

## MVP Non-Goals

- No in-bot transactions yet
- No open user classifieds/listings
- No in-bot housing booking
- No complex AI assistant in MVP
- No native mobile app before PMF signal

## 90-Day Success Metrics

| Metric | Target |
|---|---|
| Qualitative success stories | 50+ cases: "I landed, found what I needed, did not get scammed, recommended TAMITUT" |
| Verified positions in base | 200+ |
| Weekly active users | 500+ |
| User suggestions received | 30+ |
| Organic mentions in chats/channels | steady week-over-week growth |

## Key Risks and Mitigations

| Risk | Mitigation |
|---|---|
| low initial liquidity/content depth | launch with 200+ prepared entries, do not launch empty |
| trust gap | show badge + verification date + evidence discipline |
| category sprawl | keep strict 6-category MVP scope |
| support overload | FAQ + checklists + structured bot responses for common issues |
| easy product copying | defend with trust network and verification operations, not code |

## Repository Notes

- `frontend/` contains Nuxt baseline for Telegram-facing product UI.
- `backend/` still has transitional template artifacts and will be adapted for final stack.
- `vault/` is operational source of truth for planning and handoff.
