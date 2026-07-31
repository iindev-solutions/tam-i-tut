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
    label: `🇻🇳 ${t('cities.daNang')}`,
    description: t('cities.vietnam'),
    value: 'da-nang'
  },
  {
    label: `🇻🇳 ${t('cities.nhaTrang')}`,
    description: `${t('cities.vietnam')} · ${t('cities.comingSoon')}`,
    value: 'nha-trang',
    disabled: true
  },
  {
    label: `🇹🇭 ${t('cities.pattaya')}`,
    description: `${t('cities.thailand')} · ${t('cities.comingSoon')}`,
    value: 'pattaya',
    disabled: true
  },
  {
    label: `🇹🇭 ${t('cities.phuket')}`,
    description: `${t('cities.thailand')} · ${t('cities.comingSoon')}`,
    value: 'phuket',
    disabled: true
  }
])
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
        size="md"
        class="w-28 sm:w-48"
        :aria-label="t('cities.choose')"
      />
      <UButton
        color="neutral"
        variant="ghost"
        size="sm"
        class="w-7 px-0 text-xs font-semibold"
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
