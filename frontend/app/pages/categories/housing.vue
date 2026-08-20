<script setup lang="ts">
import { computed, shallowRef } from 'vue'
import { useI18n } from 'vue-i18n'

import { housingGuideData } from '~/mocks/housing'
import { useHousingDb } from '~/composables/useHousingDb'
import type { HousingGuideData, HousingResource } from '~/types/housing'

const { t } = useI18n()
const { tt } = useLocalized()

const data: HousingGuideData = housingGuideData
const { districtFeatures } = useHousingDb()
const sections = computed(() =>
  data.sections.map(section => ({
    ...section,
    titleText: t(section.title),
    description: t(section.description),
    bullets: section.bullets.map(bullet => t(bullet))
  }))
)

const RESOURCE_ICONS: Record<HousingResource['kind'], string> = {
  telegram: 'i-lucide-send',
  facebook: 'i-lucide-facebook',
  zalo: 'i-lucide-message-circle',
  site: 'i-lucide-globe',
  agency: 'i-lucide-building-2'
}

const selectedDistrictId = shallowRef<string>(districtFeatures.value[0]?.properties.id ?? '')

// Districts load async from Supabase; keep a default selection once they arrive.
watch(districtFeatures, (features) => {
  if (features.length && !features.some(f => f.properties.id === selectedDistrictId.value)) {
    selectedDistrictId.value = features[0]?.properties.id ?? ''
  }
})

const selectedDistrict = computed(() =>
  districtFeatures.value.find(feature => feature.properties.id === selectedDistrictId.value)?.properties
)

const activeTab = shallowRef('info')
const tabs = computed(() => [
  { label: t('housing.tabs.info'), value: 'info', icon: 'i-lucide-book-open' },
  { label: t('housing.tabs.map'), value: 'map', icon: 'i-lucide-map' }
])

const slideoverOpen = shallowRef(false)

const handleSelect = (id: string) => {
  selectedDistrictId.value = id
  slideoverOpen.value = true
}

const openOnMap = (id: string) => {
  selectedDistrictId.value = id
  activeTab.value = 'map'
  slideoverOpen.value = true
}
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-6">
      <header class="space-y-1">
        <p class="text-sm text-muted">
          {{ t(data.hero.kicker) }}
        </p>
        <h1 class="text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
          {{ t(data.hero.title) }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t(data.hero.description) }}
        </p>
      </header>

      <UTabs
        v-model="activeTab"
        :items="tabs"
        variant="link"
        :content="false"
      />

      <template v-if="activeTab === 'info'">
        <section class="space-y-4">
          <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <UCard
              v-for="section in sections"
              :key="section.title"
              class="border-default"
              :ui="{ body: 'p-5' }"
            >
              <div class="space-y-3">
                <div class="flex items-start justify-between gap-4">
                  <p class="text-sm font-medium text-highlighted">
                    {{ section.titleText }}
                  </p>
                  <UIcon
                    :name="section.icon"
                    class="size-5 shrink-0 text-muted"
                  />
                </div>
                <p class="text-sm leading-6 text-muted">
                  {{ section.description }}
                </p>
                <ul class="space-y-3 text-sm">
                  <li
                    v-for="bullet in section.bullets"
                    :key="bullet"
                    class="flex items-start gap-3"
                  >
                    <UIcon
                      name="i-lucide-check"
                      class="mt-0.5 size-4 shrink-0 text-muted"
                    />
                    <span class="text-muted">{{ bullet }}</span>
                  </li>
                </ul>
              </div>
            </UCard>
          </div>
        </section>

        <section class="space-y-3">
          <h2 class="text-2xl font-semibold text-highlighted">
            {{ t('housing.resources.title') }}
          </h2>
          <p class="text-sm text-muted">
            {{ t('housing.resources.subtitle') }}
          </p>
          <UCard
            class="border-default"
            :ui="{ body: 'p-0' }"
          >
            <ul class="divide-y divide-default">
              <li
                v-for="resource in data.resources"
                :key="resource.id"
              >
                <a
                  :href="resource.url"
                  target="_blank"
                  rel="noopener noreferrer"
                  class="flex items-center gap-3 px-5 py-3 transition-colors hover:bg-elevated"
                >
                  <UIcon
                    :name="RESOURCE_ICONS[resource.kind]"
                    class="size-4 shrink-0 text-muted"
                  />
                  <span class="min-w-0 flex-1">
                    <span class="block text-sm font-medium text-highlighted">{{ resource.name }}</span>
                    <span
                      v-if="resource.note"
                      class="block truncate text-xs text-muted"
                    >{{ tt(resource.note) }}</span>
                  </span>
                  <UIcon
                    name="i-lucide-arrow-up-right"
                    class="size-4 shrink-0 text-muted"
                  />
                </a>
              </li>
            </ul>
          </UCard>
          <p class="flex items-start gap-2 text-sm leading-6 text-muted">
            <UIcon
              name="i-lucide-lightbulb"
              class="mt-0.5 size-4 shrink-0"
            />
            {{ t('housing.resources.tip') }}
          </p>
        </section>

        <section class="space-y-3">
          <h2 class="text-2xl font-semibold text-highlighted">
            {{ t('housing.districtsTitle') }}
          </h2>
          <p class="text-sm text-muted">
            {{ t('housing.districtsHint') }}
          </p>
          <div class="space-y-3">
            <button
              v-for="feature in districtFeatures"
              :key="feature.properties.id"
              type="button"
              class="flex w-full items-center gap-4 rounded-2xl border border-default bg-elevated p-4 text-left shadow-sm transition-colors hover:border-primary/30"
              @click="openOnMap(feature.properties.id)"
            >
              <div class="min-w-0 flex-1">
                <p class="text-sm font-medium text-highlighted">
                  {{ feature.properties.label }}
                </p>
                <p class="mt-1 truncate text-sm text-muted">
                  {{ feature.properties.area }} · {{ feature.properties.distanceToBeach }}
                </p>
              </div>
              <div class="shrink-0 text-right">
                <p class="text-sm font-semibold text-highlighted">
                  {{ feature.properties.rentRange }}
                </p>
                <p class="mt-0.5 text-xs text-muted">
                  {{ t(feature.properties.priceRange) }}
                </p>
              </div>
              <UIcon
                name="i-lucide-map-pin"
                class="size-4 shrink-0 text-muted"
              />
            </button>
          </div>
        </section>
      </template>

      <template v-else>
        <section class="space-y-4">
          <HousingTileMap
            :districts="districtFeatures"
            :selected-id="selectedDistrictId"
            @select="handleSelect"
          />

          <div
            class="flex flex-wrap gap-2"
            role="group"
            :aria-label="t('housing.chipsAria')"
          >
            <button
              v-for="feature in districtFeatures"
              :key="feature.properties.id"
              type="button"
              class="rounded-full border px-3 py-1.5 text-sm whitespace-nowrap transition-colors"
              :class="selectedDistrictId === feature.properties.id
                ? 'border-primary/40 bg-primary/10 font-medium text-highlighted'
                : 'border-default text-muted hover:bg-elevated hover:text-default'"
              :aria-pressed="selectedDistrictId === feature.properties.id"
              @click="handleSelect(feature.properties.id)"
            >
              {{ feature.properties.label }}
            </button>
          </div>

          <p class="text-xs leading-5 text-muted">
            {{ t('housing.mapDisclaimer') }}
            {{ t('housing.mapCredits') }}
          </p>
        </section>
      </template>

      <USlideover
        v-model:open="slideoverOpen"
        :title="selectedDistrict ? selectedDistrict.label : ''"
        :description="selectedDistrict ? `${selectedDistrict.area} · ${selectedDistrict.distanceToBeach}` : ''"
        side="bottom"
        :ui="{ content: 'max-h-[78vh] rounded-t-3xl' }"
      >
        <template #body>
          <div
            v-if="selectedDistrict"
            class="space-y-5"
          >
            <div class="flex min-h-24 flex-col justify-center rounded-2xl bg-elevated p-4 text-center">
              <p class="text-lg font-semibold">
                {{ selectedDistrict.rentRange }}
              </p>
              <p class="mt-1 text-xs text-muted">
                {{ t('housing.rentTitle') }} · {{ t(selectedDistrict.priceRange) }}
              </p>
            </div>

            <div>
              <p class="text-sm font-medium text-highlighted">
                {{ t('housing.districts.idealFor') }}
              </p>
              <ul class="mt-2 space-y-1 text-sm text-muted">
                <li
                  v-for="point in selectedDistrict.bestFor"
                  :key="point"
                  class="flex items-start gap-2"
                >
                  <UIcon
                    name="i-lucide-check"
                    class="mt-0.5 size-4 shrink-0 text-muted"
                  />
                  <span>{{ t(point) }}</span>
                </li>
              </ul>
            </div>

            <div>
              <p class="text-sm font-medium text-highlighted">
                {{ t('housing.districts.reference') }}
              </p>
              <p class="mt-2 text-sm leading-6 text-muted">
                {{ selectedDistrict.summary }}
              </p>
            </div>
          </div>
        </template>
      </USlideover>
    </div>
  </UContainer>
</template>
