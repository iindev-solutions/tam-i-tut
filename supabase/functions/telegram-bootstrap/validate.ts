/**
 * Telegram Mini App initData validation (pure, environment-free).
 * Runs identically in Deno (Supabase Edge), Node, and browsers via WebCrypto.
 */

export interface TelegramInitUser {
  id: number
  first_name?: string
  last_name?: string
  username?: string
  language_code?: string
  photo_url?: string
}

export interface ValidationResult {
  ok: boolean
  error?: 'malformed' | 'bad_signature' | 'expired' | 'missing_user'
  user?: TelegramInitUser
  authDate?: number
  initDataHash?: string
}

export const MAX_AGE_SECONDS = 24 * 60 * 60

// Allow a small clock offset between the Telegram-issuing server and the
// function host so a legitimately fresh auth_date is not rejected when this
// host's clock is slightly behind. A future timestamp beyond this window is a
// clock-skip / tampering anomaly and is rejected.
export const MAX_FUTURE_SKEW_SECONDS = 5 * 60

const encoder = new TextEncoder()

const toHex = (buffer: ArrayBuffer): string =>
  [...new Uint8Array(buffer)].map(byte => byte.toString(16).padStart(2, '0')).join('')

const timingSafeEqualHex = (a: string, b: string): boolean => {
  if (a.length !== b.length || a.length === 0) return false
  let diff = 0
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i)
  return diff === 0
}

/** Derives the initData signing secret: HMAC_SHA256(key="WebAppData", message=botToken). */
export async function deriveSecret(botToken: string): Promise<Uint8Array> {
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode('WebAppData'),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  )
  return new Uint8Array(await crypto.subtle.sign('HMAC', key, encoder.encode(botToken)))
}

/**
 * Validates raw Telegram.WebApp.initData against the bot token.
 * Checks: structure, HMAC-SHA256 signature, auth_date freshness window.
 */
export async function validateInitData(
  initData: string,
  botToken: string,
  nowSeconds: number = Math.floor(Date.now() / 1000),
  maxAgeSeconds: number = MAX_AGE_SECONDS
): Promise<ValidationResult> {
  if (!initData || !initData.includes('=')) return { ok: false, error: 'malformed' }

  const params = new URLSearchParams(initData)
  const hash = params.get('hash')
  const signature = params.get('signature')
  const received = hash || signature
  if (!received) return { ok: false, error: 'malformed' }

  params.delete('hash')
  params.delete('signature')

  const checkString = [...params.entries()]
    .map(([key, value]) => `${key}=${value}`)
    .sort()
    .join('\n')

  const secret = await deriveSecret(botToken)
  const signKey = await crypto.subtle.importKey(
    'raw',
    secret,
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  )
  const computed = toHex(await crypto.subtle.sign('HMAC', signKey, encoder.encode(checkString)))
  if (!timingSafeEqualHex(computed, received.toLowerCase())) {
    return { ok: false, error: 'bad_signature' }
  }

  const authDate = Number(params.get('auth_date') ?? 0)
  const age = nowSeconds - authDate
  if (!authDate || age > maxAgeSeconds || age < -MAX_FUTURE_SKEW_SECONDS) {
    return { ok: false, error: 'expired' }
  }

  let user: TelegramInitUser | undefined
  try {
    const rawUser = params.get('user')
    if (rawUser) user = JSON.parse(rawUser) as TelegramInitUser
  } catch {
    return { ok: false, error: 'malformed' }
  }
  if (!user?.id) return { ok: false, error: 'missing_user' }

  return { ok: true, user, authDate, initDataHash: computed }
}
