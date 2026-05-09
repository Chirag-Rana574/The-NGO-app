"""
Reporting and dashboard endpoints.
Provides stats for today, historical trends, worker performance, and stock summary.
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, cast, Date, case
from datetime import datetime, timedelta, timezone
from typing import Optional
import logging

from ..database import get_db
from ..models import Schedule, ScheduleStatus, Medicine, Worker, User
from ..config import get_settings
from .google_auth import get_current_user

router = APIRouter(prefix="/reports", tags=["Reports"], dependencies=[Depends(get_current_user)])
logger = logging.getLogger(__name__)
settings = get_settings()


@router.get("/dashboard", summary="Today's dashboard stats")
async def get_dashboard(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Get today's summary stats for the dashboard."""
    today = datetime.now(timezone.utc).date()
    
    base = db.query(Schedule).filter(
        cast(Schedule.scheduled_time, Date) == today,
        Schedule.deleted_at.is_(None),
    )
    
    total = base.count()
    completed = base.filter(Schedule.status.in_([
        ScheduleStatus.COMPLETED, ScheduleStatus.LATE_COMPLETED
    ])).count()
    not_done = base.filter(Schedule.status == ScheduleStatus.NOT_DONE).count()
    missed = base.filter(Schedule.status == ScheduleStatus.EXPIRED).count()
    pending = base.filter(Schedule.status.in_([
        ScheduleStatus.CREATED, ScheduleStatus.REMINDER_SENT, ScheduleStatus.AWAITING_RESPONSE
    ])).count()
    
    completion_rate = round((completed / total * 100), 1) if total > 0 else 0
    
    # Low stock medicines
    low_stock = db.query(Medicine).filter(
        Medicine.current_stock <= Medicine.min_stock_level,
        Medicine.is_active == True,
        Medicine.deleted_at.is_(None),
    ).count()
    
    return {
        "date": str(today),
        "total": total,
        "completed": completed,
        "not_done": not_done,
        "missed": missed,
        "pending": pending,
        "completion_rate": completion_rate,
        "low_stock_count": low_stock,
    }


@router.get("/history", summary="Daily completion history")
async def get_history(
    days: int = Query(30, ge=1, le=90),
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    """Get daily schedule stats for the past N days (for charts)."""
    start_date = datetime.now(timezone.utc).date() - timedelta(days=days)
    
    results = db.query(
        cast(Schedule.scheduled_time, Date).label("date"),
        func.count(Schedule.id).label("total"),
        func.sum(case(
            (Schedule.status.in_([ScheduleStatus.COMPLETED, ScheduleStatus.LATE_COMPLETED]), 1),
            else_=0
        )).label("completed"),
        func.sum(case(
            (Schedule.status == ScheduleStatus.NOT_DONE, 1),
            else_=0
        )).label("not_done"),
        func.sum(case(
            (Schedule.status == ScheduleStatus.EXPIRED, 1),
            else_=0
        )).label("missed"),
    ).filter(
        cast(Schedule.scheduled_time, Date) >= start_date,
        Schedule.deleted_at.is_(None),
    ).group_by(
        cast(Schedule.scheduled_time, Date)
    ).order_by(
        cast(Schedule.scheduled_time, Date)
    ).all()
    
    return [
        {
            "date": str(r.date),
            "total": r.total,
            "completed": r.completed or 0,
            "not_done": r.not_done or 0,
            "missed": r.missed or 0,
            "completion_rate": round((r.completed or 0) / r.total * 100, 1) if r.total > 0 else 0,
        }
        for r in results
    ]


@router.get("/worker-performance", summary="Worker performance stats")
async def get_worker_performance(
    days: int = Query(30, ge=1, le=90),
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    """Get completion stats per worker for the past N days."""
    start_date = datetime.now(timezone.utc).date() - timedelta(days=days)
    
    results = db.query(
        Worker.id,
        Worker.name,
        func.count(Schedule.id).label("total"),
        func.sum(case(
            (Schedule.status.in_([ScheduleStatus.COMPLETED, ScheduleStatus.LATE_COMPLETED]), 1),
            else_=0
        )).label("completed"),
        func.sum(case(
            (Schedule.status == ScheduleStatus.NOT_DONE, 1),
            else_=0
        )).label("not_done"),
        func.sum(case(
            (Schedule.status == ScheduleStatus.EXPIRED, 1),
            else_=0
        )).label("missed"),
        func.sum(case(
            (Schedule.status == ScheduleStatus.LATE_COMPLETED, 1),
            else_=0
        )).label("late"),
    ).join(Schedule, Schedule.worker_id == Worker.id).filter(
        cast(Schedule.scheduled_time, Date) >= start_date,
        Schedule.deleted_at.is_(None),
        Worker.is_active == True,
    ).group_by(Worker.id, Worker.name).all()
    
    return [
        {
            "worker_id": r.id,
            "worker_name": r.name,
            "total": r.total,
            "completed": r.completed or 0,
            "not_done": r.not_done or 0,
            "missed": r.missed or 0,
            "late": r.late or 0,
            "completion_rate": round((r.completed or 0) / r.total * 100, 1) if r.total > 0 else 0,
        }
        for r in results
    ]


@router.get("/stock-summary", summary="Stock status overview")
async def get_stock_summary(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Get all medicines with their stock status."""
    medicines = db.query(Medicine).filter(
        Medicine.is_active == True,
        Medicine.deleted_at.is_(None),
    ).order_by(Medicine.current_stock.asc()).all()
    
    return [
        {
            "id": m.id,
            "name": m.name,
            "current_stock": m.current_stock,
            "min_stock_level": m.min_stock_level,
            "dosage_unit": m.dosage_unit,
            "is_low": m.current_stock <= m.min_stock_level,
        }
        for m in medicines
    ]
