from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone
from ..database import get_db
from ..models import Worker, AuditLog, AuditAction
from ..schemas import WorkerCreate, WorkerUpdate, WorkerResponse, SuccessResponse
from ..utils import normalize_phone_number
import logging
import json

router = APIRouter(prefix="/workers", tags=["Workers"])
logger = logging.getLogger(__name__)


@router.get("", response_model=List[WorkerResponse])
def list_workers(
    active_only: bool = True,
    db: Session = Depends(get_db)
):
    """List all workers"""
    query = db.query(Worker).filter(Worker.deleted_at.is_(None))
    
    if active_only:
        query = query.filter(Worker.is_active == True)
    
    return query.order_by(Worker.name).all()


@router.get("/{worker_id}", response_model=WorkerResponse)
def get_worker(worker_id: int, db: Session = Depends(get_db)):
    """Get worker by ID"""
    worker = db.query(Worker).filter(
        Worker.id == worker_id,
        Worker.deleted_at.is_(None)
    ).first()
    
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    
    return worker


@router.post("", response_model=WorkerResponse, status_code=201)
def create_worker(worker_data: WorkerCreate, db: Session = Depends(get_db)):
    """Create a new worker"""
    try:
        # Normalize phone number
        normalized_phone = normalize_phone_number(worker_data.mobile_number)
        
        # Check if phone already exists
        existing = db.query(Worker).filter(
            Worker.mobile_number == normalized_phone,
            Worker.deleted_at.is_(None)
        ).first()
        
        if existing:
            raise HTTPException(
                status_code=400,
                detail=f"Worker with mobile {normalized_phone} already exists"
            )
        
        # Create worker
        worker = Worker(
            name=worker_data.name,
            mobile_number=normalized_phone
        )
        
        db.add(worker)
        db.commit()
        db.refresh(worker)
        
        # Create audit log
        audit_log = AuditLog(
            entity_type="Worker",
            entity_id=worker.id,
            action=AuditAction.CREATE,
            new_value=json.dumps({"name": worker.name, "mobile_number": worker.mobile_number}),
            performed_by="System"
        )
        db.add(audit_log)
        db.commit()
        
        logger.info(f"Created worker: {worker.name} ({worker.mobile_number})")
        
        return worker
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.put("/{worker_id}", response_model=WorkerResponse)
def update_worker(
    worker_id: int,
    worker_data: WorkerUpdate,
    db: Session = Depends(get_db)
):
    """Update worker"""
    worker = db.query(Worker).filter(
        Worker.id == worker_id,
        Worker.deleted_at.is_(None)
    ).first()
    
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    
    try:
        # Store old values for audit
        old_value = {"name": worker.name, "mobile_number": worker.mobile_number, "is_active": worker.is_active}
        
        if worker_data.name is not None:
            worker.name = worker_data.name
        
        if worker_data.mobile_number is not None:
            normalized_phone = normalize_phone_number(worker_data.mobile_number)
            
            # Check if new phone already exists
            existing = db.query(Worker).filter(
                Worker.mobile_number == normalized_phone,
                Worker.id != worker_id,
                Worker.deleted_at.is_(None)
            ).first()
            
            if existing:
                raise HTTPException(
                    status_code=400,
                    detail=f"Mobile {normalized_phone} already in use"
                )
            
            worker.mobile_number = normalized_phone
        
        if worker_data.is_active is not None:
            worker.is_active = worker_data.is_active
        
        worker.updated_at = datetime.now(timezone.utc)
        
        db.commit()
        db.refresh(worker)
        
        # Create audit log
        new_value = {"name": worker.name, "mobile_number": worker.mobile_number, "is_active": worker.is_active}
        audit_log = AuditLog(
            entity_type="Worker",
            entity_id=worker.id,
            action=AuditAction.UPDATE,
            old_value=json.dumps(old_value),
            new_value=json.dumps(new_value),
            performed_by="System"
        )
        db.add(audit_log)
        db.commit()
        
        logger.info(f"Updated worker: {worker.name}")
        
        return worker
        
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{worker_id}", response_model=SuccessResponse)
def delete_worker(worker_id: int, db: Session = Depends(get_db)):
    """Soft delete worker"""
    worker = db.query(Worker).filter(
        Worker.id == worker_id,
        Worker.deleted_at.is_(None)
    ).first()
    
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    
    # Soft delete
    worker.deleted_at = datetime.now(timezone.utc)
    worker.is_active = False
    
    db.commit()
    
    # Create audit log
    audit_log = AuditLog(
        entity_type="Worker",
        entity_id=worker.id,
        action=AuditAction.DELETE,
        old_value=json.dumps({"name": worker.name, "mobile_number": worker.mobile_number}),
        performed_by="System"
    )
    db.add(audit_log)
    db.commit()
    
    logger.info(f"Deleted worker: {worker.name}")
    
    return SuccessResponse(message=f"Worker {worker.name} deleted successfully")
