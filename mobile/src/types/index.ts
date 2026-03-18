export interface Patient {
    id: number;
    name: string;
    is_active: boolean;
    created_at: string;
}

export interface Worker {
    id: number;
    name: string;
    mobile_number: string;
    is_active: boolean;
    created_at: string;
}

export interface Medicine {
    id: number;
    name: string;
    description?: string;
    dosage_unit: string;
    current_stock: number;
    min_stock_level: number;
    is_active: boolean;
    created_at: string;
}

export enum ScheduleStatus {
    CREATED = 'CREATED',
    REMINDER_SENT = 'REMINDER_SENT',
    AWAITING_RESPONSE = 'AWAITING_RESPONSE',
    COMPLETED = 'COMPLETED',
    NOT_DONE = 'NOT_DONE',
    LATE_COMPLETED = 'LATE_COMPLETED',
    EXPIRED = 'EXPIRED',
}

export interface Schedule {
    id: number;
    patient_id: number;
    worker_id: number;
    medicine_id: number;
    scheduled_time: string;
    status: ScheduleStatus;
    dose_amount: number;
    response_received_at?: string;
    response_message?: string;
    is_overridden: boolean;
    override_reason?: string;
    created_at: string;
    patient: Patient;
    worker: Worker;
    medicine: Medicine;
}

export interface StockTransaction {
    id: number;
    medicine_id: number;
    change_amount: number;
    reason: string;
    reference_schedule_id?: number;
    notes?: string;
    created_by?: string;
    created_at: string;
}

export interface AuditLog {
    id: number;
    entity_type: string;
    entity_id: number;
    action: string;
    old_value?: string;
    new_value?: string;
    reason?: string;
    performed_by?: string;
    created_at: string;
}
