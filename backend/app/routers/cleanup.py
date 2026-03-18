"""
Auto-cleanup endpoint for permanently purging soft-deleted records.
Records older than a configurable retention period (default 90 days)
are permanently removed to save database storage costs.
"""
import logging
from datetime import datetime, timezone, timedelta
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Patient, Worker, Medicine, Schedule, AuditLog
from ..schemas import SuccessResponse
from .auth import verify_master_key

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/cleanup", tags=["cleanup"])


@router.post("/purge", response_model=SuccessResponse)
def purge_deleted_records(
    master_key: str = Query(..., description="Master key required for purge"),
    retention_days: int = Query(90, ge=30, le=365, description="Records deleted more than this many days ago will be purged"),
    db: Session = Depends(get_db)
):
    """
    Permanently delete soft-deleted records older than retention_days.
    Requires master key for safety.
    Default retention: 90 days. Minimum: 30 days.
    """
    if not verify_master_key(db, master_key):
        raise HTTPException(status_code=403, detail="Invalid master key")
    
    cutoff = datetime.now(timezone.utc) - timedelta(days=retention_days)
    
    # Order matters: delete schedules first (they reference patients/workers/medicines)
    tables = [
        ("schedules", Schedule),
        ("patients", Patient),
        ("workers", Worker),
        ("medicines", Medicine),
    ]
    
    total_purged = 0
    details = []
    
    for name, model in tables:
        count = db.query(model).filter(
            model.deleted_at.isnot(None),
            model.deleted_at < cutoff
        ).delete(synchronize_session='fetch')
        total_purged += count
        if count > 0:
            details.append(f"{name}: {count}")
    
    # Also purge old audit logs (older than retention period)
    audit_count = db.query(AuditLog).filter(
        AuditLog.created_at < cutoff
    ).delete(synchronize_session='fetch')
    if audit_count > 0:
        total_purged += audit_count
        details.append(f"audit_logs: {audit_count}")
    
    db.commit()
    
    detail_str = ", ".join(details) if details else "no records to purge"
    logger.info(f"Purge completed: {total_purged} records removed ({detail_str})")
    
    return SuccessResponse(
        message=f"Purged {total_purged} records older than {retention_days} days ({detail_str})"
    )


@router.get("/stats")
def get_cleanup_stats(db: Session = Depends(get_db)):
    """
    Get counts of soft-deleted records grouped by age.
    Helps decide when to run a purge.
    """
    now = datetime.now(timezone.utc)
    cutoff_30 = now - timedelta(days=30)
    cutoff_90 = now - timedelta(days=90)
    
    tables = [
        ("patients", Patient),
        ("workers", Worker),
        ("medicines", Medicine),
        ("schedules", Schedule),
    ]
    
    stats = {}
    for name, model in tables:
        total_deleted = db.query(model).filter(model.deleted_at.isnot(None)).count()
        older_than_30 = db.query(model).filter(
            model.deleted_at.isnot(None),
            model.deleted_at < cutoff_30
        ).count()
        older_than_90 = db.query(model).filter(
            model.deleted_at.isnot(None),
            model.deleted_at < cutoff_90
        ).count()
        stats[name] = {
            "total_deleted": total_deleted,
            "older_than_30_days": older_than_30,
            "older_than_90_days": older_than_90,
        }
    
    # Audit log stats
    total_audit = db.query(AuditLog).count()
    audit_older_90 = db.query(AuditLog).filter(AuditLog.created_at < cutoff_90).count()
    stats["audit_logs"] = {
        "total": total_audit,
        "older_than_90_days": audit_older_90,
    }
    
    return stats
