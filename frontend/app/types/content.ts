export interface LocalizedText {
  ru: string
  en: string
}

export type ContentStatus = 'published' | 'draft'
export type ReviewStatus = 'pending' | 'approved' | 'rejected'
export type PlaceType = 'cafe' | 'street' | 'market' | 'restaurant'
export type PriceLevel = 'budget' | 'average' | 'above'
export type GuideCategory = 'transport' | 'money' | 'safety' | 'health'

export interface CityEntry {
  id: string
  labelKey: string
  countryKey: string
  flag: string
  active: boolean
  /** Locale names from the DB (fall back to `t(labelKey)` for known cities). */
  nameRu?: string
  nameEn?: string
}

export interface CategoryEntry {
  id: string
  labelKey: string
  icon: string
  to: string
  countKind: 'districts' | 'places' | 'guides' | 'none'
  guideCategory?: GuideCategory
}

export interface Place {
  id: string
  /** URL-safe slug (unique per city) used for the detail route. */
  slug: string
  name: string
  type: PlaceType
  priceLevel: PriceLevel
  area: LocalizedText
  summary: LocalizedText
  /** Externally sourced photo URL; null renders the styled placeholder. */
  imageUrl: string | null
  verified: boolean
  status: ContentStatus
  updated: string
}

export interface GuideEntry {
  id: string
  category: GuideCategory
  icon: string
  title: LocalizedText
  note: LocalizedText
  summary: LocalizedText
  status: ContentStatus
}

export interface EmergencyContact {
  id: string
  number: string
  label: LocalizedText
}

export interface Review {
  id: string
  placeId: string
  author: string
  rating: number
  text: LocalizedText
  status: ReviewStatus
}

export interface ActivityEvent {
  id: string
  icon: string
  time: string
  text: LocalizedText
}

export interface MockDb {
  cities: CityEntry[]
  categories: CategoryEntry[]
  places: Place[]
  guides: GuideEntry[]
  contacts: EmergencyContact[]
  reviews: Review[]
  activity: ActivityEvent[]
}
