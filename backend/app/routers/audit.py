from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from ..database import get_db
from ..models import AuditLog, AuditAction
from ..schemas import AuditLogResponse
from .google_auth import get_current_user

router = APIRouter(prefix="/audit", tags=["Audit"], dependencies=[Depends(get_current_user)])


@router.get("", response_model=List[AuditLogResponse])
def list_audit_logs(
    entity_type: Optional[str] = None,
    entity_id: Optional[int] = None,
    action: Optional[AuditAction] = None,
    date_from: Optional[datetime] = None,
    date_to: Optional[datetime] = None,
    limit: int = Query(default=100, le=500),
    db: Session = Depends(get_db)
):
    """
    List audit logs with filters.
    Audit logs are immutable and never deleted.
    """
    query = db.query(AuditLog)
    
    if entity_type:
        query = query.filter(AuditLog.entity_type == entity_type)
    
    if entity_id:
        query = query.filter(AuditLog.entity_id == entity_id)
    
    if action:
        query = query.filter(AuditLog.action == action)
    
    if date_from:
        query = query.filter(AuditLog.created_at >= date_from)
    
    if date_to:
        query = query.filter(AuditLog.created_at <= date_to)
    
    return query.order_by(AuditLog.created_at.desc()).limit(limit).all()


@router.get("/{audit_id}", response_model=AuditLogResponse)
def get_audit_log(audit_id: int, db: Session = Depends(get_db)):
    """Get specific audit log entry"""
    audit_log = db.query(AuditLog).filter(AuditLog.id == audit_id).first()
    
    if not audit_log:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Audit log not found")
    
    return audit_log
