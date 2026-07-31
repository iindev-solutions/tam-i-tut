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

## Layout (mobile-first, 360px hard floor)

- `UContainer`, max width `max-w-2xl` on page content.
- No horizontal overflow at 360px - verify with browser check on every layout change.
- Header composition: `[logo][city select][RU/EN button][theme button]`; collapse widths by breakpoint (`w-28` -> `sm:w-48`, logo switches `w-12` -> full at 360px).
- Radius: `rounded-2xl` icons/buttons, `rounded-3xl` hero/cards. Shadow: `shadow-sm` max.

## Components

- Use Nuxt UI components as-is (`UCard`, `UButton`, `USelectMenu`, `UColorModeButton`). Custom classes only for surface/spacing/tokens.
- No dead affordances: remove search inputs, links, and buttons that do nothing. Informational cues stay static (no `href="#"`).
- Icons: Lucide via `i-lucide-*`. Category icons neutral (`text-muted`).

## States / behavior

- RU is default locale; EN is an explicit toggle in header (`setLocale`).
- Light/dark both must produce correct computed background+text; test both, not only the class switch.
- Unavailable cities: visible but `disabled`, with flag emoji and "Скоро/Coming soon".

## Motion

- Initial SPA boot loader: `app/spa-loading-template.html`, inline and dependency-free, uses the actual TAMITUT mark from `assets/brand/logo.svg`, with a soft pulse. It defaults to dark, follows OS light mode, and honors Nuxt's saved `nuxt-color-mode` before the bundle loads.
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
