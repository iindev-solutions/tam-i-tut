// One-shot e2e for the menu-translate Edge Function:
// 1. Build a valid Telegram initData (HMAC like the real WebApp).
// 2. Bootstrap a session through the hosted telegram-bootstrap function.
// 3. Upload the synthetic menu photo to menu-translate.
// 4. Print the parsed result; cleanup is done separately via db query.
import { createHmac } from 'node:crypto'
import { readFileSync } from 'node:fs'

const BOT_TOKEN = process.env.TELEGRAM_BOT_TOKEN ?? ''
const BASE = 'https://tepsurbgsrivvcvizxph.supabase.co'
const ANON = 'sb_publishable_PeO94JnLRNMiUOrZrFZk5Q_sLD3w2Hp'
const PLACE_ID = process.env.E2E_PLACE_ID ?? ''
if (!BOT_TOKEN) throw new Error('set TELEGRAM_BOT_TOKEN env var first')

const secretKey = createHmac('sha256', 'WebAppData').update(BOT_TOKEN).digest()
const params = new URLSearchParams({
  auth_date: String(Math.floor(Date.now() / 1000)),
  user: JSON.stringify({ id: 777000777, first_name: 'E2E', language_code: 'ru' })
})
// Verified algorithm: values are URL-DECODED, only hash is excluded (the
// ECDSA signature field, when present, stays in the check string).
const dataCheckString = [...params.entries()].map(([k, v]) => `${k}=${v}`).sort().join('\n')
const hash = createHmac('sha256', secretKey).update(dataCheckString).digest('hex')
const initData = `${params.toString()}&hash=${hash}`

const boot = await fetch(BASE + '/functions/v1/telegram-bootstrap', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', apikey: ANON, Authorization: 'Bearer ' + ANON },
  body: JSON.stringify({ initData })
})
const bootBody = await boot.json()
if (!boot.ok || !bootBody?.session?.access_token) {
  console.log('bootstrap failed:', boot.status, JSON.stringify(bootBody).slice(0, 200))
  process.exit(1)
}
console.log('bootstrap ok, user:', bootBody.telegram?.id)

const photo = readFileSync('/tmp/test-menu.jpg').toString('base64')
const scan = await fetch(BASE + '/functions/v1/menu-translate', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json', Authorization: 'Bearer ' + bootBody.session.access_token },
  body: JSON.stringify({ ...(PLACE_ID ? { place_id: PLACE_ID } : {}), photo_base64: photo })
})
const scanBody = await scan.json()
if (!scan.ok) {
  console.log('scan failed:', scan.status, JSON.stringify(scanBody).slice(0, 300))
  process.exit(1)
}
const menu = scanBody.menu
const items = menu.menu_items ?? []
console.log('scan:', scan.status, '| cached:', scanBody.cached, '| items:', items.length)
for (const item of items) {
  console.log(`- [${item.position}] ${item.raw_text_vi} = ${item.price_vnd ?? '?'}đ -> slug: ${item.dish_id ? 'linked' : 'null'} | ru: ${item.ai_name_ru} | conf: ${item.confidence}`)
}
