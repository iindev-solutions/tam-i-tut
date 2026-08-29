/**
 * Pure contract for the menu-translate Edge Function: prompt building and
 * strict parsing of the Gemini response. Kept free of Deno imports so the
 * frontend vitest suite can unit-test it (see `#menu-contract` alias).
 */

export interface DictionaryEntry {
  slug: string
  name_vi: string
}

export interface ParsedMenuItem {
  raw_vi: string
  price_vnd: number | null
  dish_slug: string | null
  ai_name_ru: string | null
  ai_name_en: string | null
  ai_summary_ru: string | null
  ai_summary_en: string | null
  confidence: number
}

export interface ParsedMenuSection {
  title_vi: string
  items: ParsedMenuItem[]
}

export interface ParsedMenu {
  sections: ParsedMenuSection[]
}

/** Compact dictionary block for the prompt: one dish per line, pipe-joined. */
export function buildDictionaryBlock(dishes: DictionaryEntry[]): string {
  return dishes.map(dish => `${dish.slug}|${dish.name_vi}`).join('\n')
}

export function buildPrompt(dictionary: DictionaryEntry[]): string {
  return [
    'You are a menu translator for Vietnamese street-food venues. The photo shows a paper menu (possibly crumpled, partially lit).',
    'For EVERY legible line item: copy the Vietnamese text verbatim into raw_vi, extract the price in thousand VND (e.g. "30k" or "30.000" -> 30000; null if absent), translate the name to Russian and English, and write a ONE-sentence summary in both languages.',
    'If the line clearly matches one of the dictionary dishes, set dish_slug to that slug. Otherwise dish_slug MUST be null. Never invent slugs.',
    'Group items into sections using the menu headers; use the header text as title_vi. If there are no headers, use one section with title_vi "Menu".',
    'confidence (0-100) reflects how legible the line is in the photo. Skip lines you cannot read at all.',
    'Respond with STRICT JSON only, no markdown fences:',
    '{"sections":[{"title_vi":"...","items":[{"raw_vi":"...","price_vnd":null,"dish_slug":null,"ai_name_ru":"...","ai_name_en":"...","ai_summary_ru":"...","ai_summary_en":"...","confidence":80}]}]}',
    '',
    'Dictionary (slug|name_vi):',
    buildDictionaryBlock(dictionary)
  ].join('\n')
}

const asTrimmedString = (value: unknown): string | null =>
  typeof value === 'string' && value.trim() !== '' ? value.trim() : null

const asPrice = (value: unknown): number | null => {
  const n = typeof value === 'number' ? value : Number(value)
  return Number.isFinite(n) && n >= 0 && n < 100_000_000 ? Math.round(n) : null
}

const asConfidence = (value: unknown): number => {
  const n = typeof value === 'number' ? value : Number(value)
  return Number.isFinite(n) ? Math.min(100, Math.max(0, Math.round(n))) : 0
}

/** Normalizes one raw item; drops entries with no Vietnamese text. */
function parseItem(raw: unknown, allowedSlugs: Set<string> | null): ParsedMenuItem | null {
  if (typeof raw !== 'object' || raw === null) return null
  const item = raw as Record<string, unknown>
  const rawVi = asTrimmedString(item.raw_vi)
  if (!rawVi) return null
  const slug = asTrimmedString(item.dish_slug)
  // Dictionary-membership rule: a slug that is not in the provided dictionary
  // is nulled out (the model must not invent dishes; spec section 5).
  const knownSlug = slug && /^[a-z0-9-]+$/.test(slug) && (!allowedSlugs || allowedSlugs.has(slug))
    ? slug
    : null
  return {
    raw_vi: rawVi,
    price_vnd: asPrice(item.price_vnd),
    dish_slug: knownSlug,
    ai_name_ru: asTrimmedString(item.ai_name_ru),
    ai_name_en: asTrimmedString(item.ai_name_en),
    ai_summary_ru: asTrimmedString(item.ai_summary_ru),
    ai_summary_en: asTrimmedString(item.ai_summary_en),
    confidence: asConfidence(item.confidence)
  }
}

/**
 * Parses and sanitizes the model response. Accepts either the bare object or
 * a fenced/string-wrapped variant; throws on structurally unusable output so
 * the caller can fail gracefully. When `allowedSlugs` is provided, dish_slug
 * values outside the dictionary are nulled (dictionary-membership rule).
 */
export function parseMenuResponse(text: string, allowedSlugs?: string[]): ParsedMenu {
  let candidate = text.trim()
  const fence = candidate.match(/```(?:json)?\s*([\s\S]*?)```/)
  if (fence) candidate = fence[1].trim()
  const allowed = allowedSlugs ? new Set(allowedSlugs) : null

  let parsed: unknown
  try {
    parsed = JSON.parse(candidate)
  } catch {
    throw new Error('model response is not valid JSON')
  }
  // Some models wrap the payload: {"result": {...}} or a bare array of sections.
  if (Array.isArray(parsed)) parsed = { sections: parsed }
  if (typeof parsed === 'object' && parsed !== null && Array.isArray((parsed as Record<string, unknown>).result)) {
    parsed = { sections: (parsed as Record<string, unknown>).result }
  }

  const sections = (parsed as Record<string, unknown>).sections
  if (!Array.isArray(sections)) throw new Error('model response has no sections array')

  const clean: ParsedMenu = { sections: [] }
  for (const rawSection of sections) {
    if (typeof rawSection !== 'object' || rawSection === null) continue
    const section = rawSection as Record<string, unknown>
    const items = Array.isArray(section.items) ? section.items : []
    const cleanItems = items
      .map(item => parseItem(item, allowed))
      .filter((item): item is ParsedMenuItem => item !== null)
    if (cleanItems.length === 0) continue
    clean.sections.push({
      title_vi: asTrimmedString(section.title_vi) ?? 'Menu',
      items: cleanItems
    })
  }
  if (clean.sections.length === 0) throw new Error('model response contains no usable items')
  return clean
}
