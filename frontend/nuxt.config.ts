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
      supabaseUrl: process.env.NUXT_PUBLIC_SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL || '',
      supabaseAnonKey: process.env.NUXT_PUBLIC_SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY || '',
      // Evaluated at build time - shown in the footer so anyone can verify
      // they are running the freshly deployed bundle.
      buildTime: new Date().toISOString()
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

  // Deploy guard: a production build without the Supabase config bakes the
  // mock fallback into prod (demo data for every user). This bit us once -
  // a duplicated runtimeConfig key silently wiped supabaseUrl while the
  // build stayed green. Dev and mock-mode work are unaffected.
  hooks: {
    'build:before'() {
      if (process.env.NODE_ENV === 'production' && !(process.env.NUXT_PUBLIC_SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL)) {
        throw new Error('Production build without NUXT_PUBLIC_SUPABASE_URL - set it in .env (local) or repo secrets (CI), or every user gets demo data.')
      }
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
