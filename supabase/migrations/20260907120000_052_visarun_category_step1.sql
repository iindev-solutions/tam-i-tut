-- Migration: 052_visarun_category_step1
-- Purpose: step 1 of the visa-run category split (founder request): the guide
-- gets its own category instead of living under transport. PG forbids using a
-- just-added enum value in the same transaction (047 gotcha), so the type
-- change is its own migration.

alter type public.category_slug add value if not exists 'visarun';
