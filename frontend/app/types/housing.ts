export interface HousingSection {
  title: string
  icon: string
  description: string
  bullets: string[]
}

export type HousingResourceKind = 'telegram' | 'facebook' | 'zalo' | 'site' | 'agency'

export interface HousingResource {
  id: string
  kind: HousingResourceKind
  name: string
  url: string
  note?: {
    ru: string
    en: string
  }
}

export interface HousingDistrictProperties {
  id: string
  label: string
  area: string
  rentRange: string
  priceRange: string
  bestFor: string[]
  distanceToBeach: string
  summary: string
}

export type HousingCoordinate = [longitude: number, latitude: number]

export interface HousingDistrictFeature {
  type: 'Feature'
  properties: HousingDistrictProperties
  geometry: {
    type: 'Polygon'
    coordinates: HousingCoordinate[][]
  }
}

export interface HousingGuideData {
  hero: {
    kicker: string
    title: string
    description: string
  }
  sections: HousingSection[]
  resources: HousingResource[]
  districts: {
    type: 'FeatureCollection'
    features: HousingDistrictFeature[]
  }
}
