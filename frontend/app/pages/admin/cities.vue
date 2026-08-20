<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import type { BadgeStatus } from '~/components/StatusBadge.vue'
import { useAdminDb } from '~/composables/useAdminDb'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const { t, locale } = useI18n()
const admin = useAdminDb()

onMounted(() => admin.loadAll())

const cityName = (row: { name_en: string, name_ru: string }) => (locale.value === 'en' ? row.name_en : row.name_ru)

const rows = computed(() =>
  admin.cities.value.map(city => ({
    id: city.slug,
    flag: city.flag,
    name: cityName(city),
    country: '🇻🇳',
    active: city.is_active,
    status: (city.is_active ? 'active' : 'comingSoon') as BadgeStatus
  }))
)

// New-city form
const modalOpen = ref(false)
const form = ref({
  slug: '',
  name_ru: '',
  name_en: '',
  flag: '🇻🇳',
  is_active: false,
  sort_order: 5
})
const saving = ref(false)
const formError = ref<string | null>(null)

const openNew = () => {
  form.value = { slug: '', name_ru: '', name_en: '', flag: '🇻🇳', is_active: false, sort_order: (admin.cities.value.length ?? 0) + 1 }
  formError.value = null
  modalOpen.value = true
}

const saveNew = async () => {
  if (!form.value.slug || !form.value.name_ru) return
  saving.value = true
  formError.value = null
  try {
    await admin.saveCity({ ...form.value })
    modalOpen.value = false
  } catch (e) {
    formError.value = e instanceof Error ? e.message : typeof e === 'object' && e && 'message' in e ? String((e as { message: unknown }).message) : String(e)
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="mx-auto max-w-3xl space-y-6">
    <header class="space-y-1">
      <h1 class="text-3xl font-semibold tracking-tight text-highlighted">
        {{ t('admin.nav.cities') }}
      </h1>
      <p class="text-sm text-muted">
        {{ t('admin.cities.subtitle') }}
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
        { key: 'city', label: t('admin.columns.city') },
        { key: 'country', label: t('admin.columns.country') },
        { key: 'status', label: t('admin.columns.status') },
        { key: 'actions', label: t('admin.columns.actions'), align: 'right' as const }
      ]"
      :rows="rows"
      :loading="admin.loading.value"
    >
      <template #cell-city="{ row }">
        <span class="flex items-center gap-2">
          <span class="text-base leading-none">{{ row.flag }}</span>
          <span class="font-medium text-highlighted">{{ row.name }}</span>
        </span>
      </template>
      <template #cell-country="{ row }">
        {{ row.country }}
      </template>
      <template #cell-status="{ row }">
        <StatusBadge :status="row.status" />
      </template>
      <template #cell-actions="{ row }">
        <UButton
          size="xs"
          variant="ghost"
          color="neutral"
          :icon="row.active ? 'i-lucide-pause' : 'i-lucide-play'"
          @click="admin.toggleCityActive(row.id)"
        >
          {{ row.active ? t('admin.actions.deactivate') : t('admin.actions.activate') }}
        </UButton>
      </template>
    </AdminTable>

    <UButton
      icon="i-lucide-plus"
      variant="outline"
      @click="openNew"
    >
      {{ t('admin.editor.newCity') }}
    </UButton>

    <UModal
      v-model:open="modalOpen"
    >
      :title="t('admin.editor.newCity')"
      >
      <template #body>
        <form
          class="space-y-3"
          @submit.prevent="saveNew"
        >
          <UFormField :label="t('admin.editor.citySlug')">
            <UInput
              v-model="form.slug"
              placeholder="e.g. hoi-an"
            />
          </UFormField>
          <div class="grid grid-cols-2 gap-3">
            <UFormField :label="t('admin.editor.cityNameRu')">
              <UInput v-model="form.name_ru" />
            </UFormField>
            <UFormField :label="t('admin.editor.cityNameEn')">
              <UInput v-model="form.name_en" />
            </UFormField>
          </div>
          <div class="grid grid-cols-2 gap-3">
            <UFormField :label="t('admin.editor.flag')">
              <UInput v-model="form.flag" />
            </UFormField>
            <UFormField :label="t('admin.editor.sortOrder')">
              <UInput
                v-model.number="form.sort_order"
                type="number"
                min="1"
              />
            </UFormField>
          </div>
          <UCheckbox
            v-model="form.is_active"
            :label="t('admin.actions.activate')"
          />
          <UAlert
            v-if="formError"
            color="error"
            variant="soft"
            :title="formError"
          />
          <div class="flex justify-end gap-2 pt-2">
            <UButton
              variant="ghost"
              color="neutral"
              @click="modalOpen = false"
            >
              {{ t('admin.editor.cancel') }}
            </UButton>
            <UButton
              type="submit"
              :loading="saving"
              :disabled="!form.slug || !form.name_ru || !form.name_en"
            >
              {{ t('admin.editor.save') }}
            </UButton>
          </div>
        </form>
      </template>
    </UModal>
  </div>
</template>
