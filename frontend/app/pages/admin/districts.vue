<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import type { BadgeStatus } from '~/components/StatusBadge.vue'
import { useAdminDb, type AdminDistrictInput } from '~/composables/useAdminDb'
import type { PriceLevel } from '~/types/content'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const { t, locale } = useI18n()
const admin = useAdminDb()

onMounted(() => admin.loadAll())

const localName = (r: { localizations: { ru?: { name: string }, en?: { name: string } } }) =>
  (locale.value === 'en' ? r.localizations.en ?? r.localizations.ru : r.localizations.ru ?? r.localizations.en)?.name ?? ''

const rows = computed(() =>
  admin.districts.value.map(d => ({
    id: d.id,
    name: localName(d),
    price: t(`food.price.${d.price_level}`),
    status: 'active' as BadgeStatus
  }))
)

const priceOptions = (['budget', 'average', 'above'] as PriceLevel[]).map(level => ({
  label: t(`food.price.${level}`),
  value: level
}))

const emptyLoc = () => ({ name: '', area: '', rentRange: '', distanceToBeach: '', summary: '', bestFor: [] as string[] })

const editing = ref(false)
const saving = ref(false)
const formError = ref<string | null>(null)
const tagsText = ref('')
const form = ref<AdminDistrictInput>({
  city_slug: 'da-nang',
  slug: '',
  geometry: null as unknown as AdminDistrictInput['geometry'],
  price_level: 'average',
  sort_order: 1,
  ru: emptyLoc(),
  en: emptyLoc()
})

const openNew = () => {
  form.value = {
    city_slug: 'da-nang',
    slug: '',
    geometry: null as unknown as AdminDistrictInput['geometry'],
    price_level: 'average',
    sort_order: (admin.districts.value.length ?? 0) + 1,
    ru: emptyLoc(),
    en: emptyLoc()
  }
  formError.value = null
  tagsText.value = ''
  editing.value = true
}

const openEdit = (row: { id: string }) => {
  const d = admin.districts.value.find(x => x.id === row.id)
  if (!d) return
  const ru = { ...emptyLoc(), ...(d.localizations.ru ?? {}) }
  const en = { ...emptyLoc(), ...(d.localizations.en ?? {}) }
  form.value = {
    id: d.id,
    city_slug: d.city_slug,
    slug: d.slug,
    geometry: d.geometry ?? (null as unknown as AdminDistrictInput['geometry']),
    price_level: d.price_level,
    sort_order: d.sort_order,
    ru,
    en
  }
  formError.value = null
  tagsText.value = ru.bestFor.join(', ')
  editing.value = true
}

const onGeometry = (g: AdminDistrictInput['geometry'] | null) => {
  form.value.geometry = g as AdminDistrictInput['geometry']
}

const save = async () => {
  if (!form.value.slug || !form.value.geometry || !form.value.ru.name) {
    formError.value = 'Нужны slug, полигон на карте и название (RU)'
    return
  }
  saving.value = true
  formError.value = null
  try {
    const tags = tagsText.value.split(',').map(s => s.trim()).filter(Boolean)
    await admin.saveDistrict({ ...form.value, ru: { ...form.value.ru, bestFor: tags }, en: { ...form.value.en, bestFor: tags } })
    editing.value = false
  } catch (e) {
    formError.value = e instanceof Error ? e.message : typeof e === 'object' && e && 'message' in e ? String((e as { message: unknown }).message) : String(e)
  } finally {
    saving.value = false
  }
}

const remove = async (row: { id: string }) => {
  if (!confirm(`Удалить район ${localName(admin.districts.value.find(d => d.id === row.id) ?? { localizations: {} })}?`)) return
  try {
    await admin.deleteDistrict(row.id)
  } catch (e) {
    formError.value = e instanceof Error ? e.message : String(e)
  }
}
</script>

<template>
  <div class="mx-auto max-w-5xl space-y-6">
    <header class="space-y-1">
      <h1 class="text-3xl font-semibold tracking-tight text-highlighted">
        {{ t('admin.nav.districts') }}
      </h1>
      <p class="text-sm text-muted">
        {{ t('admin.districts.subtitle') }}
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
        { key: 'name', label: t('admin.columns.district') },
        { key: 'price', label: t('admin.columns.price') },
        { key: 'status', label: t('admin.columns.status') },
        { key: 'actions', label: t('admin.columns.actions'), align: 'right' as const }
      ]"
      :rows="rows"
      :loading="admin.loading.value"
    >
      <template #cell-name="{ row }">
        <span class="font-medium text-highlighted">{{ row.name }}</span>
      </template>
      <template #cell-price="{ row }">
        <span class="text-muted">{{ row.price }}</span>
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
            icon="i-lucide-trash-2"
            :aria-label="'Удалить'"
            @click="remove(row)"
          />
        </div>
      </template>
    </AdminTable>

    <UButton
      icon="i-lucide-plus"
      variant="outline"
      @click="openNew"
    >
      {{ t('admin.editor.newDistrict') }}
    </UButton>

    <UCard
      v-if="editing"
      class="border-default"
      :title="form.id ? t('admin.editor.editDistrict') : t('admin.editor.newDistrict')"
    >
      <div class="space-y-4">
        <DistrictMapEditor
          :geometry="form.geometry ?? null"
          @update-geometry="onGeometry"
        />

        <form
          class="space-y-4"
          @submit.prevent="save"
        >
          <div class="grid grid-cols-2 gap-3 sm:grid-cols-4">
            <UFormField :label="t('admin.editor.placeSlug')">
              <UInput
                v-model="form.slug"
                placeholder="e.g. son-tra"
                class="w-full"
              />
            </UFormField>
            <UFormField :label="t('admin.editor.priceLevel')">
              <USelectMenu
                v-model="form.price_level"
                :items="priceOptions"
                value-key="value"
                class="w-full"
              />
            </UFormField>
            <UFormField :label="t('admin.editor.sortOrder')">
              <UInput
                v-model.number="form.sort_order"
                type="number"
                min="1"
                class="w-full"
              />
            </UFormField>
          </div>

          <div class="grid grid-cols-2 gap-3 border-t border-default pt-3">
            <div class="space-y-2">
              <p class="text-xs font-medium uppercase tracking-wide text-muted">
                RU
              </p>
              <UInput
                v-model="form.ru.name"
                :placeholder="t('admin.editor.nameRu')"
                class="w-full"
              />
              <UInput
                v-model="form.ru.area"
                :placeholder="t('admin.editor.areaRu')"
                class="w-full"
              />
              <UInput
                v-model="form.ru.rentRange"
                placeholder="Аренда (RU)"
                class="w-full"
              />
              <UInput
                v-model="form.ru.distanceToBeach"
                placeholder="До моря (RU)"
                class="w-full"
              />
              <UTextarea
                v-model="form.ru.summary"
                :placeholder="t('admin.editor.summaryRu')"
                :rows="2"
              />
            </div>
            <div class="space-y-2">
              <p class="text-xs font-medium uppercase tracking-wide text-muted">
                EN
              </p>
              <UInput
                v-model="form.en.name"
                :placeholder="t('admin.editor.nameEn')"
                class="w-full"
              />
              <UInput
                v-model="form.en.area"
                :placeholder="t('admin.editor.areaEn')"
                class="w-full"
              />
              <UInput
                v-model="form.en.rentRange"
                placeholder="Rent (EN)"
                class="w-full"
              />
              <UInput
                v-model="form.en.distanceToBeach"
                placeholder="To beach (EN)"
                class="w-full"
              />
              <UTextarea
                v-model="form.en.summary"
                :placeholder="t('admin.editor.summaryEn')"
                :rows="2"
              />
            </div>
          </div>

          <div class="flex items-center gap-4 border-t border-default pt-3">
            <UInput
              v-model="tagsText"
              placeholder="Кому подходит (EN, через запятую): beach, nightlife"
              class="w-full"
            />
          </div>

          <UAlert
            v-if="formError"
            color="error"
            variant="soft"
            :title="formError"
          />
          <div class="flex justify-end gap-2">
            <UButton
              variant="ghost"
              color="neutral"
              @click="editing = false"
            >
              {{ t('admin.editor.cancel') }}
            </UButton>
            <UButton
              type="submit"
              :loading="saving"
              :disabled="!form.slug || !form.ru.name"
            >
              {{ t('admin.editor.save') }}
            </UButton>
          </div>
        </form>
      </div>
    </UCard>
  </div>
</template>
