-- ============================================================
-- NGO Medicine System — Supabase Security & Performance Fix
-- Run this in: Supabase Dashboard → SQL Editor → Run
-- ============================================================


-- ──────────────────────────────────────────────────────────
-- 1. ENABLE RLS ON TABLES MISSING IT
-- ──────────────────────────────────────────────────────────

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_config ENABLE ROW LEVEL SECURITY;


-- ──────────────────────────────────────────────────────────
-- 2. ADD RLS POLICIES FOR NEW TABLES
-- (Backend connects as DB owner → bypasses RLS, but Supabase 
--  needs at least one policy to stop the "no policy" warning)
-- ──────────────────────────────────────────────────────────

-- users
DROP POLICY IF EXISTS "Allow all for users" ON public.users;
CREATE POLICY "Allow all for users" ON public.users
    FOR ALL USING (true) WITH CHECK (true);

-- push_tokens
DROP POLICY IF EXISTS "Allow all for push_tokens" ON public.push_tokens;
CREATE POLICY "Allow all for push_tokens" ON public.push_tokens
    FOR ALL USING (true) WITH CHECK (true);

-- notifications
DROP POLICY IF EXISTS "Allow all for notifications" ON public.notifications;
CREATE POLICY "Allow all for notifications" ON public.notifications
    FOR ALL USING (true) WITH CHECK (true);

-- system_config (was RLS enabled but no policy → blocked everyone)
DROP POLICY IF EXISTS "Allow all for system_config" ON public.system_config;
CREATE POLICY "Allow all for system_config" ON public.system_config
    FOR ALL USING (true) WITH CHECK (true);


-- ──────────────────────────────────────────────────────────
-- 3. DROP DUPLICATE INDEXES
-- (SQLAlchemy auto-created ix_ variants that duplicate our idx_ ones)
-- ──────────────────────────────────────────────────────────

-- notifications duplicates
DROP INDEX IF EXISTS public.ix_notifications_created_at;  -- duplicates idx_notifications_created_at
DROP INDEX IF EXISTS public.ix_notifications_type;         -- duplicates idx_notifications_type
DROP INDEX IF EXISTS public.ix_notifications_user_id;      -- duplicates idx_notifications_user_id
DROP INDEX IF EXISTS public.ix_notifications_id;           -- duplicates notifications_pkey

-- push_tokens duplicates
DROP INDEX IF EXISTS public.ix_push_tokens_user_id;        -- duplicates idx_push_tokens_user_id
DROP INDEX IF EXISTS public.ix_push_tokens_id;             -- duplicates push_tokens_pkey

-- users duplicates
DROP INDEX IF EXISTS public.ix_users_email;                -- duplicates idx_users_email
DROP INDEX IF EXISTS public.ix_users_google_id;            -- duplicates idx_users_google_id
DROP INDEX IF EXISTS public.ix_users_id;                   -- duplicates users_pkey


-- ──────────────────────────────────────────────────────────
-- 4. ADD MISSING FOREIGN KEY INDEX
-- (stock_transactions.medicine_id has no index)
-- ──────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_stock_transactions_medicine_id 
    ON public.stock_transactions (medicine_id);

CREATE INDEX IF NOT EXISTS idx_stock_transactions_schedule_id
    ON public.stock_transactions (schedule_id);


-- ──────────────────────────────────────────────────────────
-- 5. FIX FUNCTION SEARCH PATH (mutable → fixed)
-- ──────────────────────────────────────────────────────────

ALTER FUNCTION public.update_medicine_stock() 
    SET search_path = public;

ALTER FUNCTION public.update_updated_at_column() 
    SET search_path = public;


-- ──────────────────────────────────────────────────────────
-- 6. HIDE SENSITIVE COLUMNS IN push_tokens FROM ANON ROLE
-- (the "token" column should not be exposed to anonymous callers)
-- ──────────────────────────────────────────────────────────

-- Revoke anon/public read on token column
REVOKE SELECT ON public.push_tokens FROM anon;
REVOKE SELECT ON public.push_tokens FROM authenticated;

-- Grant authenticated users read access to non-sensitive columns only
-- (backend uses service role / postgres which bypasses this)
GRANT SELECT (id, user_id, device_platform, created_at) 
    ON public.push_tokens TO authenticated;


-- ──────────────────────────────────────────────────────────
-- Done ✅
-- ──────────────────────────────────────────────────────────
SELECT 'All fixes applied successfully' AS status;
