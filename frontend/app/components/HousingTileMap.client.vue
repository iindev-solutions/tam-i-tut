<script setup lang="ts">
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import type { FeatureCollection } from 'geojson'

import type { HousingDistrictFeature } from '~/types/housing'

interface Props {
  districts: HousingDistrictFeature[]
  selectedId: string
}

interface Emits {
  select: [id: string]
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()
const { t, locale } = useI18n()
const colorMode = useColorMode()

const TILE_URLS = {
  light: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
  dark: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
}
const TILE_SUBDOMAINS = 'abcd'

const BASE_STYLE: L.PathOptions = {
  color: '#a1a1aa',
  weight: 2,
  fillColor: '#52525b',
  fillOpacity: 0.3
}
const HOVER_STYLE: L.PathOptions = { fillOpacity: 0.45, weight: 2.5 }
const SELECTED_STYLE: L.PathOptions = {
  color: '#f97316',
  weight: 3,
  fillColor: '#f97316',
  fillOpacity: 0.28
}

const mapEl = useTemplateRef<HTMLElement>('mapEl')
let map: L.Map | null = null
let tileLayer: L.TileLayer | null = null
let geoLayer: L.GeoJSON | null = null

const featureIdOf = (layer: L.Layer): string | null => {
  const feature = (layer as { feature?: { properties?: { id?: unknown } } }).feature
  return feature?.properties ? String(feature.properties.id) : null
}

const applySelection = () => {
  if (!geoLayer) return
  geoLayer.eachLayer((layer) => {
    const path = layer as L.Path
    path.setStyle(featureIdOf(layer) === props.selectedId ? SELECTED_STYLE : BASE_STYLE)
  })
}

const refreshLabels = () => {
  if (!geoLayer) return
  geoLayer.eachLayer((layer) => {
    const feature = (layer as { feature?: { properties?: { label?: unknown } } }).feature
    if (feature?.properties) layer.setTooltipContent(String(feature.properties.label))
  })
}

onMounted(() => {
  if (!mapEl.value) return

  map = L.map(mapEl.value, {
    center: [16.055, 108.2],
    zoom: 12,
    scrollWheelZoom: false,
    zoomControl: true,
    attributionControl: false
  })

  tileLayer = L.tileLayer(colorMode.value === 'dark' ? TILE_URLS.dark : TILE_URLS.light, {
    subdomains: TILE_SUBDOMAINS,
    maxZoom: 19
  }).addTo(map)

  const collection = { type: 'FeatureCollection', features: props.districts } as FeatureCollection

  geoLayer = L.geoJSON(collection, {
    style: () => BASE_STYLE,
    onEachFeature: (feature, layer) => {
      const id = String(feature.properties?.id)
      layer.bindTooltip(String(feature.properties?.label), {
        permanent: true,
        direction: 'center',
        className: 'housing-district-label'
      })
      layer.on('click', () => emit('select', id))
      layer.on('mouseover', () => {
        if (id !== props.selectedId) (layer as L.Path).setStyle(HOVER_STYLE)
      })
      layer.on('mouseout', () => {
        if (id !== props.selectedId) (layer as L.Path).setStyle(BASE_STYLE)
      })
    }
  }).addTo(map)

  map.fitBounds(geoLayer.getBounds().pad(0.08))
  applySelection()
})

watch(
  () => props.selectedId,
  () => applySelection()
)

watch(locale, () => refreshLabels())

watch(
  () => colorMode.value,
  (mode) => {
    if (!map || !tileLayer) return
    tileLayer.setUrl(mode === 'dark' ? TILE_URLS.dark : TILE_URLS.light)
  }
)

onBeforeUnmount(() => {
  map?.remove()
  map = null
  geoLayer = null
  tileLayer = null
})
</script>

<template>
  <div
    ref="mapEl"
    class="h-[400px] w-full overflow-hidden rounded-3xl border border-default shadow-sm sm:h-[440px]"
    role="application"
    :aria-label="t('housing.mapAriaLabel')"
  />
</template>

<style>
.housing-district-label {
  background: transparent;
  border: none;
  box-shadow: none;
  color: #f4f4f5;
  font-size: 12px;
  font-weight: 600;
  text-shadow: 0 1px 3px rgba(9, 9, 11, 0.9);
  pointer-events: none;
  white-space: nowrap;
}

.leaflet-container {
  font-family: inherit;
  background: #18181b;
}
</style>
