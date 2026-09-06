-- Migration: 051_menu_section_title
-- Purpose: the Gemini contract returns grouped sections with title_vi, but
-- menu_items had nowhere to store them - the client rebuilt one flat list,
-- so long menus lost their structure. Nullable column: cached scans from
-- before this migration render as a single unnamed section.

alter table public.menu_items
	add column if not exists section_title text;
