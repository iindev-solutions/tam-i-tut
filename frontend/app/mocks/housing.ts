import type { HousingGuideData } from '~/types/housing'

export const housingGuideData: HousingGuideData = {
  hero: {
    kicker: 'housing.kicker',
    title: 'housing.title',
    description: 'housing.description'
  },
  sections: [
    {
      title: 'housing.sections.renting.title',
      icon: 'i-lucide-key-round',
      description: 'housing.sections.renting.description',
      bullets: [
        'housing.sections.renting.bullets.deposit',
        'housing.sections.renting.bullets.contract'
      ]
    },
    {
      title: 'housing.sections.search.title',
      icon: 'i-lucide-search',
      description: 'housing.sections.search.description',
      bullets: [
        'housing.sections.search.bullets.telegram',
        'housing.sections.search.bullets.facebook'
      ]
    },
    {
      title: 'housing.sections.trust.title',
      icon: 'i-lucide-shield-check',
      description: 'housing.sections.trust.description',
      bullets: [
        'housing.sections.trust.bullets.visit',
        'housing.sections.trust.bullets.owner'
      ]
    }
  ],
  districts: {
    type: 'FeatureCollection',
    features: [
      {
        type: 'Feature',
        properties: {
          id: 'my-khe',
          label: 'My Khe',
          area: 'housing.districts.myKhe.area',
          priceRange: 'pricing.high',
          bestFor: ['housing.districts.keyPoints.beach', 'housing.districts.keyPoints.quiet'],
          distanceToBeach: 'housing.districts.myKhe.distance',
          summary: 'housing.districts.myKhe.summary'
        },
        geometry: {
          type: 'Polygon',
          coordinates: [
            [
              [108.2450, 16.0870],
              [108.2480, 16.0850],
              [108.2520, 16.0840],
              [108.2530, 16.0800],
              [108.2500, 16.0750],
              [108.2470, 16.0750],
              [108.2440, 16.0820],
              [108.2440, 16.0870]
            ]
          ]
        }
      },
      {
        type: 'Feature',
        properties: {
          id: 'bac-my-an',
          label: 'Bac My An',
          area: 'housing.districts.bacMyAn.area',
          priceRange: 'pricing.high',
          bestFor: ['housing.districts.keyPoints.quiet', 'housing.districts.keyPoints.family'],
          distanceToBeach: 'housing.districts.bacMyAn.distance',
          summary: 'housing.districts.bacMyAn.summary'
        },
        geometry: {
          type: 'Polygon',
          coordinates: [
            [
              [108.2400, 16.0760],
              [108.2450, 16.0750],
              [108.2460, 16.0700],
              [108.2420, 16.0650],
              [108.2380, 16.0680],
              [108.2380, 16.0760]
            ]
          ]
        }
      }
    ]
  }
}
