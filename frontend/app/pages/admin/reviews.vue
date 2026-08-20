<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

import type { BadgeStatus } from '~/components/StatusBadge.vue'
import { useAdminDb } from '~/composables/useAdminDb'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const { t } = useI18n()
const admin = useAdminDb()

onMounted(() => admin.loadAll())

const statusMap: Record<string, BadgeStatus> = {
  pending: 'pending',
  approved: 'active',
  rejected: 'rejected'
}

const rows = computed(() =>
  admin.reviews.value.map(review => ({
    id: review.id,
    place: review.place_name,
    author: review.author,
    rating: review.rating,
    status: statusMap[review.status] ?? 'pending'
  }))
)
</script>

<template>
  <div class="mx-auto max-w-4xl space-y-6">
    <header class="space-y-1">
      <h1 class="text-3xl font-semibold tracking-tight text-highlighted">
        {{ t('admin.nav.reviews') }}
      </h1>
      <p class="text-sm text-muted">
        {{ t('admin.reviews.subtitle') }}
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
        { key: 'place', label: t('admin.columns.place') },
        { key: 'author', label: t('admin.columns.author') },
        { key: 'rating', label: t('admin.columns.rating') },
        { key: 'status', label: t('admin.columns.status') },
        { key: 'actions', label: t('admin.columns.actions'), align: 'right' as const }
      ]"
      :rows="rows"
      :loading="admin.loading.value"
    >
      <template #cell-place="{ row }">
        <span class="font-medium text-highlighted">{{ row.place }}</span>
      </template>
      <template #cell-rating="{ row }">
        <span class="whitespace-nowrap">
          <span class="text-highlighted">{{ '★'.repeat(row.rating) }}</span><span class="text-muted/40">{{ '★'.repeat(5 - row.rating) }}</span>
        </span>
      </template>
      <template #cell-status="{ row }">
        <StatusBadge :status="row.status" />
      </template>
      <template #cell-actions="{ row }">
        <span class="flex justify-end gap-1">
          <UButton
            size="xs"
            variant="ghost"
            color="neutral"
            icon="i-lucide-check"
            :disabled="row.status === 'active'"
            :aria-label="t('admin.actions.approve')"
            @click="admin.setReviewStatus(row.id, 'approved')"
          />
          <UButton
            size="xs"
            variant="ghost"
            color="neutral"
            icon="i-lucide-x"
            :disabled="row.status === 'rejected'"
            :aria-label="t('admin.actions.reject')"
            @click="admin.setReviewStatus(row.id, 'rejected')"
          />
        </span>
      </template>
    </AdminTable>
  </div>
</template>
