from pydantic import BaseModel, Field, field_validator
from datetime import datetime
import re
from typing import Optional
from .models import ScheduleStatus, TransactionReason


# Patient Schemas
class PatientBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)


class PatientCreate(PatientBase):
    pass


class PatientUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    is_active: Optional[bool] = None


class PatientResponse(PatientBase):
    id: int
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


# Worker Schemas
class WorkerBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    mobile_number: str = Field(..., min_length=10, max_length=20)


class WorkerCreate(WorkerBase):
    pass


class WorkerUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    mobile_number: Optional[str] = Field(None, min_length=10, max_length=20)
    is_active: Optional[bool] = None


class WorkerResponse(WorkerBase):
    id: int
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


# Medicine Schemas
class MedicineBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    dosage_unit: str = Field(..., min_length=1, max_length=50)


class MedicineCreate(MedicineBase):
    initial_stock: int = Field(default=0, ge=0)
    min_stock_level: int = Field(default=10, ge=0)


class MedicineUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    dosage_unit: Optional[str] = Field(None, min_length=1, max_length=50)
    min_stock_level: Optional[int] = Field(None, ge=0)
    is_active: Optional[bool] = None


class MedicineResponse(MedicineBase):
    id: int
    current_stock: int
    min_stock_level: int
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


# Schedule Schemas
class ScheduleBase(BaseModel):
    patient_id: int = Field(..., gt=0)
    worker_id: int = Field(..., gt=0)
    medicine_id: int = Field(..., gt=0)
    scheduled_time: datetime
    dose_amount: int = Field(default=1, gt=0)


class ScheduleCreate(ScheduleBase):
    pass


class ScheduleUpdate(BaseModel):
    scheduled_time: Optional[datetime] = None
    dose_amount: Optional[int] = Field(None, gt=0)
    patient_id: Optional[int] = None
    worker_id: Optional[int] = None
    medicine_id: Optional[int] = None
    master_key: Optional[str] = None  # Required when editing within 24 hours


class ScheduleOverride(BaseModel):
    master_password: str
    reason: str = Field(..., min_length=1)
    update_data: ScheduleUpdate


class ScheduleResponse(ScheduleBase):
    id: int
    status: ScheduleStatus
    response_received_at: Optional[datetime] = None
    response_message: Optional[str] = None
    is_overridden: bool
    override_reason: Optional[str] = None
    reminder_count: int = 0
    created_at: datetime
    patient: PatientResponse
    worker: WorkerResponse
    medicine: MedicineResponse
    
    class Config:
        from_attributes = True


# Stock Transaction Schemas
class StockAdjustment(BaseModel):
    amount: int = Field(..., description="Positive for additions, negative for removals")
    notes: str = Field(..., min_length=1)
    created_by: str = Field(..., min_length=1)


class StockTransactionResponse(BaseModel):
    id: int
    medicine_id: int
    change_amount: int
    reason: TransactionReason
    reference_schedule_id: Optional[int] = None
    notes: Optional[str] = None
    created_by: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True


# Audit Log Schemas
class AuditLogResponse(BaseModel):
    id: int
    entity_type: str
    entity_id: int
    action: str
    old_value: Optional[str] = None
    new_value: Optional[str] = None
    reason: Optional[str] = None
    performed_by: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True


# WhatsApp Webhook Schemas
class WhatsAppWebhookPayload(BaseModel):
    """Twilio WhatsApp webhook payload"""
    MessageSid: str
    From: str  # whatsapp:+1234567890
    Body: str
    
    class Config:
        extra = "allow"  # Allow additional Twilio fields


# Response Schemas
class SuccessResponse(BaseModel):
    success: bool = True
    message: str
    data: Optional[dict] = None


class ErrorResponse(BaseModel):
    success: bool = False
    error: str
    details: Optional[dict] = None


# Master Key Schemas
class SetupKeyRequest(BaseModel):
    pin: str = Field(..., min_length=4, max_length=6)
    
    @field_validator('pin')
    @classmethod
    def pin_must_be_digits(cls, v: str) -> str:
        if not v.isdigit():
            raise ValueError('PIN must contain only digits')
        return v


class ChangeKeyRequest(BaseModel):
    current_pin: str = Field(..., min_length=4, max_length=6)
    new_pin: str = Field(..., min_length=4, max_length=6)
    
    @field_validator('current_pin', 'new_pin')
    @classmethod
    def pin_must_be_digits(cls, v: str) -> str:
        if not v.isdigit():
            raise ValueError('PIN must contain only digits')
        return v


class VerifyKeyRequest(BaseModel):
    pin: str = Field(..., min_length=4, max_length=6)


class KeyStatusResponse(BaseModel):
    is_setup: bool
    pin_length: Optional[int] = None
