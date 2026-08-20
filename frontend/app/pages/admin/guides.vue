<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

import type { BadgeStatus } from '~/components/StatusBadge.vue'
import { useAdminDb } from '~/composables/useAdminDb'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const { t } = useI18n()
const admin = useAdminDb()

onMounted(() => admin.loadAll())

const categoryLabel = (slug: string) =>
  t(slug === 'transport' ? 'home.transport' : slug === 'money' ? 'home.money' : slug === 'safety' ? 'home.safety' : slug)

const SLA_DAYS: Record<string, number> = { transport: 14, money: 14, safety: 30 }

const freshness = (guide: { category_slug: string, last_verified_at: string | null }): 'fresh' | 'overdue' | 'never' => {
  if (!guide.last_verified_at) return 'never'
  const days = SLA_DAYS[guide.category_slug] ?? 30
  const ageDays = (Date.now() - new Date(guide.last_verified_at).getTime()) / 86_400_000
  return ageDays > days ? 'overdue' : 'fresh'
}

const rows = computed(() =>
  admin.guides.value.map(guide => ({
    id: guide.id,
    title: guide.title,
    language: guide.language,
    category: categoryLabel(guide.category_slug),
    summary: guide.summary.slice(0, 80),
    status: (guide.status === 'published' ? 'active' : guide.status === 'draft' ? 'pending' : 'draft') as BadgeStatus,
    verified: guide.last_verified_at ? guide.last_verified_at.slice(0, 10) : '-',
    fresh: freshness(guide)
  }))
)
</script>

<template>
  <div class="mx-auto max-w-4xl space-y-6">
    <header class="space-y-1">
      <h1 class="text-3xl font-semibold tracking-tight text-highlighted">
        {{ t('admin.nav.guides') }}
      </h1>
      <p class="text-sm text-muted">
        {{ t('admin.guides.subtitle') }}
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
        { key: 'title', label: t('admin.columns.title') },
        { key: 'category', label: t('admin.columns.category') },
        { key: 'summary', label: t('admin.columns.note') },
        { key: 'verified', label: 'Проверено' },
        { key: 'status', label: t('admin.columns.status') },
        { key: 'actions', label: t('admin.columns.actions'), align: 'right' as const }
      ]"
      :rows="rows"
      :loading="admin.loading.value"
    >
      <template #cell-title="{ row }">
        <span class="font-medium text-highlighted">{{ row.title }}</span>
      </template>
      <template #cell-category="{ row }">
        {{ row.category }}
      </template>
      <template #cell-summary="{ row }">
        <span class="text-muted">{{ row.summary }}</span>
      </template>
      <template #cell-verified="{ row }">
        <span
          class="inline-flex items-center gap-1.5 text-xs"
          :class="row.fresh === 'overdue' ? 'text-warning' : row.fresh === 'never' ? 'text-muted' : 'text-muted'"
        >
          <UIcon
            :name="row.fresh === 'overdue' ? 'i-lucide-alert-triangle' : row.fresh === 'never' ? 'i-lucide-circle-dashed' : 'i-lucide-badge-check'"
            class="size-3.5"
          />
          {{ row.verified }}
        </span>
      </template>
      <template #cell-status="{ row }">
        <StatusBadge :status="row.status" />
      </template>
      <template #cell-actions="{ row }">
        <UButton
          size="xs"
          variant="ghost"
          color="neutral"
          :icon="row.status === 'active' ? 'i-lucide-eye-off' : 'i-lucide-eye'"
          @click="admin.toggleGuideStatus(row.id)"
        >
          {{ row.status === 'active' ? t('admin.actions.unpublish') : t('admin.actions.publish') }}
        </UButton>
      </template>
    </AdminTable>
  </div>
</template>
