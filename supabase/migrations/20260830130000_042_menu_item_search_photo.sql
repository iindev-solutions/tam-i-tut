-- Migration: 042_menu_item_search_photo
-- Purpose: long-tail menu lines that match no dictionary dish get a
-- machine-picked photo (Commons candidates ranked by Gemini vision) so
-- every scanned line shows what the dish roughly looks like. Written only
-- by the menu-translate function (service role); curation can override.

alter table public.menu_items add column if not exists search_photo_url text;
