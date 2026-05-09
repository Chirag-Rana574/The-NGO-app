import phonenumbers
from phonenumbers import NumberParseException
import re
from typing import Optional


def normalize_phone_number(phone: str, default_region: str = "IN") -> str:
    """
    Normalize phone number to E.164 format.
    
    Args:
        phone: Phone number in any format
        default_region: Default country code (ISO 3166-1 alpha-2)
    
    Returns:
        Normalized phone number in E.164 format (e.g., +919876543210)
    
    Raises:
        ValueError: If phone number is invalid
    """
    try:
        # Remove any whitespace
        phone = phone.strip()
        
        # Parse the phone number
        parsed = phonenumbers.parse(phone, default_region)
        
        # Validate
        if not phonenumbers.is_valid_number(parsed):
            raise ValueError(f"Invalid phone number: {phone}")
        
        # Format to E.164
        return phonenumbers.format_number(parsed, phonenumbers.PhoneNumberFormat.E164)
    
    except NumberParseException as e:
        raise ValueError(f"Failed to parse phone number {phone}: {str(e)}")


def extract_first_digit(message: str) -> Optional[int]:
    """
    Extract the first numeric digit from a message.
    
    Args:
        message: Message text
    
    Returns:
        First digit (0-9) or None if no digit found
    """
    # Find first digit in the message
    match = re.search(r'\d', message)
    if match:
        return int(match.group())
    return None


def format_whatsapp_number(phone: str) -> str:
    """
    Format phone number for WhatsApp (whatsapp:+1234567890).
    
    Args:
        phone: E.164 formatted phone number
    
    Returns:
        WhatsApp formatted number
    """
    # Ensure phone starts with +
    if not phone.startswith('+'):
        phone = '+' + phone
    return f"whatsapp:{phone}"


def parse_whatsapp_number(whatsapp_number: str) -> str:
    """
    Parse WhatsApp number to E.164 format.
    
    Args:
        whatsapp_number: WhatsApp formatted number (whatsapp:+1234567890)
    
    Returns:
        E.164 formatted phone number
    """
    # Remove 'whatsapp:' prefix if present
    if whatsapp_number.startswith('whatsapp:'):
        return whatsapp_number[9:]
    return whatsapp_number
