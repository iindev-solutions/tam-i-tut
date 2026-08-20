# Housing Map - How to Change Things

The housing page (`frontend/app/pages/categories/housing.vue`) has two tabs:

- **Guide** (`housing.tabs.info`): three how-to-rent cards plus a district price list. Tapping a district row selects it and switches to the Map tab.
- **Map** (`housing.tabs.map`): a real tile map (`HousingTileMap.client.vue`, Leaflet) with district polygons, permanent district labels, quick-pick chips, and the selected-district rent card.

## Change district data (names, rents, notes)

Districts live in `frontend/app/mocks/housing.ts` as a GeoJSON-like `FeatureCollection`. One feature = one district:

- `properties.id` - stable slug (`son-tra`, `hai-chau`, ...) used by chips, the admin districts table, and selection state.
- `properties.label`, `area`, `distance`, `rent`, `summary`, `priceRange`, `bestFor` - i18n keys, not literal text.
- Copy for those keys lives in `frontend/i18n/locales/ru.json` and `en.json` under `housing.districts.<district>` and `housing.priceRanges` / `housing.keyPoints`.

To add a district: append a feature (with polygon `coordinates` as `[longitude, latitude]` pairs), add its locale keys in both languages, and it appears everywhere automatically (map, chips, info list, admin table).

## Change district geometry

Edit the `geometry.coordinates` ring in `mocks/housing.ts`. Coordinates are `[lon, lat]` (GeoJSON order). Current polygons are schematic but positioned like the real city; the visible disclaimer (`housing.mapDisclaimer`) stays until official boundary GeoJSON replaces them.

## Change the map imagery (tiles)

In `frontend/app/components/HousingTileMap.client.vue`:

- `TILE_URLS.light` - CARTO Voyager raster tiles (light theme).
- `TILE_URLS.dark` - CARTO Dark Matter raster tiles (dark theme).
- `ATTRIBUTION` - must stay when swapping providers.
- The tile set swaps automatically with the app color mode; changing providers means editing these two constants (keep `{s}` subdomain support or drop `subdomains`).
- Alternatives if CARTO is ever unavailable: raw OSM tiles `https://tile.openstreetmap.org/{z}/{x}/{y}.png` (light only, respect usage policy), or self-hosted tiles.

## Change polygon/label styling

Same file: `BASE_STYLE`, `HOVER_STYLE`, `SELECTED_STYLE` (orange selection), and the `.housing-district-label` CSS class for the permanent labels.

## Map behavior notes

- `scrollWheelZoom: false` - the map does not hijack page scroll; pinch and zoom buttons work.
- The map fits all district bounds on mount.
- Selection state is shared with the chips and the Guide tab list.

## Telegram Mini App back button

`frontend/app/plugins/telegram.client.ts` syncs the native Telegram `BackButton`: hidden on `/`, shown elsewhere, tap goes back through vue-router (falls back to `/` on deep links). The official bridge script loads via `nuxt.config.ts` `app.head.script`. Outside Telegram it is a no-op; in a plain browser the header back arrow serves the same purpose.
