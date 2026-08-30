-- Migration: 048_health_category_step2
-- Purpose: step 2 (separate transaction - PG forbids using a just-added enum
-- value in the same one). Registers the health category row and moves the
-- four medical guides from safety to health. Frontend: /categories/health.

insert into public.categories (slug, title_ru, title_en, sort_order, is_active)
values ('health', 'Медицина', 'Health', 7, true)
on conflict (slug) do update
set title_ru = excluded.title_ru, title_en = excluded.title_en,
	sort_order = excluded.sort_order, is_active = excluded.is_active;

update public.categories set sort_order = 8 where slug = 'events';

update public.guide_entries set category_slug = 'health'
where slug in ('safety-hospitals', 'safety-pharmacies', 'safety-insurance', 'safety-dentist');

update public.guide_entries set slug = replace(slug, 'safety-', 'health-')
where category_slug = 'health';
