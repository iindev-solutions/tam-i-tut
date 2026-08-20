<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import type { BadgeStatus } from '~/components/StatusBadge.vue'
import { useAdminDb, type AdminPlaceRow } from '~/composables/useAdminDb'
import type { PlaceType, PriceLevel } from '~/types/content'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const { t, locale } = useI18n()
const admin = useAdminDb()

onMounted(() => admin.loadAll())

const localText = (place: AdminPlaceRow, field: 'name' | 'area' | 'summary') => {
  const loc = locale.value === 'en' ? place.localizations.en : place.localizations.ru
  return loc?.[field] ?? (field === 'name' ? place.slug : '')
}

const typeLabel = (type: PlaceType) => t(`food.filters.${type}`)

const rows = computed(() =>
  admin.places.value.map(place => ({
    id: place.id,
    name: localText(place, 'name'),
    type: typeLabel(place.place_type),
    area: localText(place, 'area'),
    status: (place.status === 'published' ? 'active' : place.status === 'draft' ? 'pending' : 'draft') as BadgeStatus,
    verified: place.verified,
    updated: place.updated_at.slice(0, 10)
  }))
)

// Editor
const modalOpen = ref(false)
const saving = ref(false)
const formError = ref<string | null>(null)
const emptyLoc = { name: '', area: '', summary: '' }
const form = ref<{
  id?: string
  city_slug: string
  slug: string
  place_type: PlaceType
  price_level: PriceLevel
  verified: boolean
  status: 'draft' | 'published'
  ru: { name: string, area: string, summary: string }
  en: { name: string, area: string, summary: string }
}>({
  city_slug: 'da-nang',
  slug: '',
  place_type: 'cafe',
  price_level: 'average',
  verified: false,
  status: 'draft',
  ru: { ...emptyLoc },
  en: { ...emptyLoc }
})

const typeOptions = (['cafe', 'street', 'market', 'restaurant'] as PlaceType[]).map(type => ({
  label: t(`food.filters.${type}`),
  value: type
}))
const priceOptions = (['budget', 'average', 'above'] as PriceLevel[]).map(level => ({
  label: t(`food.price.${level}`),
  value: level
}))
const cityOptions = computed(() => admin.cities.value.map(city => ({ label: city.name_en, value: city.slug })))

const openNew = () => {
  form.value = {
    city_slug: 'da-nang',
    slug: '',
    place_type: 'cafe',
    price_level: 'average',
    verified: false,
    status: 'draft',
    ru: { ...emptyLoc },
    en: { ...emptyLoc }
  }
  formError.value = null
  modalOpen.value = true
}

const openEdit = (row: { id: string }) => {
  const place = admin.places.value.find(p => p.id === row.id)
  if (!place) return
  const ru = place.localizations.ru ?? { ...emptyLoc }
  const en = place.localizations.en ?? { ...emptyLoc }
  form.value = {
    id: place.id,
    city_slug: place.city_slug,
    slug: place.slug,
    place_type: place.place_type,
    price_level: place.price_level,
    verified: place.verified,
    status: place.status === 'published' ? 'published' : 'draft',
    ru: { ...ru },
    en: { ...en }
  }
  formError.value = null
  modalOpen.value = true
}

const save = async () => {
  if (!form.value.slug || !form.value.ru.name) return
  saving.value = true
  formError.value = null
  try {
    await admin.savePlace({ ...form.value })
    modalOpen.value = false
  } catch (e) {
    formError.value = e instanceof Error ? e.message : typeof e === 'object' && e && 'message' in e ? String((e as { message: unknown }).message) : String(e)
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="mx-auto max-w-4xl space-y-6">
    <header class="space-y-1">
      <h1 class="text-3xl font-semibold tracking-tight text-highlighted">
        {{ t('admin.nav.places') }}
      </h1>
      <p class="text-sm text-muted">
        {{ t('admin.places.subtitle') }}
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
        { key: 'name', label: t('admin.columns.name') },
        { key: 'type', label: t('admin.columns.type') },
        { key: 'area', label: t('admin.columns.area') },
        { key: 'status', label: t('admin.columns.status') },
        { key: 'updated', label: t('admin.columns.updated') },
        { key: 'actions', label: t('admin.columns.actions'), align: 'right' as const }
      ]"
      :rows="rows"
      :loading="admin.loading.value"
    >
      <template #cell-name="{ row }">
        <span class="flex items-center gap-1.5 font-medium text-highlighted">
          {{ row.name }}
          <UIcon
            v-if="row.verified"
            name="i-lucide-badge-check"
            class="size-3.5 text-primary"
            :aria-label="t('food.verifiedTitle')"
          />
        </span>
      </template>
      <template #cell-type="{ row }">
        {{ row.type }}
      </template>
      <template #cell-area="{ row }">
        <span class="text-muted">{{ row.area }}</span>
      </template>
      <template #cell-status="{ row }">
        <StatusBadge :status="row.status" />
      </template>
      <template #cell-actions="{ row }">
        <div class="flex justify-end gap-1">
          <UButton
            size="xs"
            variant="ghost"
            color="neutral"
            icon="i-lucide-pencil"
            :aria-label="t('admin.editor.editPlace')"
            @click="openEdit(row)"
          />
          <UButton
            size="xs"
            variant="ghost"
            color="neutral"
            :icon="row.status === 'active' ? 'i-lucide-eye-off' : 'i-lucide-eye'"
            :aria-label="row.status === 'active' ? t('admin.actions.unpublish') : t('admin.actions.publish')"
            @click="admin.togglePlaceStatus(row.id)"
          >
            {{ row.status === 'active' ? t('admin.actions.unpublish') : t('admin.actions.publish') }}
          </UButton>
        </div>
      </template>
    </AdminTable>

    <UButton
      icon="i-lucide-plus"
      variant="outline"
      @click="openNew"
    >
      {{ t('admin.editor.newPlace') }}
    </UButton>

    <UModal
      v-model:open="modalOpen"
      :title="form.id ? t('admin.editor.editPlace') : t('admin.editor.newPlace')"
    >
      <template #body>
        <form
          class="space-y-3"
          @submit.prevent="save"
        >
          <div class="grid grid-cols-2 gap-3">
            <UFormField :label="t('admin.editor.citySlug')">
              <USelectMenu
                v-model="form.city_slug"
                :items="cityOptions"
                value-key="value"
              />
            </UFormField>
            <UFormField :label="t('admin.editor.placeSlug')">
              <UInput
                v-model="form.slug"
                placeholder="e.g. banh-mi-madam-khanh"
              />
            </UFormField>
          </div>
          <div class="grid grid-cols-2 gap-3">
            <UFormField :label="t('admin.editor.type')">
              <USelectMenu
                v-model="form.place_type"
                :items="typeOptions"
                value-key="value"
              />
            </UFormField>
            <UFormField :label="t('admin.editor.priceLevel')">
              <USelectMenu
                v-model="form.price_level"
                :items="priceOptions"
                value-key="value"
              />
            </UFormField>
          </div>
          <div class="flex gap-6">
            <UCheckbox
              v-model="form.verified"
              :label="t('admin.editor.verified')"
            />
            <USelectMenu
              v-model="form.status"
              :items="[
                { label: t('admin.actions.publish'), value: 'published' },
                { label: t('admin.actions.unpublish'), value: 'draft' }
              ]"
              value-key="value"
              class="w-40"
            />
          </div>

          <div class="grid grid-cols-2 gap-3 border-t border-default pt-3">
            <div class="space-y-2">
              <p class="text-xs font-medium uppercase tracking-wide text-muted">
                RU
              </p>
              <UInput
                v-model="form.ru.name"
                :placeholder="t('admin.editor.nameRu')"
              />
              <UInput
                v-model="form.ru.area"
                :placeholder="t('admin.editor.areaRu')"
              />
              <UTextarea
                v-model="form.ru.summary"
                :placeholder="t('admin.editor.summaryRu')"
                :rows="3"
              />
            </div>
            <div class="space-y-2">
              <p class="text-xs font-medium uppercase tracking-wide text-muted">
                EN
              </p>
              <UInput
                v-model="form.en.name"
                :placeholder="t('admin.editor.nameEn')"
              />
              <UInput
                v-model="form.en.area"
                :placeholder="t('admin.editor.areaEn')"
              />
              <UTextarea
                v-model="form.en.summary"
                :placeholder="t('admin.editor.summaryEn')"
                :rows="3"
              />
            </div>
          </div>

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
              :disabled="!form.slug || !form.ru.name || !form.en.name"
            >
              {{ t('admin.editor.save') }}
            </UButton>
          </div>
        </form>
      </template>
    </UModal>
  </div>
</template>
