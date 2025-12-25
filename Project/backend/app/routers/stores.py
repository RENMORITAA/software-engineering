from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas, database
from .auth import get_current_user

router = APIRouter(
    prefix="/stores",
    tags=["stores"],
)

@router.get("/", response_model=List[schemas.StoreProfile])
def get_stores(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(database.get_db)
):
    """Get all open stores"""
    stores = db.query(models.StoreProfile).filter(
        models.StoreProfile.is_open == True
    ).offset(skip).limit(limit).all()
    return stores

@router.get("/{store_id}", response_model=schemas.StoreProfile)
def get_store(store_id: int, db: Session = Depends(database.get_db)):
    """Get a specific store by ID"""
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.id == store_id
    ).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store not found")
    return store

@router.get("/my/profile", response_model=schemas.StoreProfile)
def get_my_store_profile(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Get current store's profile"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only store owners can access this endpoint")
    
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store profile not found")
    return store

@router.put("/my/profile", response_model=schemas.StoreProfile)
def update_my_store_profile(
    profile_update: schemas.StoreProfileUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Update current store's profile"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only store owners can update their profile")
    
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store profile not found")
    
    update_data = profile_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(store, field, value)
    
    db.commit()
    db.refresh(store)
    return store

@router.put("/my/toggle-open")
def toggle_store_open(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Toggle store open/closed status"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only store owners can toggle open status")
    
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store profile not found")
    
    store.is_open = not store.is_open
    db.commit()
    return {"message": "Store status updated", "is_open": store.is_open}
