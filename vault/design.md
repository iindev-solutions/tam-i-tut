# TAMITUT Design System

Single source of truth for TMA (Nuxt UI + Tailwind) visual decisions. Keep short; rules here are decisions already made in code, not aspirations.

## Principle

Monochrome first. Orange is a rare signal, not decoration density. If a screen feels busy - remove elements, not add styling.

## Colors

- Nuxt UI tokens: `primary: orange`, `neutral: zinc` (`frontend/app/app.config.ts`).
- Surfaces: `bg-white` light, `bg-gray-950` dark (`layouts/default.vue`, `AppHeader.vue`).
- Text: `text-gray-950` light, `text-white` dark.
- Orange allowed for:
  - one primary action per screen (link/button);
  - small trust cue icons;
  - one subtle decorative glow (`bg-primary/5`).
- Orange forbidden for: category icons (use `text-muted`), badges stacks, borders everywhere.

## Typography / copy

- Headings: short, one idea, no buzzwords.
- Never hardcode current city name in content - city lives only in the header selector.
- No "guide/гайд" repetition; one mention max per screen, prefer none.
- Dash character in user-facing copy and docs is `-` (hyphen), never long dash characters.
- Voice: concrete and calm - prices, places, steps. No adjectives like "лучший/легендарный".

## Layout (mobile-first, 340px hard floor)

- `UContainer`, max width `max-w-2xl` on page content.
- No horizontal overflow at 340px - verify with browser check on every layout change.
- Header composition: `[logo][city select][language][theme]`; the city trigger is a borderless ghost control with visible flag/name, the language control has a 36px target, and no horizontal overflow is allowed.
- Home hero: title with a large muted second line "in {city}" (same size as the title, no dropdown in the hero); city switching lives in the header only.
- Radius: `rounded-2xl` icons/buttons, `rounded-3xl` hero/cards. Shadow: `shadow-sm` max.

## Components

- Use Nuxt UI components as-is (`UCard`, `UButton`, `USelectMenu`, `UColorModeButton`). Custom classes only for surface/spacing/tokens.
- No dead affordances: remove search inputs, links, and buttons that do nothing. Informational cues stay static (no `href="#"`).
- Icons: Lucide via `i-lucide-*`. Category icons neutral (`text-muted`).
- Housing uses two `UTabs` tabs: Guide (sections + district price list) and Map (`HousingTileMap.client.vue`). The district list rows select a district and switch to the Map tab.
- The map is Leaflet with CARTO raster tiles (Voyager for light, Dark Matter for dark; tiles swap with color mode). District polygons come from `mocks/housing.ts` GeoJSON, get permanent labels, orange marks the selection, and `scrollWheelZoom` stays off so page scroll is never hijacked. Tile attribution is mandatory. The schematic-boundary disclaimer stays until official GeoJSON replaces the polygons. Details: `vault/wiki/services/housing-map.md`.
- Filter chips (food types): wrapped pill buttons, active state is `bg-elevated` + `text-highlighted`, never orange. No horizontal scroll strips in user-facing pages; card rows that would scroll use `UCarousel` (embla, arrows + dots, `basis-*` on item slot for per-view width).
- Bilingual mock content renders through `useLocalized().tt`; UI chrome stays on i18n keys.
- Navigation back: a slim "Назад" row under the header on every non-root route (history back with `/` fallback); the header itself never changes (logo always visible). Inside Telegram the native `BackButton` is synced by `plugins/telegram.client.ts`.
- District details open in a bottom `USlideover` sheet (`side="bottom"`, rounded top, `max-h-[78vh]`); closed overlay layers must never block input (global CSS guard on `[data-state="closed"]`).

## Admin prototype (`/admin`)

- Separate layout (`layouts/admin.vue`): sticky header with "TAMITUT Admin" wordmark, warning-toned "prototype - mock data" badge, horizontal-scrollable pill nav, "open app" link. No user header.
- Tables are `AdminTable.vue` (generic, cell slots): `rounded-2xl` border, uppercase muted headers, `min-w-[32rem]` with horizontal scroll on narrow screens - overflow scrolls, never squishes.
- Status is `StatusBadge.vue`: neutral for published/active/approved, warning for draft/pending/coming-soon, error for rejected. Orange stays out of admin chrome.
- Admin actions are small ghost buttons; icon-only actions require `aria-label`.
- Admin mutations affect user pages live within one SPA session; a full reload re-seeds the mock store.

## Errors

- `app/error.vue` is the only error surface: centered card, status code, bilingual copy, single primary "go home" action. No themed variants per error.

## States / behavior

- RU is default locale; EN is an explicit toggle in header (`setLocale`).
- Light/dark both must produce correct computed background+text; test both, not only the class switch.
- Unavailable cities: visible but `disabled`, with flag emoji and "Скоро/Coming soon".

## Motion

- Initial SPA boot loader: `app/spa-loading-template.html`. Nuxt mounts it outside `#__nuxt` as `#__nuxt-loader` (default `spaLoadingTemplateLocation: body`) and removes that node on `app:suspense:resolve`. Template renames the node, keeps the logo mark split across left/right panels, then curtains them open with the arrow halves. Finish hook: `plugins/spa-loader.client.ts`. Dark/light + reduced-motion preserved.
- Client-route loading bar: `NuxtLoadingIndicator` in `app.vue` using `--ui-primary`, height 2px.
- Page transitions: subtle opacity fade (`page-enter/leaving`, 120ms) on `NuxtPage`.
- Theme change transition: fade background/color on `html.dark` and layout (160ms), never animate transforms.
- Always respect `prefers-reduced-motion: reduce`: global rule kills animations and transitions.

## Verification checklist (before committing UI changes)

1. `npm run typecheck && npm run lint && npm run test && npm run build`
2. Browser smoke at 390px and 360px: no horizontal overflow.
3. RU/EN toggle changes text.
4. Dark and light computed colors are contrasting.
5. No dead interactive elements; no duplicated city/pilot wording.
