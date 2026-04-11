from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
import bcrypt
import logging
from typing import Optional
from ..database import get_db
from ..models import SystemConfig, User
from ..schemas import (
    SetupKeyRequest, ChangeKeyRequest, VerifyKeyRequest,
    KeyStatusResponse, SuccessResponse
)
from .google_auth import get_current_user
router = APIRouter(prefix="/auth", tags=["Authentication"])
logger = logging.getLogger(__name__)

MASTER_KEY_CONFIG = "master_key_hash"
MASTER_KEY_LENGTH = "master_key_length"

LAST_FAILURE_CONFIG = "master_key_last_failure"
FAILURE_COUNT_CONFIG = "master_key_failure_count"

def _get_key_hash(db: Session) -> Optional[str]:
    """Get the stored master key hash from DB."""
    config = db.query(SystemConfig).filter(SystemConfig.key == MASTER_KEY_CONFIG).first()
    return config.value if config else None


def _get_key_length(db: Session) -> Optional[int]:
    """Get the stored master key PIN length."""
    config = db.query(SystemConfig).filter(SystemConfig.key == MASTER_KEY_LENGTH).first()
    return int(config.value) if config else None


def verify_master_key(db: Session, pin: str) -> bool:
    """Verify a PIN against the stored master key hash."""
    stored_hash = _get_key_hash(db)
    if not stored_hash:
        return False
    return bcrypt.checkpw(pin.encode('utf-8'), stored_hash.encode('utf-8'))


@router.get("/key-status", response_model=KeyStatusResponse)
def get_key_status(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Check whether the master key has been set up."""
    stored_hash = _get_key_hash(db)
    pin_length = _get_key_length(db)
    return KeyStatusResponse(
        is_setup=stored_hash is not None,
        pin_length=pin_length
    )


@router.post("/setup-key", response_model=SuccessResponse)
def setup_key(request: SetupKeyRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Initial master key setup. Only works if no key exists yet.
    PIN must be 4-6 digits.
    """
    existing = _get_key_hash(db)
    if existing:
        raise HTTPException(
            status_code=400,
            detail="Master key already set up. Use /auth/change-key to change it."
        )
    
    # Hash the PIN with bcrypt
    hashed = bcrypt.hashpw(request.pin.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    # Store hash
    db.add(SystemConfig(key=MASTER_KEY_CONFIG, value=hashed))
    # Store PIN length (so frontend knows how many dots to show)
    db.add(SystemConfig(key=MASTER_KEY_LENGTH, value=str(len(request.pin))))
    db.commit()
    
    logger.info("Master key set up successfully")
    return SuccessResponse(message="Master key set up successfully")


@router.post("/verify-key", response_model=SuccessResponse)
def verify_key(request: VerifyKeyRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Verify a PIN against the stored master key.
    Used for medicine stock edits and near-term schedule edits.
    Implements brute-force lockout: 5 failed attempts → 15 min lockout.
    """
    stored_hash = _get_key_hash(db)
    if not stored_hash:
        raise HTTPException(status_code=400, detail="Master key not set up yet")
    
    # Check brute-force lockout
    import time as _time
    failure_count_config = db.query(SystemConfig).filter(SystemConfig.key == FAILURE_COUNT_CONFIG).first()
    last_failure_config = db.query(SystemConfig).filter(SystemConfig.key == LAST_FAILURE_CONFIG).first()
    
    failure_count = int(failure_count_config.value) if failure_count_config else 0
    last_failure_time = float(last_failure_config.value) if last_failure_config else 0
    
    MAX_ATTEMPTS = 5
    LOCKOUT_SECONDS = 900  # 15 minutes
    
    if failure_count >= MAX_ATTEMPTS:
        elapsed = _time.time() - last_failure_time
        if elapsed < LOCKOUT_SECONDS:
            remaining = int((LOCKOUT_SECONDS - elapsed) / 60) + 1
            raise HTTPException(
                status_code=429,
                detail=f"Too many failed attempts. Try again in {remaining} minutes."
            )
        else:
            # Lockout expired, reset counter
            failure_count = 0
    
    is_valid = bcrypt.checkpw(request.pin.encode('utf-8'), stored_hash.encode('utf-8'))
    
    if not is_valid:
        failure_count += 1
        # Update failure tracking
        if failure_count_config:
            failure_count_config.value = str(failure_count)
        else:
            db.add(SystemConfig(key=FAILURE_COUNT_CONFIG, value=str(failure_count)))
        if last_failure_config:
            last_failure_config.value = str(_time.time())
        else:
            db.add(SystemConfig(key=LAST_FAILURE_CONFIG, value=str(_time.time())))
        db.commit()
        
        logger.warning(f"FAILED PIN ATTEMPT by {current_user.email} (attempt {failure_count}/{MAX_ATTEMPTS})")
        import time
        time.sleep(2)
        
        remaining_attempts = MAX_ATTEMPTS - failure_count
        if remaining_attempts <= 0:
            raise HTTPException(status_code=429, detail="Too many failed attempts. Locked for 15 minutes.")
        raise HTTPException(status_code=403, detail=f"Invalid PIN ({remaining_attempts} attempts remaining)")
    
    # Success — reset failure counter
    if failure_count_config:
        failure_count_config.value = "0"
        db.commit()
    
    return SuccessResponse(message="PIN verified successfully", data={"valid": True})


@router.post("/change-key", response_model=SuccessResponse)
def change_key(request: ChangeKeyRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Change the master key. Requires the current PIN for verification.
    """
    stored_hash = _get_key_hash(db)
    if not stored_hash:
        raise HTTPException(status_code=400, detail="Master key not set up yet. Use /auth/setup-key.")
    
    # Verify current PIN
    if not bcrypt.checkpw(request.current_pin.encode('utf-8'), stored_hash.encode('utf-8')):
        logger.warning("Failed master key change attempt by {current_user.email} — wrong current PIN")
        raise HTTPException(status_code=403, detail="Current PIN is incorrect")
    
    # Hash and store new PIN
    new_hash = bcrypt.hashpw(request.new_pin.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
    
    config = db.query(SystemConfig).filter(SystemConfig.key == MASTER_KEY_CONFIG).first()
    config.value = new_hash
    
    # Update PIN length
    length_config = db.query(SystemConfig).filter(SystemConfig.key == MASTER_KEY_LENGTH).first()
    if length_config:
        length_config.value = str(len(request.new_pin))
    else:
        db.add(SystemConfig(key=MASTER_KEY_LENGTH, value=str(len(request.new_pin))))
    
    db.commit()
    
    logger.info("Master key changed successfully")
    return SuccessResponse(message="Master key changed successfully")


# Backward compatibility: old verify-passkey endpoint redirects to new system
@router.post("/verify-passkey")
def verify_passkey_legacy(request: VerifyKeyRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Legacy endpoint — redirects to verify-key."""
    return verify_key(request, db, current_user)
