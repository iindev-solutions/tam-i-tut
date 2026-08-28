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

/** Placeholder icon per place type when no photo is (yet) available. */
const typeIcons: Record<PlaceType, string> = {
  cafe: 'i-lucide-coffee',
  street: 'i-lucide-utensils',
  market: 'i-lucide-store',
  restaurant: 'i-lucide-chef-hat'
}

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

/** Photo URLs can 404/expire (external sources) - degrade to the placeholder. */
const brokenImages = shallowRef(new Set<string>())
const onImageError = (place: Place) => {
  const next = new Set(brokenImages.value)
  next.add(place.id)
  brokenImages.value = next
}
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

      <section aria-label="Places">
        <p
          v-if="places.length === 0"
          class="rounded-xl border border-default bg-elevated/50 p-6 text-center text-sm text-muted"
        >
          {{ t('food.empty') }}
        </p>

        <!-- Vertical list: one full-width photo card per place, top-down. -->
        <div
          v-else
          class="space-y-4"
        >
          <NuxtLink
            v-for="place in places"
            :key="place.id"
            :to="`/places/${place.slug}`"
            class="block overflow-hidden rounded-xl border border-default bg-default shadow-sm transition-transform active:scale-[0.99]"
          >
            <div class="relative h-44 w-full overflow-hidden bg-elevated">
              <img
                v-if="place.imageUrl && !brokenImages.has(place.id)"
                :src="place.imageUrl"
                :alt="place.name"
                class="h-full w-full object-cover"
                loading="lazy"
                @error="onImageError(place)"
              >
              <div
                v-else
                class="flex h-full w-full items-center justify-center bg-gradient-to-br from-primary/10 via-elevated to-primary/5"
              >
                <UIcon
                  :name="typeIcons[place.type]"
                  class="size-10 text-dimmed"
                />
              </div>
              <span
                v-if="place.verified"
                class="absolute top-2 right-2 flex items-center gap-1 rounded-full bg-default/85 px-2 py-0.5 text-[11px] font-medium text-default backdrop-blur"
              >
                <UIcon
                  name="i-lucide-badge-check"
                  class="size-3.5 text-primary"
                />
                {{ t('food.verifiedTitle') }}
              </span>
            </div>

            <div class="space-y-2 p-4">
              <p class="text-base font-semibold text-highlighted">
                {{ place.name }}
              </p>
              <p class="text-xs text-muted">
                {{ t(`food.filters.${place.type}`) }} · {{ tt(place.area) }} · {{ t(`food.price.${place.priceLevel}`) }}
              </p>
              <p class="line-clamp-2 text-sm leading-6 text-muted">
                {{ tt(place.summary) }}
              </p>
              <p
                v-if="place.approvedReviews > 0"
                class="flex items-center gap-1.5 text-xs text-muted"
              >
                <UIcon
                  name="i-lucide-message-circle"
                  class="size-3.5"
                />
                {{ place.approvedReviews }} · {{ t('food.reviewsLabel') }}
              </p>
            </div>
          </NuxtLink>
        </div>
      </section>
    </div>
  </UContainer>
</template>
