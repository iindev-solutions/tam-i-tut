# Menu Translator — Spec (feature: "Меню с переводом")

Status: DRAFT for founder review. No code written yet.
Author: session 2026-08-29. Stack: existing (Nuxt + Supabase Edge Functions/Postgres/Storage).

## 1. Problem

Tourists at local Da Nang (later: any) venues face Vietnamese-only menus without
photos. They cannot tell what a dish is, what it costs, or whether it is spicy.

## 2. Key insight

Vietnamese menus are standardized: ~300-500 canonical dishes cover the vast
majority of menu lines nationwide. So the product is a **dish dictionary**
(translated once, reused everywhere) + an **AI matcher** that maps a concrete
menu's lines onto the dictionary and translates the residue. The dictionary is
the accumulating moat; AI only does the long tail.

## 3. User flow

1. Venue detail page (`/places/[slug]`) gets a "Menu with translation" action.
2. User photographs the menu (`<input type="file" capture="environment">` -
   works in the TMA WebView; camera permission fallback = file picker).
3. Client compresses the photo (~1600px, JPEG q0.8, target < 400 KB) and POSTs
   it to the `menu-translate` Edge Function with the venue id.
4. Function: auth check -> per-user rate limit -> cache check -> vision LLM ->
   structured JSON -> persist -> respond. 3-7 s cold, instant on cache hit.
5. UI: grouped list (LLM returns section headers), each line = VI name +
   RU/EN translation + price. Tap -> bottom sheet with the dish card rendered
   ONLY from our dictionary (photo, description, tags). Unmatched lines show
   the AI translation under a "machine translation" badge.
6. Menu persists per venue: the next visitor gets the cached, and later
   curated, version.

## 4. Data model (schema v3 slice)

```sql
-- Canonical dish dictionary (global, not per venue/city)
dishes (
  id uuid pk default gen_random_uuid(),
  slug text unique not null,           -- 'pho-bo', 'bun-cha-ca', ...
  name_vi text not null,
  photo_url text,                      -- sourced; null = honest placeholder
  tags text[] default '{}',            -- 'soup','spicy','noodle','drink',...
  verified bool default false,         -- curated dictionary entry
  status public.entry_status default 'draft',
  created_at/updated_at timestamptz
)
dish_localizations (
  dish_id fk dishes on delete cascade,
  language public.language_code,       -- ru|en
  name text not null, summary text not null,
  pk (dish_id, language)
)

-- One scan of one venue's menu
menus (
  id uuid pk default gen_random_uuid(),
  place_id fk places on delete cascade,
  photo_path text,                     -- Storage object (private bucket)
  status text check in ('ai','verified') default 'ai',
  scanned_by uuid references auth.users,  -- nullable
  created_at/updated_at timestamptz
)

menu_items (
  id uuid pk default gen_random_uuid(),
  menu_id fk menus on delete cascade,
  raw_text_vi text not null,
  price_vnd integer check (price_vnd >= 0),
  dish_id fk dishes,                   -- null = not matched (long tail)
  ai_name_ru text, ai_name_en text,
  ai_summary_ru text, ai_summary_en text,
  confidence smallint check (confidence between 0 and 100),
  status text check in ('ai','verified','rejected') default 'ai',
  position smallint,
  created_at timestamptz
)
```

RLS posture (matches house patterns):
- `dishes`/`dish_localizations`: select for authenticated on published rows;
  write = admin/moderator only (migration 025 pattern).
- `menus`/`menu_items`: select for authenticated (menu content is public-facing,
  AI rows carry the badge); insert/update = service_role only (the Edge
  Function writes with SUPABASE_SERVICE_ROLE_KEY); curation updates = admin.
- pgTAP suites: reader sees published dishes + venue menus; reader cannot
  insert; AI rows hidden? No - visible with badge (product decision: honesty
  over hiding); rejected items hidden.

## 5. AI pipeline

- Provider: **Gemini 2.0 Flash** (cheapest vision, strong Vietnamese, free
  tier 1500 req/day covers the pilot). Key lives in `supabase secrets set
  GEMINI_API_KEY`. Swap-friendly: one adapter module, request/response JSON
  contract documented here.
- Prompt contract (system):
  - Input: menu photo + the dictionary (slug + name_vi list, compact form).
  - Output STRICT JSON: `{ "sections": [{ "title_vi": "...",
    "items": [{ "raw_vi": "...", "price_vnd": number|null, "dish_slug":
    slug|null, "ai_name_ru": "...", "ai_name_en": "...", "ai_summary_ru":
    "...", "ai_summary_en": "...", "confidence": 0-100 }] }] }`.
  - Rules baked into the prompt: `dish_slug` MUST come from the provided
    list or be null; never invent prices; copy `raw_vi` verbatim; summaries
    one sentence; confidence reflects legibility.
- Constrained rendering: the client's dish card renders only
  `dish_localizations` data. AI free-text is shown as line translation with a
  "machine translation" badge until curated. No AI text ever becomes
  dictionary content automatically.
- Cache/dedupe: if the venue has a menu with status 'verified', return it
  without an AI call. If an 'ai' menu exists and is < 7 days old, return it.
  Re-scan request with `force=1` bypasses (admin only).

## 6. Trust model (reuses house patterns)

- Item status: `ai` (badge "машинный перевод") -> `verified` (curator approved
  text and/or dictionary link) -> `rejected` (hidden).
- Dictionary entries are curated only (verified=true by an admin) - same
  discipline as places/guides. AI never self-publishes dictionary rows.
- Curation queue = admin UI slice listing unmatched/low-confidence items
  across venues: link to a dish, fix texts, verify. Each fix benefits every
  future scan containing that line.

## 7. Abuse & limits

- Auth required: `verify_jwt = true` on the function; TMA session only.
- Rate limit: reuse the durable per-key `check_rate_limit` RPC with a new
  bucket key `menu:<user_id>` - e.g. 10 scans/day, 3/hour (tunable).
- Payload guard: max ~4 MB body, image type sniffing, 1 photo per request.
- Cost bomb: cache-first (section 5) + daily cap + free-tier ceiling.

## 8. Storage

- Bucket `menu-photos` (private). Upload = Edge Function only (service key);
  client never talks to Storage directly. Retention: photos are evidence for
  curation - keep 90 days, then purge by cron (pg_cron already in stack).
  This is the first real Storage usage: policies + cron purge land with it.

## 9. Costs (pilot scale)

- Vision scan: ~$0.001-0.002 (Flash pricing) -> 1,000 scans ≈ $1-2/mo.
  Free tier: 0 while under rate limits.
- Storage: hundreds of ~300 KB photos = well under any tier.
- Dictionary sourcing: session time only (same pass as venue photos).

## 10. Pitfalls & mitigations (explicit)

| Pitfall | Mitigation |
|---|---|
| LLM hallucinates dishes/prices | slug must be from the provided dictionary or null; card renders dictionary only; prices verbatim-copy rule; confidence gate |
| Machine text erodes trust (project DNA) | badge until curated; dictionary entries are admin-only; rejected state |
| Cost abuse | auth + per-user rate limit + cache-first + free-tier cap |
| Long-tail items without dictionary match | honest "machine translation" line; unmatched queue feeds curation; dictionary grows |
| Missing dish photos | sourced top-50 first; honest placeholder elsewhere (no fabrication rule) |
| Latency 3-7 s | skeletons + progress copy; cache makes repeats instant; compression cuts upload time |
| Bad photos/handwriting | partial results + explicit "legibility low" state; force re-scan by admin |
| Key leakage | GEMINI_API_KEY only in Edge Function secrets; never client |
| Storage sprawl | private bucket, function-only upload, 90-day cron purge |

## 11. Phasing

- **Phase A - MVP (est. 2-3 sessions)**: dictionary table + seed 50 top dishes
  (names_vi/ru/en, summaries, sourced photos for as many as possible);
  `menu-translate` function (auth, rate limit, Gemini adapter, persistence);
  `/places/[slug]/menu` scan page + item sheet; RLS + pgTAP suites;
  "machine translation" badge. No admin UI yet.
- **Phase B - curation**: admin queue (unmatched/low-confidence), item
  verify/reject, menu status verified, Storage purge cron.
- **Phase C - later**: offline phrase pack for top-100 dishes; venue QR ->
  deep link `?menu`; other categories (markets); translation quality scoring.

## 12. Open questions (founder)

1. Gemini OK as provider? (Alternative: GPT-4o-mini - similar cost, weaker VN.)
2. Keep "pilot = menu photos stored 90 days" retention?
3. Dictionary scope at seed: Vietnamese food only, 50 entries, Da Nang menu
   styles first?
4. Rate limit 10 scans/day per user - agree?
