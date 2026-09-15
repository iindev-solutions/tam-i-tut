<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useI18n } from 'vue-i18n'

import type { BadgeStatus } from '~/components/StatusBadge.vue'
import { useAdminDb, type AdminClinicRow } from '~/composables/useAdminDb'
import type { ClinicKind, TrustLevel } from '~/types/content'

definePageMeta({ layout: 'admin', middleware: 'admin' })

const { t } = useI18n()
const admin = useAdminDb()

onMounted(() => admin.loadAll())

const KINDS: ClinicKind[] = ['hospital', 'dental', 'ophthalmology', 'dermatology', 'diagnostics', 'oncology', 'ent', 'veterinary']

const kindOptions = KINDS.map(kind => ({ label: t(`health.kinds.${kind}`), value: kind }))
const trustOptions = (['under_review', 'recommended_expats', 'verified_team'] as TrustLevel[]).map(level => ({
  label: t(`trust.levels.${level}`),
  value: level
}))

const rows = computed(() =>
  admin.clinics.value.map((clinic) => {
    const loc = clinic.localizations.ru ?? clinic.localizations.en
    return {
      id: clinic.id,
      name: loc?.name ?? clinic.slug,
      kind: t(`health.kinds.${clinic.kind}`),
      price: (loc?.price_note ?? '').slice(0, 44),
      trustLevel: clinic.trust_badge,
      lastVerifiedAt: clinic.last_verified_at,
      status: (clinic.trust_badge === 'under_review' ? 'pending' : 'active') as BadgeStatus,
      source: clinic.source
    }
  })
)

const modalOpen = ref(false)
const saving = ref(false)
const formError = ref<string | null>(null)
const form = ref<{
  id: string
  city_slug: string
  kind: ClinicKind
  open_24_7: boolean
  trust_badge: TrustLevel
  last_verified_at: string | null
  source: string
  ru: { name: string, price_note: string }
  en: { name: string, price_note: string }
}>({
  id: '',
  city_slug: 'da-nang',
  kind: 'hospital',
  open_24_7: false,
  trust_badge: 'under_review',
  last_verified_at: null,
  source: '',
  ru: { name: '', price_note: '' },
  en: { name: '', price_note: '' }
})

const openEdit = (row: { id: string }) => {
  const clinic: AdminClinicRow | undefined = admin.clinics.value.find(c => c.id === row.id)
  if (!clinic) return
  const empty = { name: '', price_note: '' }
  form.value = {
    id: clinic.id,
    city_slug: clinic.city_slug,
    kind: clinic.kind,
    open_24_7: clinic.open_24_7,
    trust_badge: clinic.trust_badge,
    last_verified_at: clinic.last_verified_at,
    source: clinic.source,
    ru: { ...empty, ...clinic.localizations.ru },
    en: { ...empty, ...clinic.localizations.en }
  }
  formError.value = null
  modalOpen.value = true
}

const save = async () => {
  // The venue name is required in both languages: it is what the card renders,
  // and a blank one would show the raw slug to users.
  if (!form.value.ru.name || !form.value.en.name) return
  saving.value = true
  formError.value = null
  try {
    await admin.saveClinic({ ...form.value })
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
        {{ t('admin.nav.clinics') }}
      </h1>
      <p class="text-sm text-muted">
        {{ t('admin.clinics.subtitle') }}
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
        { key: 'kind', label: t('admin.columns.type') },
        { key: 'price', label: t('admin.columns.price') },
        { key: 'status', label: t('admin.columns.status') },
        { key: 'actions', label: t('admin.columns.actions'), align: 'right' as const }
      ]"
      :rows="rows"
      :loading="admin.loading.value"
    >
      <template #cell-name="{ row }">
        <span class="flex items-center gap-1.5 font-medium text-highlighted">
          {{ row.name }}
          <TrustBadge
            :level="row.trustLevel"
            :verified-at="row.lastVerifiedAt"
          />
        </span>
      </template>
      <template #cell-kind="{ row }">
        {{ row.kind }}
      </template>
      <template #cell-price="{ row }">
        <span class="text-muted">{{ row.price }}</span>
      </template>
      <template #cell-status="{ row }">
        <StatusBadge :status="row.status" />
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
      :title="t('admin.editor.editClinic')"
    >
      <template #body>
        <form
          class="space-y-3"
          @submit.prevent="save"
        >
          <div class="grid grid-cols-2 gap-3">
            <UFormField :label="t('admin.editor.type')">
              <USelectMenu
                v-model="form.kind"
                :items="kindOptions"
                value-key="value"
              />
            </UFormField>
            <UFormField :label="t('admin.editor.trustLevel')">
              <USelectMenu
                v-model="form.trust_badge"
                :items="trustOptions"
                value-key="value"
              />
            </UFormField>
          </div>

          <!-- Promoting to a trusted level forces a check date server-side, so
               the editor asks for the source at the same moment: a price nobody
               can trace is the thing this directory is trying not to be. -->
          <UFormField :label="t('admin.editor.source')">
            <UInput
              v-model="form.source"
              placeholder="site or person + date"
            />
          </UFormField>

          <UCheckbox
            v-model="form.open_24_7"
            :label="t('health.openAllDay')"
          />

          <div class="grid grid-cols-2 gap-3 border-t border-default pt-3">
            <div class="space-y-2">
              <p class="text-xs font-medium uppercase tracking-wide text-muted">
                RU
              </p>
              <UInput
                v-model="form.ru.name"
                :placeholder="t('admin.columns.name')"
              />
              <UTextarea
                v-model="form.ru.price_note"
                :rows="2"
                :placeholder="t('admin.editor.priceNote')"
              />
            </div>
            <div class="space-y-2">
              <p class="text-xs font-medium uppercase tracking-wide text-muted">
                EN
              </p>
              <UInput
                v-model="form.en.name"
                :placeholder="t('admin.columns.name')"
              />
              <UTextarea
                v-model="form.en.price_note"
                :rows="2"
                :placeholder="t('admin.editor.priceNote')"
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
              :disabled="!form.ru.name || !form.en.name"
            >
              {{ t('admin.editor.save') }}
            </UButton>
          </div>
        </form>
      </template>
    </UModal>
  </div>
</template>
