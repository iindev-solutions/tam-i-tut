<script setup lang="ts">
import { shallowRef, watch } from 'vue'
import { useI18n } from 'vue-i18n'

import type { MenuItemView } from '~/composables/useMenuTranslator'

/**
 * Shared scan UI for the menu translator: camera button -> skeleton ->
 * translated grouped list -> dish sheet. Venue-agnostic; the page decides
 * whether a scan binds to a venue (cache + photo path) by passing place-id.
 */
const props = defineProps<{ placeId: string | null }>()

const { t } = useI18n()
const { authenticated, bootstrapError } = useAuth()
const nuxtApp = useNuxtApp()
const reconnecting = shallowRef(false)
const reconnect = async () => {
  reconnecting.value = true
  const reconnectFn = nuxtApp.$tmaReconnect as (() => Promise<void>) | undefined
  if (reconnectFn) await reconnectFn()
  reconnecting.value = false
}
const { state, sections, menuStatus, hasSession, scan } = useMenuTranslator(() => props.placeId)
const fileInput = shallowRef<HTMLInputElement | null>(null)

const pickedFile = async (event: Event) => {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  input.value = ''
  if (file) await scan(file)
}

const openPicker = () => fileInput.value?.click()

const activeItem = shallowRef<MenuItemView | null>(null)
watch(() => props.placeId, () => {
  activeItem.value = null
})
</script>

<template>
  <div class="space-y-6">
    <!-- No session: scanning needs the TMA bootstrap. Shows the exact
         bootstrap failure code so a stuck session is diagnosable. -->
    <UAlert
      v-if="!authenticated && bootstrapError"
      icon="i-lucide-unplug"
      color="warning"
      variant="soft"
      :title="t('menu.unauthorizedTitle')"
      :description="`${t('menu.bootstrapFailed')} [${bootstrapError}]`"
    >
      <template #actions>
        <UButton
          size="xs"
          color="neutral"
          variant="outline"
          :loading="reconnecting"
          :label="t('menu.reconnect')"
          @click="reconnect"
        />
      </template>
    </UAlert>

    <UAlert
      v-else-if="!hasSession"
      icon="i-lucide-lock"
      color="warning"
      variant="soft"
      :title="t('menu.unauthorizedTitle')"
      :description="t('menu.unauthorizedBody')"
    />

    <template v-else>
      <!-- Scan controls + error surface. -->
      <section
        v-if="sections.length === 0 || state.phase === 'error'"
        class="space-y-3"
      >
        <UAlert
          v-if="state.phase === 'error'"
          icon="i-lucide-triangle-alert"
          color="error"
          variant="soft"
          :title="t('menu.errorTitle')"
          :description="state.code === 'unauthorized'
            ? t('menu.unauthorizedBody')
            : state.code === 'rate_limited'
              ? t('menu.errors.rate_limited')
              : state.code === 'not_configured'
                ? t('menu.errors.not_configured')
                : state.code === 'photo'
                  ? t('menu.errors.photo')
                  : state.code === 'network'
                    ? t('menu.errors.network')
                    : state.code === 'ai_unavailable' ? t('menu.errors.ai_unavailable') : t('menu.errors.other')"
        />

        <button
          v-if="state.phase !== 'scanning'"
          type="button"
          class="flex w-full flex-col items-center gap-3 rounded-2xl border-2 border-dashed border-default bg-elevated/40 px-6 py-10 text-center transition-colors hover:bg-elevated/70"
          @click="openPicker"
        >
          <UIcon
            name="i-lucide-camera"
            class="size-10 text-primary"
          />
          <span class="text-base font-medium text-highlighted">{{ t('menu.scan') }}</span>
          <span class="text-sm text-muted">{{ t('menu.scanHint') }}</span>
        </button>
        <input
          ref="fileInput"
          type="file"
          accept="image/*"
          capture="environment"
          class="hidden"
          @change="pickedFile"
        >

        <div
          v-if="state.phase === 'scanning'"
          class="space-y-2"
        >
          <p class="flex items-center gap-2 text-sm text-muted">
            <UIcon
              name="i-lucide-loader-circle"
              class="size-4 animate-spin"
            />
            {{ t('menu.scanning') }}
          </p>
          <USkeleton class="h-12 w-full" />
          <USkeleton class="h-12 w-full" />
          <USkeleton class="h-12 w-4/5" />
          <USkeleton class="h-12 w-full" />
        </div>
      </section>

      <!-- Result: translated lines. -->
      <section
        v-else
        class="space-y-4"
      >
        <p
          v-if="menuStatus === 'ai'"
          class="flex items-center gap-2 rounded-lg bg-elevated/60 px-3 py-2 text-xs text-muted"
        >
          <UIcon
            name="i-lucide-sparkles"
            class="size-3.5 shrink-0"
          />
          {{ t('menu.cachedNote') }}
        </p>

        <UCard
          v-for="(section, sectionIndex) in sections"
          :key="sectionIndex"
          :ui="{ body: 'p-0' }"
          class="overflow-hidden border-default"
        >
          <ul class="divide-y divide-default">
            <li
              v-for="item in section.items"
              :key="item.id"
            >
              <button
                type="button"
                class="flex w-full items-center gap-3 px-4 py-3 text-left transition-colors hover:bg-elevated/50"
                @click="activeItem = item"
              >
                <span class="min-w-0 flex-1">
                  <span class="block truncate text-sm font-medium text-highlighted">
                    {{ item.name }}
                  </span>
                  <span class="block truncate text-xs text-muted">{{ item.rawVi }}</span>
                </span>
                <span
                  v-if="item.priceVnd != null"
                  class="shrink-0 text-sm font-semibold text-default"
                >
                  {{ item.priceVnd.toLocaleString('ru-RU') }} ₫
                </span>
                <UIcon
                  name="i-lucide-chevron-right"
                  class="size-4 shrink-0 text-dimmed"
                />
              </button>
            </li>
          </ul>
        </UCard>

        <button
          type="button"
          class="w-full rounded-xl border border-default px-4 py-3 text-sm text-muted transition-colors hover:bg-elevated/50"
          @click="sections = []"
        >
          {{ t('menu.retry') }}
        </button>
      </section>
    </template>

    <!-- Dish card: dictionary content only; AI text carries the badge. -->
    <USlideover
      :open="activeItem !== null"
      :overlay="true"
      :ui="{ content: 'rounded-t-2xl' }"
      @update:open="activeItem = null"
    >
      <template #body>
        <div
          v-if="activeItem"
          class="space-y-4"
        >
          <div class="relative h-48 w-full overflow-hidden rounded-xl bg-elevated">
            <img
              v-if="activeItem.photoUrl"
              :src="activeItem.photoUrl"
              :alt="activeItem.name"
              class="h-full w-full object-cover"
            >
            <div
              v-else
              class="flex h-full w-full flex-col items-center justify-center gap-2 bg-gradient-to-br from-primary/10 via-elevated to-primary/5 text-muted"
            >
              <UIcon
                name="i-lucide-image-off"
                class="size-8 text-dimmed"
              />
              <span class="text-xs">{{ t('menu.noDishPhoto') }}</span>
            </div>
          </div>

          <div class="space-y-2">
            <div class="flex items-start justify-between gap-3">
              <h2 class="text-xl font-semibold text-highlighted">
                {{ activeItem.name }}
              </h2>
              <span
                v-if="activeItem.priceVnd != null"
                class="shrink-0 text-lg font-bold text-primary"
              >
                {{ activeItem.priceVnd.toLocaleString('ru-RU') }} ₫
              </span>
            </div>
            <p class="text-sm text-muted">
              VI: {{ activeItem.rawVi }}
            </p>
            <p class="text-base leading-6 text-default">
              {{ activeItem.summary }}
            </p>
          </div>

          <!-- Curated gallery from the dish dictionary (verified photos). -->
          <div
            v-if="activeItem.galleryUrls.length"
            class="space-y-2"
          >
            <p class="text-xs font-medium text-muted">
              {{ t('menu.galleryTitle') }}
            </p>
            <div class="grid grid-cols-3 gap-1.5">
              <a
                v-for="url in activeItem.galleryUrls"
                :key="url"
                :href="url"
                target="_blank"
                rel="noopener"
                class="block overflow-hidden rounded-lg bg-elevated"
              >
                <img
                  :src="url"
                  :alt="activeItem.name"
                  class="aspect-square h-full w-full object-cover transition-transform hover:scale-105"
                  loading="lazy"
                >
              </a>
            </div>
          </div>

          <div
            v-if="activeItem.tags.length"
            class="flex flex-wrap gap-1.5"
          >
            <UBadge
              v-for="tag in activeItem.tags"
              :key="tag"
              color="neutral"
              variant="subtle"
              size="sm"
            >
              {{ t(`menu.tag.${tag}`) }}
            </UBadge>
          </div>

          <UBadge
            :color="activeItem.isDictionary ? 'success' : 'warning'"
            variant="subtle"
            icon="i-lucide-sparkles"
          >
            {{ activeItem.isDictionary ? t('menu.verifiedBadge') : t('menu.machineBadge') }}
          </UBadge>
        </div>
      </template>
    </USlideover>
  </div>
</template>
