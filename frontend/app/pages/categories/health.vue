<script setup lang="ts">
import { computed, shallowRef } from 'vue'
import { useI18n } from 'vue-i18n'

import type { Clinic, ClinicKind } from '~/types/content'

const { t } = useI18n()
const { db } = useDb()
const { tt } = useLocalized()

const tips = computed(() =>
  db.value.guides.filter(guide => guide.category === 'health' && guide.status === 'published')
)

const clinics = computed(() => db.value.clinics)

const filters: Array<{ id: ClinicKind | 'all', labelKey: string }> = [
  { id: 'all', labelKey: 'health.kinds.all' },
  { id: 'hospital', labelKey: 'health.kinds.hospital' },
  { id: 'dental', labelKey: 'health.kinds.dental' },
  { id: 'ophthalmology', labelKey: 'health.kinds.ophthalmology' },
  { id: 'dermatology', labelKey: 'health.kinds.dermatology' },
  { id: 'diagnostics', labelKey: 'health.kinds.diagnostics' },
  { id: 'oncology', labelKey: 'health.kinds.oncology' },
  { id: 'ent', labelKey: 'health.kinds.ent' },
  { id: 'veterinary', labelKey: 'health.kinds.veterinary' }
]

const activeFilter = shallowRef<ClinicKind | 'all'>('all')

const visibleClinics = computed<Clinic[]>(() =>
  activeFilter.value === 'all' ? clinics.value : clinics.value.filter(c => c.kind === activeFilter.value)
)

/** Only offer a chip for a specialisation that actually has rows. */
const activeFilters = computed(() =>
  filters.filter(f => f.id === 'all' || clinics.value.some(c => c.kind === f.id))
)

/** Distinct sources behind the visible rows - shown once, not per card. */
const sources = computed(() => [...new Set(visibleClinics.value.map(c => c.source))])
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
      <header class="space-y-1">
        <p class="text-sm text-muted">
          {{ t('health.kicker') }}
        </p>
        <h1 class="text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
          {{ t('health.title') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('health.description') }}
        </p>
      </header>

      <section
        v-if="clinics.length > 0"
        class="space-y-4"
      >
        <div class="space-y-1">
          <h2 class="text-2xl font-semibold text-highlighted">
            {{ t('health.clinicsTitle') }}
          </h2>
          <p class="text-sm leading-6 text-muted">
            {{ t('health.clinicsSubtitle') }}
          </p>
        </div>

        <!-- Prices below come from a third party and are not confirmed by us
             yet, so the caveat sits above the list rather than in a footnote. -->
        <UAlert
          v-if="clinics.some(c => c.trustLevel === 'under_review')"
          color="warning"
          variant="soft"
          icon="i-lucide-triangle-alert"
          :title="t('health.clinicsUnverified')"
          :description="t('health.clinicsSource', { source: sources.join(', ') })"
        />

        <div class="flex flex-wrap gap-2">
          <button
            v-for="filter in activeFilters"
            :key="filter.id"
            type="button"
            class="rounded-full border px-3 py-1.5 text-xs font-medium transition-colors"
            :class="activeFilter === filter.id
              ? 'border-default bg-elevated text-highlighted'
              : 'border-transparent bg-elevated/40 text-muted hover:text-highlighted'"
            :aria-pressed="activeFilter === filter.id"
            @click="activeFilter = filter.id"
          >
            {{ t(filter.labelKey) }}
          </button>
        </div>

        <ul class="space-y-3">
          <li
            v-for="clinic in visibleClinics"
            :key="clinic.id"
            class="rounded-2xl border border-default bg-elevated p-4 shadow-sm"
          >
            <div class="space-y-2">
              <div class="flex items-start justify-between gap-3">
                <p class="text-sm font-medium text-highlighted">
                  {{ clinic.name }}
                </p>
                <UBadge
                  v-if="clinic.open24_7"
                  color="neutral"
                  variant="subtle"
                  size="sm"
                  class="shrink-0"
                >
                  {{ t('health.openAllDay') }}
                </UBadge>
              </div>
              <p class="text-xs text-muted">
                {{ t(`health.kinds.${clinic.kind}`) }}
              </p>
              <p class="text-sm leading-6 text-default">
                {{ tt(clinic.priceNote) }}
              </p>
              <TrustBadge
                :level="clinic.trustLevel"
                :verified-at="clinic.lastVerifiedAt"
                variant="full"
              />
            </div>
          </li>
        </ul>
      </section>

      <section class="space-y-4">
        <h2 class="text-2xl font-semibold text-highlighted">
          {{ t('health.tipsTitle') }}
        </h2>
        <UCard
          v-for="tip in tips"
          :key="tip.id"
          class="border-default session-hover-card"
          :ui="{ body: 'p-5' }"
        >
          <div class="space-y-2">
            <div class="flex items-center gap-2">
              <UIcon
                :name="tip.icon || 'i-lucide-heart-pulse'"
                class="size-5 shrink-0 text-primary"
              />
              <p class="text-sm font-medium text-highlighted">
                {{ tt(tip.title) }}
              </p>
            </div>
            <TrustBadge
              :level="tip.trustLevel"
              :verified-at="tip.lastVerifiedAt"
              variant="full"
            />
            <GuideText
              :text="tt(tip.summary)"
              variant="summary"
              class="text-sm leading-6 text-muted"
            />
            <GuideText
              :text="tt(tip.note)"
              variant="note"
            />
          </div>
        </UCard>

        <p
          v-if="tips.length === 0"
          class="rounded-xl border border-default bg-elevated/50 p-6 text-center text-sm text-muted"
        >
          {{ t('health.empty') }}
        </p>
      </section>
    </div>
  </UContainer>
</template>
