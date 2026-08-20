<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

import { useAdminDb } from '~/composables/useAdminDb'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const { t } = useI18n()
const admin = useAdminDb()

onMounted(() => admin.loadAll())

const stats = computed(() => [
  {
    id: 'cities',
    icon: 'i-lucide-map-pin',
    value: `${admin.cities.value.filter(city => city.is_active).length}/${admin.cities.value.length}`,
    labelKey: 'admin.stats.cities'
  },
  {
    id: 'places',
    icon: 'i-lucide-utensils',
    value: `${admin.places.value.filter(place => place.status === 'published').length}/${admin.places.value.length}`,
    labelKey: 'admin.stats.places'
  },
  {
    id: 'guides',
    icon: 'i-lucide-file-text',
    value: `${admin.guides.value.filter(guide => guide.status === 'published').length}/${admin.guides.value.length}`,
    labelKey: 'admin.stats.guides'
  },
  {
    id: 'reviews',
    icon: 'i-lucide-message-circle',
    value: admin.reviews.value.filter(review => review.status === 'pending').length,
    labelKey: 'admin.stats.reviews'
  }
])

const pendingReviews = computed(
  () => admin.reviews.value.filter(review => review.status === 'pending').length
)

const recentPlaces = computed(() => admin.places.value.slice(0, 5))
</script>

<template>
  <div class="mx-auto max-w-3xl space-y-8">
    <header class="space-y-1">
      <h1 class="text-3xl font-semibold tracking-tight text-highlighted">
        {{ t('admin.dashboard.title') }}
      </h1>
      <p class="text-sm text-muted">
        {{ t('admin.dashboard.subtitle') }}
      </p>
    </header>

    <UAlert
      v-if="admin.error.value"
      color="error"
      variant="soft"
      :title="admin.error.value"
    />

    <section class="grid grid-cols-2 gap-3 sm:grid-cols-4">
      <div
        v-for="stat in stats"
        :key="stat.id"
        class="rounded-2xl border border-default bg-elevated p-4 shadow-sm"
      >
        <UIcon
          :name="stat.icon"
          class="size-5 text-muted"
        />
        <p class="mt-3 text-2xl font-semibold text-highlighted">
          {{ stat.value }}
        </p>
        <p class="mt-1 text-xs text-muted">
          {{ t(stat.labelKey) }}
        </p>
      </div>
    </section>

    <section
      v-if="recentPlaces.length"
      class="space-y-4"
    >
      <h2 class="text-xl font-semibold text-highlighted">
        {{ t('admin.dashboard.activity') }}
      </h2>
      <UCard
        class="border-default"
        :ui="{ body: 'p-0' }"
      >
        <ul class="divide-y divide-default">
          <li
            v-for="place in recentPlaces"
            :key="place.id"
            class="flex items-center gap-3 px-5 py-3"
          >
            <UIcon
              :name="place.status === 'published' ? 'i-lucide-circle-check' : 'i-lucide-circle'"
              class="size-4 shrink-0 text-muted"
            />
            <span class="min-w-0 flex-1 text-sm text-default">{{ place.localizations.ru?.name ?? place.slug }}</span>
            <span class="shrink-0 text-xs text-muted">{{ place.updated_at.slice(0, 10) }}</span>
          </li>
        </ul>
      </UCard>
    </section>

    <UButton
      v-if="pendingReviews > 0"
      to="/admin/reviews"
      color="primary"
      variant="soft"
      trailing-icon="i-lucide-arrow-right"
    >
      {{ t('admin.dashboard.pendingCta') }} ({{ pendingReviews }})
    </UButton>
  </div>
</template>
