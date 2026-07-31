<script setup lang="ts">
import logo from '~/assets/brand/logo.svg'
import logoFull from '~/assets/brand/logo-full.svg'

const { t, locale, setLocale } = useI18n()
const selectedCity = useState<string>('selectedCity', () => 'da-nang')

const toggleLocale = async () => {
  await setLocale(locale.value === 'ru' ? 'en' : 'ru')
}

const cityOptions = computed(() => [
  {
    label: t('cities.daNang'),
    flag: '🇻🇳',
    description: t('cities.vietnam'),
    value: 'da-nang'
  },
  {
    label: t('cities.nhaTrang'),
    flag: '🇻🇳',
    description: `${t('cities.vietnam')} · ${t('cities.comingSoon')}`,
    value: 'nha-trang',
    disabled: true
  },
  {
    label: t('cities.pattaya'),
    flag: '🇹🇭',
    description: `${t('cities.thailand')} · ${t('cities.comingSoon')}`,
    value: 'pattaya',
    disabled: true
  },
  {
    label: t('cities.phuket'),
    flag: '🇹🇭',
    description: `${t('cities.thailand')} · ${t('cities.comingSoon')}`,
    value: 'phuket',
    disabled: true
  }
])

const selectedCityOption = computed(() => cityOptions.value.find(city => city.value === selectedCity.value))
</script>

<template>
  <header class="border-b border-gray-200 bg-white/80 backdrop-blur dark:border-gray-800 dark:bg-gray-950/80">
    <UContainer class="flex items-center gap-2 py-3">
      <NuxtLink
        to="/"
        class="mr-auto shrink-0"
        aria-label="TAMITUT home"
      >
        <img
          class="h-auto w-12 dark:invert min-[360px]:hidden"
          :src="logo"
          alt="TAMITUT"
        >
        <img
          class="hidden h-auto w-24 dark:invert min-[360px]:block sm:w-32"
          :src="logoFull"
          alt="TAMITUT"
        >
      </NuxtLink>
      <USelectMenu
        v-model="selectedCity"
        :items="cityOptions"
        :search-input="false"
        value-key="value"
        variant="ghost"
        size="md"
        class="min-w-0 max-w-[7.5rem] shrink sm:w-48 sm:max-w-none"
        :ui="{ base: 'px-1.5' }"
        :aria-label="t('cities.choose')"
      >
        <template #default>
          <span class="flex min-w-0 items-center gap-1.5">
            <span class="shrink-0 text-base leading-none">{{ selectedCityOption?.flag }}</span>
            <span class="truncate text-sm font-medium">{{ selectedCityOption?.label }}</span>
          </span>
        </template>
        <template #item="{ item }">
          <div class="flex min-w-0 items-center gap-2">
            <span class="shrink-0 text-base leading-none">{{ item.flag }}</span>
            <span class="truncate">{{ item.label }}</span>
          </div>
        </template>
      </USelectMenu>
      <UButton
        color="neutral"
        variant="ghost"
        size="sm"
        class="min-w-9 shrink-0 justify-center px-1.5 text-xs font-semibold tracking-wide"
        :aria-label="locale === 'ru' ? 'Switch to English' : 'Переключить на русский'"
        @click="toggleLocale"
      >
        {{ locale === 'ru' ? 'EN' : 'RU' }}
      </UButton>
      <UColorModeButton
        color="neutral"
        variant="ghost"
        size="lg"
        square
      />
    </UContainer>
  </header>
</template>
