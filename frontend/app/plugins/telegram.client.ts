import type { Router } from 'vue-router'

import { getSupabaseClient } from '~/composables/useSupabaseClient'
import type { TmaSessionState } from '~/composables/useAuth'

type TelegramBackButton = {
  show: () => void
  hide: () => void
  onClick: (cb: () => void) => void
  offClick: (cb: () => void) => void
}

type TelegramWebApp = {
  ready: () => void
  expand: () => void
  initData?: string
  BackButton?: TelegramBackButton
}

const webApp = (): TelegramWebApp | undefined =>
  (window as unknown as { Telegram?: { WebApp?: TelegramWebApp } }).Telegram?.WebApp

interface BootstrapPayload {
  ok?: boolean
  telegram?: { id?: number }
  session?: { access_token?: string, refresh_token?: string, expires_in?: number }
}

/**
 * Telegram bridge:
 * - syncs the native Mini App BackButton with client-side routing
 *   (visible everywhere except `/`, tap goes back through vue-router);
 * - when a Supabase project is configured, exchanges initData for a
 *   Supabase session via the `telegram-bootstrap` Edge Function.
 *   This plugin is the SINGLE consumer of the one-shot initData nonce:
 *   no other code may call the bootstrap endpoint, or the second call
 *   hits the replay guard (409).
 * Outside Telegram (plain browser) everything here is a no-op.
 */
export default defineNuxtPlugin(() => {
  const router = useRouter() as Router
  const config = useRuntimeConfig()
  const session = useState<TmaSessionState | null>('tma-session', () => null)

  let bound = false

  const bind = () => {
    if (bound) return
    const backButton = webApp()?.BackButton
    if (!backButton) return
    backButton.onClick(() => {
      if (window.history.state?.back) router.back()
      else router.replace('/')
    })
    bound = true
  }

  const sync = () => {
    const backButton = webApp()?.BackButton
    if (!backButton) return
    if (router.currentRoute.value.path === '/') backButton.hide()
    else backButton.show()
  }

  router.afterEach(() => {
    bind()
    sync()
  })

  const app = webApp()
  app?.ready()
  app?.expand()
  bind()
  sync()

  const bootstrapAuth = async () => {
    const supabaseUrl = config.public.supabaseUrl
    const initData = app?.initData
    const client = getSupabaseClient()
    if (!supabaseUrl || !initData || !client) return
    try {
      const response = await fetch(`${supabaseUrl}/functions/v1/telegram-bootstrap`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ initData })
      })
      if (!response.ok) return
      const payload = (await response.json()) as BootstrapPayload
      if (!payload.telegram?.id || !payload.session?.access_token || !payload.session?.refresh_token) return
      const { error } = await client.auth.setSession({
        access_token: payload.session.access_token,
        refresh_token: payload.session.refresh_token
      })
      if (error) return
      session.value = { telegramId: payload.telegram.id, authenticated: true }
    } catch {
      // Offline or function not deployed yet: keep the app usable without a session.
    }
  }

  void bootstrapAuth()
})
