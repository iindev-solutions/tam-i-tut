import { ref } from 'vue'
import { useI18n } from 'vue-i18n'

import type { Place, Review } from '~/types/content'
import { getSupabaseClient } from './useSupabaseClient'

/**
 * Real admin data layer (schema v2): loads and mutates content as the logged-in
 * admin role through RLS. Replaces the mock `useMockDb` in the `/admin` panel.
 *
 * Rows are the PostgREST shapes (snake_case); the pages map them to table rows.
 */

export interface AdminCityRow {
  slug: string
  name_en: string
  name_ru: string
  flag: string
  is_active: boolean
  sort_order: number
}

export interface AdminLocalization {
  name: string
  area: string
  summary: string
}

export interface AdminPlaceRow {
  id: string
  city_slug: string
  slug: string
  place_type: Place['type']
  price_level: Place['priceLevel']
  verified: boolean
  status: Place['status']
  updated_at: string
  localizations: { ru?: AdminLocalization, en?: AdminLocalization }
}

export interface AdminReviewRow {
  id: string
  place_id: string
  place_name: string
  author: string
  rating: number
  body: string | null
  status: Review['status']
  created_at: string
}

export interface AdminGuideRow {
  id: string
  category_slug: string
  title: string
  summary: string
  language: 'ru' | 'en'
  status: 'draft' | 'published' | 'archived'
  last_verified_at: string | null
  verification_due_at: string | null
}

export interface AdminDistrictRow {
  id: string
  city_slug: string
  slug: string
  geometry: { type: 'Polygon', coordinates: number[][][] } | null
  price_level: Place['priceLevel']
  sort_order: number
  localizations: { ru?: AdminDistrictLocalization, en?: AdminDistrictLocalization }
}

export interface AdminDistrictInput {
  id?: string
  city_slug: string
  slug: string
  geometry: { type: 'Polygon', coordinates: number[][][] }
  price_level: Place['priceLevel']
  sort_order: number
  ru: AdminDistrictLocalization
  en: AdminDistrictLocalization
}

export interface AdminDistrictLocalization {
  name: string
  area: string
  rentRange: string
  distanceToBeach: string
  summary: string
  bestFor: string[]
}

/** One curation-queue row: an AI menu line that matched no dictionary dish
 * or matched with low confidence. Admin links it to a dish or rejects it. */
export interface AdminMenuQueueRow {
  id: string
  menu_id: string
  raw_text_vi: string
  price_vnd: number | null
  dish_id: string | null
  ai_name_ru: string | null
  ai_name_en: string | null
  confidence: number | null
  status: 'ai' | 'verified' | 'rejected'
  place_name: string
  place_slug: string
}

export interface AdminMenuRow {
  id: string
  place_name: string
  status: 'ai' | 'verified'
  created_at: string
  total: number
  curated: number
}

export interface AdminDishOption {
  id: string
  slug: string
  nameVi: string
  name: string
}

export function useAdminDb() {
  const client = getSupabaseClient()
  const { locale } = useI18n()

  const cities = ref<AdminCityRow[]>([])
  const places = ref<AdminPlaceRow[]>([])
  const reviews = ref<AdminReviewRow[]>([])
  const guides = ref<AdminGuideRow[]>([])
  const districts = ref<AdminDistrictRow[]>([])
  const menuQueue = ref<AdminMenuQueueRow[]>([])
  const menus = ref<AdminMenuRow[]>([])
  const dishes = ref<AdminDishOption[]>([])
  const menuScanCount7d = ref(0)
  const loading = ref(false)
  const error = ref<string | null>(null)

  const list = async (table: string, select: string, order?: string) => {
    let query = client!.from(table).select(select)
    if (order) query = query.order(order)
    const { data, error: err } = await query
    if (err) throw err
    return (data ?? []) as unknown as Array<Record<string, unknown>>
  }

  const loadCities = async () => {
    cities.value = (await list('cities', 'slug,name_en,name_ru,flag,is_active,sort_order', 'sort_order')) as unknown as AdminCityRow[]
  }

  const loadPlaces = async () => {
    const [placeRows, locRows] = await Promise.all([
      list('places', 'id,city_slug,slug,place_type,price_level,verified,status,updated_at', 'updated_at'),
      list('place_localizations', 'place_id,language,name,area,summary')
    ])
    const byPlace = new Map<string, { ru?: AdminLocalization, en?: AdminLocalization }>()
    for (const loc of locRows as Array<Record<string, unknown>>) {
      const entry = byPlace.get(loc.place_id as string) ?? {}
      entry[loc.language as 'ru' | 'en'] = {
        name: loc.name as string,
        area: loc.area as string,
        summary: loc.summary as string
      }
      byPlace.set(loc.place_id as string, entry)
    }
    places.value = (placeRows as Array<Record<string, unknown>>).map(row => ({
      id: row.id as string,
      city_slug: row.city_slug as string,
      slug: row.slug as string,
      place_type: row.place_type as AdminPlaceRow['place_type'],
      price_level: row.price_level as AdminPlaceRow['price_level'],
      verified: row.verified as boolean,
      status: row.status as AdminPlaceRow['status'],
      updated_at: row.updated_at as string,
      localizations: byPlace.get(row.id as string) ?? {}
    }))
  }

  const loadReviews = async () => {
    const [reviewRows, placeRows] = await Promise.all([
      list('reviews', 'id,place_id,author,rating,body,status,created_at'),
      list('places', 'id,slug,status')
    ])
    const names = new Map<string, string>()
    for (const p of placeRows as Array<{ id: string, slug: string }>) names.set(p.id, p.slug)
    reviews.value = (reviewRows as Array<Record<string, unknown>>).map(row => ({
      id: row.id as string,
      place_id: row.place_id as string,
      place_name: names.get(row.place_id as string) ?? '-',
      author: row.author as string,
      rating: row.rating as number,
      body: (row.body as string | null) ?? null,
      status: row.status as AdminReviewRow['status'],
      created_at: row.created_at as string
    }))
  }

  const loadGuides = async () => {
    guides.value = (await list(
      'guide_entries',
      'id,category_slug,title,summary,language,status,last_verified_at,verification_due_at',
      'created_at'
    )) as unknown as AdminGuideRow[]
  }

  const loadDistricts = async () => {
    const [districtRows, locRows] = await Promise.all([
      list('districts', 'id,city_slug,slug,geometry,price_level,sort_order', 'sort_order'),
      list('district_localizations', 'district_id,language,name,area,rent_range,distance_to_beach,summary,best_for')
    ])
    const byDistrict = new Map<string, { ru?: AdminDistrictLocalization, en?: AdminDistrictLocalization }>()
    for (const loc of locRows as Array<Record<string, unknown>>) {
      const entry = byDistrict.get(loc.district_id as string) ?? {}
      entry[loc.language as 'ru' | 'en'] = {
        name: loc.name as string,
        area: loc.area as string,
        rentRange: loc.rent_range as string,
        distanceToBeach: loc.distance_to_beach as string,
        summary: loc.summary as string,
        bestFor: (loc.best_for as string[]) ?? []
      }
      byDistrict.set(loc.district_id as string, entry)
    }
    districts.value = (districtRows as Array<Record<string, unknown>>).map(row => ({
      id: row.id as string,
      city_slug: row.city_slug as string,
      slug: row.slug as string,
      geometry: (row.geometry as AdminDistrictRow['geometry']) ?? null,
      price_level: row.price_level as AdminDistrictRow['price_level'],
      sort_order: row.sort_order as number,
      localizations: byDistrict.get(row.id as string) ?? {}
    }))
  }

  const saveDistrict = async (d: AdminDistrictInput) => {
    const base = {
      city_slug: d.city_slug,
      slug: d.slug,
      geometry: d.geometry,
      price_level: d.price_level,
      sort_order: d.sort_order
    }
    let districtId = d.id
    if (districtId) {
      await patch('districts', 'id', districtId, base)
      await audit('district_update', 'districts', districtId ?? null, base)
    } else {
      const { data, error: err } = await client!.from('districts').insert(base).select('id').single()
      if (err) throw err
      districtId = data.id
      await audit('district_create', 'districts', districtId ?? null, base)
    }
    for (const lang of ['ru', 'en'] as const) {
      const loc = d[lang]
      const body = {
        district_id: districtId,
        language: lang,
        name: loc.name,
        area: loc.area,
        rent_range: loc.rentRange ?? '',
        distance_to_beach: loc.distanceToBeach ?? '',
        summary: loc.summary,
        best_for: loc.bestFor ?? []
      }
      const { error: err } = await client!.from('district_localizations').upsert(body, { onConflict: 'district_id,language' })
      if (err) throw err
    }
    await loadDistricts()
  }

  /** Curation queue (Phase B): AI menu lines that matched no dictionary dish
   * or matched with confidence < 60. Admin RLS (migration 049) exposes the
   * rejected/draft-venue rows the reader policies hide. */
  const loadMenuQueue = async () => {
    const { data, error: err } = await client!
      .from('menu_items')
      .select('id, menu_id, raw_text_vi, price_vnd, dish_id, ai_name_ru, ai_name_en, confidence, status, menus!inner(status, places(slug, place_localizations(name, language)))')
      .eq('status', 'ai')
      .or('dish_id.is.null,confidence.lt.60')
      .order('created_at', { ascending: false })
      .limit(200)
    if (err) throw err
    menuQueue.value = ((data ?? []) as Array<Record<string, unknown>>).map((row) => {
      const menu = row.menus as Array<Record<string, unknown>> | undefined
      const place = menu?.[0]?.places as Array<Record<string, unknown>> | undefined
      const locs = place?.[0]?.place_localizations as Array<{ language: string, name: string }> | undefined
      return {
        id: row.id as string,
        menu_id: row.menu_id as string,
        raw_text_vi: row.raw_text_vi as string,
        price_vnd: (row.price_vnd as number | null) ?? null,
        dish_id: (row.dish_id as string | null) ?? null,
        ai_name_ru: (row.ai_name_ru as string | null) ?? null,
        ai_name_en: (row.ai_name_en as string | null) ?? null,
        confidence: (row.confidence as number | null) ?? null,
        status: row.status as AdminMenuQueueRow['status'],
        place_name: locs?.find(l => l.language === 'ru')?.name ?? locs?.[0]?.name ?? place?.[0]?.slug as string ?? '-',
        place_slug: (place?.[0]?.slug as string) ?? '-'
      }
    })
  }

  /** Recent scans grouped per venue, with a curated-items counter to decide
   * whether a menu can be marked verified. */
  const loadMenus = async () => {
    const { data, error: err } = await client!
      .from('menus')
      .select('id, status, created_at, places(slug, place_localizations(name, language)), menu_items(status)')
      .order('created_at', { ascending: false })
      .limit(50)
    if (err) throw err
    menus.value = ((data ?? []) as Array<Record<string, unknown>>).map((row) => {
      const place = row.places as Array<Record<string, unknown>> | undefined
      const locs = place?.[0]?.place_localizations as Array<{ language: string, name: string }> | undefined
      const items = (row.menu_items as Array<{ status: string }> | null) ?? []
      return {
        id: row.id as string,
        place_name: locs?.find(l => l.language === 'ru')?.name ?? locs?.[0]?.name ?? place?.[0]?.slug as string ?? '-',
        status: row.status as AdminMenuRow['status'],
        created_at: row.created_at as string,
        total: items.length,
        curated: items.filter(item => item.status !== 'ai').length
      }
    })
  }

  /** Published dictionary dishes for the "link to dish" action. */
  const loadDishes = async () => {
    const { data, error: err } = await client!
      .from('dishes')
      .select('id, slug, name_vi, dish_localizations(name, language)')
      .eq('status', 'published')
      .order('slug')
    if (err) throw err
    dishes.value = ((data ?? []) as Array<Record<string, unknown>>).map((row) => {
      const locs = (row.dish_localizations as Array<{ language: string, name: string }> | null) ?? []
      return {
        id: row.id as string,
        slug: row.slug as string,
        nameVi: row.name_vi as string,
        name: locs.find(l => l.language === 'ru')?.name ?? locs[0]?.name ?? (row.slug as string)
      }
    })
  }

  /** Pilot metrics: menu scans over the last 7 days (app_events, migration 049). */
  const loadMenuScanCount = async () => {
    const since = new Date(Date.now() - 7 * 86_400_000).toISOString()
    const { count, error: err } = await client!
      .from('app_events')
      .select('id', { count: 'exact', head: true })
      .eq('event', 'menu_scan')
      .gte('created_at', since)
    if (err) throw err
    menuScanCount7d.value = count ?? 0
  }

  const loadMenuAll = async () => {
    await Promise.all([loadMenuQueue(), loadMenus(), loadDishes(), loadMenuScanCount()])
  }

  const setMenuItemStatus = async (id: string, status: 'verified' | 'rejected') => {
    await patch('menu_items', 'id', id, { status })
    await audit('menu_item_status', 'menu_items', id, { status })
    await loadMenuQueue()
    await loadMenus()
  }

  /** Point an unmatched line at a dictionary dish and mark it verified. */
  const linkMenuItemToDish = async (id: string, dishId: string) => {
    await patch('menu_items', 'id', id, { dish_id: dishId, status: 'verified' })
    await audit('menu_item_link', 'menu_items', id, { dish_id: dishId, status: 'verified' })
    await loadMenuQueue()
    await loadMenus()
  }

  const setMenuStatus = async (id: string, status: 'ai' | 'verified') => {
    await patch('menus', 'id', id, { status })
    await audit('menu_status', 'menus', id, { status })
    await loadMenus()
  }

  const loadAll = async () => {
    loading.value = true
    error.value = null
    try {
      await Promise.all([loadCities(), loadPlaces(), loadReviews(), loadGuides(), loadDistricts(), loadMenuQueue(), loadMenuScanCount()])
    } catch (e) {
      error.value = e instanceof Error ? e.message : String(e)
    } finally {
      loading.value = false
    }
  }

  const deleteDistrict = async (id: string) => {
    const { error: err } = await client!.from('districts').delete().eq('id', id)
    if (err) throw err
    await audit('district_delete', 'districts', id, {})
    await loadDistricts()
  }

  const patch = async (table: string, idColumn: string, id: string, body: Record<string, unknown>) => {
    const { error: err } = await client!.from(table).update(body).eq(idColumn, id)
    if (err) throw err
  }

  const togglePlaceStatus = async (id: string) => {
    const place = places.value.find(p => p.id === id)
    if (!place) return
    const next = place.status === 'published' ? 'draft' : 'published'
    await patch('places', 'id', id, { status: next })
    await audit('place_status', 'places', id, { status: next })
    await loadPlaces()
  }

  const toggleCityActive = async (slug: string) => {
    const city = cities.value.find(c => c.slug === slug)
    if (!city) return
    await patch('cities', 'slug', slug, { is_active: !city.is_active })
    await audit('city_active', 'cities', null, { slug, is_active: !city.is_active })
    await loadCities()
  }

  const toggleGuideStatus = async (id: string) => {
    const guide = guides.value.find(g => g.id === id)
    if (!guide) return
    const next = guide.status === 'published' ? 'draft' : 'published'
    await patch('guide_entries', 'id', id, { status: next })
    await audit('guide_status', 'guide_entries', id, { status: next })
    await loadGuides()
  }

  const setReviewStatus = async (id: string, status: Review['status']) => {
    await patch('reviews', 'id', id, { status })
    await audit('review_moderation', 'reviews', id, { status })
    await loadReviews()
  }

  const saveCity = async (city: { slug: string, name_ru: string, name_en: string, flag: string, is_active: boolean, sort_order: number }) => {
    const existing = cities.value.find(c => c.slug === city.slug)
    if (existing) {
      await patch('cities', 'slug', city.slug, city)
      await audit('city_update', 'cities', null, city)
    } else {
      const { error: err } = await client!.from('cities').insert(city)
      if (err) throw err
      await audit('city_create', 'cities', null, city)
    }
    await loadCities()
  }

  const savePlace = async (place: {
    id?: string
    city_slug: string
    slug: string
    place_type: Place['type']
    price_level: Place['priceLevel']
    verified: boolean
    status: Place['status']
    ru: AdminLocalization
    en: AdminLocalization
  }) => {
    const base = {
      city_slug: place.city_slug,
      slug: place.slug,
      place_type: place.place_type,
      price_level: place.price_level,
      verified: place.verified,
      status: place.status
    }
    let placeId = place.id
    if (placeId) {
      await patch('places', 'id', placeId, base)
      await audit('place_update', 'places', placeId ?? null, base)
    } else {
      const { data, error: err } = await client!.from('places').insert(base).select('id').single()
      if (err) throw err
      placeId = data.id
      await audit('place_create', 'places', placeId ?? null, base)
    }
    for (const lang of ['ru', 'en'] as const) {
      const loc = place[lang]
      const body = { place_id: placeId, language: lang, name: loc.name, area: loc.area, summary: loc.summary }
      const { error: err } = await client!.from('place_localizations').upsert(body, { onConflict: 'place_id,language' })
      if (err) throw err
    }
    await loadPlaces()
  }

  /** Appends an audit row for sensitive mutations (append-only table, INSERT policy added in 028). */
  const audit = async (actionType: string, entityTable: string, entityId: string | null, after: Record<string, unknown>) => {
    const { data: { user } } = await client!.auth.getUser()
    try {
      const { error: err } = await client!.from('audit_logs').insert({
        actor_profile_id: user?.id ?? null,
        actor_role: 'admin',
        action_type: actionType,
        entity_table: entityTable,
        entity_id: entityId ?? null,
        after_state: after,
        metadata: { locale: locale.value }
      })
      if (err) console.warn('[useAdminDb] audit insert failed', err.message)
    } catch (e) {
      console.warn('[useAdminDb] audit failed', e)
    }
  }

  const logout = async () => {
    await client!.auth.signOut()
  }

  return {
    cities,
    places,
    reviews,
    guides,
    districts,
    menuQueue,
    menus,
    dishes,
    menuScanCount7d,
    loading,
    error,
    loadAll,
    loadMenuAll,
    loadMenuQueue,
    loadMenus,
    loadDishes,
    loadMenuScanCount,
    setMenuItemStatus,
    linkMenuItemToDish,
    setMenuStatus,
    togglePlaceStatus,
    toggleCityActive,
    toggleGuideStatus,
    setReviewStatus,
    saveCity,
    savePlace,
    saveDistrict,
    deleteDistrict,
    logout
  }
}
