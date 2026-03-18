"""
Background reminder scheduler for multi-stage WhatsApp reminders.
Runs as an asyncio background task — no Celery/Redis required.

Reminder stages (relative to scheduled_time):
  Stage 1: -10 min  ⏰ Coming up
  Stage 2:  -5 min  ⏰ Due soon
  Stage 3:   0 min  🔔 Due NOW
  Stage 4:  +5 min  ⚠️ Overdue (5 min)
  Stage 5: +10 min  ⚠️ Overdue (10 min)
  Stage 6: +15 min  🚨 FINAL reminder
"""
import asyncio
import logging
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
from twilio.rest import Client
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import text

from .database import SessionLocal
from .models import Schedule, ScheduleStatus, Medicine
from .state_machine import StateMachine
from .utils import format_whatsapp_number
from .config import get_settings
from . import notification_service

logger = logging.getLogger(__name__)
settings = get_settings()

# Twilio client
_twilio_client = Client(settings.twilio_account_sid, settings.twilio_auth_token)

# Reminder stages: offset in minutes from scheduled_time
REMINDER_OFFSETS = [-10, -5, 0, +5, +10, +15]

# How often the scheduler loop runs (seconds)
SCHEDULER_INTERVAL = 30

# Local timezone from settings
_local_tz = ZoneInfo(settings.timezone)

# Background task handle
_scheduler_task = None


def _build_message(schedule: Schedule) -> str:
    """Build the WhatsApp reminder message in the user's original format."""
    # Convert scheduled_time to local timezone
    utc_time = schedule.scheduled_time
    if utc_time.tzinfo is None:
        utc_time = utc_time.replace(tzinfo=timezone.utc)
    local_time = utc_time.astimezone(_local_tz)
    
    time_str = local_time.strftime("%I:%M %p")   # e.g. 05:55 PM
    date_str = local_time.strftime("%d/%m/%Y")    # e.g. 05/03/2026
    
    return (
        f"Task #{schedule.id}\n"
        f"Give {schedule.medicine.name} ({schedule.dose_amount} {schedule.medicine.dosage_unit}) "
        f"to {schedule.patient.name}\n"
        f"on {time_str} {date_str}\n\n"
        f"Reply:\n"
        f"1 = YES (GIVEN)\n"
        f"2 = NO (NOT GIVEN)"
    )


def _get_due_stage(schedule: Schedule, now: datetime) -> int | None:
    """
    Determine which reminder stage is due for this schedule.
    Returns the stage index (0-5) or None if no new stage is due.
    """
    already_sent = schedule.reminder_count  # 0 to 6
    
    if already_sent >= len(REMINDER_OFFSETS):
        return None  # All reminders sent
    
    # Check each stage from the next unsent one
    for stage_idx in range(already_sent, len(REMINDER_OFFSETS)):
        offset_minutes = REMINDER_OFFSETS[stage_idx]
        trigger_time = schedule.scheduled_time + timedelta(minutes=offset_minutes)
        
        # Make trigger_time offset-aware if needed
        if trigger_time.tzinfo is None:
            trigger_time = trigger_time.replace(tzinfo=timezone.utc)
        
        if now >= trigger_time:
            return stage_idx
    
    return None


def _process_reminders():
    """Query DB and send due reminders. Runs in a sync context."""
    db: Session = SessionLocal()
    
    try:
        # Quick connectivity check — skip gracefully if DB is down
        try:
            db.execute(text("SELECT 1"))
        except Exception as e:
            logger.warning(f"⚠️  DB unavailable, skipping reminder check: {type(e).__name__}")
            return
        
        now = datetime.now(timezone.utc)
        
        # Window: from 10 min before earliest possible to 15 min after latest
        window_start = now - timedelta(minutes=15 + 5)  # buffer
        window_end = now + timedelta(minutes=10 + 5)    # buffer
        
        # Find schedules that might need reminders
        schedules = db.query(Schedule).options(
            joinedload(Schedule.worker),
            joinedload(Schedule.medicine),
            joinedload(Schedule.patient)
        ).filter(
            Schedule.deleted_at.is_(None),
            Schedule.status.in_([
                ScheduleStatus.CREATED,
                ScheduleStatus.REMINDER_SENT,
                ScheduleStatus.AWAITING_RESPONSE
            ]),
            Schedule.reminder_count < len(REMINDER_OFFSETS),
            Schedule.scheduled_time >= window_start,
            Schedule.scheduled_time <= window_end,
        ).all()
        
        if not schedules:
            return
        
        logger.info(f"Scheduler: checking {len(schedules)} active schedules")
        
        for schedule in schedules:
            try:
                stage_idx = _get_due_stage(schedule, now)
                if stage_idx is None:
                    continue
                
                offset_minutes = REMINDER_OFFSETS[stage_idx]
                
                # Build and send WhatsApp message
                worker_phone = format_whatsapp_number(schedule.worker.mobile_number)
                message_body = _build_message(schedule)
                
                message = _twilio_client.messages.create(
                    from_=settings.twilio_whatsapp_number,
                    to=worker_phone,
                    body=message_body
                )
                
                logger.info(
                    f"📨 Sent reminder {stage_idx + 1}/6 (offset {offset_minutes:+d} min) "
                    f"for Task #{schedule.id} to {schedule.worker.name} "
                    f"[SID: {message.sid}]"
                )
                
                # Update reminder tracking
                schedule.reminder_count = stage_idx + 1
                schedule.last_reminder_at = now
                
                # State transitions on first reminder
                if schedule.status == ScheduleStatus.CREATED:
                    StateMachine.transition(
                        db=db, schedule=schedule,
                        target_status=ScheduleStatus.REMINDER_SENT,
                        reason=f"Reminder stage {stage_idx + 1} sent",
                        performed_by="SCHEDULER"
                    )
                
                if schedule.status == ScheduleStatus.REMINDER_SENT:
                    StateMachine.transition(
                        db=db, schedule=schedule,
                        target_status=ScheduleStatus.AWAITING_RESPONSE,
                        reason="Now accepting worker replies",
                        performed_by="SCHEDULER"
                    )
                
                # Push notification: overdue at stage 5 (+10 min)
                if stage_idx == 4:  # 0-indexed, stage 5 = +10 min
                    try:
                        notification_service.notify_task_overdue(
                            db=db,
                            schedule_id=schedule.id,
                            patient_name=schedule.patient.name,
                            medicine_name=schedule.medicine.name,
                            minutes_overdue=10,
                        )
                    except Exception as ne:
                        logger.error(f"Push notification error: {ne}")
                
                db.commit()
                
            except Exception as e:
                db.rollback()
                logger.error(f"Scheduler: error processing Task #{schedule.id}: {e}", exc_info=True)
                continue
        
        # Auto-expire schedules past final reminder window with no response
        _auto_expire(db, now)
        
    except Exception as e:
        logger.error(f"Scheduler: unexpected error: {e}", exc_info=True)
    finally:
        db.close()


def _auto_expire(db: Session, now: datetime):
    """Auto-expire schedules that are past +15 min with all reminders sent and no reply."""
    try:
        overdue_schedules = db.query(Schedule).filter(
            Schedule.deleted_at.is_(None),
            Schedule.status == ScheduleStatus.AWAITING_RESPONSE,
            Schedule.reminder_count >= len(REMINDER_OFFSETS),
        ).all()
        
        for schedule in overdue_schedules:
            expiry_time = schedule.scheduled_time + timedelta(minutes=20)  # 15 + 5 min grace
            if expiry_time.tzinfo is None:
                expiry_time = expiry_time.replace(tzinfo=timezone.utc)
            
            if now >= expiry_time:
                StateMachine.transition(
                    db=db, schedule=schedule,
                    target_status=ScheduleStatus.EXPIRED,
                    reason="No response after all 6 reminders",
                    performed_by="SCHEDULER"
                )
                logger.warning(f"⏰ Auto-expired Task #{schedule.id} — no reply after 6 reminders")
                
                # Push notification: task missed
                try:
                    notification_service.notify_task_missed(
                        db=db,
                        schedule_id=schedule.id,
                        patient_name=schedule.patient.name,
                        medicine_name=schedule.medicine.name,
                        reason="expired",
                    )
                except Exception as ne:
                    logger.error(f"Push notification error: {ne}")
        
        db.commit()
    except Exception as e:
        db.rollback()
        logger.error(f"Scheduler: error in auto-expire: {e}", exc_info=True)


def _check_low_stock():
    """Check for low stock medicines and send notifications."""
    db: Session = SessionLocal()
    try:
        low_stock = db.query(Medicine).filter(
            Medicine.current_stock <= Medicine.min_stock_level,
            Medicine.is_active == True,
            Medicine.deleted_at.is_(None),
        ).all()
        
        for med in low_stock:
            notification_service.notify_low_stock(
                db=db,
                medicine_name=med.name,
                medicine_id=med.id,
                current_stock=med.current_stock,
                unit=med.dosage_unit,
            )
        
        if low_stock:
            db.commit()
            logger.info(f"💊 Sent low-stock notifications for {len(low_stock)} medicines")
    except Exception as e:
        db.rollback()
        logger.error(f"Low stock check error: {e}", exc_info=True)
    finally:
        db.close()


def _daily_summary():
    """Generate and send end-of-day summary notification."""
    from sqlalchemy import func, cast, Date
    
    db: Session = SessionLocal()
    try:
        today = datetime.now(timezone.utc).date()
        
        # Count schedules by status for today
        base_q = db.query(Schedule).filter(
            cast(Schedule.scheduled_time, Date) == today,
            Schedule.deleted_at.is_(None),
        )
        
        completed = base_q.filter(Schedule.status.in_([
            ScheduleStatus.COMPLETED, ScheduleStatus.LATE_COMPLETED
        ])).count()
        
        not_done = base_q.filter(Schedule.status == ScheduleStatus.NOT_DONE).count()
        missed = base_q.filter(Schedule.status == ScheduleStatus.EXPIRED).count()
        pending = base_q.filter(Schedule.status.in_([
            ScheduleStatus.CREATED, ScheduleStatus.REMINDER_SENT, ScheduleStatus.AWAITING_RESPONSE
        ])).count()
        
        # Low stock medicines
        low_stock = db.query(Medicine).filter(
            Medicine.current_stock <= Medicine.min_stock_level,
            Medicine.is_active == True,
            Medicine.deleted_at.is_(None),
        ).all()
        low_stock_names = [m.name for m in low_stock]
        
        notification_service.notify_daily_summary(
            db=db,
            completed=completed,
            not_done=not_done,
            missed=missed,
            pending=pending,
            low_stock_items=low_stock_names,
        )
        db.commit()
        logger.info(f"📋 Daily summary sent: {completed} done, {not_done} not done, {missed} missed")
    except Exception as e:
        db.rollback()
        logger.error(f"Daily summary error: {e}", exc_info=True)
    finally:
        db.close()


async def _scheduler_loop():
    """Main async loop that runs _process_reminders every SCHEDULER_INTERVAL seconds."""
    logger.info(f"🚀 Reminder scheduler started (interval: {SCHEDULER_INTERVAL}s)")
    
    low_stock_counter = 0  # Check every 6 hours (720 ticks at 30s interval)
    daily_summary_sent_today = None
    
    while True:
        try:
            # Run the sync DB work in a thread to avoid blocking the event loop
            await asyncio.to_thread(_process_reminders)
            
            # Low stock check every 6 hours (720 * 30s = 6 hours)
            low_stock_counter += 1
            if low_stock_counter >= 720:
                low_stock_counter = 0
                await asyncio.to_thread(_check_low_stock)
            
            # Daily summary at 9 PM local time (21:00)
            now_local = datetime.now(ZoneInfo(settings.timezone))
            if now_local.hour == 21 and daily_summary_sent_today != now_local.date():
                daily_summary_sent_today = now_local.date()
                await asyncio.to_thread(_daily_summary)
            
        except asyncio.CancelledError:
            logger.info("🛑 Reminder scheduler stopped")
            break
        except Exception as e:
            logger.error(f"Scheduler loop error: {e}", exc_info=True)
        
        await asyncio.sleep(SCHEDULER_INTERVAL)


def start_scheduler():
    """Start the background reminder scheduler."""
    global _scheduler_task
    if _scheduler_task is None or _scheduler_task.done():
        _scheduler_task = asyncio.create_task(_scheduler_loop())
        logger.info("Reminder scheduler task created")


def stop_scheduler():
    """Stop the background reminder scheduler."""
    global _scheduler_task
    if _scheduler_task and not _scheduler_task.done():
        _scheduler_task.cancel()
        logger.info("Reminder scheduler task cancelled")
