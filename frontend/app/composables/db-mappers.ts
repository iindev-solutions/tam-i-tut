/**
 * Pure mappers: Supabase (PostgREST) rows -> the existing `MockDb` UI shapes.
 *
 * Kept free of Nuxt imports so the mapping logic is unit-testable in vitest
 * and identical in the composable and the tests. The UI shapes come from
 * `types/content.ts` (the accepted prototype contract); page components keep
 * rendering unchanged.
 */

import type {
  CategoryEntry,
  CityEntry,
  Clinic,
  ClinicKind,
  Consulate,
  ContentStatus,
  EmergencyContact,
  GuideCategory,
  GuideEntry,
  Place,
  PlaceType,
  PriceLevel,
  Review,
  ReviewStatus,
  TrustLevel
} from '~/types/content'

export type LanguageCode = 'ru' | 'en'

// PostgREST row shapes (snake_case columns as returned by the API).
export interface CityRow {
  slug: string
  name_en: string
  name_ru: string
  country_code: string
  flag: string
  is_active: boolean
  sort_order: number
}

export interface CategoryRow {
  slug: string
  title_ru: string
  title_en: string
  sort_order: number
  is_active: boolean
}

export interface PlaceRow {
  id: string
  city_slug: string
  slug: string
  place_type: PlaceType
  price_level: PriceLevel
  trust_badge: TrustLevel
  last_verified_at: string | null
  status: ContentStatus
  updated_at: string
  image_url: string | null
}

export interface PlaceLocalizationRow {
  place_id: string
  language: LanguageCode
  name: string
  area: string
  summary: string
}

export interface ReviewRow {
  id: string
  place_id: string
  author: string
  rating: number
  body: string | null
  status: ReviewStatus
  created_at: string
}

export interface GuideRow {
  id: string
  category_slug: GuideCategory
  slug: string
  title: string
  summary: string
  note: string | null
  icon: string | null
  language: LanguageCode
  status: ContentStatus
  trust_badge: TrustLevel
  last_verified_at: string | null
}

export interface EmergencyContactRow {
  id: string
  city_slug: string
  number: string
  label_ru: string
  label_en: string
  sort_order: number
}

export interface ConsulateRow {
  id: string
  city_slug: string
  country_code: string
  name_ru: string
  name_en: string
  address: string
  hours_ru: string
  hours_en: string
  phone: string | null
  emergency_phone: string | null
  source: string
  sort_order: number
}

export interface ClinicRow {
  id: string
  city_slug: string
  slug: string
  kind: ClinicKind
  open_24_7: boolean
  trust_badge: TrustLevel
  last_verified_at: string | null
  source: string
  sort_order: number
}

export interface ClinicLocalizationRow {
  clinic_id: string
  language: LanguageCode
  name: string
  price_note: string
}

/** Static UI chrome for pilot city slugs (i18n keys live in the locale files). */
export const CITY_UI: Record<string, { labelKey: string, countryKey: string }> = {
  'da-nang': { labelKey: 'cities.daNang', countryKey: 'cities.vietnam' },
  'nha-trang': { labelKey: 'cities.nhaTrang', countryKey: 'cities.vietnam' },
  'pattaya': { labelKey: 'cities.pattaya', countryKey: 'cities.thailand' },
  'phuket': { labelKey: 'cities.phuket', countryKey: 'cities.thailand' }
}

interface CategoryUi {
  labelKey: string
  icon: string
  to: string
  countKind: CategoryEntry['countKind']
  guideCategory?: GuideCategory
}

/** Static UI chrome for category slugs: icon/route/count kind are frontend concerns. */
export const CATEGORY_UI: Record<string, CategoryUi> = {
  housing: { labelKey: 'home.housing', icon: 'i-lucide-house', to: '/categories/housing', countKind: 'districts' },
  food: { labelKey: 'home.food', icon: 'i-lucide-utensils', to: '/categories/food', countKind: 'places' },
  transport: {
    labelKey: 'home.transport',
    icon: 'i-lucide-bike',
    to: '/categories/transport',
    countKind: 'guides',
    guideCategory: 'transport'
  },
  money: {
    labelKey: 'home.money',
    icon: 'i-lucide-wallet',
    to: '/categories/money',
    countKind: 'guides',
    guideCategory: 'money'
  },
  safety: {
    labelKey: 'home.safety',
    icon: 'i-lucide-shield-check',
    to: '/categories/safety',
    countKind: 'guides',
    guideCategory: 'safety'
  },
  health: {
    labelKey: 'home.health',
    icon: 'i-lucide-heart-pulse',
    to: '/categories/health',
    countKind: 'guides',
    guideCategory: 'health'
  },
  visarun: {
    labelKey: 'home.visarun',
    icon: 'i-lucide-plane-takeoff',
    to: '/categories/visarun',
    countKind: 'guides',
    guideCategory: 'visarun'
  },
  culture: { labelKey: 'home.culture', icon: 'i-lucide-book-open', to: '/categories/culture', countKind: 'none' }
}

export function mapCities(rows: CityRow[]): CityEntry[] {
  return rows.map((row) => {
    const ui = CITY_UI[row.slug]
    return {
      id: row.slug,
      labelKey: ui?.labelKey ?? `cities.${row.slug}`,
      countryKey: ui?.countryKey ?? (row.country_code === 'TH' ? 'cities.thailand' : 'cities.vietnam'),
      flag: row.flag,
      active: row.is_active,
      nameRu: row.name_ru,
      nameEn: row.name_en
    }
  })
}

/**
 * Maps active DB categories to home cards, preserving DB sort order.
 * Slugs without a pilot page (e.g. `events`) are excluded - the row stays the
 * canonical editorial set for a future page. `culture` ships a page but has no
 * `category_slug` enum value yet (schema follow-up), so it is appended from
 * the static UI map to keep the home grid intact.
 */
export function mapCategories(rows: CategoryRow[]): CategoryEntry[] {
  const entries: CategoryEntry[] = []
  for (const row of rows) {
    const ui = CATEGORY_UI[row.slug]
    if (!row.is_active || !ui) continue
    entries.push({ id: row.slug, ...ui })
  }
  if (!entries.some(entry => entry.id === 'culture')) {
    const culture = CATEGORY_UI.culture
    if (culture) entries.push({ id: 'culture', ...culture })
  }
  return entries
}

/** Maps published places with their ru/en localizations to the Place UI shape. */
export function mapPlaces(rows: PlaceRow[], localizations: PlaceLocalizationRow[], locale: LanguageCode): Place[] {
  const byPlace = new Map<string, Map<LanguageCode, PlaceLocalizationRow>>()
  for (const loc of localizations) {
    const langs = byPlace.get(loc.place_id) ?? new Map<LanguageCode, PlaceLocalizationRow>()
    langs.set(loc.language, loc)
    byPlace.set(loc.place_id, langs)
  }

  return rows
    .filter(row => row.status === 'published')
    .map((row) => {
      const langs = byPlace.get(row.id) ?? new Map<LanguageCode, PlaceLocalizationRow>()
      const ru = langs.get('ru')
      const en = langs.get('en')
      const name = (locale === 'en' ? en ?? ru : ru ?? en)?.name ?? row.slug
      return {
        id: row.id,
        slug: row.slug,
        name,
        type: row.place_type,
        priceLevel: row.price_level,
        area: { ru: ru?.area ?? '', en: en?.area ?? '' },
        summary: { ru: ru?.summary ?? '', en: en?.summary ?? '' },
        imageUrl: row.image_url,
        trustLevel: row.trust_badge,
        lastVerifiedAt: row.last_verified_at,
        status: row.status,
        updated: row.updated_at
      }
    })
}

/**
 * Maps visible reviews (RLS already restricts to approved reviews on published
 * places). `review_localizations` land with the admin authoring path; the food
 * UI only counts approved reviews, so text stays empty for now.
 */
export function mapReviews(rows: ReviewRow[]): Review[] {
  return rows.map(row => ({
    id: row.id,
    placeId: row.place_id,
    author: row.author,
    rating: row.rating,
    text: { ru: '', en: '' },
    body: row.body ?? '',
    createdAt: row.created_at,
    status: row.status
  }))
}

/**
 * Maps published guide_entries (rows-per-language) into GuideEntry, pairing
 * ru/en rows by (category_slug, slug). `note`/`icon` live on each row; the
 * first non-null value wins.
 */
export function mapGuides(rows: GuideRow[]): GuideEntry[] {
  const byKey = new Map<string, {
    category: GuideCategory
    icon: string
    status: ContentStatus
    trustLevel: TrustLevel
    lastVerifiedAt: string | null
    ru?: { title: string, note: string, summary: string }
    en?: { title: string, note: string, summary: string }
  }>()

  for (const row of rows) {
    if (row.status !== 'published') continue
    const key = `${row.category_slug}/${row.slug}`
    const entry = byKey.get(key) ?? {
      category: row.category_slug,
      icon: row.icon ?? '',
      status: row.status,
      trustLevel: row.trust_badge,
      lastVerifiedAt: row.last_verified_at
    }
    entry.icon = entry.icon ?? row.icon ?? ''
    // Both language rows are governed by the same trust transition trigger, so
    // the first row's level wins; the date takes the newest check either way.
    if (row.last_verified_at && (!entry.lastVerifiedAt || row.last_verified_at > entry.lastVerifiedAt)) {
      entry.lastVerifiedAt = row.last_verified_at
    }
    entry[row.language] = { title: row.title, note: row.note ?? '', summary: row.summary }
    byKey.set(key, entry)
  }

  return [...byKey.entries()].map(([key, entry]) => {
    const ru = entry.ru
    const en = entry.en
    const text = (lang: 'ru' | 'en', field: 'title' | 'note' | 'summary') => {
      const source = lang === 'ru' ? ru : en
      return source?.[field] ?? ''
    }
    const id = key.split('/')[1] ?? key
    return {
      id,
      category: entry.category,
      icon: entry.icon,
      title: { ru: text('ru', 'title'), en: text('en', 'title') },
      note: { ru: text('ru', 'note'), en: text('en', 'note') },
      summary: { ru: text('ru', 'summary'), en: text('en', 'summary') },
      trustLevel: entry.trustLevel,
      lastVerifiedAt: entry.lastVerifiedAt,
      status: entry.status
    }
  })
}

/**
 * Maps city-scoped emergency contacts to the UI shape. RLS already restricts
 * rows to active cities; the page filters by the selected city.
 */
export function mapEmergencyContacts(rows: EmergencyContactRow[]): EmergencyContact[] {
  return rows.map(row => ({
    id: row.id,
    citySlug: row.city_slug,
    number: row.number,
    label: { ru: row.label_ru, en: row.label_en }
  }))
}

/**
 * Maps city-scoped consulates. `address` is intentionally not localized: it is
 * the Vietnamese street form, which is what you show a taxi driver.
 */
export function mapConsulates(rows: ConsulateRow[]): Consulate[] {
  return rows.map(row => ({
    id: row.id,
    citySlug: row.city_slug,
    name: { ru: row.name_ru, en: row.name_en },
    address: row.address,
    hours: { ru: row.hours_ru, en: row.hours_en },
    phone: row.phone,
    emergencyPhone: row.emergency_phone,
    source: row.source
  }))
}

/**
 * Maps clinic rows with their ru/en localizations. Trust level and source ride
 * along untouched: the UI must be able to say both "under review" and where the
 * price came from, so neither is dropped here.
 */
export function mapClinics(rows: ClinicRow[], localizations: ClinicLocalizationRow[]): Clinic[] {
  const byClinic = new Map<string, Map<LanguageCode, ClinicLocalizationRow>>()
  for (const loc of localizations) {
    const langs = byClinic.get(loc.clinic_id) ?? new Map<LanguageCode, ClinicLocalizationRow>()
    langs.set(loc.language, loc)
    byClinic.set(loc.clinic_id, langs)
  }

  return rows.map((row) => {
    const langs = byClinic.get(row.id) ?? new Map<LanguageCode, ClinicLocalizationRow>()
    const ru = langs.get('ru')
    const en = langs.get('en')
    return {
      id: row.id,
      slug: row.slug,
      kind: row.kind,
      open24_7: row.open_24_7,
      // Venue names are proper nouns and identical across languages; the
      // localization row is the source of truth so an edited name propagates.
      name: (ru ?? en)?.name ?? row.slug,
      priceNote: { ru: ru?.price_note ?? '', en: en?.price_note ?? '' },
      trustLevel: row.trust_badge,
      lastVerifiedAt: row.last_verified_at,
      source: row.source
    }
  })
}
