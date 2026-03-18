"""
Manual WhatsApp testing endpoints.
These bypass Celery/Redis and let you test Twilio WhatsApp directly from Swagger.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from twilio.rest import Client
from pydantic import BaseModel
from typing import Optional
import logging

from ..database import get_db
from ..models import Worker, Schedule, ScheduleStatus
from ..config import get_settings
from ..utils import format_whatsapp_number
from ..state_machine import StateMachine
from datetime import timezone
from zoneinfo import ZoneInfo

router = APIRouter(prefix="/test-whatsapp", tags=["WhatsApp Testing"])
logger = logging.getLogger(__name__)
settings = get_settings()

# Twilio client
_twilio_client = Client(settings.twilio_account_sid, settings.twilio_auth_token)


class SendMessageRequest(BaseModel):
    """Send a freeform WhatsApp message to any number."""
    to: str  # e.g. "+919876543210"
    message: str


class SendReminderRequest(BaseModel):
    """Send a medicine reminder to a specific schedule."""
    schedule_id: int


@router.post("/send-message", summary="Send a test WhatsApp message")
async def send_test_message(req: SendMessageRequest):
    """
    Send a WhatsApp message to any phone number via the Twilio sandbox.
    The 'to' number must have joined the sandbox first.
    Format: +91XXXXXXXXXX (with country code)
    """
    try:
        to_number = f"whatsapp:{req.to}" if not req.to.startswith("whatsapp:") else req.to
        
        message = _twilio_client.messages.create(
            from_=settings.twilio_whatsapp_number,
            to=to_number,
            body=req.message
        )
        
        logger.info(f"Sent WhatsApp message {message.sid} to {req.to}")
        return {
            "status": "sent",
            "message_sid": message.sid,
            "to": req.to,
            "body": req.message
        }
    except Exception as e:
        logger.error(f"Failed to send WhatsApp message: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/send-reminder/{schedule_id}", summary="Send a medicine reminder for a schedule")
async def send_test_reminder(schedule_id: int, db: Session = Depends(get_db)):
    """
    Send a WhatsApp reminder for a specific schedule.
    This bypasses the Celery scheduler and sends immediately.
    """
    schedule = db.query(Schedule).filter(
        Schedule.id == schedule_id,
        Schedule.deleted_at.is_(None)
    ).first()
    
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    
    worker = schedule.worker
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found for this schedule")
    
    try:
        worker_phone = format_whatsapp_number(worker.mobile_number)
        
        _local_tz = ZoneInfo(settings.timezone)
        utc_time = schedule.scheduled_time
        if utc_time.tzinfo is None:
            utc_time = utc_time.replace(tzinfo=timezone.utc)
        local_time = utc_time.astimezone(_local_tz)
        
        message_body = (
            f"Task #{schedule.id}\n"
            f"Give {schedule.medicine.name} ({schedule.dose_amount} {schedule.medicine.dosage_unit}) "
            f"to {schedule.patient.name}\n"
            f"on {local_time.strftime('%I:%M %p')} {local_time.strftime('%d/%m/%Y')}\n\n"
            f"Reply:\n1 = YES (GIVEN)\n2 = NO (NOT GIVEN)"
        )
        
        message = _twilio_client.messages.create(
            from_=settings.twilio_whatsapp_number,
            to=worker_phone,
            body=message_body
        )
        
        logger.info(f"Sent test reminder {message.sid} for schedule #{schedule_id}")
        return {
            "status": "sent",
            "message_sid": message.sid,
            "schedule_id": schedule_id,
            "to": worker_phone,
            "body": message_body
        }
    except Exception as e:
        logger.error(f"Failed to send test reminder: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status", summary="Check Twilio connection status")
async def twilio_status():
    """Check if Twilio credentials are working."""
    try:
        account = _twilio_client.api.accounts(settings.twilio_account_sid).fetch()
        return {
            "status": "connected",
            "account_name": account.friendly_name,
            "account_status": account.status,
            "whatsapp_number": settings.twilio_whatsapp_number
        }
    except Exception as e:
        logger.error(f"Twilio connection check failed: {e}")
        raise HTTPException(status_code=500, detail=f"Twilio error: {str(e)}")


@router.post("/activate/{schedule_id}", summary="Send reminder AND make schedule ready for replies")
async def activate_schedule(schedule_id: int, db: Session = Depends(get_db)):
    """
    Full test flow in one call:
    1. Sends the WhatsApp reminder message
    2. Transitions schedule: CREATED → REMINDER_SENT → AWAITING_RESPONSE
    
    After calling this, the worker can reply 1 or 2 on WhatsApp and it will be processed.
    """
    schedule = db.query(Schedule).filter(
        Schedule.id == schedule_id,
        Schedule.deleted_at.is_(None)
    ).first()
    
    if not schedule:
        raise HTTPException(status_code=404, detail="Schedule not found")
    
    worker = schedule.worker
    if not worker:
        raise HTTPException(status_code=404, detail="Worker not found")
    
    # Step 1: Send the WhatsApp reminder
    try:
        worker_phone = format_whatsapp_number(worker.mobile_number)
        
        _local_tz = ZoneInfo(settings.timezone)
        utc_time = schedule.scheduled_time
        if utc_time.tzinfo is None:
            utc_time = utc_time.replace(tzinfo=timezone.utc)
        local_time = utc_time.astimezone(_local_tz)
        
        message_body = (
            f"Task #{schedule.id}\n"
            f"Give {schedule.medicine.name} ({schedule.dose_amount} {schedule.medicine.dosage_unit}) "
            f"to {schedule.patient.name}\n"
            f"on {local_time.strftime('%I:%M %p')} {local_time.strftime('%d/%m/%Y')}\n\n"
            f"Reply:\n1 = YES (GIVEN)\n2 = NO (NOT GIVEN)"
        )
        
        message = _twilio_client.messages.create(
            from_=settings.twilio_whatsapp_number,
            to=worker_phone,
            body=message_body
        )
        
        logger.info(f"Sent reminder {message.sid} for schedule #{schedule_id}")
    except Exception as e:
        logger.error(f"Failed to send reminder: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to send WhatsApp: {str(e)}")
    
    # Step 2: Transition CREATED → REMINDER_SENT
    if schedule.status == ScheduleStatus.CREATED:
        StateMachine.transition(
            db=db, schedule=schedule,
            target_status=ScheduleStatus.REMINDER_SENT,
            reason="Test reminder sent via WhatsApp",
            performed_by="TEST"
        )
    
    # Step 3: Transition REMINDER_SENT → AWAITING_RESPONSE
    if schedule.status == ScheduleStatus.REMINDER_SENT:
        StateMachine.transition(
            db=db, schedule=schedule,
            target_status=ScheduleStatus.AWAITING_RESPONSE,
            reason="Activated for testing — ready for worker reply",
            performed_by="TEST"
        )
    
    db.commit()
    
    return {
        "status": "activated",
        "schedule_id": schedule_id,
        "schedule_status": schedule.status.value,
        "message_sid": message.sid,
        "to": worker_phone,
        "body": message_body,
        "instructions": "Reply 1 (YES/GIVEN) or 2 (NO/NOT GIVEN) on WhatsApp to process this task"
    }
