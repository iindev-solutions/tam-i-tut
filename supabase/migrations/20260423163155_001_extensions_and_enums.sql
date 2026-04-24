-- Migration: 001_extensions_and_enums
-- Purpose: Create pgcrypto extension and all enum types
-- Source Plan: vault/wiki/architecture/supabase-migration-file-plan.md
-- Source Contract: vault/wiki/architecture/supabase-schema-rls-plan.md

create extension if not exists pgcrypto;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'app_role') THEN
		CREATE TYPE public.app_role AS ENUM ('user', 'curator', 'moderator', 'admin', 'trusted_source');
	END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'language_code') THEN
		CREATE TYPE public.language_code AS ENUM ('ru', 'en');
	END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'category_slug') THEN
		CREATE TYPE public.category_slug AS ENUM ('housing', 'transport', 'money', 'food', 'events', 'safety');
	END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'trust_badge') THEN
		CREATE TYPE public.trust_badge AS ENUM ('under_review', 'recommended_expats', 'verified_team');
	END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'entry_status') THEN
		CREATE TYPE public.entry_status AS ENUM ('draft', 'published', 'archived');
	END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'evidence_type') THEN
		CREATE TYPE public.evidence_type AS ENUM ('team_check', 'photo', 'document', 'trusted_confirmation', 'external_reference');
	END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'suggestion_status') THEN
		CREATE TYPE public.suggestion_status AS ENUM ('new', 'triaged', 'accepted', 'rejected', 'merged');
	END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'safety_case_status') THEN
		CREATE TYPE public.safety_case_status AS ENUM ('under_review', 'published', 'retracted');
	END IF;
END$$;

DO $$
BEGIN
	IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'trust_reason_code') THEN
		CREATE TYPE public.trust_reason_code AS ENUM (
			'initial_publish',
			'evidence_threshold_met',
			'team_verified',
			'evidence_revoked',
			'periodic_recheck_failed',
			'dispute_opened',
			'dispute_resolved',
			'manual_moderation'
		);
	END IF;
END$$;
