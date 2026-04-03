from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from datetime import datetime, timedelta, timezone
import logging
from twilio.request_validator import RequestValidator
from twilio.rest import Client as TwilioClient
from ..database import get_db
from ..models import Schedule, ScheduleStatus, Worker
from ..schemas import WhatsAppWebhookPayload, SuccessResponse, ErrorResponse
from ..utils import parse_whatsapp_number, normalize_phone_number, extract_first_digit
from ..state_machine import StateMachine, StateTransitionError
from ..stock_service import StockService, InsufficientStockError
from ..config import get_settings
from .. import notification_service

router = APIRouter(prefix="/whatsapp", tags=["WhatsApp"])
logger = logging.getLogger(__name__)
settings = get_settings()

# Twilio signature validator
_twilio_validator = RequestValidator(settings.twilio_auth_token)
_twilio_client = TwilioClient(settings.twilio_account_sid, settings.twilio_auth_token)


def _send_ack(to_number: str, message: str):
    """Send a WhatsApp acknowledgment reply to the worker."""
    try:
        _twilio_client.messages.create(
            body=message,
            from_=settings.twilio_whatsapp_number,
            to=f"whatsapp:{to_number}" if not to_number.startswith("whatsapp:") else to_number,
        )
        logger.info(f"Sent ack to {to_number}: {message}")
    except Exception as e:
        logger.error(f"Failed to send ack to {to_number}: {e}")


@router.post("/webhook", response_model=SuccessResponse)
async def whatsapp_webhook(
    request: Request,
    db: Session = Depends(get_db)
):
    """
    WhatsApp webhook endpoint for processing worker responses.
    
    Processing Rules:
    1. Verify Twilio signature
    2. Normalize sender phone number
    3. Verify worker exists and is active
    4. Extract first numeric digit from message
    4. Find worker's active schedule (AWAITING_RESPONSE)
    5. Process response based on digit:
       - 1 = Task completed (consume stock)
       - 2 = Task not done
    6. Handle time windows (on-time vs late vs expired)
    7. Idempotent processing using MessageSid
    """
    try:
        # Parse request body
        body = await request.form()
        
        # Validate Twilio signature (skip in debug/dev mode — tunnel URLs change)
        signature = request.headers.get("X-Twilio-Signature", "")
        url = str(request.url)
        form_params = dict(body)
        
        if not settings.debug and not _twilio_validator.validate(url, form_params, signature):
            logger.warning(f"Invalid Twilio signature from {request.client.host if request.client else 'unknown'}")
            raise HTTPException(status_code=403, detail="Invalid Twilio signature")
        elif settings.debug:
            logger.info("Skipping Twilio signature validation (debug mode)")
        
        payload = WhatsAppWebhookPayload(**body)
        
        logger.info(f"Received WhatsApp message: {payload.MessageSid} from {payload.From}")
        
        # Step 1: Normalize phone number
        try:
            raw_phone = parse_whatsapp_number(payload.From)
            normalized_phone = normalize_phone_number(raw_phone)
        except ValueError as e:
            logger.warning(f"Invalid phone number {payload.From}: {e}")
            return SuccessResponse(
                message="Invalid phone number format",
                data={"status": "ignored"}
            )
        
        # Step 2: Verify worker exists and is active
        worker = db.query(Worker).filter(
            Worker.mobile_number == normalized_phone,
            Worker.is_active == True,
            Worker.deleted_at.is_(None)
        ).first()
        
        if not worker:
            logger.warning(f"Worker not found or inactive: {normalized_phone}")
            return SuccessResponse(
                message="Worker not found or inactive",
                data={"status": "ignored"}
            )
        
        # Step 3: Extract first digit
        digit = extract_first_digit(payload.Body)
        if digit is None:
            logger.warning(f"No digit found in message from {worker.name}: {payload.Body}")
            return SuccessResponse(
                message="No valid digit in response",
                data={"status": "invalid_response"}
            )
        
        # Step 4: Find active schedule
        schedule = db.query(Schedule).filter(
            Schedule.worker_id == worker.id,
            Schedule.status == ScheduleStatus.AWAITING_RESPONSE,
            Schedule.deleted_at.is_(None)
        ).first()
        
        if not schedule:
            logger.warning(f"No active schedule for worker {worker.name}")
            return SuccessResponse(
                message="No active schedule found",
                data={"status": "no_active_schedule"}
            )
        
        # Idempotency check: prevent duplicate processing
        if schedule.twilio_message_sid == payload.MessageSid:
            logger.info(f"Duplicate message {payload.MessageSid} - already processed")
            return SuccessResponse(
                message="Message already processed",
                data={"status": "duplicate"}
            )
        
        if schedule.twilio_message_sid is not None:
            logger.warning(f"Schedule {schedule.id} already has response {schedule.twilio_message_sid}")
            return SuccessResponse(
                message="Schedule already has a response",
                data={"status": "already_responded"}
            )
        
        # Step 5: Determine time window status
        now = datetime.now(timezone.utc)
        response_window_end = schedule.scheduled_time + timedelta(
            minutes=settings.response_window_minutes
        )
        expiry_cutoff = schedule.scheduled_time + timedelta(
            hours=settings.expiry_cutoff_hours
        )
        
        # Check if response is after expiry cutoff
        if now > expiry_cutoff:
            logger.warning(
                f"Response from {worker.name} received after expiry cutoff "
                f"(scheduled: {schedule.scheduled_time}, received: {now})"
            )
            return SuccessResponse(
                message="Response received after expiry cutoff",
                data={"status": "expired"}
            )
        
        # Determine if response is late
        is_late = now > response_window_end
        
        # Step 6: Process response based on digit
        try:
            if digit == 1:
                # Task completed
                target_status = ScheduleStatus.LATE_COMPLETED if is_late else ScheduleStatus.COMPLETED
                
                # Consume stock
                try:
                    StockService.consume_for_task(
                        db=db,
                        schedule=schedule,
                        performed_by=f"Worker: {worker.name}"
                    )
                except InsufficientStockError as e:
                    logger.error(f"Insufficient stock for schedule {schedule.id}: {e}")
                    db.rollback()
                    raise HTTPException(
                        status_code=400,
                        detail=f"Insufficient stock: {str(e)}"
                    )
                
                # Transition state
                StateMachine.transition(
                    db=db,
                    schedule=schedule,
                    target_status=target_status,
                    reason=f"Worker response: {payload.Body}",
                    performed_by=f"Worker: {worker.name}",
                    additional_data={
                        "response_received_at": now,
                        "response_message": payload.Body,
                        "twilio_message_sid": payload.MessageSid
                    }
                )
                
                logger.info(
                    f"Task {schedule.id} marked as {target_status.value} "
                    f"by {worker.name}"
                )
                
                # Send push notification: task completed
                try:
                    notification_service.notify_task_completed(
                        db=db,
                        schedule_id=schedule.id,
                        patient_name=schedule.patient.name,
                        medicine_name=schedule.medicine.name,
                        worker_name=worker.name,
                    )
                except Exception as ne:
                    logger.error(f"Push notification error: {ne}")
                
                # Send WhatsApp acknowledgment
                _send_ack(
                    payload.From,
                    f"OK! Response registered for Task #{schedule.id}. Thank you \U0001f64f"
                )
                
            elif digit == 2:
                # Task not done
                StateMachine.transition(
                    db=db,
                    schedule=schedule,
                    target_status=ScheduleStatus.NOT_DONE,
                    reason=f"Worker response: {payload.Body}",
                    performed_by=f"Worker: {worker.name}",
                    additional_data={
                        "response_received_at": now,
                        "response_message": payload.Body,
                        "twilio_message_sid": payload.MessageSid
                    }
                )
                
                logger.info(f"Task {schedule.id} marked as NOT_DONE by {worker.name}")
                
                # Send push notification: task not done
                try:
                    notification_service.notify_task_missed(
                        db=db,
                        schedule_id=schedule.id,
                        patient_name=schedule.patient.name,
                        medicine_name=schedule.medicine.name,
                        reason="not_done",
                    )
                except Exception as ne:
                    logger.error(f"Push notification error: {ne}")
                
                # Send WhatsApp acknowledgment
                _send_ack(
                    payload.From,
                    f"Noted. Task #{schedule.id} marked as not given."
                )
                
            else:
                # Invalid digit (not 1 or 2)
                logger.warning(f"Invalid digit {digit} from {worker.name}")
                return SuccessResponse(
                    message=f"Invalid response digit: {digit}. Expected 1 or 2.",
                    data={"status": "invalid_digit"}
                )
            
            # Commit transaction
            db.commit()
            
            return SuccessResponse(
                message="Response processed successfully",
                data={
                    "status": "processed",
                    "schedule_id": schedule.id,
                    "new_status": schedule.status.value,
                    "is_late": is_late
                }
            )
            
        except StateTransitionError as e:
            db.rollback()
            logger.error(f"State transition error: {e}")
            raise HTTPException(status_code=400, detail=str(e))
        
    except IntegrityError as e:
        db.rollback()
        logger.error(f"Database integrity error: {e}")
        raise HTTPException(status_code=500, detail="Database error")
    
    except Exception as e:
        db.rollback()
        logger.error(f"Unexpected error processing webhook: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail="Internal server error")
