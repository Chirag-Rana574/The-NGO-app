from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # Database
    database_url: str
    
    # Redis
    redis_url: str
    
    # Twilio
    twilio_account_sid: str
    twilio_auth_token: str
    twilio_whatsapp_number: str
    twilio_webhook_url: str
    
    # Security
    master_password_hash: str
    secret_key: str
    
    # Time Windows
    response_window_minutes: int = 60
    expiry_cutoff_hours: int = 24
    reminder_advance_minutes: int = 15
    
    # Stock Alerts
    low_stock_threshold: int = 10
    
    # App Settings
    timezone: str = "Asia/Kolkata"
    debug: bool = False
    
    # Google OAuth
    google_client_id: str = ""
    
    # Medicine Management — passkey now stored in DB via SystemConfig
    # (Set up via POST /auth/setup-key)
    
    class Config:
        env_file = ".env"
        case_sensitive = False


@lru_cache()
def get_settings() -> Settings:
    return Settings()
