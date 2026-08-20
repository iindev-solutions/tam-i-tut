<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

import type { GuideEntry } from '~/types/content'

const { t } = useI18n()
const { db } = useDb()
const { tt } = useLocalized()

const entries = computed<GuideEntry[]>(() =>
  db.value.guides.filter(guide => guide.category === 'transport' && guide.status === 'published')
)
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
      <header class="space-y-1">
        <p class="text-sm text-muted">
          {{ t('transport.kicker') }}
        </p>
        <h1 class="text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
          {{ t('transport.title') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('transport.description') }}
        </p>
      </header>

      <section class="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <UCard
          v-for="entry in entries"
          :key="entry.id"
          class="border-default"
          :ui="{ body: 'p-5' }"
        >
          <div class="space-y-3">
            <div class="flex items-start justify-between gap-3">
              <p class="text-sm font-medium text-highlighted">
                {{ tt(entry.title) }}
              </p>
              <UIcon
                :name="entry.icon"
                class="size-5 shrink-0 text-muted"
              />
            </div>
            <p class="text-xs text-muted">
              {{ tt(entry.note) }}
            </p>
            <p class="text-sm leading-6 text-muted">
              {{ tt(entry.summary) }}
            </p>
          </div>
        </UCard>
      </section>
    </div>
  </UContainer>
</template>
