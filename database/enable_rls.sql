-- Row Level Security (RLS) Setup for NGO Medicine System
-- Run this in Supabase SQL Editor to enable RLS on all tables

-- ============================================================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE medicines ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- CREATE POLICIES (Permissive - Allow All for Now)
-- ============================================================================
-- Note: These policies allow all operations. In production, you should
-- restrict based on user roles and authentication.

-- Patients Policies
CREATE POLICY "Enable read access for all users" ON patients
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON patients
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON patients
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for all users" ON patients
    FOR DELETE USING (true);

-- Workers Policies
CREATE POLICY "Enable read access for all users" ON workers
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON workers
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON workers
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for all users" ON workers
    FOR DELETE USING (true);

-- Medicines Policies
CREATE POLICY "Enable read access for all users" ON medicines
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON medicines
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON medicines
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for all users" ON medicines
    FOR DELETE USING (true);

-- Schedules Policies
CREATE POLICY "Enable read access for all users" ON schedules
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON schedules
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON schedules
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for all users" ON schedules
    FOR DELETE USING (true);

-- Stock Transactions Policies
CREATE POLICY "Enable read access for all users" ON stock_transactions
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON stock_transactions
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON stock_transactions
    FOR UPDATE USING (true);

CREATE POLICY "Enable delete for all users" ON stock_transactions
    FOR DELETE USING (true);

-- Audit Logs Policies
CREATE POLICY "Enable read access for all users" ON audit_logs
    FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON audit_logs
    FOR INSERT WITH CHECK (true);

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Check RLS status for all tables
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Check policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd
FROM pg_policies
WHERE schemaname = 'public'
ORDER BY tablename, policyname;

-- ============================================================================
-- NOTES
-- ============================================================================
/*
RLS (Row Level Security) is now enabled on all tables.

CURRENT SETUP:
- All operations (SELECT, INSERT, UPDATE, DELETE) are allowed for all users
- This is suitable for development and internal use

PRODUCTION RECOMMENDATIONS:
1. Implement authentication (e.g., Supabase Auth, JWT)
2. Create user roles (admin, worker, readonly)
3. Restrict policies based on authenticated user
4. Example restrictive policy:
   
   CREATE POLICY "Workers can only see their own schedules" ON schedules
       FOR SELECT USING (auth.uid() = worker_id);

5. Audit logs should be INSERT-only for non-admins
6. Stock transactions should require admin role

For more info: https://supabase.com/docs/guides/auth/row-level-security
*/
