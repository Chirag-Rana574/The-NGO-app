# Supabase Setup Guide

This guide will help you set up Supabase as the database for your NGO Medicine Administration System.

## Prerequisites

- Supabase account (sign up at [supabase.com](https://supabase.com))
- Backend code already set up

## Step 1: Create a Supabase Project

1. Go to [https://supabase.com/dashboard](https://supabase.com/dashboard)
2. Click "New Project"
3. Fill in the details:
   - **Name**: `ngo-medicine-system`
   - **Database Password**: Choose a strong password (save this!)
   - **Region**: Select closest to your users
4. Click "Create new project"
5. Wait 2-3 minutes for setup to complete

## Step 2: Get Your Connection Details

Once your project is ready:

1. Go to **Settings** → **Database**
2. Scroll to **Connection String** section
3. Copy the **URI** (it looks like: `postgresql://postgres:[YOUR-PASSWORD]@db.xxx.supabase.co:5432/postgres`)
4. Replace `[YOUR-PASSWORD]` with your actual database password

## Step 3: Create Database Schema

1. Go to **SQL Editor** in your Supabase dashboard
2. Click "New Query"
3. Copy and paste the schema below
4. Click "Run" to execute

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Patients Table (name only)
CREATE TABLE patients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Workers Table (name + mobile_number)
CREATE TABLE workers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    mobile_number VARCHAR(20) UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Medicines Table
CREATE TABLE medicines (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    dosage_unit VARCHAR(50) NOT NULL,
    current_stock INTEGER DEFAULT 0 NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Schedules Table (links patient, worker, and medicine)
CREATE TABLE schedules (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER REFERENCES patients(id) NOT NULL,
    worker_id INTEGER REFERENCES workers(id) NOT NULL,
    medicine_id INTEGER REFERENCES medicines(id) NOT NULL,
    scheduled_time TIMESTAMP WITH TIME ZONE NOT NULL,
    status VARCHAR(50) DEFAULT 'CREATED' NOT NULL,
    dose_amount INTEGER DEFAULT 1 NOT NULL,
    response_received_at TIMESTAMP WITH TIME ZONE,
    response_message TEXT,
    is_overridden BOOLEAN DEFAULT false NOT NULL,
    override_reason TEXT,
    override_at TIMESTAMP WITH TIME ZONE,
    twilio_message_sid VARCHAR(255) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Stock Transactions Table
CREATE TABLE stock_transactions (
    id SERIAL PRIMARY KEY,
    medicine_id INTEGER REFERENCES medicines(id) NOT NULL,
    change_amount INTEGER NOT NULL,
    reason VARCHAR(50) NOT NULL,
    reference_schedule_id INTEGER REFERENCES schedules(id),
    notes TEXT,
    created_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Audit Logs Table
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INTEGER NOT NULL,
    action VARCHAR(50) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    reason TEXT,
    performed_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Create indexes for better performance
CREATE INDEX idx_patients_active ON patients(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_patients_deleted ON patients(deleted_at);

CREATE INDEX idx_workers_active ON workers(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_workers_mobile ON workers(mobile_number);
CREATE INDEX idx_workers_deleted ON workers(deleted_at);

CREATE INDEX idx_medicines_active ON medicines(is_active) WHERE deleted_at IS NULL;
CREATE INDEX idx_medicines_deleted ON medicines(deleted_at);

CREATE INDEX idx_schedules_patient ON schedules(patient_id);
CREATE INDEX idx_schedules_worker ON schedules(worker_id);
CREATE INDEX idx_schedules_medicine ON schedules(medicine_id);
CREATE INDEX idx_schedules_time ON schedules(scheduled_time);
CREATE INDEX idx_schedules_status ON schedules(status);
CREATE INDEX idx_schedules_deleted ON schedules(deleted_at);

CREATE INDEX idx_stock_medicine ON stock_transactions(medicine_id);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workers_updated_at BEFORE UPDATE ON workers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medicines_updated_at BEFORE UPDATE ON medicines
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to update medicine stock when transaction is created
CREATE OR REPLACE FUNCTION update_medicine_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE medicines
    SET current_stock = current_stock + NEW.change_amount
    WHERE id = NEW.medicine_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER stock_transaction_trigger AFTER INSERT ON stock_transactions
    FOR EACH ROW EXECUTE FUNCTION update_medicine_stock();
```

## Step 4: Insert Sample Data (Optional)

To test your setup, insert some sample data:

```sql
-- Sample Workers (Patients)
INSERT INTO workers (name, phone_number) VALUES
('John Doe', '+1 (555) 123-4567'),
('Jane Smith', '+1 (555) 987-6543'),
('Robert Johnson', '+1 (555) 456-7890');

-- Sample Medicines
INSERT INTO medicines (name, description, dosage_unit, current_stock) VALUES
('Aspirin', 'Pain reliever and fever reducer', 'tablets', 100),
('Ibuprofen', 'Anti-inflammatory medication', 'tablets', 75),
('Paracetamol', 'Pain and fever medication', 'tablets', 8);

-- Sample Schedule
INSERT INTO schedules (worker_id, medicine_id, scheduled_time, dose_amount, status) VALUES
(1, 1, '2026-02-16 09:00:00', 2, 'pending'),
(2, 2, '2026-02-16 14:00:00', 1, 'pending'),
(3, 3, '2026-02-18 10:00:00', 2, 'pending');
```

## Step 5: Configure Backend Environment

1. Open your backend `.env` file
2. Update the database URL:

```env
# Database
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.xxx.supabase.co:5432/postgres

# Medicine Management Passkey
MEDICINE_PASSKEY=1234

# Twilio (optional - for SMS notifications)
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=your_twilio_number

# Security
SECRET_KEY=your-secret-key-here
```

**Important**: Replace `[YOUR-PASSWORD]` with your actual Supabase database password!

## Step 6: Update Backend Dependencies

Make sure your backend has the PostgreSQL adapter installed:

```bash
cd backend
pip install psycopg2-binary
```

## Step 7: Test the Connection

Start your backend server:

```bash
cd backend
uvicorn app.main:app --reload
```

Visit `http://localhost:8000/docs` to see the API documentation and test endpoints.

## Step 8: Enable Row Level Security (Optional but Recommended)

For production, enable RLS in Supabase:

1. Go to **Authentication** → **Policies**
2. For each table, click "Enable RLS"
3. Create policies based on your authentication needs

Example policy for read access:

```sql
CREATE POLICY "Enable read access for all users" ON workers
FOR SELECT USING (true);
```

## Step 9: Set Up Realtime (Optional)

To enable realtime updates:

1. Go to **Database** → **Replication**
2. Enable replication for tables you want to sync in realtime
3. Update your frontend to use Supabase client for realtime subscriptions

## Troubleshooting

### Connection Issues

If you can't connect:
- Verify your database password is correct
- Check that your IP is allowed (Supabase allows all IPs by default)
- Ensure the connection string format is correct

### Migration Issues

If tables aren't created:
- Check for SQL syntax errors in the query editor
- Ensure you have the correct permissions
- Try running each CREATE TABLE statement individually

### Performance Issues

- Add indexes for frequently queried columns
- Use connection pooling (already configured in FastAPI)
- Monitor query performance in Supabase dashboard

## Next Steps

1. ✅ Database is set up
2. ✅ Backend is connected
3. 🔄 Test all CRUD operations
4. 🔄 Verify audit logging works
5. 🔄 Test the mobile app with real data

## Useful Supabase Features

- **SQL Editor**: Run custom queries and view results
- **Table Editor**: Visual interface to view and edit data
- **Database**: Monitor performance and connections
- **API**: Auto-generated REST and GraphQL APIs (not used in this project)
- **Storage**: File storage (can be used for patient photos, etc.)

## Security Best Practices

1. **Never commit `.env` files** to version control
2. **Use strong passwords** for database access
3. **Enable RLS** for production deployments
4. **Rotate secrets regularly** (database password, API keys)
5. **Monitor audit logs** for suspicious activity
6. **Backup your database** regularly (Supabase does this automatically)

---

Your Supabase database is now ready! All patient, medicine, and schedule data will be stored securely in the cloud.
