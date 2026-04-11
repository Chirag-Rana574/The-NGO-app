from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import and_, or_
from typing import List, Optional
from datetime import datetime, timedelta, timezone
import json
import bcrypt
import logging
from ..database import get_db
from ..models import Schedule, ScheduleStatus, Worker, Medicine, Patient, User, AuditLog, AuditAction
from ..schemas import (
    ScheduleCreate, ScheduleUpdate, ScheduleResponse,
    ScheduleOverride, SuccessResponse
)
from ..config import get_settings
from .auth import verify_master_key
from .google_auth import get_current_user

router = APIRouter(prefix="/schedules", tags=["Schedules"], dependencies=[Depends(get_current_user)])
logger = logging.getLogger(__name__)
settings = get_settings()


@router.get("", response_model=List[ScheduleResponse])
def list_schedules(
    worker_id: Optional[int] = None,
    medicine_id: Optional[int] = None,
    status: Optional[ScheduleStatus] = None,
    date_from: Optional[datetime] = None,
    date_to: Optional[datetime] = None,
    db: Session = Depends(get_db)
):
    """List schedules with filters"""
    query = db.query(Schedule).options(
        joinedload(Schedule.patient),
        joinedload(Schedule.worker),
        joinedload(Schedule.medicine)
    ).filter(Schedule.deleted_at.is_(None))
    
    if worker_id:
        query = query.filter(Schedule.worker_id == worker_id)
    
    if medicine_id:
        query = query.filter(Schedule.medicine_id == medicine_id)
    
    if status:
        query = query.filter(Schedule.status == status)
    
    if date_from:
        query = query.filter(Schedule.scheduled_time >= date_from)
    
    if date_to:
        query = query.filter(Schedule.scheduled_time <= date_to)
    
    return query.order_by(Schedule.scheduled_time.desc()).all()


@router.get("/{schedule_id}", response_model=ScheduleResponse)
def get_schedule(schedule_id: int, db: Session = Depends(get_db)):
    """Get schedule by ID"""
    schedule = db.query(Schedule).options(
        joinedload(Schedule.patient),
        joinedload(Schedule.worker),
        joinedload(Schedule.medicine)
    ).filter(
        Schedule.id == schedule_id,
        Schedule.deleted_at.is_(None)
    ).first()
    
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    
    return schedule


@router.post("", response_model=ScheduleResponse, status_code=201)
def create_schedule(schedule_data: ScheduleCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Create a new schedule"""
    # Validate patient exists and is active
    patient = db.query(Patient).filter(
        Patient.id == schedule_data.patient_id,
        Patient.is_active == True,
        Patient.deleted_at.is_(None)
    ).first()
    
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found or inactive")
    
    # Validate worker exists and is active
    worker = db.query(Worker).filter(
        Worker.id == schedule_data.worker_id,
        Worker.is_active == True,
        Worker.deleted_at.is_(None)
    ).first()
    
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found or inactive")
    
    # Validate medicine exists and is active
    medicine = db.query(Medicine).filter(
        Medicine.id == schedule_data.medicine_id,
        Medicine.is_active == True,
        Medicine.deleted_at.is_(None)
    ).first()
    
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found or inactive")
    
    # Validate scheduled_time is not in the past
    now = datetime.now(timezone.utc)
    if schedule_data.scheduled_time < now:
        raise HTTPException(
            status_code=400,
            detail="Cannot create a schedule in the past"
        )
    
    # Validate scheduled_time is within 2 weeks from now
    max_date = now + timedelta(days=14)
    if schedule_data.scheduled_time > max_date:
        raise HTTPException(
            status_code=400,
            detail="Schedules can only be created within 2 weeks from today"
        )
    
    # Create schedule
    schedule = Schedule(
        patient_id=schedule_data.patient_id,
        worker_id=schedule_data.worker_id,
        medicine_id=schedule_data.medicine_id,
        scheduled_time=schedule_data.scheduled_time,
        dose_amount=schedule_data.dose_amount
    )
    
    db.add(schedule)
    db.commit()
    db.refresh(schedule)

    db.add(AuditLog(
        entity_type="Schedule",
        entity_id=schedule.id,
        action=AuditAction.CREATE,
        performed_by=current_user.email,
        new_value=json.dumps({
            "patient_id": schedule.patient_id,
            "time": str(schedule.scheduled_time),
            "dose": schedule.dose_amount
        })
    ))
    db.commit()
    
    # Re-query with eager loading for response serialization
    schedule = db.query(Schedule).options(
        joinedload(Schedule.patient),
        joinedload(Schedule.worker),
        joinedload(Schedule.medicine)
    ).filter(Schedule.id == schedule.id).first()
    
    logger.info(
        f"Created schedule #{schedule.id}: Patient {patient.name}, Worker {worker.name} - {medicine.name} "
        f"at {schedule.scheduled_time}"
    )
    
    return schedule


@router.put("/{schedule_id}", response_model=ScheduleResponse)
def update_schedule(
    schedule_id: int,
    schedule_data: ScheduleUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Update schedule with 24-hour lock enforcement.
    Cannot edit if less than 24 hours remain (use override endpoint).
    """
    schedule = db.query(Schedule).filter(
        Schedule.id == schedule_id,
        Schedule.deleted_at.is_(None)
    ).first()
    
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    
    old_values = {
        "scheduled_time": str(schedule.scheduled_time),
        "dose_amount": schedule.dose_amount,
        "worker_id": schedule.worker_id
    }
    
    # Check if schedule is in terminal state
    if schedule.status in [
        ScheduleStatus.COMPLETED,
        ScheduleStatus.NOT_DONE,
        ScheduleStatus.LATE_COMPLETED,
        ScheduleStatus.EXPIRED
    ]:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot edit schedule in {schedule.status.value} state"
        )
    
    # Check 24-hour lock
    now = datetime.now(timezone.utc)
    time_until_scheduled = (schedule.scheduled_time - now).total_seconds() / 3600
    
    if time_until_scheduled < 24:
        # Within 24 hours — require master key
        if not schedule_data.master_key:
            raise HTTPException(
                status_code=403,
                detail="Master key required to edit schedules within 24 hours"
            )
        if not verify_master_key(db, schedule_data.master_key):
            logger.warning(f"Failed master key verification for schedule #{schedule_id}")
            raise HTTPException(status_code=403, detail="Invalid master key")
        
        # Mark as overridden
        schedule.is_overridden = True
        schedule.override_reason = "Edited within 24-hour window with master key"
        schedule.override_at = datetime.now(timezone.utc)
    
    # Update fields
    if schedule_data.scheduled_time is not None:
        schedule.scheduled_time = schedule_data.scheduled_time
    
    if schedule_data.dose_amount is not None:
        schedule.dose_amount = schedule_data.dose_amount
    
    if schedule_data.patient_id is not None:
        patient = db.query(Patient).filter(
            Patient.id == schedule_data.patient_id,
            Patient.is_active == True,
            Patient.deleted_at.is_(None)
        ).first()
        if not patient:
            raise HTTPException(status_code=404, detail="Patient not found or inactive")
        schedule.patient_id = schedule_data.patient_id
    
    if schedule_data.worker_id is not None:
        worker = db.query(Worker).filter(
            Worker.id == schedule_data.worker_id,
            Worker.is_active == True,
            Worker.deleted_at.is_(None)
        ).first()
        if not worker:
            raise HTTPException(status_code=404, detail="Worker not found or inactive")
        schedule.worker_id = schedule_data.worker_id
    
    if schedule_data.medicine_id is not None:
        medicine = db.query(Medicine).filter(
            Medicine.id == schedule_data.medicine_id,
            Medicine.is_active == True,
            Medicine.deleted_at.is_(None)
        ).first()
        if not medicine:
            raise HTTPException(status_code=404, detail="Medicine not found or inactive")
        schedule.medicine_id = schedule_data.medicine_id
    
    schedule.updated_at = datetime.now(timezone.utc)
    
    db.commit()
    db.refresh(schedule)
    
    db.add(AuditLog(
        entity_type="Schedule",
        entity_id=schedule.id,
        action=AuditAction.UPDATE,
        performed_by=current_user.email,
        old_value=json.dumps(old_values),
        reason="Updated schedule (Override used if within 24h)"
    ))
    db.commit()

    logger.info(f"Updated schedule #{schedule.id}")
    
    return schedule


@router.post("/{schedule_id}/override", response_model=ScheduleResponse)
def override_schedule(
    schedule_id: int,
    override_data: ScheduleOverride,
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    """
    Override schedule edit lock with master password.
    Requires master password validation and reason.
    """
    schedule = db.query(Schedule).filter(
        Schedule.id == schedule_id,
        Schedule.deleted_at.is_(None)
    ).first()
    
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    
    # Validate master password
    if not bcrypt.checkpw(
        override_data.master_password.encode('utf-8'),
        settings.master_password_hash.encode('utf-8')
    ):
        logger.warning(f"Failed override attempt for schedule #{schedule_id}")
        raise HTTPException(status_code=403, detail="Invalid master password")
    
    # Check if schedule is in terminal state
    if schedule.status in [
        ScheduleStatus.COMPLETED,
        ScheduleStatus.NOT_DONE,
        ScheduleStatus.LATE_COMPLETED,
        ScheduleStatus.EXPIRED
    ]:
        raise HTTPException(
            status_code=400,
            detail=f"Cannot edit schedule in {schedule.status.value} state"
        )
    
    # Apply updates
    if override_data.update_data.scheduled_time is not None:
        schedule.scheduled_time = override_data.update_data.scheduled_time
    
    if override_data.update_data.dose_amount is not None:
        schedule.dose_amount = override_data.update_data.dose_amount
    
    # Mark as overridden
    schedule.is_overridden = True
    schedule.override_reason = override_data.reason
    schedule.override_at = datetime.now(timezone.utc)
    schedule.updated_at = datetime.now(timezone.utc)
    
    db.commit()
    db.refresh(schedule)

    db.add(AuditLog(
        entity_type="Schedule",
        entity_id=schedule.id,
        action=AuditAction.UPDATE,
        performed_by=current_user.email,
        reason=f"FORCE OVERRIDE: {override_data.reason}"
    ))
    db.commit()
    
    logger.info(f"Override applied to schedule #{schedule.id}: {override_data.reason}")
    
    return schedule


@router.delete("/{schedule_id}", response_model=SuccessResponse)
def delete_schedule(
    schedule_id: int,
    master_key: Optional[str] = None,
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    """Soft delete schedule — requires master key if within 24 hours"""
    schedule = db.query(Schedule).filter(
        Schedule.id == schedule_id,
        Schedule.deleted_at.is_(None)
    ).first()
    
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    
    # Prevent deletion of completed schedules
    if schedule.status in [ScheduleStatus.COMPLETED, ScheduleStatus.LATE_COMPLETED]:
        raise HTTPException(
            status_code=400,
            detail="Cannot delete completed schedules (audit trail)"
        )
    
    # Check 24-hour lock
    now = datetime.now(timezone.utc)
    time_until_scheduled = (schedule.scheduled_time - now).total_seconds() / 3600
    
    if time_until_scheduled < 24:
        if not master_key:
            raise HTTPException(
                status_code=403,
                detail="Master key required to delete schedules within 24 hours"
            )
        if not verify_master_key(db, master_key):
            logger.warning(f"Failed master key verification for deleting schedule #{schedule_id}")
            raise HTTPException(status_code=403, detail="Invalid master key")
    
    # Soft delete
    schedule.deleted_at = datetime.now(timezone.utc)
    
    db.commit()
    
    db.add(AuditLog(
        entity_type="Schedule",
        entity_id=schedule.id,
        action=AuditAction.DELETE,
        performed_by=current_user.email
    ))
    db.commit()

    logger.info(f"Deleted schedule #{schedule.id}")
    
    return SuccessResponse(message=f"Schedule #{schedule.id} deleted successfully")
