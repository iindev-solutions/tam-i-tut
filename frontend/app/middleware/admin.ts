import { getSupabaseClient } from '~/composables/useSupabaseClient'

const STAFF_ROLES = ['admin', 'curator', 'moderator']

/**
 * Guards the /admin panel: requires a Supabase session whose profile role is
 * staff (admin/curator/moderator). Everyone else is sent to /admin/login.
 */
export default defineNuxtRouteMiddleware(async () => {
  const client = getSupabaseClient()
  if (!client) return navigateTo('/admin/login')

  const {
    data: { session }
  } = await client.auth.getSession()
  if (!session) return navigateTo('/admin/login')

  const { data, error } = await client
    .from('profiles')
    .select('role')
    .eq('id', session.user.id)
    .maybeSingle()

  const role = data?.role
  if (error || !role || !STAFF_ROLES.includes(role)) return navigateTo('/admin/login')
})
