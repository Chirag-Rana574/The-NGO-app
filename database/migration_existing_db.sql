-- Migration Script: Existing Database to Patients/Workers Separation
-- Run this if you already have the old schema with workers table for patients
-- This script will migrate your existing data to the new structure

-- Step 1: Create the new patients table
CREATE TABLE IF NOT EXISTS patients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Step 2: Migrate existing workers data to patients
-- (Assuming your old workers table was used for patients)
INSERT INTO patients (id, name, is_active, created_at)
SELECT id, name, is_active, created_at
FROM workers
ON CONFLICT (id) DO NOTHING;

-- Step 3: Create a new workers_new table with the correct schema
CREATE TABLE IF NOT EXISTS workers_new (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    mobile_number VARCHAR(20) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Step 4: If you have actual worker data, migrate it
-- NOTE: You'll need to manually add mobile numbers for workers
-- Example:
-- INSERT INTO workers_new (name, mobile_number) VALUES
-- ('Alice Brown', '+1 (555) 123-4567'),
-- ('Bob Wilson', '+1 (555) 987-6543');

-- Step 5: Add patient_id column to schedules
ALTER TABLE schedules 
ADD COLUMN IF NOT EXISTS patient_id INTEGER;

-- Step 6: Migrate existing schedule data
-- Assuming old schedules.worker_id was actually the patient
UPDATE schedules 
SET patient_id = worker_id 
WHERE patient_id IS NULL;

-- Step 7: Set patient_id as NOT NULL and add foreign key
ALTER TABLE schedules 
ALTER COLUMN patient_id SET NOT NULL;

ALTER TABLE schedules
ADD CONSTRAINT schedules_patient_id_fkey 
FOREIGN KEY (patient_id) REFERENCES patients(id);

-- Step 8: Update schedules to reference new workers table
-- First, you need to populate workers_new with actual worker data
-- Then update worker_id in schedules to reference the new workers

-- Step 9: Drop old workers table and rename workers_new
DROP TABLE IF EXISTS workers CASCADE;
ALTER TABLE workers_new RENAME TO workers;

-- Step 10: Re-add foreign key for worker_id in schedules
ALTER TABLE schedules
ADD CONSTRAINT schedules_worker_id_fkey 
FOREIGN KEY (worker_id) REFERENCES workers(id);

-- Step 11: Update schedules table columns
ALTER TABLE schedules 
ALTER COLUMN status SET DEFAULT 'CREATED';

ALTER TABLE schedules 
ADD COLUMN IF NOT EXISTS response_received_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE schedules 
ADD COLUMN IF NOT EXISTS response_message TEXT;

ALTER TABLE schedules 
ADD COLUMN IF NOT EXISTS is_overridden BOOLEAN DEFAULT false NOT NULL;

ALTER TABLE schedules 
ADD COLUMN IF NOT EXISTS override_reason TEXT;

ALTER TABLE schedules 
ADD COLUMN IF NOT EXISTS override_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE schedules 
ADD COLUMN IF NOT EXISTS twilio_message_sid VARCHAR(255) UNIQUE;

ALTER TABLE schedules 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;

-- Step 12: Update medicines table
ALTER TABLE medicines 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE;

-- Step 13: Rename stock_adjustments to stock_transactions if needed
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'stock_adjustments') THEN
        ALTER TABLE stock_adjustments RENAME TO stock_transactions;
        ALTER TABLE stock_transactions RENAME COLUMN amount TO change_amount;
        ALTER TABLE stock_transactions ADD COLUMN IF NOT EXISTS reason VARCHAR(50) NOT NULL DEFAULT 'MANUAL';
    END IF;
END $$;

-- Step 14: Update audit_logs table
ALTER TABLE audit_logs 
ADD COLUMN IF NOT EXISTS old_value TEXT;

ALTER TABLE audit_logs 
ADD COLUMN IF NOT EXISTS new_value TEXT;

ALTER TABLE audit_logs 
ADD COLUMN IF NOT EXISTS reason TEXT;

ALTER TABLE audit_logs 
RENAME COLUMN created_by TO performed_by;

-- Step 15: Create indexes
CREATE INDEX IF NOT EXISTS idx_patients_active ON patients(is_active) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_patients_deleted ON patients(deleted_at);

CREATE INDEX IF NOT EXISTS idx_workers_active ON workers(is_active) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_workers_mobile ON workers(mobile_number);
CREATE INDEX IF NOT EXISTS idx_workers_deleted ON workers(deleted_at);

CREATE INDEX IF NOT EXISTS idx_medicines_deleted ON medicines(deleted_at);

CREATE INDEX IF NOT EXISTS idx_schedules_patient ON schedules(patient_id);
CREATE INDEX IF NOT EXISTS idx_schedules_deleted ON schedules(deleted_at);

-- Step 16: Create/Update triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_patients_updated_at ON patients;
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_workers_updated_at ON workers;
CREATE TRIGGER update_workers_updated_at BEFORE UPDATE ON workers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Step 17: Update stock trigger
CREATE OR REPLACE FUNCTION update_medicine_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE medicines
    SET current_stock = current_stock + NEW.change_amount
    WHERE id = NEW.medicine_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS stock_adjustment_trigger ON stock_transactions;
DROP TRIGGER IF EXISTS stock_transaction_trigger ON stock_transactions;
CREATE TRIGGER stock_transaction_trigger AFTER INSERT ON stock_transactions
    FOR EACH ROW EXECUTE FUNCTION update_medicine_stock();

-- Migration complete!
-- IMPORTANT: You need to manually populate the workers_new table with actual worker data
-- before running steps 8-9, or you can do it after and update schedules.worker_id manually.
