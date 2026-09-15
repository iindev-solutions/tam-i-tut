<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import { useAdminDb } from '~/composables/useAdminDb'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const { t } = useI18n()
const admin = useAdminDb()

onMounted(() => admin.loadAll())

const rows = computed(() =>
  admin.consulates.value.map(consulate => ({
    id: consulate.id,
    name: consulate.name_ru,
    address: consulate.address,
    phone: consulate.phone ?? '-',
    emergency: consulate.emergency_phone ?? '-',
    source: consulate.source
  }))
)

const modalOpen = ref(false)
const saving = ref(false)
const formError = ref<string | null>(null)
/**
 * Form state is all strings: a text input cannot hold null. The DB shape allows
 * null phones, so the conversion happens at the boundary in both directions.
 */
interface ConsulateForm {
  id: string
  name_ru: string
  name_en: string
  address: string
  hours_ru: string
  hours_en: string
  phone: string
  emergency_phone: string
  source: string
}

const blank = (): ConsulateForm => ({
  id: '',
  name_ru: '',
  name_en: '',
  address: '',
  hours_ru: '',
  hours_en: '',
  phone: '',
  emergency_phone: '',
  source: ''
})
const form = ref<ConsulateForm>(blank())

const openEdit = (row: { id: string }) => {
  const consulate = admin.consulates.value.find(c => c.id === row.id)
  if (!consulate) return
  form.value = {
    id: consulate.id,
    name_ru: consulate.name_ru,
    name_en: consulate.name_en,
    address: consulate.address,
    hours_ru: consulate.hours_ru,
    hours_en: consulate.hours_en,
    phone: consulate.phone ?? '',
    emergency_phone: consulate.emergency_phone ?? '',
    source: consulate.source
  }
  formError.value = null
  modalOpen.value = true
}

/** Empty inputs must become NULL, not the string "": the card hides a missing
 *  number instead of rendering a tel: link to nowhere. */
const orNull = (value: string) => (value.trim() !== '' ? value.trim() : null)

const save = async () => {
  if (!form.value.address || !form.value.name_ru || !form.value.name_en) return
  saving.value = true
  formError.value = null
  try {
    const existing = admin.consulates.value.find(c => c.id === form.value.id)
    await admin.saveConsulate({
      id: form.value.id,
      city_slug: existing?.city_slug ?? 'da-nang',
      sort_order: existing?.sort_order ?? 1,
      name_ru: form.value.name_ru.trim(),
      name_en: form.value.name_en.trim(),
      address: form.value.address.trim(),
      hours_ru: form.value.hours_ru.trim(),
      hours_en: form.value.hours_en.trim(),
      phone: orNull(form.value.phone),
      emergency_phone: orNull(form.value.emergency_phone),
      source: form.value.source.trim()
    })
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
        {{ t('admin.nav.consulates') }}
      </h1>
      <p class="text-sm text-muted">
        {{ t('admin.consulates.subtitle') }}
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
        { key: 'address', label: t('admin.columns.address') },
        { key: 'phone', label: t('admin.columns.phone') },
        { key: 'emergency', label: t('admin.columns.emergency') },
        { key: 'actions', label: t('admin.columns.actions'), align: 'right' as const }
      ]"
      :rows="rows"
      :loading="admin.loading.value"
    >
      <template #cell-name="{ row }">
        <span class="font-medium text-highlighted">{{ row.name }}</span>
      </template>
      <template #cell-address="{ row }">
        <span class="text-muted">{{ row.address }}</span>
      </template>
      <template #cell-phone="{ row }">
        {{ row.phone }}
      </template>
      <template #cell-emergency="{ row }">
        {{ row.emergency }}
      </template>
      <template #cell-actions="{ row }">
        <UButton
          size="xs"
          variant="ghost"
          color="neutral"
          icon="i-lucide-pencil"
          @click="openEdit(row)"
        >
          {{ t('admin.editor.edit') }}
        </UButton>
      </template>
    </AdminTable>

    <UModal
      v-model:open="modalOpen"
      :title="t('admin.editor.editConsulate')"
    >
      <template #body>
        <form
          class="space-y-3"
          @submit.prevent="save"
        >
          <div class="grid grid-cols-2 gap-3">
            <UFormField :label="`${t('admin.columns.name')} RU`">
              <UInput v-model="form.name_ru" />
            </UFormField>
            <UFormField :label="`${t('admin.columns.name')} EN`">
              <UInput v-model="form.name_en" />
            </UFormField>
          </div>

          <!-- Vietnamese street form, deliberately not localized: it is the
               string you show a taxi driver. -->
          <UFormField :label="t('admin.columns.address')">
            <UInput
              v-model="form.address"
              placeholder="22 Trần Phú, Thạch Thang, Hải Châu, Đà Nẵng"
            />
          </UFormField>

          <div class="grid grid-cols-2 gap-3">
            <UFormField :label="`${t('admin.editor.hours')} RU`">
              <UInput
                v-model="form.hours_ru"
                placeholder="пн, вт, чт, пт 9:00-11:30"
              />
            </UFormField>
            <UFormField :label="`${t('admin.editor.hours')} EN`">
              <UInput
                v-model="form.hours_en"
                placeholder="Mon, Tue, Thu, Fri 9:00-11:30"
              />
            </UFormField>
          </div>

          <div class="grid grid-cols-2 gap-3">
            <UFormField :label="t('admin.columns.phone')">
              <UInput
                v-model="form.phone"
                placeholder="+84 236 382 23 80"
              />
            </UFormField>
            <UFormField :label="t('admin.columns.emergency')">
              <UInput
                v-model="form.emergency_phone"
                placeholder="+84 94 720-00-94"
              />
            </UFormField>
          </div>

          <UFormField :label="t('admin.editor.source')">
            <UInput
              v-model="form.source"
              placeholder="official site + date"
            />
          </UFormField>

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
              :disabled="!form.name_ru || !form.name_en || !form.address"
            >
              {{ t('admin.editor.save') }}
            </UButton>
          </div>
        </form>
      </template>
    </UModal>
  </div>
</template>
