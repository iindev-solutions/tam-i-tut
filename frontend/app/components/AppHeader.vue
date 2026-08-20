<script setup lang="ts">
import logo from '~/assets/brand/logo.svg'
import logoFull from '~/assets/brand/logo-full.svg'

const { locale, setLocale } = useI18n()

const toggleLocale = async () => {
  await setLocale(locale.value === 'ru' ? 'en' : 'ru')
}
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
          class="h-auto w-12 dark:invert min-[400px]:hidden"
          :src="logo"
          alt="TAMITUT"
        >
        <img
          class="hidden h-auto w-24 dark:invert min-[400px]:block sm:w-32"
          :src="logoFull"
          alt="TAMITUT"
        >
      </NuxtLink>
      <AppCitySelect compact />
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
