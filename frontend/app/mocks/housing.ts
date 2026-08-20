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
        'housing.sections.renting.bullets.contract',
        'housing.sections.renting.bullets.deposit',
        'housing.sections.renting.bullets.agent',
        'housing.sections.renting.bullets.bilingual',
        'housing.sections.renting.bullets.registration',
        'housing.sections.renting.bullets.utilities'
      ]
    },
    {
      title: 'housing.sections.trust.title',
      icon: 'i-lucide-shield-check',
      description: 'housing.sections.trust.description',
      bullets: [
        'housing.sections.trust.bullets.visit',
        'housing.sections.trust.bullets.pests',
        'housing.sections.trust.bullets.neighbors',
        'housing.sections.trust.bullets.walk',
        'housing.sections.trust.bullets.meters'
      ]
    }
  ],
  resources: [
    {
      id: 'vietnam-rent',
      kind: 'telegram',
      name: 'Вьетнам аренда | недвижимость',
      url: 'https://t.me/vietnam_rent',
      note: {
        ru: 'Главный русскоязычный канал по аренде',
        en: 'The main Russian-language rental channel'
      }
    },
    {
      id: 'fb-danang-expats',
      kind: 'facebook',
      name: 'DA NANG EXPATS HOUSE - APARTMENT',
      url: 'https://www.facebook.com/groups/2050474701865103',
      note: {
        ru: 'Ценник чуть выше среднего',
        en: 'Prices slightly above average'
      }
    },
    {
      id: 'fb-danang-hoian',
      kind: 'facebook',
      name: 'Apartments, Houses, Villas Rental in Da Nang - Hoi An Expats',
      url: 'https://www.facebook.com/groups/203559903815711'
    },
    {
      id: 'fb-danang-rooms',
      kind: 'facebook',
      name: 'Da Nang Apartments & Rooms',
      url: 'https://www.facebook.com/groups/danangrent'
    },
    {
      id: 'fb-cho-thue',
      kind: 'facebook',
      name: 'Cho thuê căn hộ Đà Nẵng',
      url: 'https://www.facebook.com/groups/chothuecanhodanang43',
      note: {
        ru: 'Местные группы, 80 000+ участников, цены ниже',
        en: 'Local groups, 80,000+ members, lower prices'
      }
    },
    {
      id: 'cho-tot',
      kind: 'site',
      name: 'Cho Tot (nhatot.com)',
      url: 'https://www.nhatot.com/',
      note: {
        ru: 'Местный сайт объявлений + приложение',
        en: 'Local listing site + mobile app'
      }
    },
    {
      id: 'zalo-1',
      kind: 'zalo',
      name: 'Zalo · группа 1',
      url: 'https://zalo.me/g/nseeyy190'
    },
    {
      id: 'zalo-2',
      kind: 'zalo',
      name: 'Zalo · группа 2',
      url: 'https://zalo.me/g/rknips395'
    },
    {
      id: 'zalo-3',
      kind: 'zalo',
      name: 'Zalo · группа 3',
      url: 'https://zalo.me/g/agrsjs497'
    },
    {
      id: 'danang-landlord',
      kind: 'agency',
      name: 'Da Nang Landlord',
      url: 'https://dananglandlord.com/',
      note: {
        ru: 'Агентство: порядок цен по районам',
        en: 'Agency: price levels by district'
      }
    },
    {
      id: 'toan-huy-hoang',
      kind: 'agency',
      name: 'Toan Huy Hoang Realty',
      url: 'https://toanhuyhoang.com/en/real-estate-danang/'
    },
    {
      id: 'cvr',
      kind: 'agency',
      name: 'Central Vietnam Realty',
      url: 'https://cvr.com.vn/'
    }
  ],
  districts: {
    type: 'FeatureCollection',
    features: [
      {
        type: 'Feature',
        properties: {
          id: 'son-tra',
          label: 'housing.districts.sonTra.label',
          area: 'housing.districts.sonTra.area',
          rentRange: 'housing.districts.sonTra.rent',
          priceRange: 'housing.priceRanges.aboveAverage',
          bestFor: ['housing.keyPoints.beach', 'housing.keyPoints.nightlife', 'housing.keyPoints.expat'],
          distanceToBeach: 'housing.districts.sonTra.distance',
          summary: 'housing.districts.sonTra.summary'
        },
        geometry: {
          type: 'Polygon',
          coordinates: [
            [
              [108.235, 16.078],
              [108.245, 16.11],
              [108.26, 16.14],
              [108.3, 16.165],
              [108.33, 16.16],
              [108.315, 16.12],
              [108.28, 16.075],
              [108.255, 16.05],
              [108.235, 16.078]
            ]
          ]
        }
      },
      {
        type: 'Feature',
        properties: {
          id: 'ngu-hanh-son',
          label: 'housing.districts.nguHanhSon.label',
          area: 'housing.districts.nguHanhSon.area',
          rentRange: 'housing.districts.nguHanhSon.rent',
          priceRange: 'housing.priceRanges.average',
          bestFor: ['housing.keyPoints.family', 'housing.keyPoints.quiet'],
          distanceToBeach: 'housing.districts.nguHanhSon.distance',
          summary: 'housing.districts.nguHanhSon.summary'
        },
        geometry: {
          type: 'Polygon',
          coordinates: [
            [
              [108.235, 16.045],
              [108.255, 16.05],
              [108.28, 16.07],
              [108.29, 16.045],
              [108.285, 16.01],
              [108.27, 15.995],
              [108.25, 16.005],
              [108.235, 16.02],
              [108.23, 16.035],
              [108.235, 16.045]
            ]
          ]
        }
      },
      {
        type: 'Feature',
        properties: {
          id: 'hai-chau',
          label: 'housing.districts.haiChau.label',
          area: 'housing.districts.haiChau.area',
          rentRange: 'housing.districts.haiChau.rent',
          priceRange: 'housing.priceRanges.average',
          bestFor: ['housing.keyPoints.markets', 'housing.keyPoints.transport'],
          distanceToBeach: 'housing.districts.haiChau.distance',
          summary: 'housing.districts.haiChau.summary'
        },
        geometry: {
          type: 'Polygon',
          coordinates: [
            [
              [108.185, 16.05],
              [108.215, 16.03],
              [108.235, 16.045],
              [108.23, 16.06],
              [108.22, 16.075],
              [108.19, 16.07],
              [108.185, 16.05]
            ]
          ]
        }
      },
      {
        type: 'Feature',
        properties: {
          id: 'thanh-khe',
          label: 'housing.districts.thanhKhe.label',
          area: 'housing.districts.thanhKhe.area',
          rentRange: 'housing.districts.thanhKhe.rent',
          priceRange: 'housing.priceRanges.budget',
          bestFor: ['housing.keyPoints.budget', 'housing.keyPoints.local'],
          distanceToBeach: 'housing.districts.thanhKhe.distance',
          summary: 'housing.districts.thanhKhe.summary'
        },
        geometry: {
          type: 'Polygon',
          coordinates: [
            [
              [108.15, 16.065],
              [108.185, 16.06],
              [108.195, 16.08],
              [108.19, 16.105],
              [108.16, 16.115],
              [108.145, 16.09],
              [108.15, 16.065]
            ]
          ]
        }
      },
      {
        type: 'Feature',
        properties: {
          id: 'lien-chieu',
          label: 'housing.districts.lienChieu.label',
          area: 'housing.districts.lienChieu.area',
          rentRange: 'housing.districts.lienChieu.rent',
          priceRange: 'housing.priceRanges.budget',
          bestFor: ['housing.keyPoints.quiet', 'housing.keyPoints.budget'],
          distanceToBeach: 'housing.districts.lienChieu.distance',
          summary: 'housing.districts.lienChieu.summary'
        },
        geometry: {
          type: 'Polygon',
          coordinates: [
            [
              [108.105, 16.1],
              [108.145, 16.092],
              [108.158, 16.118],
              [108.135, 16.15],
              [108.11, 16.14],
              [108.105, 16.1]
            ]
          ]
        }
      },
      {
        type: 'Feature',
        properties: {
          id: 'cam-le',
          label: 'housing.districts.camLe.label',
          area: 'housing.districts.camLe.area',
          rentRange: 'housing.districts.camLe.rent',
          priceRange: 'housing.priceRanges.budget',
          bestFor: ['housing.keyPoints.budget', 'housing.keyPoints.family'],
          distanceToBeach: 'housing.districts.camLe.distance',
          summary: 'housing.districts.camLe.summary'
        },
        geometry: {
          type: 'Polygon',
          coordinates: [
            [
              [108.18, 16.028],
              [108.215, 16.025],
              [108.232, 16.033],
              [108.235, 16.018],
              [108.22, 15.99],
              [108.195, 16.0],
              [108.18, 16.01],
              [108.18, 16.028]
            ]
          ]
        }
      }
    ]
  }
}
