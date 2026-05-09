from sqlalchemy import (
    Column, Integer, String, DateTime, Boolean, ForeignKey, 
    Enum, Text, CheckConstraint, UniqueConstraint, Numeric, Index
)
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime
import enum
from .database import Base


class ScheduleStatus(str, enum.Enum):
    CREATED = "CREATED"
    REMINDER_SENT = "REMINDER_SENT"
    AWAITING_RESPONSE = "AWAITING_RESPONSE"
    COMPLETED = "COMPLETED"
    NOT_DONE = "NOT_DONE"
    LATE_COMPLETED = "LATE_COMPLETED"
    EXPIRED = "EXPIRED"


class TransactionReason(str, enum.Enum):
    TASK_COMPLETION = "TASK_COMPLETION"
    MANUAL_ADJUSTMENT = "MANUAL_ADJUSTMENT"
    CORRECTION = "CORRECTION"


class AuditAction(str, enum.Enum):
    CREATE = "CREATE"
    UPDATE = "UPDATE"
    DELETE = "DELETE"
    STATE_TRANSITION = "STATE_TRANSITION"
    STOCK_CHANGE = "STOCK_CHANGE"
    OVERRIDE = "OVERRIDE"


class Patient(Base):
    __tablename__ = "patients"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    schedules = relationship("Schedule", back_populates="patient")


class Worker(Base):
    __tablename__ = "workers"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    mobile_number = Column(String(20), unique=True, nullable=False, index=True)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    assigned_schedules = relationship("Schedule", back_populates="worker")


class Medicine(Base):
    __tablename__ = "medicines"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    dosage_unit = Column(String(50), nullable=False)  # e.g., "tablet", "ml", "mg"
    current_stock = Column(Integer, default=0, nullable=False)
    min_stock_level = Column(Integer, default=10, nullable=False)  # Per-medicine low stock threshold
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    schedules = relationship("Schedule", back_populates="medicine")
    transactions = relationship("StockTransaction", back_populates="medicine")
    
    # Constraints
    __table_args__ = (
        CheckConstraint('current_stock >= 0', name='check_stock_non_negative'),
    )


class Schedule(Base):
    __tablename__ = "schedules"
    
    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patients.id"), nullable=False, index=True)
    worker_id = Column(Integer, ForeignKey("workers.id"), nullable=False, index=True)
    medicine_id = Column(Integer, ForeignKey("medicines.id"), nullable=False, index=True)
    scheduled_time = Column(DateTime(timezone=True), nullable=False, index=True)
    status = Column(Enum(ScheduleStatus), default=ScheduleStatus.CREATED, nullable=False, index=True)
    dose_amount = Column(Integer, default=1, nullable=False)
    
    # Response tracking
    response_received_at = Column(DateTime(timezone=True), nullable=True)
    response_message = Column(Text, nullable=True)
    
    # Override tracking
    is_overridden = Column(Boolean, default=False, nullable=False)
    override_reason = Column(Text, nullable=True)
    override_at = Column(DateTime(timezone=True), nullable=True)
    
    # Idempotency
    twilio_message_sid = Column(String(255), nullable=True, unique=True, index=True)
    
    # Reminder tracking
    reminder_count = Column(Integer, default=0, nullable=False)  # 0-6, tracks how many reminders sent
    last_reminder_at = Column(DateTime(timezone=True), nullable=True)
    
    # Timestamps
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    patient = relationship("Patient", back_populates="schedules")
    worker = relationship("Worker", back_populates="assigned_schedules")
    medicine = relationship("Medicine", back_populates="schedules")
    stock_transaction = relationship("StockTransaction", back_populates="schedule", uselist=False)
    
    # Constraints: Only one AWAITING_RESPONSE schedule per active worker
    __table_args__ = (
        Index(
            'unique_awaiting_response_per_worker',
            'worker_id', 
            'status',
            unique=True,
            postgresql_where=(status == ScheduleStatus.AWAITING_RESPONSE)
        ),
        CheckConstraint('dose_amount > 0', name='check_dose_positive'),
    )


class StockTransaction(Base):
    __tablename__ = "stock_transactions"
    
    id = Column(Integer, primary_key=True, index=True)
    medicine_id = Column(Integer, ForeignKey("medicines.id"), nullable=False, index=True)
    change_amount = Column(Integer, nullable=False)  # Positive for additions, negative for consumption
    reason = Column(Enum(TransactionReason), nullable=False)
    reference_schedule_id = Column(Integer, ForeignKey("schedules.id"), nullable=True, index=True)
    notes = Column(Text, nullable=True)
    created_by = Column(String(255), nullable=True)  # Supervisor name/ID for manual adjustments
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False, index=True)
    
    # Relationships
    medicine = relationship("Medicine", back_populates="transactions")
    schedule = relationship("Schedule", back_populates="stock_transaction")


class AuditLog(Base):
    __tablename__ = "audit_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    entity_type = Column(String(50), nullable=False, index=True)  # "Schedule", "Medicine", etc.
    entity_id = Column(Integer, nullable=False, index=True)
    action = Column(Enum(AuditAction), nullable=False, index=True)
    old_value = Column(Text, nullable=True)  # JSON string
    new_value = Column(Text, nullable=True)  # JSON string
    reason = Column(Text, nullable=True)
    performed_by = Column(String(255), nullable=True)  # System, Supervisor, Worker
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False, index=True)
    
    # No relationships - immutable log


class SystemConfig(Base):
    """Key-value store for system settings (e.g. master key hash)."""
    __tablename__ = "system_config"
    
    key = Column(String(100), primary_key=True)
    value = Column(Text, nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class User(Base):
    """User account (Google OAuth)."""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    name = Column(String(255), nullable=False)
    picture_url = Column(Text, nullable=True)
    google_id = Column(String(255), unique=True, nullable=False, index=True)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    # Relationships
    push_tokens = relationship("PushToken", back_populates="user")
    notifications = relationship("Notification", back_populates="user")


class PushToken(Base):
    """Expo Push Notification tokens for each user device."""
    __tablename__ = "push_tokens"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    token = Column(String(255), unique=True, nullable=False)
    device_info = Column(String(255), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="push_tokens")


class NotificationSeverity(str, enum.Enum):
    NORMAL = "NORMAL"
    MODERATE = "MODERATE"
    SERIOUS = "SERIOUS"


class Notification(Base):
    """In-app notification history."""
    __tablename__ = "notifications"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True, index=True)
    type = Column(String(50), nullable=False, index=True)  # TASK_COMPLETED, TASK_OVERDUE, TASK_MISSED, LOW_STOCK, DAILY_SUMMARY
    title = Column(String(255), nullable=False)
    body = Column(Text, nullable=False)
    severity = Column(Enum(NotificationSeverity), default=NotificationSeverity.NORMAL, nullable=False)
    data = Column(Text, nullable=True)  # JSON string with extra data (schedule_id, medicine_id, etc.)
    is_read = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False, index=True)
    
    # Relationships
    user = relationship("User", back_populates="notifications")

