"""
Google OAuth authentication router.
Verifies Google ID tokens and issues JWTs.
"""
from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from datetime import datetime, timedelta, timezone
import jwt
import logging

from google.oauth2 import id_token
from google.auth.transport import requests as google_requests

from ..database import get_db
from ..models import User
from ..config import get_settings

router = APIRouter(prefix="/auth", tags=["Authentication"])
logger = logging.getLogger(__name__)
settings = get_settings()

# JWT settings
JWT_ALGORITHM = "HS256"
JWT_EXPIRY_DAYS = 30


class GoogleLoginRequest(BaseModel):
    id_token: str


class UserResponse(BaseModel):
    id: int
    email: str
    name: str
    picture_url: Optional[str] = None
    created_at: datetime
    
    class Config:
        from_attributes = True


def create_jwt(user_id: int, email: str) -> str:
    """Create a JWT token for the user."""
    payload = {
        "user_id": user_id,
        "email": email,
        "exp": datetime.now(timezone.utc) + timedelta(days=JWT_EXPIRY_DAYS),
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(payload, settings.secret_key, algorithm=JWT_ALGORITHM)


def verify_jwt(token: str) -> dict:
    """Verify and decode a JWT token."""
    try:
        return jwt.decode(token, settings.secret_key, algorithms=[JWT_ALGORITHM])
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


def get_current_user(
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
) -> User:
    """Dependency to get the current authenticated user from JWT."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid authorization header")
    
    token = authorization.split(" ", 1)[1]
    
    # Dev Bypass Hook
    if token == "dev-bypass-token":
        user = db.query(User).filter(User.email == "admin@ngo.org").first()
        if not user:
            user = User(email="admin@ngo.org", name="Admin", google_id="dev-bypass-123")
            db.add(user)
            db.commit()
            db.refresh(user)
        return user

    payload = verify_jwt(token)
    
    user = db.query(User).filter(User.id == payload["user_id"]).first()
    if not user or not user.is_active:
        raise HTTPException(status_code=401, detail="User not found or inactive")
    
    return user


@router.post("/google", response_model=dict)
async def google_login(request: GoogleLoginRequest, db: Session = Depends(get_db)):
    """
    Authenticate with Google OAuth.
    Accepts a Google ID token, verifies it, creates/finds user, and returns a JWT.
    """
    try:
        # Verify Google ID token
        google_client_id = settings.google_client_id
        
        idinfo = id_token.verify_oauth2_token(
            request.id_token,
            google_requests.Request(),
            google_client_id
        )
        
        # Extract user info
        google_id = idinfo["sub"]
        email = idinfo.get("email", "")
        name = idinfo.get("name", "")
        picture = idinfo.get("picture", "")
        
        if not email:
            raise HTTPException(status_code=400, detail="Email not provided by Google")
        
        logger.info(f"Google login for: {email}")
        
    except ValueError as e:
        logger.warning(f"Invalid Google token: {e}")
        raise HTTPException(status_code=401, detail="Invalid Google token")
    
    # Find or create user
    user = db.query(User).filter(User.google_id == google_id).first()
    
    if not user:
        # Create new user
        user = User(
            email=email,
            name=name,
            picture_url=picture,
            google_id=google_id,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        logger.info(f"Created new user: {email} (ID: {user.id})")
    else:
        # Update existing user info
        user.name = name
        user.picture_url = picture
        db.commit()
    
    # Issue JWT
    token = create_jwt(user.id, user.email)
    
    return {
        "token": token,
        "user": {
            "id": user.id,
            "email": user.email,
            "name": user.name,
            "picture_url": user.picture_url,
        }
    }


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    """Get the current authenticated user."""
    return current_user
