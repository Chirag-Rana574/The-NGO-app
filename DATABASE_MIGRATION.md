# Database Migration Guide

## For Existing Databases

If you already set up your Supabase database with the old schema (where `workers` table was used for patients), follow this guide to migrate to the new structure.

## What's Changing

**Old Structure:**
- `workers` table contained patient data (with phone_number)
- Schedules linked to workers only

**New Structure:**
- `patients` table (name only)
- `workers` table (name + mobile_number)
- Schedules link patient + worker + medicine

## Migration Steps

### Step 1: Run the Migration Script

1. Open Supabase SQL Editor
2. Copy the contents of [`database/migration_existing_db.sql`](file:///Users/chiragrana/.gemini/antigravity/scratch/ngo-medicine-system/database/migration_existing_db.sql)
3. Paste into SQL Editor
4. Click "Run"

### Step 2: Add Worker Data

The migration script copies your old `workers` data to `patients`. Now you need to add actual worker data:

```sql
-- Add your workers (staff who administer medicine)
INSERT INTO workers (name, mobile_number) VALUES
('Alice Brown', '+1 (555) 123-4567'),
('Bob Wilson', '+1 (555) 987-6543'),
('Carol Davis', '+1 (555) 456-7890');
```

### Step 3: Update Existing Schedules

Update your existing schedules to reference the correct workers:

```sql
-- Example: Update all schedules to use worker ID 1
UPDATE schedules 
SET worker_id = 1 
WHERE worker_id IS NOT NULL;

-- Or update specific schedules:
UPDATE schedules 
SET worker_id = 2 
WHERE patient_id = 5;
```

### Step 4: Verify Migration

Check that everything migrated correctly:

```sql
-- Check patients
SELECT * FROM patients LIMIT 10;

-- Check workers  
SELECT * FROM workers LIMIT 10;

-- Check schedules have both patient_id and worker_id
SELECT 
    s.id,
    p.name as patient_name,
    w.name as worker_name,
    m.name as medicine_name
FROM schedules s
JOIN patients p ON s.patient_id = p.id
JOIN workers w ON s.worker_id = w.id
JOIN medicines m ON s.medicine_id = m.id
LIMIT 10;
```

## What the Migration Does

1. ✅ Creates `patients` table
2. ✅ Copies existing `workers` → `patients`
3. ✅ Creates new `workers` table with `mobile_number`
4. ✅ Adds `patient_id` to schedules
5. ✅ Updates all table structures
6. ✅ Creates proper indexes and triggers
7. ⚠️ **You must manually add worker data**
8. ⚠️ **You must update schedule worker_id references**

## Rollback (If Needed)

If something goes wrong, you can restore from Supabase's automatic backups:

1. Go to **Database** → **Backups**
2. Select a backup from before the migration
3. Click "Restore"

## Fresh Setup (Alternative)

If you prefer to start fresh instead of migrating:

1. Delete all tables in Supabase
2. Run [`database/supabase_migration.sql`](file:///Users/chiragrana/.gemini/antigravity/scratch/ngo-medicine-system/database/supabase_migration.sql) instead
3. This creates everything from scratch with sample data

## Need Help?

- Check the [SUPABASE_SETUP.md](file:///Users/chiragrana/.gemini/antigravity/scratch/ngo-medicine-system/SUPABASE_SETUP.md) for fresh setup instructions
- Review the [walkthrough](file:///Users/chiragrana/.gemini/antigravity/brain/72fb5d89-eadf-40e9-910f-3593c39e416a/walkthrough.md) for complete implementation details
