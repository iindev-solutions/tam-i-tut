<script setup lang="ts">
import { computed, shallowRef } from 'vue'
import { useI18n } from 'vue-i18n'

import type { Place, PlaceType } from '~/types/content'

const { t } = useI18n()
const { db } = useDb()
const { tt } = useLocalized()

const filters: Array<{ id: PlaceType | 'all', labelKey: string }> = [
  { id: 'all', labelKey: 'food.filters.all' },
  { id: 'cafe', labelKey: 'food.filters.cafe' },
  { id: 'street', labelKey: 'food.filters.street' },
  { id: 'market', labelKey: 'food.filters.market' },
  { id: 'restaurant', labelKey: 'food.filters.restaurant' }
]

const activeFilter = shallowRef<PlaceType | 'all'>('all')

interface PlaceWithReviews extends Place {
  approvedReviews: number
}

const places = computed<PlaceWithReviews[]>(() => {
  const approved = new Map<string, number>()
  for (const review of db.value.reviews) {
    if (review.status === 'approved') approved.set(review.placeId, (approved.get(review.placeId) ?? 0) + 1)
  }
  return db.value.places
    .filter(place => place.status === 'published' && (activeFilter.value === 'all' || place.type === activeFilter.value))
    .map(place => ({ ...place, approvedReviews: approved.get(place.id) ?? 0 }))
})
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
      <header class="space-y-1">
        <p class="text-sm text-muted">
          {{ t('food.kicker') }}
        </p>
        <h1 class="text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
          {{ t('food.title') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('food.description') }}
        </p>
      </header>

      <div
        class="flex flex-wrap gap-2"
        role="group"
        :aria-label="t('food.filters.aria')"
      >
        <button
          v-for="filter in filters"
          :key="filter.id"
          type="button"
          class="rounded-full border px-3 py-1.5 text-sm whitespace-nowrap transition-colors"
          :class="activeFilter === filter.id
            ? 'border-default bg-elevated font-medium text-highlighted'
            : 'border-transparent text-muted hover:bg-elevated hover:text-default'"
          :aria-pressed="activeFilter === filter.id"
          @click="activeFilter = filter.id"
        >
          {{ t(filter.labelKey) }}
        </button>
      </div>

      <section>
        <UCarousel
          :items="places"
          :ui="{ item: 'basis-[86%] sm:basis-1/2' }"
          dots
          arrows
        >
          <template #default="{ item }">
            <div class="h-full pr-3">
              <UCard
                :key="item.id"
                class="h-full border-default"
                :ui="{ body: 'p-5' }"
              >
                <div class="space-y-3">
                  <div class="flex items-start justify-between gap-3">
                    <p class="text-sm font-medium text-highlighted">
                      {{ item.name }}
                    </p>
                    <UIcon
                      v-if="item.verified"
                      name="i-lucide-badge-check"
                      class="mt-0.5 size-4 shrink-0 text-primary"
                      :aria-label="t('food.verifiedTitle')"
                    />
                  </div>
                  <p class="text-xs text-muted">
                    {{ t(`food.filters.${item.type}`) }} · {{ tt(item.area) }} · {{ t(`food.price.${item.priceLevel}`) }}
                  </p>
                  <p class="text-sm leading-6 text-muted">
                    {{ tt(item.summary) }}
                  </p>
                  <p
                    v-if="item.approvedReviews > 0"
                    class="flex items-center gap-1.5 text-xs text-muted"
                  >
                    <UIcon
                      name="i-lucide-message-circle"
                      class="size-3.5"
                    />
                    {{ item.approvedReviews }} · {{ t('food.reviewsLabel') }}
                  </p>
                </div>
              </UCard>
            </div>
          </template>
        </UCarousel>
      </section>
    </div>
  </UContainer>
</template>
