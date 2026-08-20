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

const WELCOME_RU =
  '🇻🇳 Привет! Это TAMITUT — гид для первых недель в новом городе 🏖️\n\n' +
  '🏠 Жильё • 🍜 Еда • 🛵 Транспорт • 💰 Деньги • 🛡️ Безопасность\n\n' +
  'Выбери город в приложении и нажми кнопку ниже ✨'
const WELCOME_EN =
  '🇻🇳 Hi! This is TAMITUT — a guide for your first weeks in a new city 🏖️\n\n' +
  '🏠 Housing • 🍜 Food • 🛵 Transport • 💰 Money • 🛡️ Safety\n\n' +
  'Pick your city in the app and tap the button below ✨'

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

  const lang = update.message?.from?.language_code === 'en' ? 'en' : 'ru'
  const welcome = lang === 'en' ? WELCOME_EN : WELCOME_RU
  const buttonText = lang === 'en' ? 'Open TAMITUT' : 'Открыть TAMITUT'

  try {
    await fetch(`https://api.telegram.org/bot${BOT_TOKEN}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: chatId,
        text: welcome,
        reply_markup: replyMarkup(buttonText)
      })
    })
  } catch (error) {
    console.error('sendMessage failed', error)
  }

  return new Response('ok', { status: 200 })
})
