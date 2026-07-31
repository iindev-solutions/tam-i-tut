<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref, watch } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

import type { HousingGuideData } from '~/types/housing'

interface Props {
  data: HousingGuideData
  selectedId: string
}

interface Emits {
  select: [id: string]
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()
const mapContainer = ref<HTMLElement | null>(null)
let map: L.Map | null = null

onMounted(() => {
  if (!mapContainer.value) return

  map = L.map(mapContainer.value, {
    zoomControl: false,
    scrollWheelZoom: false
  }).setView([16.0599, 108.2353], 13)

  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(map)

  L.control.zoom({
    position: 'bottomright'
  }).addTo(map)

  const defaultStyle = {
    color: '#71717a',
    weight: 1.5,
    fillColor: '#fafafa',
    fillOpacity: 0.4
  }

  const activeStyle = {
    color: '#f97316',
    weight: 2,
    fillColor: '#ffedd5',
    fillOpacity: 0.55
  }

  const layers: Record<string, L.Layer> = {}

  L.geoJSON(props.data.districts, {
    style: () => defaultStyle,
    onEachFeature: (feature, layer) => {
      const id = feature.properties.id
      layers[id] = layer

      layer.on({
        click: () => emit('select', id)
      })

      layer.bindTooltip(feature.properties.label, {
        permanent: true,
        direction: 'center',
        className: 'district-label'
      })
    }
  }).addTo(map)

  const applyStyle = (id: string, style: L.PathOptions) => {
    const layer = layers[id]
    if (layer && 'setStyle' in layer) {
      ;(layer as L.Path).setStyle(style)
    }
  }

  const updateSelection = (newId: string, oldId?: string) => {
    if (oldId) applyStyle(oldId, defaultStyle)
    if (newId) applyStyle(newId, activeStyle)
  }

  updateSelection(props.selectedId)

  watch(() => props.selectedId, updateSelection)
})

onBeforeUnmount(() => {
  map?.remove()
  map = null
})
</script>

<template>
  <div
    ref="mapContainer"
    class="h-[400px] w-full overflow-hidden rounded-3xl border border-default"
  />
</template>

<style scoped>
:deep(.district-label) {
  background: transparent;
  border: none;
  box-shadow: none;
  font-weight: 600;
  color: #18181b;
  text-shadow: 0 0 4px #fff, 0 0 4px #fff, 0 0 4px #fff;
  font-family: Inter, sans-serif;
  font-size: 13px;
}
</style>
