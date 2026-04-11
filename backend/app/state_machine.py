from typing import Dict, List, Optional
from sqlalchemy.orm import Session
from datetime import datetime, timezone
import json
from .models import Schedule, ScheduleStatus, AuditLog, AuditAction


# Valid state transitions - deterministic and forward-only
VALID_TRANSITIONS: Dict[ScheduleStatus, List[ScheduleStatus]] = {
    ScheduleStatus.CREATED: [ScheduleStatus.REMINDER_SENT],
    ScheduleStatus.REMINDER_SENT: [ScheduleStatus.AWAITING_RESPONSE],
    ScheduleStatus.AWAITING_RESPONSE: [
        ScheduleStatus.COMPLETED,
        ScheduleStatus.NOT_DONE,
        ScheduleStatus.LATE_COMPLETED,
        ScheduleStatus.EXPIRED
    ],
    ScheduleStatus.COMPLETED: [],  # Terminal state
    ScheduleStatus.NOT_DONE: [],   # Terminal state
    ScheduleStatus.LATE_COMPLETED: [],  # Terminal state
    ScheduleStatus.EXPIRED: [],    # Terminal state
}


class StateTransitionError(Exception):
    """Raised when an invalid state transition is attempted"""
    pass


class StateMachine:
    """
    Deterministic state machine for schedule status transitions.
    
    Rules:
    1. Transitions are forward-only (no backward transitions)
    2. Duplicate transitions are rejected
    3. All transitions are logged in AuditLog
    4. Idempotency is enforced
    """
    
    @staticmethod
    def can_transition(current: ScheduleStatus, target: ScheduleStatus) -> bool:
        """Check if transition from current to target state is valid"""
        if current == target:
            return False  # Duplicate transition
        return target in VALID_TRANSITIONS.get(current, [])
    
    @staticmethod
    def transition(
        db: Session,
        schedule: Schedule,
        target_status: ScheduleStatus,
        reason: Optional[str] = None,
        performed_by: str = "SYSTEM",
        additional_data: Optional[dict] = None
    ) -> Schedule:
        """
        Transition schedule to target status with validation and audit logging.
        
        Args:
            db: Database session
            schedule: Schedule object to transition
            target_status: Target status
            reason: Optional reason for transition
            performed_by: Who performed the transition (SYSTEM, SUPERVISOR, etc.)
            additional_data: Additional data to log (e.g., response message)
        
        Returns:
            Updated schedule object
        
        Raises:
            StateTransitionError: If transition is invalid
        """
        current_status = schedule.status
        
        # Check if transition is valid
        if not StateMachine.can_transition(current_status, target_status):
            raise StateTransitionError(
                f"Invalid transition from {current_status} to {target_status} "
                f"for schedule {schedule.id}"
            )
        
        # Prepare old and new values for audit
        old_value = {
            "status": current_status.value,
            "updated_at": schedule.updated_at.isoformat() if schedule.updated_at else None
        }
        
        # Update schedule status
        schedule.status = target_status
        schedule.updated_at = datetime.now(timezone.utc)
        
        # Add additional data if provided
        if additional_data:
            for key, value in additional_data.items():
                if hasattr(schedule, key):
                    setattr(schedule, key, value)
        
        new_value = {
            "status": target_status.value,
            "updated_at": schedule.updated_at.isoformat(),
            **(additional_data or {})
        }
        
        # Create audit log entry
        audit_entry = AuditLog(
            entity_type="Schedule",
            entity_id=schedule.id,
            action=AuditAction.STATE_TRANSITION,
            old_value=json.dumps(old_value),
            new_value=json.dumps(new_value),
            reason=reason,
            performed_by=performed_by
        )
        
        db.add(audit_entry)
        db.flush()  # Ensure audit log is written
        
        return schedule
    
    @staticmethod
    def is_terminal_state(status: ScheduleStatus) -> bool:
        """Check if status is a terminal state (no further transitions possible)"""
        return len(VALID_TRANSITIONS.get(status, [])) == 0
    
    @staticmethod
    def get_valid_next_states(current: ScheduleStatus) -> List[ScheduleStatus]:
        """Get list of valid next states from current state"""
        return VALID_TRANSITIONS.get(current, [])
