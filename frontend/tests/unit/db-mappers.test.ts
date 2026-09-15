import { describe, expect, it } from 'vitest'

import { mockDb } from '~/mocks/db'

import {
  CATEGORY_UI,
  CITY_UI,
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
    trust_badge: 'verified_team',
    last_verified_at: '2026-08-20T00:00:00Z',
    status: 'published',
    updated_at: '2026-08-01T10:00:00Z',
    image_url: null
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
      slug: 'banh-mi',
      name: 'Банхми',
      type: 'street',
      priceLevel: 'budget',
      area: { ru: 'Район', en: 'Area' },
      summary: { ru: 'Описание', en: 'Summary' },
      imageUrl: null,
      trustLevel: 'verified_team',
      lastVerifiedAt: '2026-08-20T00:00:00Z',
      status: 'published',
      updated: '2026-08-01T10:00:00Z'
    })
  })

  it('carries the trust level and its check date through to the UI shape', () => {
    const unverified: PlaceRow = { ...place, id: 'p3', trust_badge: 'under_review', last_verified_at: null }
    const [mapped] = mapPlaces([unverified], localizations, 'ru')
    expect(mapped).toMatchObject({ trustLevel: 'under_review', lastVerifiedAt: null })
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
    { id: 'r1', place_id: 'p1', author: 'Alice', rating: 5, body: 'Great place', status: 'approved', created_at: '2026-08-01T10:00:00Z' }
  ]

  it('maps rows to the Review UI shape with empty localized text (counts only)', () => {
    expect(mapReviews(rows)).toEqual([
      { id: 'r1', placeId: 'p1', author: 'Alice', rating: 5, text: { ru: '', en: '' }, body: 'Great place', createdAt: '2026-08-01T10:00:00Z', status: 'approved' }
    ])
  })
})

describe('mapGuides', () => {
  const rows: GuideRow[] = [
    { id: '1', category_slug: 'transport', slug: 'transport-grab', title: 'Grab', summary: 'Sum ru', note: 'Note ru', icon: 'i-lucide-car-taxi-front', language: 'ru', status: 'published', trust_badge: 'under_review', last_verified_at: '2026-08-01T00:00:00Z' },
    { id: '2', category_slug: 'transport', slug: 'transport-grab', title: 'Grab and Xanh SM', summary: 'Sum en', note: 'Note en', icon: 'i-lucide-car-taxi-front', language: 'en', status: 'published', trust_badge: 'under_review', last_verified_at: '2026-09-01T00:00:00Z' },
    { id: '3', category_slug: 'money', slug: 'money-atm', title: 'Банкоматы', summary: 'ru only', note: null, icon: 'i-lucide-landmark', language: 'ru', status: 'published', trust_badge: 'verified_team', last_verified_at: '2026-08-20T00:00:00Z' },
    { id: '4', category_slug: 'safety', slug: 'safety-draft', title: 'Draft', summary: 'x', note: null, icon: null, language: 'ru', status: 'draft', trust_badge: 'under_review', last_verified_at: null }
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

  it('keeps the trust level and takes the newest check date across language rows', () => {
    const grab = mapGuides(rows).find(g => g.id === 'transport-grab')
    expect(grab).toMatchObject({ trustLevel: 'under_review', lastVerifiedAt: '2026-09-01T00:00:00Z' })
  })

  it('carries the trusted level with its check date', () => {
    const atm = mapGuides(rows).find(g => g.id === 'money-atm')
    expect(atm).toMatchObject({ trustLevel: 'verified_team', lastVerifiedAt: '2026-08-20T00:00:00Z' })
  })
})

describe('mapEmergencyContacts', () => {
  const rows: EmergencyContactRow[] = [
    { id: 'c1', city_slug: 'da-nang', number: '113', label_ru: 'Полиция', label_en: 'Police', sort_order: 1 }
  ]

  it('maps rows to the UI shape and keeps the city scope', () => {
    expect(mapEmergencyContacts(rows)).toEqual([
      { id: 'c1', citySlug: 'da-nang', number: '113', label: { ru: 'Полиция', en: 'Police' } }
    ])
  })
})

describe('mapClinics', () => {
  const rows: ClinicRow[] = [
    { id: 'cl1', city_slug: 'da-nang', slug: 'thien-nhan', kind: 'hospital', open_24_7: false, trust_badge: 'under_review', last_verified_at: null, source: 'third-party guide, 2026-09-15', sort_order: 1 }
  ]
  const localizations: ClinicLocalizationRow[] = [
    { clinic_id: 'cl1', language: 'ru', name: 'Thiện Nhân Hospital', price_note: 'Приём 165 000 ₫' },
    { clinic_id: 'cl1', language: 'en', name: 'Thiện Nhân Hospital', price_note: 'Visit 165,000 ₫' }
  ]

  it('maps a clinic with both localized price notes', () => {
    const [clinic] = mapClinics(rows, localizations)
    expect(clinic).toMatchObject({
      id: 'cl1',
      kind: 'hospital',
      name: 'Thiện Nhân Hospital',
      priceNote: { ru: 'Приём 165 000 ₫', en: 'Visit 165,000 ₫' },
      open24_7: false
    })
  })

  // The honesty guarantee: an imported row must never lose the level that says
  // it is unverified, nor the source the price came from.
  it('never drops the trust level or the source of an imported row', () => {
    const [clinic] = mapClinics(rows, localizations)
    expect(clinic?.trustLevel).toBe('under_review')
    expect(clinic?.lastVerifiedAt).toBeNull()
    expect(clinic?.source).toBe('third-party guide, 2026-09-15')
  })

  it('survives a missing localization without inventing a price', () => {
    const [clinic] = mapClinics(rows, [])
    expect(clinic?.name).toBe('thien-nhan')
    expect(clinic?.priceNote).toEqual({ ru: '', en: '' })
  })
})

describe('mapConsulates', () => {
  const rows: ConsulateRow[] = [
    {
      id: 'cons1',
      city_slug: 'da-nang',
      country_code: 'RU',
      name_ru: 'Генконсульство России',
      name_en: 'Russian Consulate General',
      address: '22 Trần Phú, Thạch Thang, Hải Châu, Đà Nẵng',
      hours_ru: 'пн, вт, чт, пт 9:00-11:30',
      hours_en: 'Mon, Tue, Thu, Fri 9:00-11:30',
      phone: '+84 236 382 23 80',
      emergency_phone: '+84 94 720-00-94',
      source: 'rusconsdanang.mid.ru, 2026-09-15',
      sort_order: 1
    }
  ]

  it('maps a consulate with both numbers and localized name/hours', () => {
    const [consulate] = mapConsulates(rows)
    expect(consulate).toMatchObject({
      citySlug: 'da-nang',
      name: { ru: 'Генконсульство России', en: 'Russian Consulate General' },
      hours: { ru: 'пн, вт, чт, пт 9:00-11:30', en: 'Mon, Tue, Thu, Fri 9:00-11:30' },
      phone: '+84 236 382 23 80',
      emergencyPhone: '+84 94 720-00-94'
    })
  })

  // The address is deliberately NOT localized: it is the Vietnamese street form,
  // which is what a taxi driver reads. Localizing it would be a regression.
  it('keeps a single untranslated Vietnamese address', () => {
    const [consulate] = mapConsulates(rows)
    expect(consulate?.address).toBe('22 Trần Phú, Thạch Thang, Hải Châu, Đà Nẵng')
    expect(typeof consulate?.address).toBe('string')
  })

  it('carries the source so a reader can audit the fact', () => {
    expect(mapConsulates(rows)[0]?.source).toBe('rusconsdanang.mid.ru, 2026-09-15')
  })
})

describe('static UI maps', () => {
  it('cover every category used by the mock contract (1:1, order-insensitive)', () => {
    const mockCategories = mockDb.categories.map(category => category.id).sort()
    expect([...Object.keys(CATEGORY_UI)].sort()).toEqual(mockCategories)
  })

  it('cover every pilot city used by the mock contract (1:1, order-insensitive)', () => {
    const mockCities = mockDb.cities.map(city => city.id).sort()
    expect([...Object.keys(CITY_UI)].sort()).toEqual(mockCities)
  })
})
