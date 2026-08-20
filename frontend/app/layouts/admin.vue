<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

import { useAdminDb } from '~/composables/useAdminDb'

const { t } = useI18n()
const route = useRoute()
const admin = useAdminDb()

const navItems = [
  { to: '/admin', labelKey: 'admin.nav.dashboard', exact: true },
  { to: '/admin/cities', labelKey: 'admin.nav.cities' },
  { to: '/admin/categories', labelKey: 'admin.nav.categories' },
  { to: '/admin/districts', labelKey: 'admin.nav.districts' },
  { to: '/admin/places', labelKey: 'admin.nav.places' },
  { to: '/admin/guides', labelKey: 'admin.nav.guides' },
  { to: '/admin/reviews', labelKey: 'admin.nav.reviews' }
]

const isActive = (item: { to: string, exact?: boolean }) =>
  item.exact ? route.path === item.to : route.path.startsWith(item.to)

const isLogin = computed(() => route.path === '/admin/login')

const logout = async () => {
  await admin.logout()
  await navigateTo('/admin/login')
}
</script>

<template>
  <div class="min-h-screen bg-white text-gray-950 transition-colors dark:bg-gray-950 dark:text-white">
    <header class="sticky top-0 z-10 border-b border-default bg-white/90 backdrop-blur dark:bg-gray-950/90">
      <UContainer class="flex items-center gap-3 py-3">
        <p class="text-sm font-semibold tracking-tight text-highlighted">
          {{ t('admin.title') }}
        </p>
        <div
          v-if="!isLogin"
          class="ml-auto flex items-center gap-1"
        >
          <UButton
            to="/"
            size="xs"
            variant="ghost"
            color="neutral"
            trailing-icon="i-lucide-arrow-right"
            :aria-label="t('admin.openApp')"
          >
            {{ t('admin.openApp') }}
          </UButton>
          <UButton
            size="xs"
            variant="ghost"
            color="neutral"
            icon="i-lucide-log-out"
            :aria-label="t('admin.logout')"
            @click="logout"
          >
            {{ t('admin.logout') }}
          </UButton>
        </div>
      </UContainer>
      <nav
        v-if="!isLogin"
        class="overflow-x-auto"
      >
        <UContainer class="flex gap-1 pb-2">
          <NuxtLink
            v-for="item in navItems"
            :key="item.to"
            :to="item.to"
            class="rounded-full px-3 py-1.5 text-sm whitespace-nowrap transition-colors"
            :class="isActive(item)
              ? 'bg-primary/10 font-medium text-highlighted'
              : 'text-muted hover:bg-elevated hover:text-default'"
          >
            {{ t(item.labelKey) }}
          </NuxtLink>
        </UContainer>
      </nav>
    </header>

    <main class="py-6">
      <UContainer>
        <slot />
      </UContainer>
    </main>
  </div>
</template>
