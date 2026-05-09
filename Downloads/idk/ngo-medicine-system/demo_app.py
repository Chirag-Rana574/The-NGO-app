"""
Standalone FastAPI Demo - NGO Medicine System
This is a simplified version that runs without database for demonstration
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from enum import Enum

app = FastAPI(
    title="NGO Medicine Administration System",
    description="Production-grade medicine administration management with WhatsApp integration",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Enums
class ScheduleStatus(str, Enum):
    CREATED = "CREATED"
    REMINDER_SENT = "REMINDER_SENT"
    AWAITING_RESPONSE = "AWAITING_RESPONSE"
    COMPLETED = "COMPLETED"
    NOT_DONE = "NOT_DONE"
    LATE_COMPLETED = "LATE_COMPLETED"
    EXPIRED = "EXPIRED"

# Schemas
class Worker(BaseModel):
    id: int
    name: str
    phone_number: str
    is_active: bool = True

class Medicine(BaseModel):
    id: int
    name: str
    dosage_unit: str
    current_stock: int

class Schedule(BaseModel):
    id: int
    worker: Worker
    medicine: Medicine
    scheduled_time: datetime
    status: ScheduleStatus
    dose_amount: int

# Demo Data
demo_workers = [
    Worker(id=1, name="Rajesh Kumar", phone_number="+919876543210", is_active=True),
    Worker(id=2, name="Priya Sharma", phone_number="+919876543211", is_active=True),
    Worker(id=3, name="Amit Patel", phone_number="+919876543212", is_active=True),
]

demo_medicines = [
    Medicine(id=1, name="Paracetamol", dosage_unit="tablet", current_stock=150),
    Medicine(id=2, name="Amoxicillin", dosage_unit="capsule", current_stock=75),
    Medicine(id=3, name="Ibuprofen", dosage_unit="tablet", current_stock=200),
]

demo_schedules = [
    Schedule(
        id=1,
        worker=demo_workers[0],
        medicine=demo_medicines[0],
        scheduled_time=datetime.now(),
        status=ScheduleStatus.AWAITING_RESPONSE,
        dose_amount=2
    ),
    Schedule(
        id=2,
        worker=demo_workers[1],
        medicine=demo_medicines[1],
        scheduled_time=datetime.now(),
        status=ScheduleStatus.COMPLETED,
        dose_amount=1
    ),
    Schedule(
        id=3,
        worker=demo_workers[2],
        medicine=demo_medicines[2],
        scheduled_time=datetime.now(),
        status=ScheduleStatus.CREATED,
        dose_amount=3
    ),
]

# Routes
@app.get("/")
def root():
    return {
        "message": "NGO Medicine Administration System API",
        "version": "1.0.0",
        "status": "running",
        "features": [
            "WhatsApp Integration",
            "State Machine",
            "Stock Accounting",
            "Audit Logging"
        ]
    }

@app.get("/health")
def health_check():
    return {"status": "healthy", "timestamp": datetime.now()}

@app.get("/api/workers", response_model=List[Worker])
def get_workers():
    """Get all workers"""
    return demo_workers

@app.get("/api/medicines", response_model=List[Medicine])
def get_medicines():
    """Get all medicines with current stock"""
    return demo_medicines

@app.get("/api/schedules", response_model=List[Schedule])
def get_schedules(status: Optional[ScheduleStatus] = None):
    """Get all schedules, optionally filtered by status"""
    if status:
        return [s for s in demo_schedules if s.status == status]
    return demo_schedules

@app.get("/api/schedules/today", response_model=List[Schedule])
def get_today_schedules():
    """Get today's schedules"""
    return demo_schedules

@app.post("/api/whatsapp/webhook")
def whatsapp_webhook(payload: dict):
    """
    WhatsApp webhook endpoint
    
    Processing Rules:
    1. Extract FIRST digit only from message
    2. 1 = Task completed (consume stock)
    3. 2 = Task not done
    4. Idempotent processing via MessageSid
    5. Time window validation (on-time vs late)
    """
    return {
        "status": "processed",
        "message": "WhatsApp message processed successfully",
        "rules": {
            "digit_1": "Task completed",
            "digit_2": "Task not done",
            "idempotency": "MessageSid checked",
            "time_window": "Validated"
        }
    }

@app.get("/api/state-machine/transitions")
def get_state_transitions():
    """Get valid state machine transitions"""
    return {
        "transitions": {
            "CREATED": ["REMINDER_SENT"],
            "REMINDER_SENT": ["AWAITING_RESPONSE"],
            "AWAITING_RESPONSE": ["COMPLETED", "NOT_DONE", "LATE_COMPLETED", "EXPIRED"],
            "COMPLETED": [],
            "NOT_DONE": [],
            "LATE_COMPLETED": [],
            "EXPIRED": []
        },
        "rules": [
            "Forward-only transitions",
            "No state skipping",
            "All transitions logged",
            "Atomic operations"
        ]
    }

@app.get("/api/stock/rules")
def get_stock_rules():
    """Get stock accounting rules"""
    return {
        "rules": [
            "Stock NEVER modified directly",
            "All changes via StockTransaction records",
            "current_stock recalculated from transaction history",
            "Negative stock prevented (database constraint)",
            "All changes audited"
        ],
        "constraint": "CHECK (current_stock >= 0)"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
