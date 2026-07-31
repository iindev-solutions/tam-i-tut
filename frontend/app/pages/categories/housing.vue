<script setup lang="ts">
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import { housingGuideData } from '~/mocks/housing'
import type { HousingGuideData, HousingDistrictFeature } from '~/types/housing'

const { t } = useI18n()

const data: HousingGuideData = housingGuideData
const sections = data.sections.map(section => ({
  ...section,
  description: t(section.description),
  bullets: section.bullets.map(bullet => t(bullet))
}))

const districtFeatures = data.districts.features
const selectedDistrictId = ref<string>(districtFeatures[0]?.properties.id ?? '')
const selectedDistrict = computed(() =>
  districtFeatures.find((feature: HousingDistrictFeature) => feature.properties.id === selectedDistrictId.value)?.properties
)

const handleSelect = (id: string) => {
  selectedDistrictId.value = id
}
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
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

      <section class="space-y-4">
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <UCard
            v-for="section in sections"
            :key="section.title"
            class="border-default"
            :ui="{ body: 'p-5' }"
          >
          <div class="space-y-3">
            <div class="flex items-start justify-between gap-4">
              <p class="text-sm font-medium text-highlighted">
                {{ t(section.title) }}
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

      <section class="space-y-4">
        <h2 class="text-2xl font-semibold text-highlighted">
          {{ t('housing.mapTitle') }}
        </h2>
        <p class="text-sm text-muted">
          {{ t('housing.mapDescription') }}
        </p>

        <ClientOnly>
          <HousingMap
            :data="data"
            :selected-id="selectedDistrictId"
            @select="handleSelect"
          />
          <template #fallback>
            <div class="flex h-[400px] w-full items-center justify-center rounded-3xl border border-default bg-elevated">
              <p class="text-sm text-muted">
                {{ t('housing.mapLoading') }}
              </p>
            </div>
          </template>
        </ClientOnly>

        <Transition
          name="fade"
          mode="out-in"
        >
          <UCard
            v-if="selectedDistrict"
            class="mt-4 border-default"
          >
            <div class="flex flex-col gap-4">
              <div>
                <p class="flex items-center gap-2 text-sm font-medium text-highlighted">
                  {{ t(selectedDistrict.label) }}
                </p>
                <p class="mt-1 text-sm text-muted">
                  {{ t(selectedDistrict.area) }} · {{ t(selectedDistrict.distanceToBeach) }}
                </p>

                <div class="grid gap-4 sm:grid-cols-3">
                  <div>
                    <div class="aspect-square rounded-2xl bg-elevated p-4">
                      <p class="text-center text-2xl font-semibold">
                        {{ t(selectedDistrict.priceRange) }}
                      </p>
                    </div>
                    <p class="mt-1 text-center text-xs text-muted">
                      {{ t('housing.kickerPricing') }}
                    </p>
                  </div>
                  <div class="sm:col-span-2">
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
                    <p class="mt-4 text-sm font-medium text-highlighted">
                      {{ t('housing.districts.reference') }}
                    </p>
                    <p class="mt-2 text-sm text-muted">
                      {{ t(selectedDistrict.summary) }}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </UCard>
        </Transition>
      </section>
    </div>
  </UContainer>
</template>

<style scoped>
.fade-enter-active,
.fade-leave-active {
  transition: opacity 150ms ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
