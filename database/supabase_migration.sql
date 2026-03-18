-- NGO Medicine System - Updated Database Schema
-- This script creates separate tables for Patients and Workers

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing tables (DEVELOPMENT ONLY - comment out for production)
DROP TABLE IF EXISTS schedules CASCADE;
DROP TABLE IF EXISTS stock_adjustments CASCADE;
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS workers CASCADE;
DROP TABLE IF EXISTS medicines CASCADE;

-- Patients Table (name only)
CREATE TABLE patients (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Workers Table (healthcare staff with mobile numbers)
CREATE TABLE workers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    mobile_number VARCHAR(50) NOT NULL,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Medicines Table
CREATE TABLE medicines (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    dosage_unit VARCHAR(50) NOT NULL,
    current_stock INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Stock Adjustments Table
CREATE TABLE stock_adjustments (
    id SERIAL PRIMARY KEY,
    medicine_id INTEGER REFERENCES medicines(id),
    amount INTEGER NOT NULL,
    notes TEXT,
    created_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Schedules Table (links Patient + Worker + Medicine)
CREATE TABLE schedules (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER REFERENCES patients(id),
    worker_id INTEGER REFERENCES workers(id),
    medicine_id INTEGER REFERENCES medicines(id),
    scheduled_time TIMESTAMP NOT NULL,
    dose_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit Logs Table
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INTEGER NOT NULL,
    action VARCHAR(50) NOT NULL,
    notes TEXT,
    created_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_patients_active ON patients(active);
CREATE INDEX idx_workers_active ON workers(active);
CREATE INDEX idx_medicines_active ON medicines(active);
CREATE INDEX idx_schedules_patient ON schedules(patient_id);
CREATE INDEX idx_schedules_worker ON schedules(worker_id);
CREATE INDEX idx_schedules_medicine ON schedules(medicine_id);
CREATE INDEX idx_schedules_time ON schedules(scheduled_time);
CREATE INDEX idx_schedules_status ON schedules(status);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_stock_medicine ON stock_adjustments(medicine_id);

-- Create trigger function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to tables
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workers_updated_at BEFORE UPDATE ON workers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_medicines_updated_at BEFORE UPDATE ON medicines
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_schedules_updated_at BEFORE UPDATE ON schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to update medicine stock when adjustment is made
CREATE OR REPLACE FUNCTION update_medicine_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE medicines
    SET current_stock = current_stock + NEW.amount
    WHERE id = NEW.medicine_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER stock_adjustment_trigger AFTER INSERT ON stock_adjustments
    FOR EACH ROW EXECUTE FUNCTION update_medicine_stock();

-- Insert Sample Data

-- Sample Patients (name only)
INSERT INTO patients (name) VALUES
('John Doe'),
('Jane Smith'),
('Robert Johnson'),
('Mary Williams'),
('James Brown');

-- Sample Workers (healthcare staff with mobile numbers)
INSERT INTO workers (name, mobile_number) VALUES
('Dr. Sarah Wilson', '+1 (555) 111-2222'),
('Nurse Emily Brown', '+1 (555) 333-4444'),
('Dr. Michael Chen', '+1 (555) 555-6666'),
('Nurse David Lee', '+1 (555) 777-8888');

-- Sample Medicines
INSERT INTO medicines (name, description, dosage_unit, current_stock) VALUES
('Aspirin', 'Pain reliever and fever reducer', 'tablets', 100),
('Ibuprofen', 'Anti-inflammatory medication', 'tablets', 75),
('Paracetamol', 'Pain and fever medication', 'tablets', 8),
('Amoxicillin', 'Antibiotic', 'capsules', 50);

-- Sample Schedules (Patient receives medicine, Worker administers it)
INSERT INTO schedules (patient_id, worker_id, medicine_id, scheduled_time, dose_amount, status) VALUES
(1, 1, 1, '2026-02-16 09:00:00', 2, 'pending'),
(2, 2, 2, '2026-02-16 14:00:00', 1, 'pending'),
(3, 3, 3, '2026-02-18 10:00:00', 2, 'pending'),
(4, 1, 4, '2026-02-17 11:00:00', 1, 'pending');

-- Verify data
SELECT 'Patients' as table_name, COUNT(*) as count FROM patients
UNION ALL
SELECT 'Workers', COUNT(*) FROM workers
UNION ALL
SELECT 'Medicines', COUNT(*) FROM medicines
UNION ALL
SELECT 'Schedules', COUNT(*) FROM schedules;
