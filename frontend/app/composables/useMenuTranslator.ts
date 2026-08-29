import { computed, ref, shallowRef } from 'vue'
import { useI18n } from 'vue-i18n'

import { getSupabaseClient } from './useSupabaseClient'

/**
 * Menu translator feature logic (spec: vault/wiki/architecture/menu-translator-spec.md).
 * Owns the scan state machine: compress the photo, POST it to the
 * menu-translate Edge Function with the TMA session token, then hydrate the
 * matched dish_ids from the dictionary so the UI renders cards only from
 * our data. AI free-text stays on the line with a badge.
 */

export interface MenuItemView {
  id: string
  rawVi: string
  priceVnd: number | null
  name: string
  summary: string
  photoUrl: string | null
  tags: string[]
  isDictionary: boolean
  status: 'ai' | 'verified' | 'rejected'
}

export interface MenuSectionView {
  title: string
  items: MenuItemView[]
}

export type MenuScanState
  = | { phase: 'idle' }
    | { phase: 'scanning' }
    | { phase: 'error', code: string }

interface RawMenuItemRow {
  id: string
  raw_text_vi: string
  price_vnd: number | null
  dish_id: string | null
  ai_name_ru: string | null
  ai_name_en: string | null
  ai_summary_ru: string | null
  ai_summary_en: string | null
  status: 'ai' | 'verified' | 'rejected'
}

interface RawMenuRow {
  id: string
  status: 'ai' | 'verified'
  menu_items: RawMenuItemRow[] | null
}

interface DishRow {
  id: string
  slug: string
  photo_url: string | null
  tags: string[] | null
}

interface DishLocalizationRow {
  dish_id: string
  language: 'ru' | 'en'
  name: string
  summary: string
}

const MAX_SIDE = 1600

/** Canvas downscale + JPEG compress; keeps TMA uploads small and fast. */
async function compressPhoto(file: File): Promise<string> {
  const bitmap = await createImageBitmap(file)
  const scale = Math.min(1, MAX_SIDE / Math.max(bitmap.width, bitmap.height))
  const canvas = document.createElement('canvas')
  canvas.width = Math.round(bitmap.width * scale)
  canvas.height = Math.round(bitmap.height * scale)
  const ctx = canvas.getContext('2d')
  if (!ctx) throw new Error('canvas unavailable')
  ctx.drawImage(bitmap, 0, 0, canvas.width, canvas.height)
  bitmap.close()
  return canvas.toDataURL('image/jpeg', 0.8).replace(/^data:image\/jpeg;base64,/, '')
}

export function useMenuTranslator(placeId: () => string | null) {
  const { locale } = useI18n()
  const client = getSupabaseClient()
  const { session } = useAuth()
  const supabaseUrl = useRuntimeConfig().public.supabaseUrl

  const state = shallowRef<MenuScanState>({ phase: 'idle' })
  const sections = ref<MenuSectionView[]>([])
  const menuStatus = ref<'ai' | 'verified'>('ai')

  const hasSession = computed(() => Boolean(client && session.value?.authenticated))

  async function hydrateDictionary(itemRows: RawMenuItemRow[]): Promise<Map<string, { row: DishRow, loc: Map<string, DishLocalizationRow> }>> {
    const dishIds = [...new Set(itemRows.map(item => item.dish_id).filter((id): id is string => Boolean(id)))]
    const map = new Map<string, { row: DishRow, loc: Map<string, DishLocalizationRow> }>()
    if (!client || dishIds.length === 0) return map

    const [dishRes, locRes] = await Promise.all([
      client.from('dishes').select('id,slug,photo_url,tags').in('id', dishIds),
      client.from('dish_localizations').select('dish_id,language,name,summary').in('dish_id', dishIds).in('language', ['ru', 'en'])
    ])
    for (const row of (dishRes.data ?? []) as DishRow[]) {
      map.set(row.id, { row, loc: new Map() })
    }
    for (const row of (locRes.data ?? []) as DishLocalizationRow[]) {
      map.get(row.dish_id)?.loc.set(row.language, row)
    }
    return map
  }

  function buildSections(rawItems: RawMenuItemRow[], dict: Map<string, { row: DishRow, loc: Map<string, DishLocalizationRow> }>): MenuSectionView[] {
    // The function returns flat items ordered by (section*1000 + index);
    // rebuild a single grouped list by position order. Section titles live
    // server-side only as positions today - Phase B adds stored titles.
    const lang = locale.value === 'en' ? 'en' : 'ru'
    const items: MenuItemView[] = rawItems
      .filter(item => item.status !== 'rejected')
      .map((item) => {
        const entry = item.dish_id ? dict.get(item.dish_id) : undefined
        const loc = entry?.loc.get(lang) ?? entry?.loc.get('ru') ?? entry?.loc.get('en')
        return {
          id: item.id,
          rawVi: item.raw_text_vi,
          priceVnd: item.price_vnd,
          name: (loc?.name ?? (lang === 'en' ? item.ai_name_en : item.ai_name_ru)) ?? item.raw_text_vi,
          summary: loc?.summary ?? ((lang === 'en' ? item.ai_summary_en : item.ai_summary_ru) ?? ''),
          photoUrl: entry?.row.photo_url ?? null,
          tags: entry?.row.tags ?? [],
          isDictionary: Boolean(loc),
          status: item.status
        }
      })
    return [{ title: 'menu', items }]
  }

  async function loadCached(placeId: string): Promise<boolean> {
    if (!client || !placeId) return false
    const { data, error } = await client
      .from('menus')
      .select('id, status, menu_items(*)')
      .eq('place_id', placeId)
      .order('created_at', { ascending: false })
      .limit(1)
      .maybeSingle()
    if (error || !data) return false
    const menu = data as RawMenuRow
    const rawItems = menu.menu_items ?? []
    if (rawItems.length === 0) return false
    const dict = await hydrateDictionary(rawItems)
    sections.value = buildSections(rawItems, dict)
    menuStatus.value = menu.status
    return true
  }

  async function scan(file: File): Promise<void> {
    if (!client || !session.value?.authenticated) {
      state.value = { phase: 'error', code: 'unauthorized' }
      return
    }
    state.value = { phase: 'scanning' }
    try {
      // Cached menus skip the AI call entirely.
      const currentPlaceId = placeId()
      const hadCached = currentPlaceId ? await loadCached(currentPlaceId) : false
      if (hadCached) {
        state.value = { phase: 'idle' }
        return
      }

      const { data: sessionData } = await client.auth.getSession()
      const token = sessionData.session?.access_token
      if (!token) {
        state.value = { phase: 'error', code: 'unauthorized' }
        return
      }

      const response = await fetch(`${supabaseUrl}/functions/v1/menu-translate`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify({
          ...(placeId() ? { place_id: placeId() } : {}),
          photo_base64: await compressPhoto(file)
        })
      })
      const payload = await response.json()
      if (!response.ok) {
        state.value = { phase: 'error', code: payload?.error?.code ?? 'ai_unavailable' }
        return
      }
      const menu = payload.menu as RawMenuRow
      const rawItems = menu.menu_items ?? []
      const dict = await hydrateDictionary(rawItems)
      sections.value = buildSections(rawItems, dict)
      menuStatus.value = menu.status ?? 'ai'
      state.value = { phase: 'idle' }
    } catch {
      state.value = { phase: 'error', code: 'network' }
    }
  }

  return { state, sections, menuStatus, hasSession, scan }
}
