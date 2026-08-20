<script setup lang="ts">
import type { NuxtError } from '#app'

const props = defineProps<{
  error: NuxtError
}>()

const { t } = useI18n()

const isNotFound = computed(() => props.error.statusCode === 404)

const goHome = () => clearError({ redirect: '/' })
</script>

<template>
  <div class="flex min-h-screen items-center justify-center bg-white px-4 text-gray-950 transition-colors dark:bg-gray-950 dark:text-white">
    <div class="w-full max-w-md space-y-6 rounded-3xl border border-default bg-elevated p-8 text-center shadow-sm">
      <p class="text-5xl font-semibold tracking-tight text-highlighted">
        {{ error.statusCode }}
      </p>
      <div class="space-y-2">
        <h1 class="text-xl font-semibold text-highlighted">
          {{ isNotFound ? t('error.notFoundTitle') : t('error.genericTitle') }}
        </h1>
        <p class="text-sm leading-6 text-muted">
          {{ isNotFound ? t('error.notFoundDescription') : t('error.genericDescription') }}
        </p>
      </div>
      <UButton
        color="primary"
        variant="soft"
        icon="i-lucide-arrow-left"
        :aria-label="t('error.backHome')"
        @click="goHome"
      >
        {{ t('error.backHome') }}
      </UButton>
    </div>
  </div>
</template>
