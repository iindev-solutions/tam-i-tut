export interface LocalizedText {
  ru: string
  en: string
}

export type ContentStatus = 'published' | 'draft'
export type ReviewStatus = 'pending' | 'approved' | 'rejected'
/**
 * Publish-confidence level, mirrored from the DB `trust_badge` enum. The
 * product promise is "badge + verification date + evidence discipline", so a
 * level always travels with `lastVerifiedAt`.
 */
export type TrustLevel = 'under_review' | 'recommended_expats' | 'verified_team'
export type PlaceType = 'cafe' | 'street' | 'market' | 'restaurant'
export type PriceLevel = 'budget' | 'average' | 'above'
export type GuideCategory = 'transport' | 'money' | 'safety' | 'health' | 'visarun'

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
  trustLevel: TrustLevel
  /** ISO timestamp of the team's last check; null only while under review. */
  lastVerifiedAt: string | null
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
  trustLevel: TrustLevel
  lastVerifiedAt: string | null
  status: ContentStatus
}

export interface EmergencyContact {
  id: string
  /** Contacts are per-country facts, so they hang off the city tenancy axis. */
  citySlug: string
  number: string
  label: LocalizedText
}

/** Clinic specialisation, mirrored from the DB CHECK constraint on `clinics`. */
export type ClinicKind
  = | 'hospital'
    | 'dental'
    | 'ophthalmology'
    | 'dermatology'
    | 'diagnostics'
    | 'oncology'
    | 'ent'
    | 'veterinary'

export interface Clinic {
  id: string
  slug: string
  kind: ClinicKind
  open24_7: boolean
  name: string
  /** Quoted price for the reference service; figures are not localized. */
  priceNote: LocalizedText
  trustLevel: TrustLevel
  lastVerifiedAt: string | null
  /** Where the row came from - always shown next to the price it applies to. */
  source: string
}

export interface Review {
  id: string
  placeId: string
  author: string
  rating: number
  text: LocalizedText
  body: string
  createdAt: string
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
  clinics: Clinic[]
  reviews: Review[]
  activity: ActivityEvent[]
}
