<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

import logo from '~/assets/brand/logo.svg'

const { t } = useI18n()
const buildTime = String((useRuntimeConfig().public as Record<string, string | undefined>).buildTime ?? '')
const { db } = useDb()

const categories = computed(() => db.value.categories)

const selectedCity = useState<string>('selectedCity', () => 'da-nang')
const selectedCityIn = computed(() => t(`citiesIn.${selectedCity.value}`))
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
      <section class="relative overflow-hidden rounded-3xl border border-default bg-elevated px-5 py-6 shadow-sm sm:px-10 sm:py-10">
        <div class="absolute -right-16 -top-20 size-56 rounded-full bg-primary/5 blur-3xl" />
        <div class="relative space-y-3">
          <h1 class="max-w-xl text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
            {{ t('home.title') }}
            <span class="mt-1 block text-muted">{{ t('home.inCity', { city: selectedCityIn }) }}</span>
          </h1>
          <p class="max-w-lg text-base leading-7 text-muted">
            {{ t('home.description') }}
          </p>
        </div>
      </section>

      <section
        id="start"
        class="space-y-4"
      >
        <div class="grid grid-cols-2 gap-3 sm:grid-cols-3">
          <UCard class="border-primary/25 bg-primary/5 session-hover-card">
            <NuxtLink
              to="/scan"
              class="block"
            >
              <div class="flex items-center justify-between">
                <UIcon
                  name="i-lucide-camera"
                  class="size-5 text-primary"
                />
                <UIcon
                  name="i-lucide-arrow-right"
                  class="size-4 text-primary"
                />
              </div>
              <p class="mt-5 text-sm font-medium text-highlighted">
                {{ t('home.scanTitle') }}
              </p>
            </NuxtLink>
          </UCard>
          <UCard
            v-for="category in categories"
            :key="category.id"
            class="border-default session-hover-card"
          >
            <NuxtLink
              :to="category.to"
              class="block"
            >
              <div class="flex items-center justify-between">
                <UIcon
                  :name="category.icon"
                  class="size-5 text-muted"
                />
                <UIcon
                  name="i-lucide-arrow-right"
                  class="size-4 text-muted"
                />
              </div>
              <p class="mt-5 text-sm font-medium text-highlighted">
                {{ t(category.labelKey) }}
              </p>
            </NuxtLink>
          </UCard>
        </div>
      </section>

      <UCard class="overflow-hidden border-primary/15 bg-primary/5">
        <h2 class="text-2xl font-semibold text-highlighted">
          {{ t('home.firstDayTitle') }}
        </h2>
        <p class="mt-2 max-w-lg leading-6 text-muted">
          {{ t('home.firstDayDescription') }}
        </p>
        <UButton
          to="/journey/first-day"
          variant="link"
          color="primary"
          class="mt-3 px-0"
          trailing-icon="i-lucide-arrow-right"
        >
          {{ t('home.openCollection') }}
        </UButton>
      </UCard>

      <p class="flex items-center gap-2 text-sm text-muted">
        <UIcon
          name="i-lucide-badge-check"
          class="size-4 text-primary"
        />
        {{ t('home.trustDescription') }}
      </p>

      <footer class="flex items-center justify-between gap-3 border-t border-default pt-6 text-xs text-muted">
        <img
          class="h-4 w-auto opacity-50 dark:invert"
          :src="logo"
          alt="TAMITUT"
        >
        <span class="flex items-center gap-3">
          <NuxtLink
            to="/privacy"
            class="hover:text-default"
          >
            {{ t('privacy.link') }}
          </NuxtLink>
          <span>build {{ buildTime.slice(0, 16).replace('T', ' ') }} UTC · {{ t('home.footer') }}</span>
        </span>
      </footer>
    </div>
  </UContainer>
</template>
