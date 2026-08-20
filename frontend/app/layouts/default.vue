<script setup lang="ts">
const { t } = useI18n()
const route = useRoute()
const router = useRouter()

const isHome = computed(() => route.path === '/')

const goBack = () => {
  if (window.history.state?.back) router.back()
  else navigateTo('/')
}
</script>

<template>
  <div class="min-h-screen bg-white text-gray-950 transition-colors dark:bg-gray-950 dark:text-white">
    <AppHeader />
    <nav
      v-if="!isHome"
      class="border-b border-default"
      :aria-label="t('nav.back')"
    >
      <UContainer class="py-1">
        <UButton
          color="neutral"
          variant="ghost"
          size="sm"
          icon="i-lucide-arrow-left"
          class="-ml-2"
          :aria-label="t('nav.back')"
          @click="goBack"
        >
          {{ t('nav.back') }}
        </UButton>
      </UContainer>
    </nav>
    <main class="mx-auto max-w-4xl px-4 py-4">
      <slot />
    </main>
  </div>
</template>
