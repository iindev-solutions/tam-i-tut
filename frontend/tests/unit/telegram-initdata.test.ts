import { createHmac } from 'node:crypto'

import { describe, expect, it } from 'vitest'

import { MAX_AGE_SECONDS, MAX_FUTURE_SKEW_SECONDS, deriveSecret, validateInitData } from '#telegram-validate'

const BOT_TOKEN = '123456:TEST-TOKEN'
const NOW = 1_800_000_000

// Verified against a live client: values are URL-DECODED, only hash is excluded -
// the ECDSA signature field stays in the check string.
const sign = (initData: string, token: string): string => {
  const params = new URLSearchParams(initData)
  params.delete('hash')
  const checkString = [...params.entries()].map(([k, v]) => `${k}=${v}`).sort().join('\n')
  const secret = createHmac('sha256', 'WebAppData').update(token).digest()
  return createHmac('sha256', secret).update(checkString).digest('hex')
}

const buildInitData = (user: object, authDate: number, extra: Record<string, string> = {}) => {
  const params = new URLSearchParams({
    user: JSON.stringify(user),
    auth_date: String(authDate),
    ...extra
  })
  const hash = sign(params.toString(), BOT_TOKEN)
  params.set('hash', hash)
  return params.toString()
}

const user = { id: 8815351798, first_name: 'Slava', username: 'slava', language_code: 'ru' }

describe('telegram initData validation', () => {
  // Regression for the real-client bug: Telegram sends values percent-encoded
  // (and user.photo_url with escaped slashes) - the raw-pair signature must
  // verify, which the old decoded-check-string implementation rejected.
  it('verifies a percent-encoded Telegram-style initData', async () => {
    const raw = 'query_id=AAFjUEFUAgAAAGNQ&user=%7B%22id%22%3A5708533859%2C%22first_name%22%3A%22ssslava%22%2C%22photo_url%22%3A%22https%3A%5C%2F%5C%2Ft.me%5C%2Fi%5C%2Fuserpic%5C%2F320%5C%2Fpic.svg%22%7D&auth_date=1788000000&signature=LLA7Hammx4Tc3kufADUPQJ3pMMpx5hYt_LXILw1lVFBjnEcZa7nE6HXcrkoh4L8ZHwpTgYi5wjwAn0MjY2ZjCw'
    const hash = sign(raw, BOT_TOKEN)
    const result = await validateInitData(raw + '&hash=' + hash, BOT_TOKEN, 1788000600)
    expect(result.ok).toBe(true)
    expect(result.user?.id).toBe(5708533859)
  })

  it('accepts fresh correctly signed initData and extracts the user', async () => {
    const initData = buildInitData(user, NOW - 100)
    const result = await validateInitData(initData, BOT_TOKEN, NOW)
    expect(result.ok).toBe(true)
    expect(result.user?.id).toBe(user.id)
    expect(result.initDataHash).toMatch(/^[0-9a-f]{64}$/)
  })

  it('rejects tampered payloads with bad_signature', async () => {
    const initData = buildInitData(user, NOW - 100)
    const tampered = initData.replace('Slava', 'Hacker')
    const result = await validateInitData(tampered, BOT_TOKEN, NOW)
    expect(result.ok).toBe(false)
    expect(result.error).toBe('bad_signature')
  })

  it('rejects signatures made with a different bot token', async () => {
    const initData = buildInitData(user, NOW - 100)
    const result = await validateInitData(initData, '999999:OTHER-TOKEN', NOW)
    expect(result.ok).toBe(false)
    expect(result.error).toBe('bad_signature')
  })

  it('rejects stale auth_date beyond the freshness window', async () => {
    const initData = buildInitData(user, NOW - 25 * 60 * 60)
    const result = await validateInitData(initData, BOT_TOKEN, NOW)
    expect(result.ok).toBe(false)
    expect(result.error).toBe('expired')
  })

  it('rejects malformed input', async () => {
    expect((await validateInitData('', BOT_TOKEN)).error).toBe('malformed')
    expect((await validateInitData('nonsense', BOT_TOKEN)).error).toBe('malformed')
    const noHash = new URLSearchParams({ user: JSON.stringify(user), auth_date: '1' }).toString()
    expect((await validateInitData(noHash, BOT_TOKEN)).error).toBe('malformed')
  })

  it('derives the same secret as the reference HMAC chain', async () => {
    const expected = createHmac('sha256', 'WebAppData').update(BOT_TOKEN).digest()
    const derived = await deriveSecret(BOT_TOKEN)
    expect([...derived]).toEqual([...expected])
  })

  it('rejects a signed payload without a user as missing_user', async () => {
    const params = new URLSearchParams({ auth_date: String(NOW - 100) })
    const hash = sign(params.toString(), BOT_TOKEN)
    params.set('hash', hash)
    const result = await validateInitData(params.toString(), BOT_TOKEN, NOW)
    expect(result.ok).toBe(false)
    expect(result.error).toBe('missing_user')
  })

  it('accepts initData exactly at the freshness boundary (age === maxAge)', async () => {
    const initData = buildInitData(user, NOW - MAX_AGE_SECONDS)
    expect((await validateInitData(initData, BOT_TOKEN, NOW)).ok).toBe(true)
  })

  it('rejects initData one second past the freshness boundary', async () => {
    const initData = buildInitData(user, NOW - (MAX_AGE_SECONDS + 1))
    const result = await validateInitData(initData, BOT_TOKEN, NOW)
    expect(result.ok).toBe(false)
    expect(result.error).toBe('expired')
  })

  it('accepts auth_date within the future skew window (clock offset)', async () => {
    const initData = buildInitData(user, NOW + MAX_FUTURE_SKEW_SECONDS)
    expect((await validateInitData(initData, BOT_TOKEN, NOW)).ok).toBe(true)
  })

  it('rejects auth_date beyond the future skew window as expired', async () => {
    const initData = buildInitData(user, NOW + MAX_FUTURE_SKEW_SECONDS + 1)
    const result = await validateInitData(initData, BOT_TOKEN, NOW)
    expect(result.ok).toBe(false)
    expect(result.error).toBe('expired')
  })
})
