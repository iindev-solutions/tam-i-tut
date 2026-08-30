import { ref, watch } from 'vue'
import { useI18n } from 'vue-i18n'

import { mockDb } from '~/mocks/db'
import type { MockDb } from '~/types/content'
import { getSupabaseClient } from './useSupabaseClient'
import {
  mapCategories,
  mapCities,
  mapGuides,
  mapPlaces,
  mapReviews,
  type CategoryRow,
  type CityRow,
  type GuideRow,
  type PlaceLocalizationRow,
  type PlaceRow,
  type ReviewRow
} from './db-mappers'

/**
 * RLS-safe content reads for user-facing routes (schema v2 cutover, food slice).
 *
 * - With a configured Supabase project AND an authenticated session (from the
 *   telegram-bootstrap flow) it queries `cities`, `categories`, `places`,
 *   `place_localizations` and `reviews` through the anon key; RLS restricts
 *   reads to active cities, published places/localizations and approved
 *   reviews. Defense-in-depth filters mirror the policies in the queries.
 * - Without a project or a session (plain browser, function not deployed) it
 *   falls back to the shared mock store, so the prototype and the
 *   admin->user live demo keep working unchanged.
 *
 * The returned `db` ref has the exact `MockDb` shape, so page components are
 * untouched. The mock admin prototype keeps using `useMockDb()` directly.
 */
export function useDb() {
  const client = getSupabaseClient()
  const { locale } = useI18n()
  const mock = useMockDb()

  const db = useState<MockDb>('content-db', () => structuredClone(mockDb))
  const loading = useState<boolean>('content-db-loading', () => false)
  const source = ref<'mock' | 'supabase'>('mock')

  // Raw PostgREST rows kept between refreshes: a locale switch re-maps them
  // instantly instead of re-fetching six tables (mappers hold both languages).
  const raw = useState('content-db-raw', () => null as {
    cities: CityRow[]
    categories: CategoryRow[]
    places: PlaceRow[]
    localizations: PlaceLocalizationRow[]
    reviews: ReviewRow[]
    guides: GuideRow[]
  } | null)

  const applyMock = () => {
    // Same reference as the mock store: admin publish/moderate mutations keep
    // flowing to user pages in prototype mode.
    db.value = mock.db.value
    source.value = 'mock'
  }

  const remapFromRaw = () => {
    // Supabase mode only: the mock store handles its own reactivity.
    if (source.value !== 'supabase' || !raw.value) return
    db.value = {
      ...db.value,
      cities: mapCities(raw.value.cities),
      categories: mapCategories(raw.value.categories),
      places: mapPlaces(raw.value.places, raw.value.localizations, locale.value),
      reviews: mapReviews(raw.value.reviews),
      guides: mapGuides(raw.value.guides)
    }
  }

  const refresh = async () => {
    if (!client) {
      applyMock()
      return
    }
    const {
      data: { session }
    } = await client.auth.getSession()
    if (!session) {
      applyMock()
      return
    }

    loading.value = true
    try {
      const [cities, categories, places, localizations, reviews, guides] = await Promise.all([
        client
          .from('cities')
          .select('slug,name_en,name_ru,country_code,flag,is_active,sort_order')
          .order('sort_order'),
        client.from('categories').select('slug,title_ru,title_en,sort_order,is_active').order('sort_order'),
        client
          .from('places')
          .select('id,city_slug,slug,place_type,price_level,verified,status,updated_at,image_url')
          .eq('status', 'published'),
        client.from('place_localizations').select('place_id,language,name,area,summary').in('language', ['ru', 'en']),
        client.from('reviews').select('id,place_id,author,rating,status'),
        client
          .from('guide_entries')
          .select('id,category_slug,slug,title,summary,note,icon,language,status')
          .eq('status', 'published')
      ])

      for (const result of [cities, categories, places, localizations, reviews, guides]) {
        if (result.error) throw result.error
      }

      raw.value = {
        cities: cities.data as CityRow[],
        categories: categories.data as CategoryRow[],
        places: places.data as PlaceRow[],
        localizations: localizations.data as PlaceLocalizationRow[],
        reviews: reviews.data as ReviewRow[],
        guides: guides.data as GuideRow[]
      }
      remapFromRaw()
      source.value = 'supabase'
    } catch (error) {
      // RLS read failed (e.g. stale session, network): keep the app usable.
      console.error('[useDb] Supabase read failed, using mock fallback', error)
      applyMock()
    } finally {
      loading.value = false
    }
  }

  // Session lands (telegram plugin) -> fetch; locale changes -> instant re-map.
  const { session: tmaSession } = useAuth()
  watch(tmaSession, refresh)
  watch(locale, remapFromRaw)
  void refresh()

  return { db, loading, source, refresh }
}
