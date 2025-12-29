from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime
from .. import models, schemas, database
from .auth import get_current_user

router = APIRouter(
    prefix="/delivery",
    tags=["delivery"],
)

@router.get("/jobs", response_model=List[schemas.DeliveryJob])
def get_delivery_jobs(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Get available delivery jobs (deliverer only)"""
    if current_user.role != "deliverer":
        raise HTTPException(status_code=403, detail="Only deliverers can access this endpoint")
    
    # Get orders that are ready for pickup and not yet assigned
    orders = db.query(models.Order).filter(
        models.Order.status == "ready_for_pickup",
        models.Order.deliverer_id == None
    ).all()
    
    jobs = []
    for order in orders:
        store = db.query(models.StoreProfile).filter(
            models.StoreProfile.id == order.store_id
        ).first()
        
        # Count items in order
        items_count = db.query(models.OrderDetail).filter(
            models.OrderDetail.order_id == order.id
        ).count()
        
        jobs.append({
            "id": order.id,
            "order_id": order.id,
            "store_name": store.store_name if store else "Unknown",
            "store_address": store.address if store else "Unknown",
            "delivery_address": order.delivery_address,
            "reward": order.delivery_fee or 300,
            "distance": 2.5,  # TODO: Calculate actual distance
            "items_count": items_count
        })
    
    return jobs

@router.post("/jobs/{order_id}/accept")
def accept_job(
    order_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Accept a delivery job (deliverer only)"""
    if current_user.role != "deliverer":
        raise HTTPException(status_code=403, detail="Only deliverers can accept jobs")
    
    deliverer = db.query(models.DelivererProfile).filter(
        models.DelivererProfile.user_id == current_user.id
    ).first()
    if not deliverer:
        raise HTTPException(status_code=404, detail="Deliverer profile not found")
    
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    if order.status != "ready_for_pickup":
        raise HTTPException(status_code=400, detail="Order not ready for pickup")
    
    if order.deliverer_id is not None:
        raise HTTPException(status_code=400, detail="Order already assigned to a deliverer")

    # Assign deliverer to order
    order.deliverer_id = deliverer.id
    order.status = "picked_up"
    
    # Create delivery record
    delivery = models.Delivery(
        order_id=order_id,
        deliverer_id=deliverer.id,
        status="assigned",
        delivery_fee=order.delivery_fee
    )
    db.add(delivery)
    
    # Update deliverer status
    deliverer.work_status = "busy"
    
    db.commit()
    
    return {"message": "Job accepted", "order_id": order_id}

@router.get("/my", response_model=List[schemas.Delivery])
def get_my_deliveries(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Get current deliverer's deliveries"""
    if current_user.role != "deliverer":
        raise HTTPException(status_code=403, detail="Only deliverers can access this endpoint")
    
    deliverer = db.query(models.DelivererProfile).filter(
        models.DelivererProfile.user_id == current_user.id
    ).first()
    if not deliverer:
        return []
    
    deliveries = db.query(models.Delivery).filter(
        models.Delivery.deliverer_id == deliverer.id
    ).order_by(models.Delivery.created_at.desc()).all()
    
    return deliveries

@router.put("/{delivery_id}/status")
def update_delivery_status(
    delivery_id: int,
    status_update: schemas.DeliveryStatusUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Update delivery status"""
    if current_user.role != "deliverer":
        raise HTTPException(status_code=403, detail="Only deliverers can update delivery status")
    
    delivery = db.query(models.Delivery).filter(models.Delivery.id == delivery_id).first()
    if not delivery:
        raise HTTPException(status_code=404, detail="Delivery not found")
    
    delivery.status = status_update.status
    
    # Update timestamps
    if status_update.status == "picked_up":
        delivery.pickup_time = datetime.utcnow()
    elif status_update.status == "completed":
        delivery.delivery_time = datetime.utcnow()
        # Update order status
        order = db.query(models.Order).filter(models.Order.id == delivery.order_id).first()
        if order:
            order.status = "delivered"
            order.completed_at = datetime.utcnow()
        # Update deliverer status
        deliverer = db.query(models.DelivererProfile).filter(
            models.DelivererProfile.id == delivery.deliverer_id
        ).first()
        if deliverer:
            deliverer.work_status = "online"
    
    db.commit()
    return {"message": "Delivery status updated", "status": delivery.status}

@router.put("/{delivery_id}/location")
def update_delivery_location(
    delivery_id: int,
    location: schemas.DeliveryLocationUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Update deliverer's current location"""
    if current_user.role != "deliverer":
        raise HTTPException(status_code=403, detail="Only deliverers can update location")
    
    delivery = db.query(models.Delivery).filter(models.Delivery.id == delivery_id).first()
    if not delivery:
        raise HTTPException(status_code=404, detail="Delivery not found")
    
    delivery.current_latitude = location.latitude
    delivery.current_longitude = location.longitude
    
    # Save location history
    location_history = models.DeliveryLocationHistory(
        delivery_id=delivery_id,
        latitude=location.latitude,
        longitude=location.longitude
    )
    db.add(location_history)
    
    db.commit()
    return {"message": "Location updated"}

@router.put("/status/online")
def set_deliverer_online(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Set deliverer status to online"""
    if current_user.role != "deliverer":
        raise HTTPException(status_code=403, detail="Only deliverers can use this endpoint")
    
    deliverer = db.query(models.DelivererProfile).filter(
        models.DelivererProfile.user_id == current_user.id
    ).first()
    if not deliverer:
        raise HTTPException(status_code=404, detail="Deliverer profile not found")
    
    deliverer.work_status = "online"
    db.commit()
    return {"message": "Status set to online", "work_status": "online"}

@router.put("/status/offline")
def set_deliverer_offline(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Set deliverer status to offline"""
    if current_user.role != "deliverer":
        raise HTTPException(status_code=403, detail="Only deliverers can use this endpoint")
    
    deliverer = db.query(models.DelivererProfile).filter(
        models.DelivererProfile.user_id == current_user.id
    ).first()
    if not deliverer:
        raise HTTPException(status_code=404, detail="Deliverer profile not found")
    
    deliverer.work_status = "offline"
    db.commit()
    return {"message": "Status set to offline", "work_status": "offline"}
