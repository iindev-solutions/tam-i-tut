import { getSupabaseClient } from './useSupabaseClient'

/**
 * Pilot metrics (migration 049): fire-and-forget event log into app_events.
 * RLS forces user_id to the session identity; failures are swallowed on
 * purpose - analytics must never break a user flow.
 */
export function useAnalytics() {
  const client = getSupabaseClient()
  const { authenticated } = useAuth()

  const log = (event: string, metadata: Record<string, unknown> = {}) => {
    if (!client || !authenticated.value) return
    void client
      .from('app_events')
      .insert({ event, metadata })
      .then(undefined, () => {})
  }

  return { log }
}
