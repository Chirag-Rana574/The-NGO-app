from celery import Celery
from .config import get_settings

settings = get_settings()

celery_app = Celery(
    "ngo_medicine_system",
    broker=settings.redis_url,
    backend=settings.redis_url,
    include=["app.tasks"]
)

# Celery configuration
celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_time_limit=300,  # 5 minutes
    task_soft_time_limit=240,  # 4 minutes
)

# Beat schedule for periodic tasks
celery_app.conf.beat_schedule = {
    "send-reminders-every-minute": {
        "task": "app.tasks.send_reminders",
        "schedule": 60.0,  # Every 60 seconds
    },
    "expire-schedules-every-5-minutes": {
        "task": "app.tasks.expire_schedules",
        "schedule": 300.0,  # Every 5 minutes
    },
    "check-stock-alerts-every-hour": {
        "task": "app.tasks.check_stock_alerts",
        "schedule": 3600.0,  # Every hour
    },
}
