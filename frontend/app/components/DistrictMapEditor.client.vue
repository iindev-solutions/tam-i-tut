<script setup lang="ts">
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'
import 'leaflet-draw'
import 'leaflet-draw/dist/leaflet.draw.css'

interface Props {
  geometry: { type: 'Polygon', coordinates: number[][][] } | null
}

interface Emits {
  updateGeometry: [g: { type: 'Polygon', coordinates: number[][][] } | null]
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()
const colorMode = useColorMode()

const TILE_URLS = {
  light: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
  dark: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
}
const TILE_SUBDOMAINS = 'abcd'

const mapEl = useTemplateRef<HTMLElement>('mapEl')
let map: L.Map | null = null
let tileLayer: L.TileLayer | null = null
let featureGroup: L.FeatureGroup | null = null

const polygonFromProps = (): L.Polygon | null => {
  if (!props.geometry) return null
  const ring = props.geometry.coordinates[0]
  if (!ring) return null
  // GeoJSON coords are [lng, lat]; Leaflet wants [lat, lng]
  const latlngs = ring.map(([lng, lat]) => [lat, lng] as [number, number])
  return L.polygon(latlngs, { color: '#f97316', weight: 2, fillColor: '#f97316', fillOpacity: 0.28 })
}

const syncTile = () => {
  if (!tileLayer) return
  tileLayer.setUrl(colorMode.value === 'dark' ? TILE_URLS.dark : TILE_URLS.light)
}

const emitGeometry = () => {
  if (!featureGroup) return
  const layer = featureGroup.getLayers()[0] as L.Polygon | undefined
  if (!layer) {
    emit('updateGeometry', null)
    return
  }
  // [lat, lng] -> GeoJSON [lng, lat]
  const latlngs = layer.getLatLngs() as L.LatLng[][]
  const first = latlngs[0]
  if (!first) return
  const ring = first.map(p => [p.lng, p.lat] as [number, number])
  if (ring.length < 3) return
  const start = ring[0]
  if (start) ring.push(start)
  emit('updateGeometry', { type: 'Polygon', coordinates: [ring] })
}

onMounted(() => {
  if (!mapEl.value) return
  map = L.map(mapEl.value, {
    center: [16.055, 108.2],
    zoom: 12,
    scrollWheelZoom: true,
    zoomControl: true,
    attributionControl: false
  })
  tileLayer = L.tileLayer(colorMode.value === 'dark' ? TILE_URLS.dark : TILE_URLS.light, {
    subdomains: TILE_SUBDOMAINS,
    maxZoom: 19
  }).addTo(map)

  featureGroup = new L.FeatureGroup()
  const existing = polygonFromProps()
  if (existing) featureGroup.addLayer(existing)
  map.addLayer(featureGroup)

  const drawControl = new L.Control.Draw({
    position: 'topleft',
    draw: {
      // allowIntersection stays true (default): with `false`, the preview ghost
      // point often intersects the growing polygon, the intersection check
      // rejects it and the user is stuck with a triangle (3 points).
      polygon: { showArea: true },
      rectangle: false,
      circle: false,
      marker: false,
      circlemarker: false,
      polyline: false
    },
    edit: { featureGroup }
  })
  map.addControl(drawControl)

  map.on(L.Draw.Event.CREATED, (e: L.LeafletEvent) => {
    featureGroup?.clearLayers()
    featureGroup?.addLayer((e as unknown as { layer: L.Layer }).layer as L.Polygon)
    emitGeometry()
  })
  map.on(L.Draw.Event.EDITED, () => emitGeometry())
  map.on(L.Draw.Event.DELETED, () => emitGeometry())

  if (existing) map.fitBounds(existing.getBounds())
})

onUnmounted(() => {
  map?.remove()
  map = null
  featureGroup = null
})

// Re-render the polygon when the parent passes a geometry (edit open, external
// change). Do NOT re-emit here: emitting a fresh object would change the prop
// reference and retrigger this watch - an infinite loop that freezes the map.
watch(() => props.geometry, () => {
  if (!featureGroup) return
  featureGroup.clearLayers()
  const p = polygonFromProps()
  if (p) featureGroup.addLayer(p)
})

watch(colorMode, syncTile)
</script>

<template>
  <div
    ref="mapEl"
    class="h-[420px] w-full overflow-hidden rounded-2xl border border-default shadow-sm"
    role="application"
    :aria-label="'District polygon editor'"
  />
</template>

<style>
.leaflet-container {
  font-family: inherit;
  background: #18181b;
}
</style>
