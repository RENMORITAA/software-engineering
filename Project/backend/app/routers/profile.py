from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas, database
from .auth import get_current_user

router = APIRouter(
    prefix="/profile",
    tags=["profile"],
)

# ==========================================
# 共通エンドポイント: 銀行口座情報
# ==========================================

@router.put("/{role}/banking")
def update_banking_info(
    role: str,
    data: schemas.BankingUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """
    依頼者・店舗・配達員 共通の銀行口座情報更新エンドポイント
    """
    if current_user.role != role:
        raise HTTPException(status_code=403, detail="権限がありません")

    # ロールに応じたプロフィールを取得
    if role == "requester":
        profile = db.query(models.RequesterProfile).filter(models.RequesterProfile.user_id == current_user.id).first()
    elif role == "store":
        profile = db.query(models.StoreProfile).filter(models.StoreProfile.user_id == current_user.id).first()
    elif role == "deliverer":
        profile = db.query(models.DelivererProfile).filter(models.DelivererProfile.user_id == current_user.id).first()
    else:
        raise HTTPException(status_code=400, detail="不正なロールです")

    if not profile:
        raise HTTPException(status_code=404, detail="プロフィールが見つかりません")

    # 銀行情報を更新
    profile.bank_name = data.bank_name
    profile.bank_branch = data.bank_branch
    profile.bank_account_type = data.bank_account_type
    profile.bank_account_number = data.bank_account_number
    profile.bank_account_holder = data.bank_account_holder

    db.commit()
    return {"message": f"{role}の口座情報を更新しました"}


# ==========================================
# Requester Profile
# ==========================================

@router.get("/requester", response_model=schemas.RequesterProfile)
def get_requester_profile(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Get current requester's profile"""
    if current_user.role != "requester":
        raise HTTPException(status_code=403, detail="Only requesters can access this endpoint")
    
    profile = db.query(models.RequesterProfile).filter(
        models.RequesterProfile.user_id == current_user.id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

@router.put("/requester", response_model=schemas.RequesterProfile)
def update_requester_profile(
    profile_update: schemas.RequesterProfileUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Update current requester's profile"""
    if current_user.role != "requester":
        raise HTTPException(status_code=403, detail="Only requesters can update their profile")
    
    profile = db.query(models.RequesterProfile).filter(
        models.RequesterProfile.user_id == current_user.id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    update_data = profile_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(profile, field, value)
    
    db.commit()
    db.refresh(profile)
    return profile

# ==========================================
# Requester Addresses
# ==========================================

@router.get("/requester/addresses", response_model=List[schemas.RequesterAddress])
def get_requester_addresses(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Get current requester's addresses"""
    if current_user.role != "requester":
        raise HTTPException(status_code=403, detail="Only requesters can access this endpoint")
    
    profile = db.query(models.RequesterProfile).filter(
        models.RequesterProfile.user_id == current_user.id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    addresses = db.query(models.RequesterAddress).filter(
        models.RequesterAddress.requester_id == profile.id
    ).all()
    return addresses

@router.post("/requester/addresses", response_model=schemas.RequesterAddress)
def add_requester_address(
    address: schemas.RequesterAddressCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Add a new address for current requester"""
    if current_user.role != "requester":
        raise HTTPException(status_code=403, detail="Only requesters can add addresses")
    
    profile = db.query(models.RequesterProfile).filter(
        models.RequesterProfile.user_id == current_user.id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    if address.is_default:
        db.query(models.RequesterAddress).filter(
            models.RequesterAddress.requester_id == profile.id
        ).update({"is_default": False})
    
    db_address = models.RequesterAddress(
        requester_id=profile.id,
        label=address.label,
        postal_code=address.postal_code,
        prefecture=address.prefecture,
        city=address.city,
        address_line1=address.address_line1,
        address_line2=address.address_line2,
        latitude=address.latitude,
        longitude=address.longitude,
        is_default=address.is_default
    )
    db.add(db_address)
    db.commit()
    db.refresh(db_address)
    
    if address.is_default:
        profile.default_address_id = db_address.id
        db.commit()
    
    return db_address

@router.delete("/requester/addresses/{address_id}")
def delete_requester_address(
    address_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Delete an address"""
    if current_user.role != "requester":
        raise HTTPException(status_code=403, detail="Only requesters can delete addresses")
    
    profile = db.query(models.RequesterProfile).filter(
        models.RequesterProfile.user_id == current_user.id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    address = db.query(models.RequesterAddress).filter(
        models.RequesterAddress.id == address_id,
        models.RequesterAddress.requester_id == profile.id
    ).first()
    if not address:
        raise HTTPException(status_code=404, detail="Address not found")
    
    db.delete(address)
    db.commit()
    return {"message": "Address deleted"}

# ==========================================
# Deliverer Profile
# ==========================================

@router.get("/deliverer", response_model=schemas.DelivererProfile)
def get_deliverer_profile(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Get current deliverer's profile"""
    if current_user.role != "deliverer":
        raise HTTPException(status_code=403, detail="Only deliverers can access this endpoint")
    
    profile = db.query(models.DelivererProfile).filter(
        models.DelivererProfile.user_id == current_user.id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

@router.put("/deliverer", response_model=schemas.DelivererProfile)
def update_deliverer_profile(
    profile_update: schemas.DelivererProfileUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Update current deliverer's profile"""
    if current_user.role != "deliverer":
        raise HTTPException(status_code=403, detail="Only deliverers can update their profile")
    
    profile = db.query(models.DelivererProfile).filter(
        models.DelivererProfile.user_id == current_user.id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    update_data = profile_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(profile, field, value)
    
    db.commit()
    db.refresh(profile)
    return profile

# ==========================================
# Store Profile
# ==========================================

@router.get("/store", response_model=schemas.StoreProfile)
def get_store_profile(
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Get current store's profile"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only stores can access this endpoint")
    
    profile = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

@router.put("/store", response_model=schemas.StoreProfile)
def update_store_profile(
    profile_update: schemas.StoreProfileUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Update current store's profile"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only stores can update their profile")
    
    profile = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    update_data = profile_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(profile, field, value)
    
    db.commit()
    db.refresh(profile)
    return profile