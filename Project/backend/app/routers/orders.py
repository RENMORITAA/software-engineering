from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
from .. import models, schemas, database
from .auth import get_current_user

router = APIRouter(
    prefix="/orders",
    tags=["orders"],
)

@router.post("/", response_model=schemas.Order)
def create_order(
    order: schemas.OrderCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Create a new order (requester only)"""
    if current_user.role != "requester":
        raise HTTPException(status_code=403, detail="Only requesters can create orders")
    
    # Get requester profile
    requester = db.query(models.RequesterProfile).filter(
        models.RequesterProfile.user_id == current_user.id
    ).first()
    if not requester:
        raise HTTPException(status_code=404, detail="Requester profile not found")
    
    # Calculate total amount
    subtotal = 0
    for item in order.details:
        product = db.query(models.Product).filter(models.Product.id == item.product_id).first()
        if not product:
            raise HTTPException(status_code=404, detail=f"Product {item.product_id} not found")
        if not product.is_available:
            raise HTTPException(status_code=400, detail=f"Product {product.name} is not available")
        subtotal += product.price * item.quantity
    
    delivery_fee = 300  # Default delivery fee
    total_price = subtotal + delivery_fee

    db_order = models.Order(
        requester_id=requester.id,
        store_id=order.store_id,
        status="pending",
        subtotal=subtotal,
        delivery_fee=delivery_fee,
        total_price=total_price,
        delivery_address=order.delivery_address,
        delivery_latitude=order.delivery_latitude,
        delivery_longitude=order.delivery_longitude,
        notes=order.notes
    )
    db.add(db_order)
    db.commit()
    db.refresh(db_order)

    for item in order.details:
        product = db.query(models.Product).filter(models.Product.id == item.product_id).first()
        db_detail = models.OrderDetail(
            order_id=db_order.id,
            product_id=item.product_id,
            product_name=product.name,
            quantity=item.quantity,
            unit_price=product.price,
            subtotal=product.price * item.quantity,
            notes=item.notes
        )
        db.add(db_detail)
    
    db.commit()
    db.refresh(db_order)
    return db_order

@router.get("/my", response_model=List[schemas.Order])
def get_my_orders(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Get current user's orders"""
    if current_user.role == "requester":
        requester = db.query(models.RequesterProfile).filter(
            models.RequesterProfile.user_id == current_user.id
        ).first()
        if not requester:
            return []
        orders = db.query(models.Order).filter(
            models.Order.requester_id == requester.id
        ).order_by(models.Order.ordered_at.desc()).all()
    elif current_user.role == "store":
        store = db.query(models.StoreProfile).filter(
            models.StoreProfile.user_id == current_user.id
        ).first()
        if not store:
            return []
        orders = db.query(models.Order).filter(
            models.Order.store_id == store.id
        ).order_by(models.Order.ordered_at.desc()).all()
    elif current_user.role == "deliverer":
        deliverer = db.query(models.DelivererProfile).filter(
            models.DelivererProfile.user_id == current_user.id
        ).first()
        if not deliverer:
            return []
        orders = db.query(models.Order).filter(
            models.Order.deliverer_id == deliverer.id
        ).order_by(models.Order.ordered_at.desc()).all()
    else:
        orders = []
    
    return orders

@router.get("/{order_id}", response_model=schemas.Order)
def get_order(
    order_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Get a specific order"""
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order

@router.put("/{order_id}/status")
def update_order_status(
    order_id: int,
    status_update: schemas.OrderUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Update order status"""
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    if status_update.status:
        order.status = status_update.status
        
        # Update timestamps based on status
        if status_update.status == "accepted":
            order.accepted_at = datetime.utcnow()
        elif status_update.status in ["delivered", "completed"]:
            order.completed_at = datetime.utcnow()
        elif status_update.status == "cancelled":
            order.cancelled_at = datetime.utcnow()
    
    db.commit()
    return {"message": "Status updated", "status": order.status}

@router.get("/store/pending", response_model=List[schemas.Order])
def get_store_pending_orders(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Get pending orders for store"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only stores can access this endpoint")
    
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store profile not found")
    
    orders = db.query(models.Order).filter(
        models.Order.store_id == store.id,
        models.Order.status.in_(["pending", "accepted", "preparing", "ready_for_pickup"])
    ).order_by(models.Order.ordered_at.desc()).all()
    
    return orders
