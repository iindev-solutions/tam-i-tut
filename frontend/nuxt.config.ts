export default defineNuxtConfig({
  modules: ['@nuxt/eslint', '@nuxt/ui', '@nuxtjs/i18n', 'nitro-cloudflare-dev'],
  ssr: false,

  devtools: {
    enabled: false
  },

  app: {
    head: {
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1',
      script: [
        {
          // Official Telegram WebApp bridge; inert in a plain browser.
          src: 'https://telegram.org/js/telegram-web-app.js'
        }
      ]
    }
  },

  css: ['~/assets/css/main.css'],

  runtimeConfig: {
    public: {
      appName: process.env.NUXT_PUBLIC_APP_NAME || 'TAMITUT',
      supabaseUrl: process.env.NUXT_PUBLIC_SUPABASE_URL || '',
      supabaseAnonKey: process.env.NUXT_PUBLIC_SUPABASE_ANON_KEY || ''
    }
  },

  // No X-Frame-Options / CSP frame-ancestors: the app must stay framable for the Telegram Mini App.
  routeRules: {
    '/**': {
      headers: {
        'X-Content-Type-Options': 'nosniff',
        'Referrer-Policy': 'strict-origin-when-cross-origin',
        'Permissions-Policy': 'camera=(), microphone=(), geolocation=()'
      }
    }
  },

  runtimeConfig: {
    public: {
      // Evaluated at build time - shown in the footer so anyone can verify
      // they are running the freshly deployed bundle.
      buildTime: new Date().toISOString()
    }
  },

  compatibilityDate: '2026-01-19',

  nitro: {
    preset: 'cloudflare_module',

    cloudflare: {
      // Deploy target is the repo-root wrangler.jsonc (main = the Nitro
      // server entry + assets binding). deployConfig must stay off: Nitro's
      // generated .output/server/wrangler.json plus the .wrangler/deploy/
      // config.json redirect hijack `wrangler deploy` into a server build
      // with a missing index.mjs entry point.
      deployConfig: false,
      nodeCompat: true
    }
  },

  eslint: {
    config: {
      stylistic: {
        commaDangle: 'never',
        braceStyle: '1tbs'
      }
    }
  },

  i18n: {
    locales: [
      {
        code: 'ru',
        name: 'Русский',
        file: 'ru.json'
      },
      {
        code: 'en',
        name: 'English',
        file: 'en.json'
      }
    ],
    defaultLocale: 'ru',
    strategy: 'no_prefix',
    detectBrowserLanguage: false
  }
})
