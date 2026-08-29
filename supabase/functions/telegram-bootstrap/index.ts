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

import { createRateLimiter } from './rate-limit.ts'
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

// Per-IP burst cap in two layers: this in-memory counter (cheap, best-effort
// per isolate - Supabase may spawn a fresh isolate per request) plus the
// durable Postgres RPC below (authoritative). See rate-limit.ts.
const rateLimiter = createRateLimiter()

const clientIp = (request: Request): string =>
  (request.headers.get('x-forwarded-for') ?? '').split(',')[0].trim() || 'unknown'

// Authoritative fixed-window counter via the check_rate_limit RPC (migration
// 030). Fails open: if the counter store is unreachable the request still
// proceeds - the initData HMAC and the replay-nonce table remain the guards.
const dbRateLimit = async (ip: string, supabaseUrl: string, serviceRoleKey: string): Promise<number | null> => {
  const response = await fetch(`${supabaseUrl}/rest/v1/rpc/check_rate_limit`, {
    method: 'POST',
    headers: {
      apikey: serviceRoleKey,
      Authorization: `Bearer ${serviceRoleKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ p_key: `bootstrap-ip:${ip}`, p_max: 10, p_window_seconds: 60 })
  })
  if (!response.ok) return null
  const retryAfter = (await response.json()) as number
  return retryAfter > 0 ? retryAfter : null
}

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

  const rateLimitResponse = (retryAfter: number | null) =>
    new Response(JSON.stringify({ error: 'rate_limited' }), {
      status: 429,
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json', 'Retry-After': String(retryAfter ?? 60) }
    })

  const ip = clientIp(request)
  if (rateLimiter.check(ip) !== null) return rateLimitResponse(60)
  const dbRetryAfter = await dbRateLimit(ip, supabaseUrl, serviceRoleKey)
  if (dbRetryAfter !== null) return rateLimitResponse(dbRetryAfter)

  const result = await validateInitData(initData, botToken)
  if (!result.ok || !result.user || !result.initDataHash) {
    return json({ error: result.error ?? 'invalid' }, 401),
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

  // generate_link(magiclink) requires the user to exist on hosted projects -
  // it does not auto-create. Idempotent: 422 (already registered) is fine.
  const createResponse = await fetch(`${supabaseUrl}/auth/v1/admin/users`, {
    method: 'POST',
    headers: adminHeaders,
    body: JSON.stringify({ email, email_confirm: true })
  })
  if (!createResponse.ok && createResponse.status !== 422) {
    console.error('admin user create failed', createResponse.status, await createResponse.text())
    return json({ error: 'user_sync_failed' }, 503)
  }

  const linkResponse = await fetch(`${supabaseUrl}/auth/v1/admin/generate_link`, {
    method: 'POST',
    headers: adminHeaders,
    body: JSON.stringify({ type: 'magiclink', email })
  })

  if (linkResponse.status === 400) {
    // User exists? generate_link still returns action_link for existing users,
    // a 400 here means bad request shape - surface it.
    const detail = await linkResponse.text()
    console.error('generate_link 400', detail)
    return json({ error: 'link_generation_failed' }, 503)
  }
  if (!linkResponse.ok) {
    const detail = await linkResponse.text()
    console.error('generate_link failed', linkResponse.status, detail)
    return json({ error: 'link_generation_failed' }, 503)
  }

  const linkBody = await linkResponse.json() as { action_link?: string, properties?: { action_link?: string } }
  const actionLink = linkBody.action_link ?? linkBody.properties?.action_link
  if (!actionLink) {
    console.error('generate_link body missing action_link', JSON.stringify(linkBody).slice(0, 400))
    return json({ error: 'link_generation_failed' }, 503)
  }

  // GoTrue versions differ: hashed-link deployments put `token_hash` in the
  // action link, older ones put the plain `token`. Verify with whichever we
  // got - POST /auth/v1/verify accepts either field.
  const linkUrl = new URL(actionLink)
  const tokenHash = linkUrl.searchParams.get('token_hash')
  const plainToken = linkUrl.searchParams.get('token')
  if (!tokenHash && !plainToken) {
    console.error('action_link has no token', actionLink.slice(0, 200))
    return json({ error: 'link_generation_failed' }, 503)
  }

  const verifyResponse = await fetch(`${supabaseUrl}/auth/v1/verify`, {
    method: 'POST',
    headers: { ...adminHeaders, 'X-Client-Info': 'telegram-bootstrap' },
    body: JSON.stringify(tokenHash
      ? { type: 'magiclink', token_hash: tokenHash }
      : { type: 'magiclink', token_hash: plainToken })
  })
  if (!verifyResponse.ok) {
    const verifyDetail = await verifyResponse.text().catch(() => '')
    console.error('verify failed', verifyResponse.status, verifyDetail)
    return json({ error: 'session_exchange_failed' }, 503)
  }

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
