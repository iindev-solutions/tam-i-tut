export interface HousingSection {
  title: string
  icon: string
  description: string
  bullets: string[]
}

export interface HousingDistrictProperties {
  id: string
  label: string
  area: string
  priceRange: string
  bestFor: string[]
  distanceToBeach: string
  summary: string
}

export interface HousingDistrictFeature extends GeoJSON.Feature<GeoJSON.Polygon> {
  properties: HousingDistrictProperties
}

export interface HousingGuideData {
  hero: {
    kicker: string
    title: string
    description: string
  }
  sections: HousingSection[]
  districts: {
    type: 'FeatureCollection'
    features: HousingDistrictFeature[]
  }
}
