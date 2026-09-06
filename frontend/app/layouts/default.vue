<script setup lang="ts">
const { source } = useDb()
const { bootstrapError } = useAuth()
const { t } = useI18n()

// A plain browser has no Telegram session (expected demo state); a Telegram
// client with a failing bootstrap shows its error code here instead.
const bannerText = computed(() => {
  const base = t('common.demoBanner')
  return bootstrapError.value ? `${base} [${bootstrapError.value}]` : base
})
</script>

<template>
  <div class="min-h-screen bg-white text-gray-950 transition-colors dark:bg-gray-950 dark:text-white">
    <AppHeader />
    <!-- Mock fallback is silent by design - this strip keeps it honest. -->
    <div
      v-if="source === 'mock'"
      class="bg-warning/15 px-4 py-1 text-center text-xs text-default"
      role="status"
    >
      {{ bannerText }}
    </div>
    <!-- Prod builds never show prototype data: without a session the user
         gets the honest bot-gate instead. -->
    <div
      v-else-if="source === 'unavailable'"
      class="flex min-h-[60vh] items-center justify-center px-6"
    >
      <div class="max-w-sm space-y-3 text-center">
        <UIcon
          name="i-lucide-send"
          class="mx-auto size-10 text-primary"
        />
        <h2 class="text-xl font-semibold text-highlighted">
          {{ t('common.openInBotTitle') }}
        </h2>
        <p class="text-sm leading-6 text-muted">
          {{ t('common.openInBotDesc') }}
        </p>
        <p
          v-if="bootstrapError"
          class="font-mono text-xs text-dimmed"
        >
          {{ bootstrapError }}
        </p>
      </div>
    </div>
    <!-- Back navigation is the Telegram native BackButton only
         (plugins/telegram.client.ts): a per-route back strip here shifted
         the whole page down on inner routes and made transitions jump. -->
    <main
      v-else
      class="mx-auto max-w-4xl px-4 py-4"
    >
      <slot />
    </main>
  </div>
</template>
