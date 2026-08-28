<script setup lang="ts">
import { computed, shallowRef } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const route = useRoute()
const { db } = useDb()
const { tt } = useLocalized()

const typeIcons: Record<string, string> = {
  cafe: 'i-lucide-coffee',
  street: 'i-lucide-utensils',
  market: 'i-lucide-store',
  restaurant: 'i-lucide-chef-hat'
}

const place = computed(() =>
  db.value.places.find(p => p.status === 'published' && p.slug === route.params.slug)
)

const approvedReviews = computed(() =>
  db.value.reviews.filter(r => r.status === 'approved' && r.placeId === place.value?.id).length
)

/** Google Maps deep link: name + area resolve reliably without stored coordinates. */
const mapsUrl = computed(() => {
  const p = place.value
  if (!p) return ''
  const query = [p.name, tt(p.area), 'Da Nang'].filter(Boolean).join(', ')
  return `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(query)}`
})

const imageBroken = shallowRef(false)
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-6">
      <UButton
        to="/categories/food"
        variant="ghost"
        color="neutral"
        size="sm"
        icon="i-lucide-arrow-left"
        :label="t('food.details.back')"
      />

      <article
        v-if="place"
        class="space-y-5"
      >
        <div class="relative h-56 w-full overflow-hidden rounded-2xl border border-default bg-elevated sm:h-72">
          <img
            v-if="place.imageUrl && !imageBroken"
            :src="place.imageUrl"
            :alt="place.name"
            class="h-full w-full object-cover"
            @error="imageBroken = true"
          >
          <div
            v-else
            class="flex h-full w-full items-center justify-center bg-gradient-to-br from-primary/10 via-elevated to-primary/5"
          >
            <UIcon
              :name="typeIcons[place.type]"
              class="size-14 text-dimmed"
            />
          </div>
        </div>

        <header class="space-y-2">
          <div class="flex items-start justify-between gap-3">
            <h1 class="text-3xl font-semibold tracking-tight text-highlighted">
              {{ place.name }}
            </h1>
            <UIcon
              v-if="place.verified"
              name="i-lucide-badge-check"
              class="mt-1.5 size-6 shrink-0 text-primary"
              :aria-label="t('food.verifiedTitle')"
            />
          </div>
          <p class="text-sm text-muted">
            {{ t(`food.filters.${place.type}`) }} · {{ t(`food.price.${place.priceLevel}`) }}
            <template v-if="approvedReviews > 0">
              · {{ approvedReviews }} {{ t('food.details.reviews') }}
            </template>
          </p>
        </header>

        <p class="text-base leading-7 text-default">
          {{ tt(place.summary) }}
        </p>

        <section class="space-y-2 rounded-xl border border-default bg-elevated/50 p-4">
          <p class="flex items-center gap-2 text-sm font-medium text-highlighted">
            <UIcon
              name="i-lucide-map-pin"
              class="size-4 text-primary"
            />
            {{ t('food.details.location') }}
          </p>
          <p class="text-sm text-muted">
            {{ tt(place.area) }}
          </p>
          <UButton
            :to="mapsUrl"
            target="_blank"
            rel="noopener"
            color="primary"
            variant="soft"
            size="sm"
            icon="i-lucide-external-link"
            :label="t('food.details.openMaps')"
            class="mt-1"
          />
        </section>
      </article>

      <p
        v-else
        class="rounded-xl border border-default bg-elevated/50 p-6 text-center text-sm text-muted"
      >
        {{ t('food.empty') }}
      </p>
    </div>
  </UContainer>
</template>
