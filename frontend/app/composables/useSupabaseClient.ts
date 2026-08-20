import { createClient, type SupabaseClient } from '@supabase/supabase-js'

let cached: SupabaseClient | null | undefined

/**
 * App-wide Supabase client from public runtime config.
 * Returns null when no project is configured (plain-browser prototype mode).
 * The app is SPA-only (`ssr: false`), so a module-level cache is safe and
 * guarantees every consumer shares one client (single session, single source
 * for `auth.getSession()`).
 */
export function getSupabaseClient(): SupabaseClient | null {
  if (cached !== undefined) return cached
  const config = useRuntimeConfig()
  const url = config.public.supabaseUrl
  const anonKey = config.public.supabaseAnonKey
  cached = url && anonKey ? createClient(url, anonKey) : null
  return cached
}
