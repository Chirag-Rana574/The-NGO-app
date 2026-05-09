from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone
from ..database import get_db
from ..models import Patient, AuditLog, AuditAction, User 
from ..schemas import PatientCreate, PatientUpdate, PatientResponse, SuccessResponse
import logging
import json
from .google_auth import get_current_user

router = APIRouter(prefix="/patients", tags=["Patients"], dependencies=[Depends(get_current_user)])
logger = logging.getLogger(__name__)


@router.get("", response_model=List[PatientResponse])
def list_patients(
    active_only: bool = True,
    db: Session = Depends(get_db)
):
    """List all patients"""
    query = db.query(Patient).filter(Patient.deleted_at.is_(None))
    
    if active_only:
        query = query.filter(Patient.is_active == True)
    
    return query.order_by(Patient.name).all()


@router.get("/{patient_id}", response_model=PatientResponse)
def get_patient(patient_id: int, db: Session = Depends(get_db)):
    """Get patient by ID"""
    patient = db.query(Patient).filter(
        Patient.id == patient_id,
        Patient.deleted_at.is_(None)
    ).first()
    
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    return patient


@router.post("", response_model=PatientResponse, status_code=201)
def create_patient(patient_data: PatientCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Create a new patient"""
    # Check if name already exists
    existing = db.query(Patient).filter(
        Patient.name == patient_data.name,
        Patient.deleted_at.is_(None)
    ).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Patient with name '{patient_data.name}' already exists"
        )
    
    # Create patient
    patient = Patient(
        name=patient_data.name
    )
    
    db.add(patient)
    db.commit()
    db.refresh(patient)
    
    # Create audit log
    audit_log = AuditLog(
        entity_type="Patient",
        entity_id=patient.id,
        action=AuditAction.CREATE,
        new_value=json.dumps({"name": patient.name}),
        performed_by=current_user.email
    )
    db.add(audit_log)
    db.commit()
    
    logger.info(f"Created patient: {patient.name}")
    
    return patient


@router.put("/{patient_id}", response_model=PatientResponse)
def update_patient(
    patient_id: int,
    patient_data: PatientUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update patient"""
    patient = db.query(Patient).filter(
        Patient.id == patient_id,
        Patient.deleted_at.is_(None)
    ).first()
    
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    # Store old values for audit
    old_value = {"name": patient.name, "is_active": patient.is_active}
    
    # Update fields
    if patient_data.name is not None:
        # Check uniqueness
        existing = db.query(Patient).filter(
            Patient.name == patient_data.name,
            Patient.id != patient_id,
            Patient.deleted_at.is_(None)
        ).first()
        if existing:
            raise HTTPException(
                status_code=400,
                detail=f"Patient with name '{patient_data.name}' already exists"
            )
        patient.name = patient_data.name
    
    if patient_data.is_active is not None:
        patient.is_active = patient_data.is_active
    
    patient.updated_at = datetime.now(timezone.utc)
    
    db.commit()
    db.refresh(patient)
    
    # Create audit log
    new_value = {"name": patient.name, "is_active": patient.is_active}
    audit_log = AuditLog(
        entity_type="Patient",
        entity_id=patient.id,
        action=AuditAction.UPDATE,
        old_value=json.dumps(old_value),
        new_value=json.dumps(new_value),
        performed_by=current_user.email
    )
    db.add(audit_log)
    db.commit()
    
    logger.info(f"Updated patient: {patient.name}")
    
    return patient


@router.delete("/{patient_id}", response_model=SuccessResponse)
def delete_patient(patient_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Soft delete patient"""
    patient = db.query(Patient).filter(
        Patient.id == patient_id,
        Patient.deleted_at.is_(None)
    ).first()
    
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")
    
    # Soft delete
    patient.deleted_at = datetime.now(timezone.utc)
    patient.is_active = False
    
    db.commit()
    
    # Create audit log
    audit_log = AuditLog(
        entity_type="Patient",
        entity_id=patient.id,
        action=AuditAction.DELETE,
        old_value=json.dumps({"name": patient.name}),
        performed_by=current_user.email
    )
    db.add(audit_log)
    db.commit()
    
    logger.info(f"Deleted patient: {patient.name}")
    
    return SuccessResponse(message=f"Patient {patient.name} deleted successfully")
