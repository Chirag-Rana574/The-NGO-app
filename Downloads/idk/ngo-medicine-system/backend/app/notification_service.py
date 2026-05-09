"""
Push notification service using Expo Push API.
Sends push notifications to mobile devices and stores in-app notification history.
"""
import json
import logging
from datetime import datetime, timezone
from typing import Optional, List
from sqlalchemy.orm import Session

from exponent_server_sdk import (
    PushClient,
    PushMessage,
    PushServerError,
)

from .database import SessionLocal
from .models import PushToken, Notification, NotificationSeverity, User

logger = logging.getLogger(__name__)

# Expo Push client
_push_client = PushClient()


def send_push_to_all(
    db: Session,
    title: str,
    body: str,
    notification_type: str,
    severity: NotificationSeverity = NotificationSeverity.NORMAL,
    data: Optional[dict] = None,
    user_id: Optional[int] = None,
):
    """
    Send a push notification to all registered devices and save to notification history.
    
    Args:
        db: Database session
        title: Notification title
        body: Notification body
        notification_type: Type (TASK_COMPLETED, TASK_OVERDUE, TASK_MISSED, LOW_STOCK, DAILY_SUMMARY)
        severity: NORMAL, MODERATE, or SERIOUS
        data: Extra data dict (e.g. schedule_id, medicine_id)
        user_id: Optional user to associate notification with
    """
    # Save to notification history
    notification = Notification(
        user_id=user_id,
        type=notification_type,
        title=title,
        body=body,
        severity=severity,
        data=json.dumps(data) if data else None,
    )
    db.add(notification)
    
    # Get all push tokens
    tokens = db.query(PushToken).all()
    
    if not tokens:
        logger.info(f"No push tokens registered — notification saved to DB only: {title}")
        return
    
    # Build push messages
    messages = []
    for token_record in tokens:
        try:
            messages.append(
                PushMessage(
                    to=token_record.token,
                    title=title,
                    body=body,
                    data=data or {},
                    sound="default",
                    priority="high" if severity == NotificationSeverity.SERIOUS else "default",
                    channel_id="default",
                )
            )
        except Exception as e:
            logger.error(f"Error building push message for token {token_record.token}: {e}")
    
    if not messages:
        return
    
    # Send in batches
    try:
        responses = _push_client.publish_multiple(messages)
        logger.info(f"📱 Sent {len(responses)} push notifications: {title}")
    except PushServerError as e:
        logger.error(f"Push server error: {e}")
    except Exception as e:
        logger.error(f"Push notification error: {e}")


# Convenience functions for each notification type

def notify_task_completed(db: Session, schedule_id: int, patient_name: str, medicine_name: str, worker_name: str):
    """✅ Normal notification when a task is completed."""
    send_push_to_all(
        db=db,
        title=f"✅ Task #{schedule_id} completed",
        body=f"{worker_name} gave {medicine_name} to {patient_name}",
        notification_type="TASK_COMPLETED",
        severity=NotificationSeverity.NORMAL,
        data={"schedule_id": schedule_id},
    )


def notify_task_overdue(db: Session, schedule_id: int, patient_name: str, medicine_name: str, minutes_overdue: int):
    """⚠️ Serious notification when task is overdue (+10 min, no response)."""
    send_push_to_all(
        db=db,
        title=f"⚠️ Task #{schedule_id} overdue — no response",
        body=f"{medicine_name} for {patient_name} is {minutes_overdue} min overdue",
        notification_type="TASK_OVERDUE",
        severity=NotificationSeverity.SERIOUS,
        data={"schedule_id": schedule_id},
    )


def notify_task_missed(db: Session, schedule_id: int, patient_name: str, medicine_name: str, reason: str = "expired"):
    """❌ Serious notification when task is missed/expired/not done."""
    if reason == "not_done":
        title = f"❌ Task #{schedule_id} — NOT GIVEN"
        body = f"{medicine_name} for {patient_name} was reported as not given"
    else:
        title = f"❌ Task #{schedule_id} missed"
        body = f"{medicine_name} for {patient_name} — no response received"
    
    send_push_to_all(
        db=db,
        title=title,
        body=body,
        notification_type="TASK_MISSED",
        severity=NotificationSeverity.SERIOUS,
        data={"schedule_id": schedule_id, "reason": reason},
    )


def notify_low_stock(db: Session, medicine_name: str, medicine_id: int, current_stock: int, unit: str):
    """💊 Moderate notification for low stock."""
    send_push_to_all(
        db=db,
        title=f"💊 {medicine_name} — low stock",
        body=f"Only {current_stock} {unit} remaining",
        notification_type="LOW_STOCK",
        severity=NotificationSeverity.MODERATE,
        data={"medicine_id": medicine_id, "current_stock": current_stock},
    )


def notify_daily_summary(
    db: Session,
    completed: int,
    not_done: int,
    missed: int,
    pending: int,
    low_stock_items: List[str],
):
    """📋 End-of-day summary notification."""
    lines = [
        f"Completed: {completed}",
        f"Not given: {not_done}",
        f"Missed: {missed}",
    ]
    if pending > 0:
        lines.append(f"Still pending: {pending}")
    if low_stock_items:
        lines.append(f"Low stock: {', '.join(low_stock_items)}")
    
    body = " | ".join(lines)
    
    send_push_to_all(
        db=db,
        title="📋 Daily Summary",
        body=body,
        notification_type="DAILY_SUMMARY",
        severity=NotificationSeverity.NORMAL,
        data={
            "completed": completed,
            "not_done": not_done,
            "missed": missed,
            "pending": pending,
            "low_stock": low_stock_items,
        },
    )
