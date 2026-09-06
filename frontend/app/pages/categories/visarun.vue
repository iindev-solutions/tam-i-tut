<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const { db } = useDb()
const { tt } = useLocalized()

const guides = computed(() =>
  db.value.guides.filter(guide => guide.category === 'visarun' && guide.status === 'published')
)
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
      <header class="space-y-1">
        <p class="text-sm text-muted">
          {{ t('visarun.kicker') }}
        </p>
        <h1 class="text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
          {{ t('visarun.title') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('visarun.description') }}
        </p>
      </header>

      <section class="space-y-4">
        <h2 class="text-2xl font-semibold text-highlighted">
          {{ t('visarun.tipsTitle') }}
        </h2>
        <UCard
          v-for="tip in guides"
          :key="tip.id"
          class="border-default session-hover-card"
          :ui="{ body: 'p-5' }"
        >
          <div class="space-y-2">
            <div class="flex items-center gap-2">
              <UIcon
                :name="tip.icon || 'i-lucide-plane-takeoff'"
                class="size-5 shrink-0 text-primary"
              />
              <p class="text-sm font-medium text-highlighted">
                {{ tt(tip.title) }}
              </p>
            </div>
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
          v-if="guides.length === 0"
          class="rounded-xl border border-default bg-elevated/50 p-6 text-center text-sm text-muted"
        >
          {{ t('visarun.empty') }}
        </p>
      </section>
    </div>
  </UContainer>
</template>
