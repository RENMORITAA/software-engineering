from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas, database

router = APIRouter(
    prefix="/delivery",
    tags=["delivery"],
)

@router.get("/jobs", response_model=List[schemas.DeliveryJob])
def get_delivery_jobs(db: Session = Depends(database.get_db)):
    # Get orders that are ready for delivery and not yet assigned
    # This is a simplified logic
    orders = db.query(models.Order).filter(models.Order.status == "ready").all()
    
    jobs = []
    for order in orders:
        store = db.query(models.StoreProfile).filter(models.StoreProfile.id == order.store_id).first()
        requester = db.query(models.RequesterProfile).filter(models.RequesterProfile.id == order.requester_id).first()
        
        jobs.append({
            "id": order.id, # Using order ID as job ID for simplicity
            "order_id": order.id,
            "store_name": store.name,
            "store_address": store.address,
            "delivery_address": requester.address,
            "reward": 500, # Fixed reward for now
            "distance": 2.5 # Mock distance
        })
    
    return jobs

@router.post("/jobs/{order_id}/accept")
def accept_job(order_id: int, deliverer_id: int, db: Session = Depends(database.get_db)):
    order = db.query(models.Order).filter(models.Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    if order.status != "ready":
        raise HTTPException(status_code=400, detail="Order not ready for delivery")

    # Create delivery record
    delivery = models.Delivery(
        order_id=order_id,
        deliverer_id=deliverer_id,
        status="assigned"
    )
    db.add(delivery)
    
    order.status = "delivering"
    db.commit()
    
    return {"message": "Job accepted"}
