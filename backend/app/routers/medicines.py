from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone
from ..database import get_db
from ..models import Medicine, StockTransaction, TransactionReason
from ..schemas import (
    MedicineCreate, MedicineUpdate, MedicineResponse,
    StockAdjustment, StockTransactionResponse, SuccessResponse
)
from ..stock_service import StockService, InsufficientStockError
from ..config import get_settings
from .auth import verify_master_key
import logging

router = APIRouter(prefix="/medicines", tags=["Medicines"])
logger = logging.getLogger(__name__)


@router.get("", response_model=List[MedicineResponse])
def list_medicines(
    active_only: bool = True,
    db: Session = Depends(get_db)
):
    """List all medicines with current stock"""
    query = db.query(Medicine).filter(Medicine.deleted_at.is_(None))
    
    if active_only:
        query = query.filter(Medicine.is_active == True)
    
    return query.order_by(Medicine.name).all()


@router.get("/{medicine_id}", response_model=MedicineResponse)
def get_medicine(medicine_id: int, db: Session = Depends(get_db)):
    """Get medicine by ID"""
    medicine = db.query(Medicine).filter(
        Medicine.id == medicine_id,
        Medicine.deleted_at.is_(None)
    ).first()
    
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    
    return medicine


@router.post("", response_model=MedicineResponse, status_code=201)
def create_medicine(medicine_data: MedicineCreate, db: Session = Depends(get_db)):
    """Create a new medicine"""
    # Check if name already exists
    existing = db.query(Medicine).filter(
        Medicine.name == medicine_data.name,
        Medicine.deleted_at.is_(None)
    ).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Medicine with name '{medicine_data.name}' already exists"
        )
    
    # Create medicine
    medicine = Medicine(
        name=medicine_data.name,
        description=medicine_data.description,
        dosage_unit=medicine_data.dosage_unit,
        current_stock=0,  # Will be set via transaction
        min_stock_level=medicine_data.min_stock_level
    )
    
    db.add(medicine)
    db.flush()
    
    # Create initial stock transaction if initial_stock > 0
    if medicine_data.initial_stock > 0:
        StockService.create_transaction(
            db=db,
            medicine_id=medicine.id,
            change_amount=medicine_data.initial_stock,
            reason=TransactionReason.MANUAL_ADJUSTMENT,
            notes="Initial stock",
            created_by="SYSTEM"
        )
    
    db.commit()
    db.refresh(medicine)
    
    logger.info(f"Created medicine: {medicine.name} with stock {medicine.current_stock}")
    
    return medicine


@router.put("/{medicine_id}", response_model=MedicineResponse)
def update_medicine(
    medicine_id: int,
    medicine_data: MedicineUpdate,
    db: Session = Depends(get_db)
):
    """Update medicine (not stock - use adjust-stock endpoint)"""
    medicine = db.query(Medicine).filter(
        Medicine.id == medicine_id,
        Medicine.deleted_at.is_(None)
    ).first()
    
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    
    # Update fields
    if medicine_data.name is not None:
        # Check uniqueness
        existing = db.query(Medicine).filter(
            Medicine.name == medicine_data.name,
            Medicine.id != medicine_id,
            Medicine.deleted_at.is_(None)
        ).first()
        if existing:
            raise HTTPException(
                status_code=400,
                detail=f"Medicine with name '{medicine_data.name}' already exists"
            )
        medicine.name = medicine_data.name
    
    if medicine_data.description is not None:
        medicine.description = medicine_data.description
    
    if medicine_data.dosage_unit is not None:
        medicine.dosage_unit = medicine_data.dosage_unit
    
    if medicine_data.min_stock_level is not None:
        medicine.min_stock_level = medicine_data.min_stock_level
    
    if medicine_data.is_active is not None:
        medicine.is_active = medicine_data.is_active
    
    medicine.updated_at = datetime.now(timezone.utc)
    
    db.commit()
    db.refresh(medicine)
    
    logger.info(f"Updated medicine: {medicine.name}")
    
    return medicine


@router.post("/{medicine_id}/adjust-stock", response_model=StockTransactionResponse)
def adjust_stock(
    medicine_id: int,
    adjustment: StockAdjustment,
    db: Session = Depends(get_db)
):
    """
    Manually adjust medicine stock.
    Use positive amount for additions, negative for removals.
    """
    medicine = db.query(Medicine).filter(
        Medicine.id == medicine_id,
        Medicine.deleted_at.is_(None)
    ).first()
    
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    
    try:
        transaction = StockService.manual_adjustment(
            db=db,
            medicine_id=medicine_id,
            amount=adjustment.amount,
            notes=adjustment.notes,
            created_by=adjustment.created_by
        )
        
        db.commit()
        db.refresh(transaction)
        
        logger.info(
            f"Stock adjusted for {medicine.name}: {adjustment.amount:+d} "
            f"by {adjustment.created_by}"
        )
        
        return transaction
        
    except Exception as e:
        db.rollback()
        logger.error(f"Stock adjustment error: {e}")
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{medicine_id}/transactions", response_model=List[StockTransactionResponse])
def get_transactions(
    medicine_id: int,
    limit: int = 50,
    db: Session = Depends(get_db)
):
    """Get stock transaction history for medicine"""
    medicine = db.query(Medicine).filter(
        Medicine.id == medicine_id,
        Medicine.deleted_at.is_(None)
    ).first()
    
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    
    transactions = db.query(StockTransaction).filter(
        StockTransaction.medicine_id == medicine_id
    ).order_by(
        StockTransaction.created_at.desc()
    ).limit(limit).all()
    
    return transactions


@router.delete("/{medicine_id}", response_model=SuccessResponse)
def delete_medicine(medicine_id: int, db: Session = Depends(get_db)):
    """Soft delete medicine"""
    medicine = db.query(Medicine).filter(
        Medicine.id == medicine_id,
        Medicine.deleted_at.is_(None)
    ).first()
    
    if not medicine:
        raise HTTPException(status_code=404, detail="Medicine not found")
    
    # Soft delete
    medicine.deleted_at = datetime.now(timezone.utc)
    medicine.is_active = False
    
    db.commit()
    
    logger.info(f"Deleted medicine: {medicine.name}")
    
    return SuccessResponse(message=f"Medicine {medicine.name} deleted successfully")
