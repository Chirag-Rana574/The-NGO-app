from celery import Task
from datetime import datetime, timedelta
from twilio.rest import Client
from sqlalchemy.orm import Session
import logging
from .celery_app import celery_app
from .database import SessionLocal
from .models import Schedule, ScheduleStatus, Medicine
from .state_machine import StateMachine
from .stock_service import StockService
from .utils import format_whatsapp_number
from .config import get_settings

logger = logging.getLogger(__name__)
settings = get_settings()

# Initialize Twilio client
twilio_client = Client(settings.twilio_account_sid, settings.twilio_auth_token)


class DatabaseTask(Task):
    """Base task with database session management"""
    _db = None
    
    @property
    def db(self) -> Session:
        if self._db is None:
            self._db = SessionLocal()
        return self._db
    
    def after_return(self, *args, **kwargs):
        if self._db is not None:
            self._db.close()
            self._db = None


@celery_app.task(base=DatabaseTask, bind=True)
def send_reminders(self):
    """
    Send WhatsApp reminders for upcoming schedules.
    Runs every minute to check for schedules that need reminders.
    """
    db = self.db
    now = datetime.utcnow()
    reminder_time = now + timedelta(minutes=settings.reminder_advance_minutes)
    
    # Find schedules that need reminders
    # Status should be CREATED and scheduled_time is within reminder window
    schedules_to_remind = db.query(Schedule).filter(
        Schedule.status == ScheduleStatus.CREATED,
        Schedule.scheduled_time <= reminder_time,
        Schedule.scheduled_time > now,
        Schedule.deleted_at.is_(None)
    ).all()
    
    logger.info(f"Found {len(schedules_to_remind)} schedules to remind")
    
    for schedule in schedules_to_remind:
        try:
            # Send WhatsApp reminder
            worker_phone = format_whatsapp_number(schedule.worker.mobile_number)
            
            message_body = (
                f"Task #{schedule.id}\n"
                f"Give {schedule.medicine.name} ({schedule.dose_amount} {schedule.medicine.dosage_unit}) "
                f"to {schedule.patient.name}\n"
                f"on {schedule.scheduled_time.strftime('%I:%M %p')} {schedule.scheduled_time.strftime('%d/%m/%Y')}\n\n"
                f"Reply:\n1 = YES (GIVEN)\n2 = NO (NOT GIVEN)"
            )
            
            twilio_client.messages.create(
                from_=settings.twilio_whatsapp_number,
                to=worker_phone,
                body=message_body
            )
            
            # Transition to REMINDER_SENT
            StateMachine.transition(
                db=db,
                schedule=schedule,
                target_status=ScheduleStatus.REMINDER_SENT,
                reason="Reminder sent via WhatsApp",
                performed_by="SYSTEM"
            )
            
            logger.info(f"Sent reminder for schedule #{schedule.id} to {schedule.worker.name}")
            
        except Exception as e:
            logger.error(f"Failed to send reminder for schedule #{schedule.id}: {e}")
            continue
    
    db.commit()
    return {"reminded": len(schedules_to_remind)}


@celery_app.task(base=DatabaseTask, bind=True)
def transition_to_awaiting_response(self):
    """
    Transition schedules from REMINDER_SENT to AWAITING_RESPONSE at scheduled time.
    This should run frequently (e.g., every minute).
    """
    db = self.db
    now = datetime.utcnow()
    
    # Find schedules that have passed their scheduled time
    schedules_to_transition = db.query(Schedule).filter(
        Schedule.status == ScheduleStatus.REMINDER_SENT,
        Schedule.scheduled_time <= now,
        Schedule.deleted_at.is_(None)
    ).all()
    
    logger.info(f"Found {len(schedules_to_transition)} schedules to transition to AWAITING_RESPONSE")
    
    for schedule in schedules_to_transition:
        try:
            StateMachine.transition(
                db=db,
                schedule=schedule,
                target_status=ScheduleStatus.AWAITING_RESPONSE,
                reason="Scheduled time reached",
                performed_by="SYSTEM"
            )
            logger.info(f"Transitioned schedule #{schedule.id} to AWAITING_RESPONSE")
        except Exception as e:
            logger.error(f"Failed to transition schedule #{schedule.id}: {e}")
            continue
    
    db.commit()
    return {"transitioned": len(schedules_to_transition)}


@celery_app.task(base=DatabaseTask, bind=True)
def expire_schedules(self):
    """
    Mark schedules as EXPIRED if no response received by expiry cutoff.
    Runs every 5 minutes.
    """
    db = self.db
    now = datetime.utcnow()
    
    # Find schedules that have expired
    schedules_to_expire = db.query(Schedule).filter(
        Schedule.status == ScheduleStatus.AWAITING_RESPONSE,
        Schedule.deleted_at.is_(None)
    ).all()
    
    expired_count = 0
    
    for schedule in schedules_to_expire:
        expiry_cutoff = schedule.scheduled_time + timedelta(
            hours=settings.expiry_cutoff_hours
        )
        
        if now > expiry_cutoff:
            try:
                StateMachine.transition(
                    db=db,
                    schedule=schedule,
                    target_status=ScheduleStatus.EXPIRED,
                    reason=f"No response received by {expiry_cutoff}",
                    performed_by="SYSTEM"
                )
                logger.info(f"Expired schedule #{schedule.id}")
                expired_count += 1
            except Exception as e:
                logger.error(f"Failed to expire schedule #{schedule.id}: {e}")
                continue
    
    db.commit()
    return {"expired": expired_count}


@celery_app.task(base=DatabaseTask, bind=True)
def check_stock_alerts(self):
    """
    Check for low stock and send alerts to supervisors.
    Runs every hour.
    """
    db = self.db
    
    low_stock_medicines = StockService.check_low_stock(
        db=db,
        threshold=settings.low_stock_threshold
    )
    
    if low_stock_medicines:
        logger.warning(f"Low stock alert: {len(low_stock_medicines)} medicines below threshold")
        
        # In production, send notifications to supervisors
        # For now, just log
        for medicine in low_stock_medicines:
            logger.warning(
                f"LOW STOCK: {medicine.name} - "
                f"Current: {medicine.current_stock} {medicine.dosage_unit}"
            )
    
    return {"low_stock_count": len(low_stock_medicines)}


# Register the transition task in beat schedule
celery_app.conf.beat_schedule["transition-to-awaiting-every-minute"] = {
    "task": "app.tasks.transition_to_awaiting_response",
    "schedule": 60.0,
}
