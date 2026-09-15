import { watch } from 'vue'
import { useI18n } from 'vue-i18n'

import { mockDb } from '~/mocks/db'
import type { MockDb } from '~/types/content'
import { getSupabaseClient } from './useSupabaseClient'
import type { SupabaseClient } from '@supabase/supabase-js'
import {
  mapCategories,
  mapCities,
  mapClinics,
  mapConsulates,
  mapEmergencyContacts,
  mapGuides,
  mapPlaces,
  mapReviews,
  type CategoryRow,
  type CityRow,
  type ClinicLocalizationRow,
  type ClinicRow,
  type ConsulateRow,
  type EmergencyContactRow,
  type GuideRow,
  type PlaceLocalizationRow,
  type PlaceRow,
  type ReviewRow
} from './db-mappers'

/**
 * One in-flight Supabase read per client. Eleven components call `useDb()`
 * (layout, city select, every category page), so without this each mount ran
 * its own seven-table query. `ssr: false`, so a module-scoped promise is safe.
 */
let inflight: Promise<void> | null = null

/** `unavailable` = no session (bot gate); `error` = session but the read failed. */
type SourceState = 'loading' | 'mock' | 'supabase' | 'unavailable' | 'error'

/**
 * RLS-safe content reads for user-facing routes (schema v2 cutover, food slice).
 *
 * - With a configured Supabase project AND an authenticated session (from the
 *   telegram-bootstrap flow) it queries `cities`, `categories`, `places`,
 *   `place_localizations`, `reviews`, `guide_entries`, `emergency_contacts` and
 *   `clinics` through the anon key; RLS restricts reads to active cities,
 *   published places/localizations, approved reviews and published guides.
 *   Defense-in-depth filters mirror the policies in the queries.
 * - Without a project or a session (plain browser, function not deployed) it
 *   falls back to the shared mock store, so the prototype and the
 *   admin->user live demo keep working unchanged.
 * - With a session but a FAILED read the state is `error`, never the bot
 *   gate: a signed-in user on a broken connection was told to "open the app
 *   from the bot" while already inside it.
 *
 * The returned `db` ref has the exact `MockDb` shape, so page components are
 * untouched. The mock admin prototype keeps using `useMockDb()` directly.
 */
export function useDb() {
  const client = getSupabaseClient()
  const { locale } = useI18n()
  const mock = useMockDb()

  // Prod fallback policy: mocks are a DEV-only prototype. In a production
  // build a missing/failed session must show the honest "open from the bot"
  // state instead of prototype data - silent mock fallback shipped stale
  // content to prod twice before this rule existed.
  const mockAllowed = import.meta.dev

  const emptyDb = (): MockDb => ({
    cities: [],
    categories: [],
    places: [],
    guides: [],
    contacts: [],
    consulates: [],
    clinics: [],
    reviews: [],
    activity: []
  })

  const db = useState<MockDb>('content-db', () => (mockAllowed ? structuredClone(mockDb) : emptyDb()))
  const loading = useState<boolean>('content-db-loading', () => false)
  // Shared, not a local ref: the layout renders the bot gate / error screen
  // from this value while pages render from their own useDb() instance.
  const source = useState<SourceState>('content-db-source', () => 'loading')

  // Raw PostgREST rows kept between refreshes: a locale switch re-maps them
  // instantly instead of re-fetching six tables (mappers hold both languages).
  const raw = useState('content-db-raw', () => null as {
    cities: CityRow[]
    categories: CategoryRow[]
    places: PlaceRow[]
    localizations: PlaceLocalizationRow[]
    reviews: ReviewRow[]
    guides: GuideRow[]
    contacts: EmergencyContactRow[]
    consulates: ConsulateRow[]
    clinics: ClinicRow[]
    clinicLocalizations: ClinicLocalizationRow[]
  } | null)

  const applyMock = () => {
    // Drop any previously fetched rows: `raw` alone now decides whether
    // remapping happens, so a stale set would otherwise repaint over the mock
    // on the next locale switch.
    raw.value = null
    if (!mockAllowed) {
      // Prod: no honest data to show - pages render their empty states and
      // the layout shows the "open from the bot" screen.
      db.value = emptyDb()
      source.value = 'unavailable'
      return
    }
    // Same reference as the mock store: admin publish/moderate mutations keep
    // flowing to user pages in prototype mode.
    db.value = mock.db.value
    source.value = 'mock'
  }

  const remapFromRaw = () => {
    // Guarded by the rows themselves, never by `source`: `read()` fills `raw`
    // and only then flips `source`, so a `source`-based guard made the FIRST
    // successful read a guaranteed no-op - the app rendered an empty db (no
    // city select, no categories) for a returning user whose session was
    // already in storage, because nothing ever triggered a second pass.
    // `raw` is the single source of truth: it only exists when the fetched
    // row set is the live Supabase data.
    if (!raw.value) return
    db.value = {
      ...db.value,
      cities: mapCities(raw.value.cities),
      categories: mapCategories(raw.value.categories),
      places: mapPlaces(raw.value.places, raw.value.localizations, locale.value),
      reviews: mapReviews(raw.value.reviews),
      guides: mapGuides(raw.value.guides),
      contacts: mapEmergencyContacts(raw.value.contacts),
      consulates: mapConsulates(raw.value.consulates),
      clinics: mapClinics(raw.value.clinics, raw.value.clinicLocalizations)
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

    // Concurrent callers share one read. The slot is taken after the session
    // check, so a no-session call can never swallow the session-triggered read.
    if (inflight) return inflight
    inflight = read(client).finally(() => {
      inflight = null
    })
    return inflight
  }

  const read = async (sb: SupabaseClient) => {
    loading.value = true
    try {
      const [cities, categories, places, localizations, reviews, guides, contacts, consulates, clinics, clinicLocalizations] = await Promise.all([
        sb
          .from('cities')
          .select('slug,name_en,name_ru,country_code,flag,is_active,sort_order')
          .order('sort_order'),
        sb.from('categories').select('slug,title_ru,title_en,sort_order,is_active').order('sort_order'),
        sb
          .from('places')
          .select('id,city_slug,slug,place_type,price_level,trust_badge,last_verified_at,status,updated_at,image_url')
          .eq('status', 'published'),
        sb.from('place_localizations').select('place_id,language,name,area,summary').in('language', ['ru', 'en']),
        sb.from('reviews').select('id,place_id,author,rating,body,status,created_at'),
        sb
          .from('guide_entries')
          .select('id,category_slug,slug,title,summary,note,icon,language,status,trust_badge,last_verified_at')
          .eq('status', 'published'),
        sb
          .from('emergency_contacts')
          .select('id,city_slug,number,label_ru,label_en,sort_order')
          .order('sort_order'),
        sb
          .from('consulates')
          .select('id,city_slug,country_code,name_ru,name_en,address,hours_ru,hours_en,phone,emergency_phone,source,sort_order')
          .order('sort_order'),
        sb
          .from('clinics')
          .select('id,city_slug,slug,kind,open_24_7,trust_badge,last_verified_at,source,sort_order')
          .order('sort_order'),
        sb
          .from('clinic_localizations')
          .select('clinic_id,language,name,price_note')
          .in('language', ['ru', 'en'])
      ])

      for (const result of [cities, categories]) {
        if (result.error) throw result.error
      }

      // Secondary reads degrade independently. Without cities/categories there
      // is no app at all, but a single failing table here must NOT blank the
      // home grid: one 400 on any of these (a dropped column, PostgREST schema
      // cache lag after a migration, a policy change) otherwise throws the
      // whole read into the error state - exactly how the stale-bundle
      // `places.verified` select took the live app down. The failed section
      // renders empty and the reason is logged instead of swallowed.
      const degraded: string[] = []
      const rows = <T>(result: { data: unknown, error: unknown }, label: string): T[] => {
        if (result.error) {
          degraded.push(label)
          console.warn(`[useDb] ${label} read failed, section degrades to empty`, result.error)
          return []
        }
        return (result.data ?? []) as T[]
      }

      raw.value = {
        cities: cities.data as CityRow[],
        categories: categories.data as CategoryRow[],
        places: rows<PlaceRow>(places, 'places'),
        localizations: rows<PlaceLocalizationRow>(localizations, 'place_localizations'),
        reviews: rows<ReviewRow>(reviews, 'reviews'),
        guides: rows<GuideRow>(guides, 'guide_entries'),
        contacts: rows<EmergencyContactRow>(contacts, 'emergency_contacts'),
        consulates: rows<ConsulateRow>(consulates, 'consulates'),
        clinics: rows<ClinicRow>(clinics, 'clinics'),
        clinicLocalizations: rows<ClinicLocalizationRow>(clinicLocalizations, 'clinic_localizations')
      }
      if (degraded.length > 0) console.error('[useDb] degraded sections:', degraded.join(', '))
      remapFromRaw()
      source.value = 'supabase'
    } catch (error) {
      // A session exists here, so the user is inside the bot and a read
      // failure is a real error - not the "open from the bot" gate.
      console.error('[useDb] Supabase read failed', error)
      if (mockAllowed) {
        applyMock()
      } else {
        // Same reasoning as applyMock: no fetched rows may survive a failure,
        // or a later locale switch would repaint the app with stale content
        // while the UI claims an error.
        raw.value = null
        db.value = emptyDb()
        source.value = 'error'
      }
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
