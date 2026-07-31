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
      <section class="relative overflow-hidden rounded-3xl border border-default bg-elevated px-4 py-4 shadow-sm sm:px-10">
        <div class="absolute -right-16 -top-20 size-56 rounded-full bg-primary/10 blur-3xl" />
        <div class="relative space-y-6">
          <div class="space-y-3">
            <h1 class="max-w-xl text-4xl font-semibold tracking-tight text-highlighted sm:text-5xl">
              {{ t('home.title') }}
            </h1>
            <p class="max-w-lg text-base leading-7 text-muted">
              {{ t('home.description') }}
            </p>
          </div>
        </div>
      </section>

      <section
        id="start"
        class="space-y-4"
      >
        <div>
          <p class="text-xs font-semibold uppercase tracking-[0.24em] text-primary">
            {{ t('home.exploreLabel') }}
          </p>
          <h2 class="mt-1 text-2xl font-semibold text-highlighted">
            {{ t('home.exploreTitle') }}
          </h2>
        </div>
        <UInput
          :placeholder="t('home.searchPlaceholder')"
          icon="i-lucide-search"
          size="xl"
          class="w-full"
        />
        <div class="grid grid-cols-2 gap-3 sm:grid-cols-3">
          <UCard
            v-for="link in quickLinks"
            :key="link.label"
            as="a"
            href="#start"
            class="group cursor-pointer transition hover:-translate-y-0.5 hover:shadow-md"
          >
            <div class="flex items-center justify-between">
              <UIcon
                :name="link.icon"
                class="size-5 text-primary"
              />
              <UIcon
                name="i-lucide-arrow-up-right"
                class="size-4 text-muted transition group-hover:text-highlighted"
              />
            </div>
            <p class="mt-5 text-sm font-medium text-highlighted">
              {{ t(link.label) }}
            </p>
          </UCard>
        </div>
      </section>

      <UCard class="overflow-hidden border-primary/20 bg-primary/5">
        <UBadge
          color="primary"
          variant="subtle"
        >
          {{ t('home.featureBadge') }}
        </UBadge>
        <h2 class="mt-5 text-2xl font-semibold text-highlighted">
          {{ t('home.firstDayTitle') }}
        </h2>
        <p class="mt-2 max-w-lg leading-6 text-muted">
          {{ t('home.firstDayDescription') }}
        </p>
        <UButton
          to="#start"
          variant="link"
          color="primary"
          class="mt-4 px-0"
          trailing-icon="i-lucide-arrow-right"
        >
          {{ t('home.openCollection') }}
        </UButton>
      </UCard>

      <UAlert
        icon="i-lucide-badge-check"
        color="success"
        variant="subtle"
        :title="t('home.trustTitle')"
        :description="t('home.trustDescription')"
      />

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
