<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

import type { BadgeStatus } from '~/components/StatusBadge.vue'
import { useAdminDb } from '~/composables/useAdminDb'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const { t, locale } = useI18n()
const admin = useAdminDb()

onMounted(() => admin.loadAll())

const rows = computed(() =>
  admin.cities.value.map(city => ({
    id: city.slug,
    name: locale.value === 'en' ? city.name_en : city.name_ru,
    status: (city.is_active ? 'active' : 'comingSoon') as BadgeStatus
  }))
)
</script>

<template>
  <div class="mx-auto max-w-3xl space-y-6">
    <header class="space-y-1">
      <h1 class="text-3xl font-semibold tracking-tight text-highlighted">
        {{ t('admin.nav.categories') }}
      </h1>
      <p class="text-sm text-muted">
        {{ t('admin.categories.subtitle') }}
      </p>
    </header>

    <UAlert
      v-if="admin.error.value"
      color="error"
      variant="soft"
      :title="admin.error.value"
    />

    <AdminTable
      :columns="[
        { key: 'name', label: t('admin.columns.category') },
        { key: 'status', label: t('admin.columns.status') }
      ]"
      :rows="rows"
      :loading="admin.loading.value"
    >
      <template #cell-name="{ row }">
        <span class="font-medium text-highlighted">{{ row.name }}</span>
      </template>
      <template #cell-status="{ row }">
        <StatusBadge :status="row.status" />
      </template>
    </AdminTable>
  </div>
</template>
