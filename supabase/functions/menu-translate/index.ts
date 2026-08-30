// Supabase Edge Function: menu-translate
// Menu translator Phase A (spec: vault/wiki/architecture/menu-translator-spec.md).
// Authenticated TMA session uploads a menu photo for a venue; the function
// rate-limits per user, returns the cached menu when fresh, otherwise calls
// Gemini 2.0 Flash with the dish dictionary and persists the structured scan.
//
// Required secrets (supabase secrets set ...):
//   GEMINI_API_KEY  - Google AI Studio key
//   SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY - provided by the platform
//
// Platform JWT verification stays ON for this function (default): the client
// sends the session access_token in the Authorization header.

import { buildPrompt, parseMenuResponse, type DictionaryEntry } from './contract.ts'

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY') ?? ''
const GEMINI_MODEL = Deno.env.get('GEMINI_MODEL') ?? 'gemini-3.6-flash'
const CACHE_DAYS = 7
const RATE_MAX_PER_HOUR = 3
const RATE_MAX_PER_DAY = 10
const MAX_BODY_BYTES = 4 * 1024 * 1024

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
}

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' }
  })

const fail = (code: string, message: string, status: number, extra: Record<string, unknown> = {}) =>
  json({ error: { code, message, ...extra } }, status)

Deno.serve(async (request: Request) => {
  // Browser clients preflight the JSON POST - without this the WebView
  // reports a network error before the function ever runs.
  if (request.method === 'OPTIONS') return new Response('ok', { headers: CORS_HEADERS })
  if (request.method !== 'POST') return fail('method_not_allowed', 'POST only', 405)
  if (!GEMINI_API_KEY) return fail('not_configured', 'GEMINI_API_KEY is not set', 503)

  const {
    createClient
  } = await import('https://esm.sh/@supabase/supabase-js@2')

  // 1) Auth: the platform verified the platform JWT; resolve the user.
  const userToken = request.headers.get('Authorization')?.replace(/^Bearer\s+/i, '') ?? ''
  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )
  const { data: userData, error: userError } = await admin.auth.getUser(userToken)
  if (userError || !userData?.user) return fail('unauthorized', 'valid session required', 401)
  const userId = userData.user.id

  // 2) Per-user rate limit (durable, same RPC the bootstrap function uses).
  const hourly = await admin.rpc('check_rate_limit', { p_key: `menu:h:${userId}`, p_max: RATE_MAX_PER_HOUR, p_window_seconds: 3600 })
  const daily = await admin.rpc('check_rate_limit', { p_key: `menu:d:${userId}`, p_max: RATE_MAX_PER_DAY, p_window_seconds: 86_400 })
  const retryAfter = Math.max(Number(hourly.data ?? 0), Number(daily.data ?? 0))
  if (retryAfter > 0) {
    return fail('rate_limited', 'too many scans, try later', 429, { retry_after: retryAfter })
  }

  // 3) Payload: { place_id: uuid, photo_base64: string }.
  const raw = await request.arrayBuffer()
  if (raw.byteLength > MAX_BODY_BYTES) return fail('payload_too_large', 'photo too large', 413)
  let payload: { place_id?: string, photo_base64?: string }
  try {
    payload = JSON.parse(new TextDecoder().decode(raw))
  } catch {
    return fail('bad_request', 'invalid JSON', 400)
  }
  const placeId = typeof payload.place_id === 'string' && /^[0-9a-f-]{36}$/.test(payload.place_id) ? payload.place_id : null
  const photoBase64 = (payload.photo_base64 ?? '').replace(/^data:image\/[a-z]+;base64,/, '')

  if (photoBase64.length < 1000) return fail('bad_request', 'photo_base64 required', 400)

  // 4) Venue optional: checked only when the scan is venue-bound.
  let place: { id: string, slug: string, status: string } | null = null
  if (placeId) {
    const { data } = await admin.from('places').select('id, slug, status').eq('id', placeId).maybeSingle()
    if (!data || data.status !== 'published') return fail('not_found', 'venue not found', 404)
    place = data
  }

  // 5) Cache-first (venue scans only): verified menu wins; fresh AI menu reused.
  if (placeId) {
    const since = new Date(Date.now() - CACHE_DAYS * 86_400_000).toISOString()
    const { data: cached } = await admin
      .from('menus')
      .select('id, status, created_at, menu_items(*)')
      .eq('place_id', placeId)
      .gte('created_at', since)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle()
    if (cached && (cached.status === 'verified' || cached.status === 'ai')) {
      return json({ cached: true, place_id: placeId, menu: cached })
    }
  }

  // 6) Dictionary for the prompt.
  const { data: dishRows } = await admin
    .from('dishes')
    .select('slug, name_vi')
    .eq('status', 'published')
    .order('slug')
  const dictionary: DictionaryEntry[] = dishRows ?? []
  if (dictionary.length === 0) return fail('not_configured', 'dish dictionary is empty', 503)

  // 7) Gemini call.
  let menu
  try {
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{
            parts: [
              { text: buildPrompt(dictionary) },
              { inline_data: { mime_type: 'image/jpeg', data: photoBase64 } }
            ]
          }],
          generationConfig: { temperature: 0.2, responseMimeType: 'application/json', maxOutputTokens: 8192 }
        })
      }
    )
    if (!response.ok) {
      console.error('gemini http', response.status, await response.text())
      return fail('ai_unavailable', 'translation service failed', 502)
    }
    const payloadJson = await response.json()
    const text: string | undefined = payloadJson?.candidates?.[0]?.content?.parts?.[0]?.text
    if (!text) return fail('ai_unavailable', 'empty model response', 502)
    menu = parseMenuResponse(text, dictionary.map(dish => dish.slug))
  } catch (error) {
    console.error('gemini parse failed', error)
    return fail('ai_unavailable', 'could not parse the menu', 502)
  }

  // 8) Persist: menu + items (service role writes; RLS not involved).
  const { data: menuRow, error: menuError } = await admin
    .from('menus')
    .insert(placeId ? { place_id: placeId, status: 'ai', scanned_by: userId } : { status: 'ai', scanned_by: userId })
    .select('id, status, created_at')
    .single()
  if (menuError || !menuRow) {
    console.error('menu insert failed', menuError)
    return fail('server_error', 'could not save the scan', 500)
  }

  const { data: dishIds } = await admin.from('dishes').select('id, slug').eq('status', 'published')
  const idBySlug = new Map((dishIds ?? []).map(dish => [dish.slug, dish.id]))

  const itemRows = menu.sections.flatMap((section, sectionIndex) =>
    section.items.map((item, itemIndex) => ({
      menu_id: menuRow.id,
      raw_text_vi: item.raw_vi,
      price_vnd: item.price_vnd,
      dish_id: item.dish_slug ? idBySlug.get(item.dish_slug) ?? null : null,
      ai_name_ru: item.ai_name_ru,
      ai_name_en: item.ai_name_en,
      ai_summary_ru: item.ai_summary_ru,
      ai_summary_en: item.ai_summary_en,
      confidence: item.confidence,
      status: 'ai',
      position: sectionIndex * 1000 + itemIndex
    }))
  )
  const { data: itemRowsInserted, error: itemsError } = await admin
    .from('menu_items')
    .insert(itemRows)
    .select('id, menu_id, raw_text_vi, price_vnd, dish_id, ai_name_ru, ai_name_en, ai_summary_ru, ai_summary_en, confidence, status, position')
  if (itemsError) {
    console.error('menu_items insert failed', itemsError)
    return fail('server_error', 'could not save the scan', 500)
  }

  // 8b) Long-tail photos: for lines that matched no dictionary dish, search
  // Wikimedia Commons for candidates and let Gemini vision pick the ones that
  // actually show the dish. Best effort - never blocks the answer. Capped at
  // 12 lines to bound cost; results land in menu_items.search_photo_url.
  const unmatchedIdx: number[] = []
  itemRows.forEach((row, idx) => {
    if (!row.dish_id && itemRowsInserted?.[idx]) unmatchedIdx.push(idx)
  })
  const unmatchedRows = unmatchedIdx.slice(0, 12)
  if (unmatchedRows.length > 0) {
    try {
      const candidatesByItem = await Promise.all(unmatchedRows.map(async (idx) => {
        const row = itemRows[idx]
        const query = encodeURIComponent(`${row.ai_name_en || row.raw_text_vi}`)
        const api = `https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=${query}&gsrnamespace=6&gsrlimit=6&prop=imageinfo&iiprop=url|mime&iiurlwidth=640&format=json`
        const res = await fetch(api, { headers: { 'User-Agent': 'TAMITUT-pilot/1.0 (aslavadoma@tuta.io)' } })
        if (!res.ok) return []
        const body = await res.json() as { query?: { pages?: Record<string, { imageinfo?: Array<{ thumburl?: string, mime?: string }> }> } }
        const pages = Object.values(body.query?.pages ?? {})
        return pages
          .map(page => page.imageinfo?.[0])
          .filter(info => info?.thumburl && (info.mime === 'image/jpeg' || info.mime === 'image/png'))
          .map(info => ({ thumburl: info!.thumburl!, title: info!.thumburl!.split('/').pop() ?? '' }))
      }))

      const ask = unmatchedRows.map((idx, i) => ({
        idx: i,
        dish: itemRows[idx].ai_name_en || itemRows[idx].ai_name_ru || itemRows[idx].raw_text_vi,
        candidates: candidatesByItem[i].map((cand, ci) => ({ ci, title: cand.title }))
      })).filter(entry => entry.candidates.length > 0)

      if (ask.length > 0) {
        const pickPrompt = [
          'You are an image picker for a food guide. For each dish, decide which candidate images (by title) actually show that dish.',
          'Titles are noisy - judge by the TITLE text only (describing what the file likely shows). Return STRICT JSON: {"picks":{"<idx>":[candidateCi,...]}}.',
          'Pick 0-2 candidates per dish; empty array if none plausibly match. No markdown.',
          JSON.stringify({ items: ask.map(a => ({ idx: a.idx, dish: a.dish, candidates: a.candidates })) })
        ].join('\n')
        const pickRes = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'x-goog-api-key': GEMINI_API_KEY },
            body: JSON.stringify({
              contents: [{ parts: [{ text: pickPrompt }] }],
              generationConfig: { temperature: 0, responseMimeType: 'application/json', maxOutputTokens: 2048 }
            })
          }
        )
        if (pickRes.ok) {
          const pickBody = await pickRes.json() as { candidates?: Array<{ content?: { parts?: Array<{ text?: string }> } }> }
          const pickText = pickBody.candidates?.[0]?.content?.parts?.[0]?.text ?? '{}'
          const picks = (JSON.parse(pickText.replace(/^```(?:json)?|```$/g, '').trim()) as { picks?: Record<string, number[]> }).picks ?? {}
          for (const [idxStr, cis] of Object.entries(picks)) {
            const askPos = Number(idxStr)
            const itemIdx = unmatchedRows[askPos]
            const first = Array.isArray(cis) ? cis[0] : undefined
            const cand = ask.find(a => String(a.idx) === idxStr) && first !== undefined
              ? candidatesByItem[askPos]?.[first]
              : undefined
            if (cand?.thumburl) {
              await admin.from('menu_items').update({ search_photo_url: cand.thumburl }).eq('id', itemRowsInserted![itemIdx].id)
              ;(itemRowsInserted as Array<Record<string, unknown>>)[itemIdx].search_photo_url = cand.thumburl
            }
          }
        }
      }
    } catch (error) {
      console.error('long-tail photos failed', error)
    }
  }

  // 9) Photo evidence (best effort - a failed upload never blocks the answer).
  const photoPath = `${place ? `${place.slug}/` : 'global/'}${menuRow.id}.jpg`
  try {
    const bytes = Uint8Array.from(atob(photoBase64), c => c.charCodeAt(0))
    await admin.storage.from('menu-photos').upload(photoPath, bytes, {
      contentType: 'image/jpeg',
      upsert: true
    })
    await admin.from('menus').update({ photo_path: photoPath }).eq('id', menuRow.id)
  } catch (error) {
    console.error('photo upload failed', error)
  }

  return json({ cached: false, place_id: placeId, menu: { ...menuRow, menu_items: itemRowsInserted } })
})
