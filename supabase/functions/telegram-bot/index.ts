// Supabase Edge Function: telegram-bot
// Telegram bot webhook: answers /start (and any text) with a welcome message
// and an inline web_app button that opens the TAMITUT Mini App.
//
// Required secrets (supabase secrets set ...):
//   TELEGRAM_BOT_TOKEN - bot token from @BotFather
//   TMA_URL            - public HTTPS URL of the deployed Mini App
//   SUPABASE_URL       - provided by the platform
//
// Register the webhook after deploy:
//   curl -s -X POST "https://api.telegram.org/bot<TOKEN>/setWebhook" \
//     -d "url=https://<ref>.supabase.co/functions/v1/telegram-bot"

const BOT_TOKEN = Deno.env.get('TELEGRAM_BOT_TOKEN')
const TMA_URL = Deno.env.get('TMA_URL') ?? ''
const WEBHOOK_SECRET = Deno.env.get('WEBHOOK_SECRET') ?? ''

// One bilingual welcome for everyone: many RU-speaking expats keep their
// Telegram client in English, so per-locale branching showed one language
// only. Both blocks always travel together; the button label is dual too.
// City-neutral wording: da-nang is the pilot, more cities follow (cities
// table already carries inactive nha-trang/pattaya/phuket rows).
const WELCOME =
  '🇻🇳 Привет! Это TAMITUT — гид для первых недель в новом городе 🏖️\n' +
  '🏠 Жильё • 🍜 Еда • 🛵 Транспорт • 💰 Деньги • 🛡️ Безопасность\n' +
  '\n' +
  '🇬🇧 Hi! This is TAMITUT — a guide for your first weeks in a new city\n' +
  '🏠 Housing • 🍜 Food • 🛵 Transport • 💰 Money • 🛡️ Safety\n' +
  '\n' +
  'Выбери город и жми кнопку ↓ / Pick your city and tap the button ↓'

const BUTTON_TEXT = 'Открыть TAMITUT · Open TAMITUT'

const replyMarkup = (text: string) => ({
  inline_keyboard: [[{ text, web_app: { url: TMA_URL } }]]
})

Deno.serve(async (request: Request) => {
  if (request.method !== 'POST') return new Response('ok', { status: 200 })
  if (!BOT_TOKEN || !TMA_URL) {
    console.error('telegram-bot not configured: missing TELEGRAM_BOT_TOKEN or TMA_URL')
    return new Response('ok', { status: 200 })
  }

  // Telegram signs every webhook delivery with the secret_token from setWebhook.
  // Reject anything else so forged updates cannot spam users.
  if (!WEBHOOK_SECRET || request.headers.get('x-telegram-bot-api-secret-token') !== WEBHOOK_SECRET) {
    return new Response('forbidden', { status: 403 })
  }

  let update: { message?: { chat?: { id?: number }; text?: string; from?: { language_code?: string } } }
  try {
    update = await request.json()
  } catch {
    return new Response('ok', { status: 200 })
  }

  const chatId = update.message?.chat?.id
  const text = update.message?.text ?? ''
  if (!chatId) return new Response('ok', { status: 200 })

  try {
    await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: chatId,
        text: WELCOME,
        reply_markup: replyMarkup(BUTTON_TEXT)
      })
    })
  } catch (error) {
    console.error('sendMessage failed', error)
  }

  return new Response('ok', { status: 200 })
})
