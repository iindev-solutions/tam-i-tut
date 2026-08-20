# Deploy Runbook - Telegram Mini App Production

Order matters. Everything below is one-time unless noted.

## 1. Rotate the bot token (SECURITY, FIRST)

The original token was shared in a chat. In @BotFather: `/mybots` -> select bot -> API Token -> Revoke. Put the new value into `.env` (gitignored, repo root) and nowhere else.

## 2. Supabase project

1. Create the project (any region close to VN users, e.g. Singapore).
2. Apply migrations: `supabase db push` (or SQL editor in order). Migration `021` creates the `telegram_bootstrap_nonces` replay-protection table.
3. Set the function secret:
   `supabase secrets set TELEGRAM_BOT_TOKEN=<new-token>`
   (`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are injected by the platform.)
4. Deploy the function: `supabase functions deploy telegram-bootstrap`
5. Verify: `supabase functions logs telegram-bootstrap` - a request with garbage initData must return 401 `malformed`/`bad_signature`.

## 3. Frontend hosting

The app is a SPA (`ssr: false`), any static host works:

- `npm run build` -> host `.output/public` (Cloudflare Pages / Netlify / Vercel), or
- run the Node server: `node .output/server/index.mjs` (needs a process manager).

Environment variables for the frontend (set in the host dashboard):

- `NUXT_PUBLIC_APP_NAME=TAMITUT`
- `NUXT_PUBLIC_SUPABASE_URL=https://<project>.supabase.co`
- `NUXT_PUBLIC_SUPABASE_ANON_KEY=<anon key>`

HTTPS is mandatory (Telegram requirement); all mainstream hosts provide it.

## 4. Wire the Mini App in Telegram

1. A public HTTPS domain is required: BotFather does not accept raw IPs or localhost. For quick verification, any tunnel with a stable hostname works, but production needs the real domain.
2. In @BotFather: `/newapp` (or Bot Settings -> Menu Button) -> paste the app URL.
3. Set the menu button so users can open the TMA from the bot screen.

## 5. Smoke checklist after deploy

- App opens from Telegram; native BackButton appears on inner pages and returns to home.
- DevTools badge absent (devtools disabled).
- `curl -sI https://<domain>/` shows `x-content-type-options`, `referrer-policy`, `permissions-policy`.
- `telegram-bootstrap` logs show 200s with fresh initData; replaying the same initData returns 401 `replay`.
- Map tiles load (CARTO), district sheet opens by polygon tap.

## 6. Content operations

- Supabase Studio remains the pilot admin surface; the `/admin` route is a UI demo of the editorial workflow, not an access-controlled surface - do not link it publicly.
- Seed content lives in `frontend/app/mocks/db.ts` and `mocks/housing.ts` as the schema-v2 contract; migrate to tables when schema v2 is approved.

## 7. Backups (before real user data)

Add the off-site backup runbook (database + Storage) per sprint task 5.10 - not done yet, block real user content until it exists.
