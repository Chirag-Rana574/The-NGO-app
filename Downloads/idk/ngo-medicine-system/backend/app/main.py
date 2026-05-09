from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging
from .routers import workers, medicines, schedules, audit, whatsapp_webhook, auth, patients, cleanup, test_whatsapp, google_auth, push, settings, reports, exports
from .database import engine, Base
from .reminder_scheduler import start_scheduler, stop_scheduler

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="NGO Medicine Administration System",
    description="Production-grade medicine administration management with WhatsApp integration",
    version="1.0.0"
)

# CORS middleware for mobile app
ALLOWED_ORIGINS = [
    "http://localhost:3000",          # Local development
    "http://localhost:8081",          # React Native Metro
    "http://127.0.0.1:8000",         # Backend self
    "http://10.248.163.249:8081",    # React Native on phone
    "http://10.248.163.249:8000",    # API from LAN
    "http://192.168.0.104:8081",     # React Native (home LAN)
]

# In debug mode, allow all origins for development convenience
from .config import get_settings as _get_settings
_startup_settings = _get_settings()
if _startup_settings.debug:
    ALLOWED_ORIGINS = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Simple in-memory rate limiting middleware
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse
from collections import defaultdict
import time as _time

class RateLimitMiddleware(BaseHTTPMiddleware):
    """Simple rate limiter: 100 requests/minute per IP."""
    
    def __init__(self, app, requests_per_minute: int = 100):
        super().__init__(app)
        self.requests_per_minute = requests_per_minute
        self.requests: dict = defaultdict(list)
    
    async def dispatch(self, request: Request, call_next):
        client_ip = request.client.host if request.client else "unknown"
        now = _time.time()
        window_start = now - 60
        
        # Clean old entries
        self.requests[client_ip] = [
            t for t in self.requests[client_ip] if t > window_start
        ]
        
        if len(self.requests[client_ip]) >= self.requests_per_minute:
            return JSONResponse(
                status_code=429,
                content={"detail": "Too many requests. Please try again later."}
            )
        
        self.requests[client_ip].append(now)
        return await call_next(request)

app.add_middleware(RateLimitMiddleware, requests_per_minute=100)

# Include routers
app.include_router(patients.router, prefix="/api")
app.include_router(workers.router, prefix="/api")
app.include_router(medicines.router, prefix="/api")
app.include_router(schedules.router, prefix="/api")
app.include_router(audit.router, prefix="/api")
app.include_router(auth.router, prefix="/api")
app.include_router(whatsapp_webhook.router, prefix="/api")
app.include_router(cleanup.router, prefix="/api")
app.include_router(test_whatsapp.router, prefix="/api")
app.include_router(google_auth.router, prefix="/api")
app.include_router(push.router, prefix="/api")
app.include_router(settings.router, prefix="/api")
app.include_router(reports.router, prefix="/api")
app.include_router(exports.router, prefix="/api")


@app.on_event("startup")
async def startup_event():
    """Create database tables and start background scheduler"""
    logger.info("Starting NGO Medicine Administration System")
    # Auto-create all tables — non-fatal if DB is temporarily unavailable
    try:
        Base.metadata.create_all(bind=engine)
        logger.info("Database tables verified/created successfully")
    except Exception as e:
        logger.error(
            f"⚠️  Database connection failed on startup: {e}\n"
            "Server is starting anyway. Check your DATABASE_URL and ensure "
            "the Supabase project is not paused. Resume it at: https://supabase.com/dashboard"
        )
    # Start the multi-stage WhatsApp reminder scheduler
    start_scheduler()


@app.on_event("shutdown")
async def shutdown_event():
    """Stop scheduler and cleanup on shutdown"""
    stop_scheduler()
    logger.info("Shutting down NGO Medicine Administration System")


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "NGO Medicine Administration System",
        "version": "1.0.0"
    }


@app.get("/health")
async def health_check():
    """Detailed health check"""
    from .database import SessionLocal
    from sqlalchemy import text
    db_status = "disconnected"
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        db.close()
        db_status = "connected"
    except Exception:
        pass
    return {
        "status": "healthy" if db_status == "connected" else "degraded",
        "database": db_status,
    }
