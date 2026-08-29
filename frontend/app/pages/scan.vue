<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-6">
      <header class="space-y-1">
        <p class="text-sm text-muted">
          {{ t('menu.kicker') }}
        </p>
        <h1 class="text-3xl font-semibold tracking-tight text-highlighted sm:text-4xl">
          {{ t('menu.globalTitle') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('menu.globalDescription') }}
        </p>
      </header>

      <MenuScanPanel :place-id="null" />
    </div>
  </UContainer>
</template>
