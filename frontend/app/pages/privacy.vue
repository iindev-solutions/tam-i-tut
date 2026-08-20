<script setup lang="ts">
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-6">
      <header class="space-y-1">
        <h1 class="text-3xl font-semibold tracking-tight text-highlighted sm:text-4xl">
          {{ t('privacy.title') }}
        </h1>
        <p class="text-sm text-muted">
          {{ t('privacy.updated') }}
        </p>
      </header>

      <section class="space-y-4 text-sm leading-6 text-default">
        <div class="space-y-1">
          <p class="font-medium text-highlighted">
            {{ t('privacy.what.title') }}
          </p>
          <p class="text-muted">
            {{ t('privacy.what.body') }}
          </p>
        </div>

        <div class="space-y-1">
          <p class="font-medium text-highlighted">
            {{ t('privacy.why.title') }}
          </p>
          <p class="text-muted">
            {{ t('privacy.why.body') }}
          </p>
        </div>

        <div class="space-y-1">
          <p class="font-medium text-highlighted">
            {{ t('privacy.share.title') }}
          </p>
          <p class="text-muted">
            {{ t('privacy.share.body') }}
          </p>
        </div>

        <div class="space-y-1">
          <p class="font-medium text-highlighted">
            {{ t('privacy.contact.title') }}
          </p>
          <p class="text-muted">
            {{ t('privacy.contact.body') }}
          </p>
        </div>
      </section>

      <NuxtLink
        to="/"
        class="inline-flex items-center gap-1.5 text-sm text-primary"
      >
        <UIcon
          name="i-lucide-arrow-left"
          class="size-4"
        />
        {{ t('privacy.back') }}
      </NuxtLink>
    </div>
  </UContainer>
</template>
