import { useState } from '#imports'
import { useI18n } from 'vue-i18n'

import { getSupabaseClient } from './useSupabaseClient'
import { housingGuideData } from '~/mocks/housing'
import type { HousingDistrictFeature } from '~/types/housing'

/**
 * District data for the housing page: DB-backed (PostGIS geometry + localized
 * text) when a Supabase session exists, mock fallback otherwise. Text fields
 * are resolved to the CURRENT locale, so the page renders them directly;
 * `priceRange`/`bestFor` stay i18n keys (the UI translates them).
 */
export function useHousingDb() {
  const client = getSupabaseClient()
  const { t, locale } = useI18n()

  const districtFeatures = useState<HousingDistrictFeature[]>('housing-district-features', () => [])

  const mockFeatures = (): HousingDistrictFeature[] =>
    housingGuideData.districts.features.map(feature => ({
      ...feature,
      properties: {
        ...feature.properties,
        label: t(feature.properties.label),
        area: t(feature.properties.area),
        rentRange: t(feature.properties.rentRange),
        distanceToBeach: t(feature.properties.distanceToBeach),
        summary: t(feature.properties.summary)
      }
    }))

  const load = async () => {
    if (!client) {
      districtFeatures.value = mockFeatures()
      return
    }
    const {
      data: { session }
    } = await client.auth.getSession()
    if (!session) {
      districtFeatures.value = mockFeatures()
      return
    }
    try {
      const [districtRows, locRows] = await Promise.all([
        client.from('districts').select('id,slug,geometry,price_level,sort_order').order('sort_order'),
        client
          .from('district_localizations')
          .select('district_id,language,name,area,rent_range,distance_to_beach,summary,best_for')
      ])
      if (districtRows.error || locRows.error) throw districtRows.error ?? locRows.error
      const byDistrict = new Map<string, Record<string, Record<string, unknown>>>()
      for (const loc of locRows.data ?? []) {
        const entry = byDistrict.get(loc.district_id) ?? {}
        entry[loc.language] = loc
        byDistrict.set(loc.district_id, entry)
      }
      const lang = locale.value === 'en' ? 'en' : 'ru'
      districtFeatures.value = (districtRows.data ?? []).map((row) => {
        const loc = (byDistrict.get(row.id) ?? {})[lang] ?? (byDistrict.get(row.id) ?? {})[lang === 'en' ? 'ru' : 'en'] ?? {}
        const priceKey = row.price_level === 'above'
          ? 'housing.priceRanges.aboveAverage'
          : `housing.priceRanges.${row.price_level}`
        return {
          type: 'Feature',
          properties: {
            id: row.slug,
            label: (loc.name as string) ?? row.slug,
            area: (loc.area as string) ?? '',
            rentRange: (loc.rent_range as string) ?? '',
            priceRange: priceKey,
            bestFor: ((loc.best_for as string[]) ?? []).map((tag: string) => `housing.keyPoints.${tag}`),
            distanceToBeach: (loc.distance_to_beach as string) ?? '',
            summary: (loc.summary as string) ?? ''
          },
          geometry: (row.geometry as HousingDistrictFeature['geometry']) ?? { type: 'Polygon', coordinates: [] }
        }
      })
      if (!districtFeatures.value.length) districtFeatures.value = mockFeatures()
    } catch {
      // RLS read failed: keep the prototype usable.
      districtFeatures.value = mockFeatures()
    }
  }

  watch(locale, load, { immediate: true })

  return { districtFeatures, reload: load }
}
