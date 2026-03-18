"""
App settings endpoints (timezone, etc.)
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
import logging

from ..database import get_db
from ..models import SystemConfig
from ..config import get_settings

router = APIRouter(prefix="/settings", tags=["Settings"])
logger = logging.getLogger(__name__)
settings = get_settings()


class TimezoneUpdate(BaseModel):
    timezone: str


@router.get("", summary="Get app settings")
async def get_app_settings(db: Session = Depends(get_db)):
    """Get current app settings."""
    # Get timezone from system_config, fallback to .env default
    tz_config = db.query(SystemConfig).filter(SystemConfig.key == "timezone").first()
    current_tz = tz_config.value if tz_config else settings.timezone
    
    return {
        "timezone": current_tz,
        "low_stock_threshold": settings.low_stock_threshold,
        "response_window_minutes": settings.response_window_minutes,
    }


@router.put("/timezone", summary="Update app timezone")
async def update_timezone(data: TimezoneUpdate, db: Session = Depends(get_db)):
    """Update the app timezone."""
    # Validate timezone
    try:
        from zoneinfo import ZoneInfo
        ZoneInfo(data.timezone)
    except Exception:
        raise HTTPException(status_code=400, detail=f"Invalid timezone: {data.timezone}")
    
    # Upsert system_config
    existing = db.query(SystemConfig).filter(SystemConfig.key == "timezone").first()
    if existing:
        existing.value = data.timezone
    else:
        db.add(SystemConfig(key="timezone", value=data.timezone))
    
    db.commit()
    
    logger.info(f"Timezone updated to: {data.timezone}")
    return {"status": "updated", "timezone": data.timezone}
