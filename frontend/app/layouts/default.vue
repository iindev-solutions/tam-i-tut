<template>
  <div class="min-h-screen bg-white text-gray-950 transition-colors dark:bg-gray-950 dark:text-white">
    <AppHeader />
    <!-- Back navigation is the Telegram native BackButton only
         (plugins/telegram.client.ts): a per-route back strip here shifted
         the whole page down on inner routes and made transitions jump. -->
    <main class="mx-auto max-w-4xl px-4 py-4">
      <slot />
    </main>
  </div>
</template>
