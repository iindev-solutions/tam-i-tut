<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

interface Props {
  compact?: boolean
}

withDefaults(defineProps<Props>(), { compact: false })

const { t, locale } = useI18n()
const { db } = useDb()
const selectedCity = useState<string>('selectedCity', () => 'da-nang')

const cityOptions = computed(() =>
  db.value.cities.map(city => ({
    label: (locale.value === 'en' ? city.nameEn : city.nameRu) ?? t(city.labelKey),
    flag: city.flag,
    description: city.active
      ? t(city.countryKey)
      : `${t(city.countryKey)} · ${t('cities.comingSoon')}`,
    value: city.id,
    disabled: !city.active
  }))
)
const selectedCityOption = computed(() => cityOptions.value.find(city => city.value === selectedCity.value))
</script>

<template>
  <USelectMenu
    v-model="selectedCity"
    :items="cityOptions"
    :search-input="false"
    value-key="value"
    variant="ghost"
    :size="compact ? 'md' : 'sm'"
    class="min-w-0 shrink"
    :ui="{ base: compact ? 'px-1.5' : 'px-2.5' }"
    :aria-label="t('cities.choose')"
  >
    <template #default>
      <span class="flex min-w-0 items-center gap-1.5">
        <span class="shrink-0 text-base leading-none">{{ selectedCityOption?.flag }}</span>
        <span class="truncate text-sm font-medium">{{ selectedCityOption?.label }}</span>
        <UIcon
          name="i-lucide-chevrons-up-down"
          class="size-3.5 shrink-0 text-muted"
        />
      </span>
    </template>
    <template #item="{ item }">
      <div class="flex min-w-0 items-center gap-2">
        <span class="shrink-0 text-base leading-none">{{ item.flag }}</span>
        <span class="truncate">{{ item.label }}</span>
      </div>
    </template>
  </USelectMenu>
</template>
