-- Migration: 002_profiles_and_categories
-- Purpose: Create profiles/categories and seed six category rows
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create table if not exists public.profiles (
	id uuid primary key references auth.users (id) on delete cascade,
	role public.app_role not null default 'user',
	display_name text,
	telegram_user_id bigint unique,
	locale public.language_code not null default 'ru',
	is_active boolean not null default true,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint profiles_telegram_user_id_positive check (telegram_user_id is null or telegram_user_id > 0)
);

create table if not exists public.categories (
	slug public.category_slug primary key,
	title_ru text not null,
	title_en text not null,
	sort_order smallint not null unique,
	is_active boolean not null default true,
	created_at timestamptz not null default now(),
	constraint categories_sort_order_positive check (sort_order > 0)
);

insert into public.categories (slug, title_ru, title_en, sort_order, is_active)
values
	('housing', 'Жильё', 'Housing', 1, true),
	('transport', 'Транспорт', 'Transport', 2, true),
	('money', 'Деньги', 'Money', 3, true),
	('food', 'Еда и кафе', 'Food & Cafes', 4, true),
	('events', 'Афиша', 'Events', 5, true),
	('safety', 'Безопасность', 'Safety', 6, true)
on conflict (slug) do update
set
	title_ru = excluded.title_ru,
	title_en = excluded.title_en,
	sort_order = excluded.sort_order,
	is_active = excluded.is_active;
