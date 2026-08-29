import { computed } from 'vue'

export interface TmaSessionState {
  telegramId: number
  /** true once the telegram-bootstrap session was exchanged into Supabase Auth */
  authenticated: boolean
}

/**
 * Read-side view of the TMA/Supabase session state.
 * The session itself is established by the telegram plugin (the single
 * consumer of the one-shot initData nonce); this composable only reads it.
 */
export function useAuth() {
  const session = useState<TmaSessionState | null>('tma-session', () => null)
  /** Last bootstrap failure code from the telegram plugin (null = none). */
  const bootstrapError = useState<string | null>('tma-bootstrap-error', () => null)

  const authenticated = computed(() => session.value?.authenticated === true)
  const telegramId = computed(() => session.value?.telegramId ?? null)

  return { session, authenticated, telegramId, bootstrapError }
}
