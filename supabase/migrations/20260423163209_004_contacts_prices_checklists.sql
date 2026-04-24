-- Migration: 004_contacts_prices_checklists
-- Purpose: Create trusted_contacts, price_snapshots, checklist_items
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create table if not exists public.trusted_contacts (
	id uuid primary key default gen_random_uuid(),
	guide_entry_id uuid not null references public.guide_entries (id) on delete cascade,
	contact_type text not null,
	label text,
	value text not null,
	is_primary boolean not null default false,
	notes text,
	verified_at timestamptz,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint trusted_contacts_contact_type_allowed check (
		contact_type in ('phone', 'telegram', 'email', 'website', 'address', 'other')
	)
);

create table if not exists public.price_snapshots (
	id uuid primary key default gen_random_uuid(),
	category_slug public.category_slug not null references public.categories (slug),
	guide_entry_id uuid references public.guide_entries (id) on delete set null,
	district text,
	item_label text not null,
	currency_code char(3) not null default 'VND',
	min_price numeric(12,2) not null,
	max_price numeric(12,2) not null,
	typical_price numeric(12,2),
	unit_label text not null,
	captured_on date not null,
	source_note text not null,
	confidence_score numeric(3,2) not null default 0.50,
	verified_by_profile_id uuid references public.profiles (id),
	created_at timestamptz not null default now(),
	constraint price_snapshots_min_price_non_negative check (min_price >= 0),
	constraint price_snapshots_max_price_not_below_min check (max_price >= min_price),
	constraint price_snapshots_typical_price_in_range check (
		typical_price is null or (typical_price >= min_price and typical_price <= max_price)
	),
	constraint price_snapshots_confidence_score_range check (
		confidence_score >= 0 and confidence_score <= 1
	)
);

create table if not exists public.checklist_items (
	id uuid primary key default gen_random_uuid(),
	category_slug public.category_slug not null references public.categories (slug),
	guide_entry_id uuid references public.guide_entries (id) on delete cascade,
	language public.language_code not null default 'ru',
	position integer not null,
	item_text text not null,
	is_required boolean not null default false,
	created_by_profile_id uuid references public.profiles (id),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	constraint checklist_items_position_positive check (position > 0)
);
