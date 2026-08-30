-- Migration: 047_health_category_step1
-- Purpose: founder call - medicine is its own category, not a Safety subtopic.
-- Step 1 (separate push): add the enum value and the categories row. The new
-- enum value is used by migration 048 in a later transaction (PG forbids
-- using a just-added enum value in the same one).

alter type public.category_slug add value if not exists 'health' after 'food';


