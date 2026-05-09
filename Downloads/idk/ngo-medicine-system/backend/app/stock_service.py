from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timezone
import json
from .models import Medicine, StockTransaction, TransactionReason, AuditLog, AuditAction, Schedule


class InsufficientStockError(Exception):
    """Raised when attempting to consume more stock than available"""
    pass


class StockService:
    """
    Stock accounting service with strict transaction-based tracking.
    
    Rules:
    1. Stock can NEVER be directly modified
    2. All stock changes go through StockTransaction records
    3. current_stock is recalculated from transaction history
    4. Stock can never go negative
    5. All changes are audited
    """
    
    @staticmethod
    def create_transaction(
        db: Session,
        medicine_id: int,
        change_amount: int,
        reason: TransactionReason,
        reference_schedule_id: Optional[int] = None,
        notes: Optional[str] = None,
        created_by: Optional[str] = None
    ) -> StockTransaction:
        """
        Create a stock transaction and update medicine stock.
        
        Args:
            db: Database session
            medicine_id: Medicine ID
            change_amount: Amount to change (positive for additions, negative for consumption)
            reason: Reason for transaction
            reference_schedule_id: Optional schedule reference
            notes: Optional notes
            created_by: Who created the transaction
        
        Returns:
            Created StockTransaction
        
        Raises:
            InsufficientStockError: If resulting stock would be negative
        """
        # Get medicine
        medicine = db.query(Medicine).filter(Medicine.id == medicine_id).first()
        if not medicine:
            raise ValueError(f"Medicine {medicine_id} not found")
        
        # Calculate new stock
        new_stock = medicine.current_stock + change_amount
        
        # Validate non-negative stock
        if new_stock < 0:
            raise InsufficientStockError(
                f"Insufficient stock for {medicine.name}. "
                f"Current: {medicine.current_stock}, Requested: {abs(change_amount)}"
            )
        
        # Create transaction record
        transaction = StockTransaction(
            medicine_id=medicine_id,
            change_amount=change_amount,
            reason=reason,
            reference_schedule_id=reference_schedule_id,
            notes=notes,
            created_by=created_by
        )
        db.add(transaction)
        
        # Update medicine stock
        old_stock = medicine.current_stock
        medicine.current_stock = new_stock
        medicine.updated_at = datetime.now(timezone.utc)
        
        # Create audit log
        audit_entry = AuditLog(
            entity_type="Medicine",
            entity_id=medicine_id,
            action=AuditAction.STOCK_CHANGE,
            old_value=json.dumps({"current_stock": old_stock}),
            new_value=json.dumps({"current_stock": new_stock}),
            reason=f"{reason.value}: {notes or ''}",
            performed_by=created_by or "SYSTEM"
        )
        db.add(audit_entry)
        
        db.flush()
        
        return transaction
    
    @staticmethod
    def recalculate_stock(db: Session, medicine_id: int) -> int:
        """
        Recalculate medicine stock from transaction history.
        This is a safety mechanism to ensure stock accuracy.
        
        Args:
            db: Database session
            medicine_id: Medicine ID
        
        Returns:
            Calculated stock amount
        """
        # Sum all transactions for this medicine
        total_change = db.query(
            func.coalesce(func.sum(StockTransaction.change_amount), 0)
        ).filter(
            StockTransaction.medicine_id == medicine_id
        ).scalar()
        
        return int(total_change)
    
    @staticmethod
    def verify_stock_integrity(db: Session, medicine_id: int) -> bool:
        """
        Verify that current_stock matches transaction history.
        
        Args:
            db: Database session
            medicine_id: Medicine ID
        
        Returns:
            True if stock is accurate, False otherwise
        """
        medicine = db.query(Medicine).filter(Medicine.id == medicine_id).first()
        if not medicine:
            return False
        
        calculated_stock = StockService.recalculate_stock(db, medicine_id)
        return medicine.current_stock == calculated_stock
    
    @staticmethod
    def consume_for_task(
        db: Session,
        schedule: Schedule,
        performed_by: str = "SYSTEM"
    ) -> StockTransaction:
        """
        Consume stock for a completed task.
        
        Args:
            db: Database session
            schedule: Schedule that was completed
            performed_by: Who performed the action
        
        Returns:
            Created StockTransaction
        
        Raises:
            InsufficientStockError: If not enough stock available
        """
        return StockService.create_transaction(
            db=db,
            medicine_id=schedule.medicine_id,
            change_amount=-schedule.dose_amount,  # Negative for consumption
            reason=TransactionReason.TASK_COMPLETION,
            reference_schedule_id=schedule.id,
            notes=f"Task completion for worker {schedule.worker.name}",
            created_by=performed_by
        )
    
    @staticmethod
    def manual_adjustment(
        db: Session,
        medicine_id: int,
        amount: int,
        notes: str,
        created_by: str
    ) -> StockTransaction:
        """
        Manual stock adjustment by supervisor.
        
        Args:
            db: Database session
            medicine_id: Medicine ID
            amount: Amount to adjust (positive or negative)
            notes: Reason for adjustment
            created_by: Supervisor name/ID
        
        Returns:
            Created StockTransaction
        """
        return StockService.create_transaction(
            db=db,
            medicine_id=medicine_id,
            change_amount=amount,
            reason=TransactionReason.MANUAL_ADJUSTMENT,
            notes=notes,
            created_by=created_by
        )
    
    @staticmethod
    def check_low_stock(db: Session, threshold: int = None) -> list[Medicine]:
        """
        Get list of medicines with stock below their individual min_stock_level.
        If threshold is provided, use it as a fallback for medicines without min_stock_level.
        
        Args:
            db: Database session
            threshold: Optional global fallback threshold (used if min_stock_level is not set)
        
        Returns:
            List of medicines with low stock
        """
        return db.query(Medicine).filter(
            Medicine.current_stock <= Medicine.min_stock_level,
            Medicine.is_active == True,
            Medicine.deleted_at.is_(None)
        ).all()
