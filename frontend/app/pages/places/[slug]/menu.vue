<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const route = useRoute()
const { db } = useDb()

const slug = computed(() => String(route.params.slug))
const place = computed(() => db.value.places.find(p => p.status === 'published' && p.slug === slug.value))
</script>

<template>
  <UContainer class="px-0">
    <div class="mx-auto max-w-2xl space-y-6">
      <header
        v-if="place"
        class="space-y-1"
      >
        <p class="text-sm text-muted">
          {{ t('menu.kicker') }} · {{ place.name }}
        </p>
        <h1 class="text-3xl font-semibold tracking-tight text-highlighted sm:text-4xl">
          {{ t('menu.title') }}
        </h1>
        <p class="max-w-lg text-base leading-7 text-muted">
          {{ t('menu.description') }}
        </p>
      </header>

      <p
        v-if="!place"
        class="rounded-xl border border-default bg-elevated/50 p-6 text-center text-sm text-muted"
      >
        {{ t('food.empty') }}
      </p>

      <MenuScanPanel
        v-else
        :place-id="place.id"
      />
    </div>
  </UContainer>
</template>
