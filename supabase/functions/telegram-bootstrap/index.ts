// Supabase Edge Function: telegram-bootstrap
// Validates Telegram Mini App initData, enforces freshness and replay protection,
// and establishes a Supabase Auth session for the Telegram user.
//
// Required secrets (supabase secrets set ...):
//   TELEGRAM_BOT_TOKEN     - bot token from @BotFather
//   SUPABASE_URL           - provided by the platform
//   SUPABASE_SERVICE_ROLE_KEY - provided by the platform
//
// Replay protection uses the telegram_bootstrap_nonces table (migration 021).

import { validateInitData } from './validate.ts'

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
}

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' }
  })

interface SessionResponse {
  access_token: string
  refresh_token: string
  expires_in: number
  user: { id: string; email: string }
}

Deno.serve(async (request: Request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: CORS_HEADERS })
  if (request.method !== 'POST') return json({ error: 'method_not_allowed' }, 405)

  const botToken = Deno.env.get('TELEGRAM_BOT_TOKEN')
  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (!botToken || !supabaseUrl || !serviceRoleKey) {
    return json({ error: 'function_not_configured' }, 503)
  }

  let initData: string | undefined
  try {
    const body = (await request.json()) as { initData?: string }
    initData = body.initData
  } catch {
    return json({ error: 'malformed' }, 400)
  }
  if (!initData) return json({ error: 'malformed' }, 400)

  const result = await validateInitData(initData, botToken)
  if (!result.ok || !result.user || !result.initDataHash) {
    return json({ error: result.error ?? 'invalid' }, 401)
  }

  // Replay protection: unique insert fails when this initData was already used.
  const nonceResponse = await fetch(`${supabaseUrl}/rest/v1/telegram_bootstrap_nonces`, {
    method: 'POST',
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
      'Content-Type': 'application/json',
      Prefer: 'return=minimal'
    },
    body: JSON.stringify({
      init_data_hash: result.initDataHash,
      telegram_user_id: result.user.id
    })
  })
  if (!nonceResponse.ok) {
    if (nonceResponse.status === 409) return json({ error: 'replay' }, 401)
    return json({ error: 'nonce_store_unavailable' }, 503)
  }

  // Deterministic email per Telegram identity, invisible and unguessable.
  const email = `tg-${result.user.id}@tma.tamitut.local`
  const adminHeaders = {
    apikey: serviceRoleKey,
    Authorization: `Bearer ${serviceRoleKey}`,
    'Content-Type': 'application/json'
  }

  const linkResponse = await fetch(`${supabaseUrl}/auth/v1/admin/generate_link`, {
    method: 'POST',
    headers: adminHeaders,
    body: JSON.stringify({ type: 'magiclink', email })
  })

  if (linkResponse.status === 400) {
    // User exists? generate_link still returns action_link for existing users,
    // a 400 here means bad request shape - surface it.
    return json({ error: 'link_generation_failed' }, 503)
  }
  if (!linkResponse.ok) return json({ error: 'link_generation_failed' }, 503)

  const { action_link: actionLink } = (await linkResponse.json()) as { action_link?: string }
  if (!actionLink) return json({ error: 'link_generation_failed' }, 503)

  const tokenHash = new URL(actionLink).searchParams.get('token_hash')
  if (!tokenHash) return json({ error: 'link_generation_failed' }, 503)

  const verifyResponse = await fetch(`${supabaseUrl}/auth/v1/verify`, {
    method: 'POST',
    headers: { ...adminHeaders, 'X-Client-Info': 'telegram-bootstrap' },
    body: JSON.stringify({ type: 'magiclink', token_hash: tokenHash })
  })
  if (!verifyResponse.ok) return json({ error: 'session_exchange_failed' }, 503)

  const session = (await verifyResponse.json()) as SessionResponse

  // No trigger creates a profiles row from auth.users, so the bootstrap creates
  // the read profile on first sign-in. Idempotent insert (ignore on conflict)
  // ensures an existing curator/moderator profile is never downgraded here.
  const locale = result.user.language_code === 'en' ? 'en' : 'ru'
  const profileResponse = await fetch(supabaseUrl + '/rest/v1/profiles', {
    method: 'POST',
    headers: {
      ...adminHeaders,
      Prefer: 'resolution=ignore-duplicates,return=minimal'
    },
    body: JSON.stringify({
      id: session.user.id,
      telegram_user_id: result.user.id,
      display_name: result.user.first_name || null,
      locale
    })
  })
  if (!profileResponse.ok) return json({ error: 'profile_sync_failed' }, 503)

  return json({
    ok: true,
    telegram: {
      id: result.user.id,
      first_name: result.user.first_name,
      username: result.user.username,
      language_code: result.user.language_code
    },
    session: {
      access_token: session.access_token,
      refresh_token: session.refresh_token,
      expires_in: session.expires_in
    }
  })
})
