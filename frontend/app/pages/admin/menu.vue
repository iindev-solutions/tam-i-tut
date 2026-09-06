<script setup lang="ts">
import { computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'

import type { BadgeStatus } from '~/components/StatusBadge.vue'
import { useAdminDb } from '~/composables/useAdminDb'

/**
 * Menu translator Phase B: curation queue + per-venue menu verification.
 * Queue = AI lines that matched no dictionary dish or matched with low
 * confidence; the admin links them to a dictionary dish (which verifies the
 * line for every future scan) or rejects them. Verified menus are served
 * from cache without an AI call.
 */
definePageMeta({ layout: 'admin', middleware: 'admin' })

const { t } = useI18n()
const admin = useAdminDb()

onMounted(() => admin.loadMenuAll())

const dishOptions = computed(() =>
  admin.dishes.value.map(dish => ({ label: `${dish.name} · ${dish.nameVi}`, value: dish.id }))
)

const queueRows = computed(() =>
  admin.menuQueue.value.map(item => ({
    id: item.id,
    place: item.place_name,
    line: item.ai_name_ru || item.ai_name_en || item.raw_text_vi,
    raw: item.raw_text_vi,
    price: item.price_vnd,
    confidence: item.confidence
  }))
)

const menuStatusMap: Record<string, BadgeStatus> = { ai: 'pending', verified: 'active' }

const menuRows = computed(() =>
  admin.menus.value.map(menu => ({
    id: menu.id,
    place: menu.place_name,
    created: menu.created_at.slice(0, 10),
    curated: `${menu.curated}/${menu.total}`,
    status: menuStatusMap[menu.status] ?? 'pending'
  }))
)
</script>

<template>
  <div class="mx-auto max-w-4xl space-y-10">
    <header class="space-y-1">
      <h1 class="text-3xl font-semibold tracking-tight text-highlighted">
        {{ t('admin.nav.menu') }}
      </h1>
      <p class="text-sm text-muted">
        {{ t('admin.menu.subtitle') }}
      </p>
    </header>

    <UAlert
      v-if="admin.error.value"
      color="error"
      variant="soft"
      :title="admin.error.value"
    />

    <!-- Curation queue -->
    <section class="space-y-4">
      <h2 class="text-xl font-semibold text-highlighted">
        {{ t('admin.menu.queueTitle') }}
      </h2>
      <AdminTable
        :columns="[
          { key: 'place', label: t('admin.columns.place') },
          { key: 'line', label: t('admin.columns.line') },
          { key: 'confidence', label: t('admin.columns.confidence') },
          { key: 'actions', label: t('admin.columns.actions'), align: 'right' as const }
        ]"
        :rows="queueRows"
        :loading="admin.loading.value"
      >
        <template #empty>
          <p class="px-4 py-6 text-center text-sm text-muted">
            {{ t('admin.menu.emptyQueue') }}
          </p>
        </template>
        <template #cell-place="{ row }">
          <span class="font-medium text-highlighted">{{ row.place }}</span>
        </template>
        <template #cell-line="{ row }">
          <span class="block text-sm text-default">{{ row.line }}</span>
          <span class="block text-xs text-muted">
            {{ row.raw }}<template v-if="row.price != null"> · {{ row.price.toLocaleString('ru-RU') }} ₫</template>
          </span>
        </template>
        <template #cell-confidence="{ row }">
          <span
            class="text-sm"
            :class="row.confidence != null && row.confidence < 40 ? 'text-error' : 'text-muted'"
          >
            {{ row.confidence != null ? `${row.confidence}%` : '—' }}
          </span>
        </template>
        <template #cell-actions="{ row }">
          <span class="flex items-center justify-end gap-2">
            <USelect
              :items="dishOptions"
              :placeholder="t('admin.menu.linkDish')"
              size="xs"
              class="w-48"
              @update:model-value="(dishId: string) => admin.linkMenuItemToDish(row.id, dishId)"
            />
            <UButton
              size="xs"
              variant="ghost"
              color="neutral"
              icon="i-lucide-x"
              :aria-label="t('admin.actions.reject')"
              @click="admin.setMenuItemStatus(row.id, 'rejected')"
            />
          </span>
        </template>
      </AdminTable>
    </section>

    <!-- Per-venue menus -->
    <section class="space-y-4">
      <h2 class="text-xl font-semibold text-highlighted">
        {{ t('admin.menu.menusTitle') }}
      </h2>
      <AdminTable
        :columns="[
          { key: 'place', label: t('admin.columns.place') },
          { key: 'created', label: t('admin.columns.updated') },
          { key: 'curated', label: t('admin.menu.curated') },
          { key: 'status', label: t('admin.columns.status') },
          { key: 'actions', label: t('admin.columns.actions'), align: 'right' as const }
        ]"
        :rows="menuRows"
        :loading="admin.loading.value"
      >
        <template #empty>
          <p class="px-4 py-6 text-center text-sm text-muted">
            {{ t('admin.menu.emptyMenus') }}
          </p>
        </template>
        <template #cell-place="{ row }">
          <span class="font-medium text-highlighted">{{ row.place }}</span>
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
              :aria-label="t('admin.actions.verify')"
              @click="admin.setMenuStatus(row.id, 'verified')"
            />
            <UButton
              size="xs"
              variant="ghost"
              color="neutral"
              icon="i-lucide-rotate-ccw"
              :disabled="row.status !== 'active'"
              :aria-label="t('admin.actions.reopen')"
              @click="admin.setMenuStatus(row.id, 'ai')"
            />
          </span>
        </template>
      </AdminTable>
    </section>
  </div>
</template>
