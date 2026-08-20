import { describe, expect, it } from 'vitest'

import {
  CATEGORY_UI,
  CITY_UI,
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
} from '~/composables/db-mappers'

describe('mapCities', () => {
  const rows: CityRow[] = [
    { slug: 'da-nang', name_en: 'Da Nang', name_ru: 'Дананг', country_code: 'VN', flag: '🇻🇳', is_active: true, sort_order: 1 },
    { slug: 'phuket', name_en: 'Phuket', name_ru: 'Пхукет', country_code: 'TH', flag: '🇹🇭', is_active: false, sort_order: 4 }
  ]

  it('maps slugs to the pilot i18n keys and flags', () => {
    const cities = mapCities(rows)
    expect(cities).toEqual([
      { id: 'da-nang', labelKey: 'cities.daNang', countryKey: 'cities.vietnam', flag: '🇻🇳', active: true, nameRu: 'Дананг', nameEn: 'Da Nang' },
      { id: 'phuket', labelKey: 'cities.phuket', countryKey: 'cities.thailand', flag: '🇹🇭', active: false, nameRu: 'Пхукет', nameEn: 'Phuket' }
    ])
  })

  it('falls back to a derived key for unknown slugs', () => {
    const unknown: CityRow = { slug: 'hoi-an', name_en: 'Hoi An', name_ru: 'Хойан', country_code: 'VN', flag: '🇻🇳', is_active: true, sort_order: 9 }
    expect(mapCities([unknown])[0]).toMatchObject({ id: 'hoi-an', labelKey: 'cities.hoi-an', countryKey: 'cities.vietnam' })
  })
})

describe('mapCategories', () => {
  const rows: CategoryRow[] = [
    { slug: 'housing', title_ru: 'Жильё', title_en: 'Housing', sort_order: 1, is_active: true },
    { slug: 'food', title_ru: 'Еда и кафе', title_en: 'Food & Cafes', sort_order: 4, is_active: true },
    { slug: 'events', title_ru: 'Афиша', title_en: 'Events', sort_order: 5, is_active: true },
    { slug: 'safety', title_ru: 'Безопасность', title_en: 'Safety', sort_order: 6, is_active: true },
    { slug: 'money', title_ru: 'Деньги', title_en: 'Money', sort_order: 3, is_active: false }
  ]

  it('keeps DB sort order and drops slugs without a pilot page', () => {
    const categories = mapCategories(rows)
    expect(categories.map(c => c.id)).toEqual(['housing', 'food', 'safety', 'culture'])
    expect(categories[0]).toMatchObject({ id: 'housing', ...CATEGORY_UI.housing })
    expect(categories[1]).toMatchObject({ id: 'food', ...CATEGORY_UI.food })
  })

  it('appends culture from the static UI map when the enum lacks it', () => {
    const categories = mapCategories(rows)
    const culture = categories.find(c => c.id === 'culture')
    expect(culture).toMatchObject({ id: 'culture', to: '/categories/culture', icon: 'i-lucide-book-open' })
  })

  it('never renders inactive categories', () => {
    expect(mapCategories(rows).some(c => c.id === 'money')).toBe(false)
  })
})

describe('mapPlaces', () => {
  const place: PlaceRow = {
    id: 'p1',
    city_slug: 'da-nang',
    slug: 'banh-mi',
    place_type: 'street',
    price_level: 'budget',
    verified: true,
    status: 'published',
    updated_at: '2026-08-01T10:00:00Z'
  }
  const draft: PlaceRow = { ...place, id: 'p2', slug: 'draft-place', status: 'draft' }

  const localizations: PlaceLocalizationRow[] = [
    { place_id: 'p1', language: 'ru', name: 'Банхми', area: 'Район', summary: 'Описание' },
    { place_id: 'p1', language: 'en', name: 'Banh mi', area: 'Area', summary: 'Summary' }
  ]

  it('maps published places with both localizations, name from the active locale', () => {
    const [ru] = mapPlaces([place, draft], localizations, 'ru')
    expect(ru).toEqual({
      id: 'p1',
      name: 'Банхми',
      type: 'street',
      priceLevel: 'budget',
      area: { ru: 'Район', en: 'Area' },
      summary: { ru: 'Описание', en: 'Summary' },
      verified: true,
      status: 'published',
      updated: '2026-08-01T10:00:00Z'
    })
  })

  it('uses the english name when the active locale is en', () => {
    const [mapped] = mapPlaces([place], localizations, 'en')
    expect(mapped.name).toBe('Banh mi')
  })

  it('drops non-published rows (defense in depth; RLS already filters)', () => {
    expect(mapPlaces([place, draft], localizations, 'ru')).toHaveLength(1)
  })

  it('tolerates missing localizations with empty gaps', () => {
    const [mapped] = mapPlaces([place], [], 'ru')
    expect(mapped.name).toBe('banh-mi')
    expect(mapped.area).toEqual({ ru: '', en: '' })
  })
})

describe('mapReviews', () => {
  const rows: ReviewRow[] = [
    { id: 'r1', place_id: 'p1', author: 'Alice', rating: 5, status: 'approved', created_at: '2026-08-01T10:00:00Z' }
  ]

  it('maps rows to the Review UI shape with empty localized text (counts only)', () => {
    expect(mapReviews(rows)).toEqual([
      { id: 'r1', placeId: 'p1', author: 'Alice', rating: 5, text: { ru: '', en: '' }, status: 'approved' }
    ])
  })
})

describe('mapGuides', () => {
  const rows: GuideRow[] = [
    { id: '1', category_slug: 'transport', slug: 'transport-grab', title: 'Grab', summary: 'Sum ru', note: 'Note ru', icon: 'i-lucide-car-taxi-front', language: 'ru', status: 'published' },
    { id: '2', category_slug: 'transport', slug: 'transport-grab', title: 'Grab and Xanh SM', summary: 'Sum en', note: 'Note en', icon: 'i-lucide-car-taxi-front', language: 'en', status: 'published' },
    { id: '3', category_slug: 'money', slug: 'money-atm', title: 'Банкоматы', summary: 'ru only', note: null, icon: 'i-lucide-landmark', language: 'ru', status: 'published' },
    { id: '4', category_slug: 'safety', slug: 'safety-draft', title: 'Draft', summary: 'x', note: null, icon: null, language: 'ru', status: 'draft' }
  ]

  it('pairs ru/en rows by slug into LocalizedText', () => {
    const guides = mapGuides(rows)
    const grab = guides.find(g => g.id === 'transport-grab')
    expect(grab?.title).toEqual({ ru: 'Grab', en: 'Grab and Xanh SM' })
    expect(grab?.note).toEqual({ ru: 'Note ru', en: 'Note en' })
    expect(grab?.icon).toBe('i-lucide-car-taxi-front')
    expect(grab?.category).toBe('transport')
  })

  it('fills missing languages with empty text and drops drafts', () => {
    const guides = mapGuides(rows)
    const atm = guides.find(g => g.id === 'money-atm')
    expect(atm?.title).toEqual({ ru: 'Банкоматы', en: '' })
    expect(guides.some(g => g.id === 'safety-draft')).toBe(false)
  })
})

describe('static UI maps', () => {
  it('cover every pilot city and category used by the mock contract', () => {
    expect(Object.keys(CITY_UI)).toEqual(['da-nang', 'nha-trang', 'pattaya', 'phuket'])
    expect(Object.keys(CATEGORY_UI)).toEqual(['housing', 'food', 'transport', 'money', 'safety', 'culture'])
  })
})
