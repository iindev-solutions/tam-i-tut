<script setup lang="ts">
import logo from '~/assets/brand/logo.svg'

const { t } = useI18n()

const quickLinks = [
  { label: 'home.housing', icon: 'i-lucide-house' },
  { label: 'home.food', icon: 'i-lucide-utensils' },
  { label: 'home.transport', icon: 'i-lucide-bike' },
  { label: 'home.money', icon: 'i-lucide-wallet' },
  { label: 'home.safety', icon: 'i-lucide-shield-check' },
  { label: 'home.culture', icon: 'i-lucide-book-open' }
]
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-8">
      <section class="relative overflow-hidden rounded-3xl border border-default bg-elevated px-5 py-6 shadow-sm sm:px-10 sm:py-10">
        <div class="absolute -right-16 -top-20 size-56 rounded-full bg-primary/5 blur-3xl" />
        <div class="relative space-y-3">
          <h1 class="max-w-xl text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
            {{ t('home.title') }}
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
          <UCard
            v-for="link in quickLinks"
            :key="link.label"
            class="border-default"
          >
            <div class="flex items-center justify-between">
              <UIcon
                :name="link.icon"
                class="size-5 text-muted"
              />
            </div>
            <p class="mt-5 text-sm font-medium text-highlighted">
              {{ t(link.label) }}
            </p>
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
          to="#start"
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

      <footer class="flex items-center justify-between border-t border-default pt-6 text-xs text-muted">
        <img
          class="h-4 w-auto opacity-50 dark:invert"
          :src="logo"
          alt="TAMITUT"
        >
        <span>{{ t('home.footer') }}</span>
      </footer>
    </div>
  </UContainer>
</template>
