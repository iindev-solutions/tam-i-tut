<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const dos = computed(() => [1, 2, 3, 4].map(n => t(`culture.do.${n}`)))
const donts = computed(() => [1, 2, 3, 4].map(n => t(`culture.dont.${n}`)))
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
      <header class="space-y-1">
        <p class="text-sm text-muted">
          {{ t('culture.kicker') }}
        </p>
        <h1 class="text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
          {{ t('culture.title') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('culture.description') }}
        </p>
      </header>

      <section class="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <UCard
          class="border-default"
          :ui="{ body: 'p-5' }"
        >
          <div class="space-y-4">
            <p class="flex items-center gap-2 text-sm font-medium text-highlighted">
              <UIcon
                name="i-lucide-check"
                class="size-4 text-muted"
              />
              {{ t('culture.doTitle') }}
            </p>
            <ul class="space-y-3 text-sm">
              <li
                v-for="item in dos"
                :key="item"
                class="flex items-start gap-3"
              >
                <UIcon
                  name="i-lucide-check"
                  class="mt-0.5 size-4 shrink-0 text-muted"
                />
                <span class="text-muted">{{ item }}</span>
              </li>
            </ul>
          </div>
        </UCard>

        <UCard
          class="border-default"
          :ui="{ body: 'p-5' }"
        >
          <div class="space-y-4">
            <p class="flex items-center gap-2 text-sm font-medium text-highlighted">
              <UIcon
                name="i-lucide-x"
                class="size-4 text-muted"
              />
              {{ t('culture.dontTitle') }}
            </p>
            <ul class="space-y-3 text-sm">
              <li
                v-for="item in donts"
                :key="item"
                class="flex items-start gap-3"
              >
                <UIcon
                  name="i-lucide-x"
                  class="mt-0.5 size-4 shrink-0 text-muted"
                />
                <span class="text-muted">{{ item }}</span>
              </li>
            </ul>
          </div>
        </UCard>
      </section>

      <p class="text-sm leading-6 text-muted">
        {{ t('culture.note') }}
      </p>
    </div>
  </UContainer>
</template>
