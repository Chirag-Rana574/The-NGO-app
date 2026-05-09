"""
CSV data export endpoints.
Generates CSV files for schedules, stock transactions, and audit logs.
"""
from fastapi import APIRouter, Depends, Query
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import cast, Date
from datetime import datetime, timezone
from typing import Optional
import csv
import io
import logging

from ..database import get_db
from ..models import Schedule, Medicine, StockTransaction, AuditLog, User, AuditAction
from ..config import get_settings
from .google_auth import get_current_user

router = APIRouter(prefix="/exports", tags=["Data Export"], dependencies=[Depends(get_current_user)])
logger = logging.getLogger(__name__)


def _csv_response(rows: list, headers: list, filename: str) -> StreamingResponse:
    """Helper to create a CSV streaming response."""
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(headers)
    writer.writerows(rows)
    output.seek(0)
    
    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": f"attachment; filename={filename}"},
    )


@router.get("/schedules", summary="Export schedules as CSV")
async def export_schedules(
    month: str = Query(..., description="Month in YYYY-MM format", pattern=r"^\d{4}-\d{2}$"),
    db: Session = Depends(get_db), current_user: User = Depends(get_current_user)
):
    """Export all schedules for a given month as CSV."""
    year, mon = map(int, month.split("-"))
    start = datetime(year, mon, 1, tzinfo=timezone.utc)
    if mon == 12:
        end = datetime(year + 1, 1, 1, tzinfo=timezone.utc)
    else:
        end = datetime(year, mon + 1, 1, tzinfo=timezone.utc)
    
    schedules = db.query(Schedule).options(
        joinedload(Schedule.patient),
        joinedload(Schedule.worker),
        joinedload(Schedule.medicine),
    ).filter(
        Schedule.scheduled_time >= start,
        Schedule.scheduled_time < end,
        Schedule.deleted_at.is_(None),
    ).order_by(Schedule.scheduled_time).all()
    
    headers = ["ID", "Date", "Time", "Patient", "Worker", "Medicine", "Dose", "Unit", "Status", "Reminder Count"]
    rows = []
    for s in schedules:
        rows.append([
            s.id,
            s.scheduled_time.strftime("%d/%m/%Y"),
            s.scheduled_time.strftime("%I:%M %p"),
            s.patient.name if s.patient else "",
            s.worker.name if s.worker else "",
            s.medicine.name if s.medicine else "",
            s.dose_amount,
            s.medicine.dosage_unit if s.medicine else "",
            s.status.value,
            s.reminder_count or 0,
        ])
    db.add(AuditLog(
        entity_type="EXPORT",
        entity_id=0,
        action=AuditAction.UPDATE,
        performed_by=current_user.email,
        reason=f"Exported schedules for {month}"
    ))
    db.commit()
    
    return _csv_response(rows, headers, f"schedules_{month}.csv")


@router.get("/stock", summary="Export stock transactions as CSV")
async def export_stock(
    month: str = Query(..., description="Month in YYYY-MM format", pattern=r"^\d{4}-\d{2}$"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Export stock transactions for a given month as CSV."""
    year, mon = map(int, month.split("-"))
    start = datetime(year, mon, 1, tzinfo=timezone.utc)
    if mon == 12:
        end = datetime(year + 1, 1, 1, tzinfo=timezone.utc)
    else:
        end = datetime(year, mon + 1, 1, tzinfo=timezone.utc)
    
    txns = db.query(StockTransaction).options(
        joinedload(StockTransaction.medicine),
    ).filter(
        StockTransaction.created_at >= start,
        StockTransaction.created_at < end,
    ).order_by(StockTransaction.created_at).all()
    
    headers = ["ID", "Date", "Medicine", "Amount", "Reason", "Notes", "Created By"]
    rows = []
    for t in txns:
        rows.append([
            t.id,
            t.created_at.strftime("%d/%m/%Y %I:%M %p") if t.created_at else "",
            t.medicine.name if t.medicine else "",
            t.change_amount,
            t.reason.value if t.reason else "",
            t.notes or "",
            t.created_by or "",
        ])
    db.add(AuditLog(
        entity_type="EXPORT",
        entity_id=0,
        action=AuditAction.UPDATE,
        performed_by=current_user.email,
        reason=f"Exported stock transactions for {month}"
    ))
    db.commit()
    
    return _csv_response(rows, headers, f"stock_{month}.csv")


@router.get("/audit", summary="Export audit logs as CSV")
async def export_audit(
    month: str = Query(..., description="Month in YYYY-MM format", pattern=r"^\d{4}-\d{2}$"),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Export audit logs for a given month as CSV."""
    year, mon = map(int, month.split("-"))
    start = datetime(year, mon, 1, tzinfo=timezone.utc)
    if mon == 12:
        end = datetime(year + 1, 1, 1, tzinfo=timezone.utc)
    else:
        end = datetime(year, mon + 1, 1, tzinfo=timezone.utc)
    
    logs = db.query(AuditLog).filter(
        AuditLog.created_at >= start,
        AuditLog.created_at < end,
    ).order_by(AuditLog.created_at).all()
    
    headers = ["ID", "Timestamp", "Entity Type", "Entity ID", "Action", "Performed By", "Details"]
    rows = []
    for l in logs:
        rows.append([
            l.id,
            l.created_at.strftime("%d/%m/%Y %I:%M %p") if l.created_at else "",
            l.entity_type or "",
            l.entity_id or "",
            l.action.value if l.action else "",
            l.performed_by or "",
            l.reason or "",
        ])
    db.add(AuditLog(
        entity_type="EXPORT",
        entity_id=0,
        action=AuditAction.UPDATE,
        performed_by=current_user.email,
        reason=f"Exported audit logs for {month}"
    ))
    db.commit()
    
    return _csv_response(rows, headers, f"audit_{month}.csv")
