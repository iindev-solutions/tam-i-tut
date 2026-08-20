interface Env {
  SUPABASE_URL: string
  SUPABASE_ANON_KEY: string
  TMA_URL: string
  ALERT_CHAT_ID: string
  TELEGRAM_BOT_TOKEN?: string
}

export default {
  async scheduled(_event: ScheduledEvent, env: Env, ctx: ExecutionContext): Promise<void> {
    const state: Record<string, string> = {}

    // Any HTTP response (even 4xx/5xx) proves the project is awake; only a
    // network failure means it is down.
    const pingAlive = async (url: string, headers?: HeadersInit): Promise<string> => {
      try {
        const res = await fetch(url, { headers: { 'User-Agent': 'tamitut-keepalive', ...headers } })
        return `up(${res.status})`
      } catch {
        return 'down(err)'
      }
    }

    state.supabase = await pingAlive(`${env.SUPABASE_URL}/auth/v1/health`, { apikey: env.SUPABASE_ANON_KEY })
    state.tma = await pingAlive(env.TMA_URL)

    console.log('keepalive', JSON.stringify(state))

    const allUp = state.supabase.startsWith('up') && state.tma.startsWith('up')
    if (!allUp) {
      if (env.ALERT_CHAT_ID && env.TELEGRAM_BOT_TOKEN) {
        const text = `TAMITUT keepalive ALERT: ${JSON.stringify(state)}`
        ctx.waitUntil(
          fetch(`https://api.telegram.org/bot${env.TELEGRAM_BOT_TOKEN}/sendMessage`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ chat_id: env.ALERT_CHAT_ID, text })
          }).catch(() => undefined)
        )
      }
    }
  }
}
