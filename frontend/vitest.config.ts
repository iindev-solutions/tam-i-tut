import { fileURLToPath } from 'node:url'

import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
    include: ['tests/**/*.test.ts']
  },
  resolve: {
    alias: {
      // Nuxt-compatible app alias so composable modules resolve identically
      // in tests and in the app.
      '~': fileURLToPath(new URL('./app', import.meta.url)),
      '@': fileURLToPath(new URL('./app', import.meta.url)),
      // Shared with the Supabase edge function; alias keeps Vite inside its root.
      '#telegram-validate': fileURLToPath(
        new URL('../supabase/functions/telegram-bootstrap/validate.ts', import.meta.url)
      )
    }
  }
})
