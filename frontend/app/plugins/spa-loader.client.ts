declare global {
  interface Window {
    __TAMITUT_FINISH_LOADER?: () => void
  }
}

export default defineNuxtPlugin((nuxtApp) => {
  // Nuxt would remove #__nuxt-loader here; template renames it so we finish the curtain.
  nuxtApp.hook('app:suspense:resolve', () => {
    window.__TAMITUT_FINISH_LOADER?.()
  })
})
