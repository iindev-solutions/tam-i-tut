export default defineNuxtConfig({
	modules: ['@nuxt/eslint', '@nuxt/ui', '@nuxtjs/i18n'],
	ssr: false,

	app: {
		head: {
			charset: 'utf-8',
			viewport: 'width=device-width, initial-scale=1'
		}
	},

	css: ['~/assets/css/main.css'],

	runtimeConfig: {
		public: {
			appName: process.env.NUXT_PUBLIC_APP_NAME || 'TAMITUT',
			apiBase: process.env.NUXT_PUBLIC_API_BASE || 'http://localhost:8000/api'
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
				code: 'en',
				name: 'English',
				file: 'en.json'
			}
		],
		defaultLocale: 'en',
		strategy: 'no_prefix',
		detectBrowserLanguage: false
	},

	compatibilityDate: '2026-01-19'
})
