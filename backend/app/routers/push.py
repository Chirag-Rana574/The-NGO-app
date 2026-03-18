"""
Push notification token management and notification history endpoints.
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
import logging

from ..database import get_db
from ..models import PushToken, Notification
from ..routers.google_auth import get_current_user
from ..models import User

router = APIRouter(prefix="/push", tags=["Push Notifications"])
logger = logging.getLogger(__name__)


class RegisterTokenRequest(BaseModel):
    token: str
    device_info: Optional[str] = None


class NotificationResponse(BaseModel):
    id: int
    type: str
    title: str
    body: str
    severity: str
    is_read: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


@router.post("/register", summary="Register an Expo Push Token")
async def register_push_token(
    req: RegisterTokenRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Register or update a push notification token for the current user."""
    # Check if token already exists
    existing = db.query(PushToken).filter(PushToken.token == req.token).first()
    
    if existing:
        # Update ownership if different user
        existing.user_id = current_user.id
        existing.device_info = req.device_info
        db.commit()
        return {"status": "updated", "token": req.token}
    
    # Create new token
    token = PushToken(
        user_id=current_user.id,
        token=req.token,
        device_info=req.device_info,
    )
    db.add(token)
    db.commit()
    
    logger.info(f"Registered push token for user {current_user.email}")
    return {"status": "registered", "token": req.token}


@router.delete("/unregister", summary="Remove a push token (e.g. on logout)")
async def unregister_push_token(
    token: str,
    db: Session = Depends(get_db),
):
    """Remove a push notification token."""
    deleted = db.query(PushToken).filter(PushToken.token == token).delete()
    db.commit()
    
    if deleted:
        logger.info(f"Unregistered push token: {token[:20]}...")
    
    return {"status": "removed", "deleted": deleted}


@router.get("/notifications", response_model=List[NotificationResponse], summary="Get notification history")
async def get_notifications(
    limit: int = 50,
    unread_only: bool = False,
    db: Session = Depends(get_db),
):
    """Get notification history for in-app display."""
    query = db.query(Notification).order_by(Notification.created_at.desc())
    
    if unread_only:
        query = query.filter(Notification.is_read == False)
    
    return query.limit(limit).all()


@router.post("/notifications/{notification_id}/read", summary="Mark notification as read")
async def mark_read(notification_id: int, db: Session = Depends(get_db)):
    """Mark a notification as read."""
    notification = db.query(Notification).filter(Notification.id == notification_id).first()
    if not notification:
        raise HTTPException(status_code=404, detail="Notification not found")
    
    notification.is_read = True
    db.commit()
    return {"status": "read"}


@router.post("/notifications/read-all", summary="Mark all notifications as read")
async def mark_all_read(db: Session = Depends(get_db)):
    """Mark all notifications as read."""
    db.query(Notification).filter(Notification.is_read == False).update({"is_read": True})
    db.commit()
    return {"status": "all_read"}


@router.get("/notifications/unread-count", summary="Get unread notification count")
async def unread_count(db: Session = Depends(get_db)):
    """Get the count of unread notifications (for badge display)."""
    count = db.query(Notification).filter(Notification.is_read == False).count()
    return {"unread_count": count}
