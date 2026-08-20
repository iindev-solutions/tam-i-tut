<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

import type { GuideEntry } from '~/types/content'

const { t } = useI18n()
const { db } = useDb()
const { tt } = useLocalized()

const tips = computed<GuideEntry[]>(() =>
  db.value.guides.filter(guide => guide.category === 'safety' && guide.status === 'published')
)
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
      <header class="space-y-1">
        <p class="text-sm text-muted">
          {{ t('safety.kicker') }}
        </p>
        <h1 class="text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
          {{ t('safety.title') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('safety.description') }}
        </p>
      </header>

      <section class="space-y-4">
        <h2 class="text-2xl font-semibold text-highlighted">
          {{ t('safety.contactsTitle') }}
        </h2>
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <div
            v-for="contact in db.contacts"
            :key="contact.id"
            class="rounded-2xl border border-default bg-elevated p-5 text-center shadow-sm"
          >
            <p class="text-3xl font-semibold tracking-tight text-highlighted">
              {{ contact.number }}
            </p>
            <p class="mt-1 text-sm text-muted">
              {{ tt(contact.label) }}
            </p>
          </div>
        </div>
        <p class="flex items-center gap-2 text-xs text-muted">
          <UIcon
            name="i-lucide-landmark"
            class="size-3.5 shrink-0"
          />
          {{ t('safety.consulateNote') }}
        </p>
      </section>

      <section class="space-y-4">
        <h2 class="text-2xl font-semibold text-highlighted">
          {{ t('safety.tipsTitle') }}
        </h2>
        <div class="grid grid-cols-1 gap-4 sm:grid-cols-3">
          <UCard
            v-for="tip in tips"
            :key="tip.id"
            class="border-default"
            :ui="{ body: 'p-5' }"
          >
            <div class="space-y-3">
              <UIcon
                :name="tip.icon"
                class="size-5 text-muted"
              />
              <p class="text-sm font-medium text-highlighted">
                {{ tt(tip.title) }}
              </p>
              <p class="text-xs text-muted">
                {{ tt(tip.note) }}
              </p>
              <p class="text-sm leading-6 text-muted">
                {{ tt(tip.summary) }}
              </p>
            </div>
          </UCard>
        </div>
      </section>
    </div>
  </UContainer>
</template>
