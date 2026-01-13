from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from typing import Optional
import os
import uuid
import shutil
from datetime import datetime
from .. import models, database
from .auth import get_current_user

router = APIRouter(
    prefix="/uploads",
    tags=["uploads"],
)

# アップロードディレクトリ
UPLOAD_DIR = "/app/uploads"
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "gif", "webp"}
MAX_FILE_SIZE = 5 * 1024 * 1024  # 5MB

def ensure_upload_dir():
    """アップロードディレクトリを作成"""
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    os.makedirs(f"{UPLOAD_DIR}/profiles", exist_ok=True)
    os.makedirs(f"{UPLOAD_DIR}/stores", exist_ok=True)
    os.makedirs(f"{UPLOAD_DIR}/products", exist_ok=True)

def get_file_extension(filename: str) -> str:
    """ファイル拡張子を取得"""
    return filename.rsplit(".", 1)[-1].lower() if "." in filename else ""

def generate_unique_filename(original_filename: str) -> str:
    """ユニークなファイル名を生成"""
    ext = get_file_extension(original_filename)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    unique_id = uuid.uuid4().hex[:8]
    return f"{timestamp}_{unique_id}.{ext}"

@router.post("/profile-image")
async def upload_profile_image(
    file: UploadFile = File(...),
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """プロフィール画像をアップロード"""
    ensure_upload_dir()
    
    # ファイル拡張子チェック
    ext = get_file_extension(file.filename or "")
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400, 
            detail=f"Allowed file types: {', '.join(ALLOWED_EXTENSIONS)}"
        )
    
    # ファイルサイズチェック
    file_content = await file.read()
    if len(file_content) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File size exceeds 5MB limit")
    
    # ファイル保存
    filename = generate_unique_filename(file.filename or "image.jpg")
    file_path = f"{UPLOAD_DIR}/profiles/{filename}"
    
    with open(file_path, "wb") as f:
        f.write(file_content)
    
    # データベース更新
    image_url = f"/uploads/profiles/{filename}"
    
    if current_user.role == "deliverer":
        profile = db.query(models.DelivererProfile).filter(
            models.DelivererProfile.user_id == current_user.id
        ).first()
        if profile:
            # 古い画像を削除
            if profile.profile_image_url:
                old_path = f"{UPLOAD_DIR}{profile.profile_image_url.replace('/uploads', '')}"
                if os.path.exists(old_path):
                    os.remove(old_path)
            profile.profile_image_url = image_url
            db.commit()
    
    return {"url": image_url, "message": "Image uploaded successfully"}

@router.post("/store-image")
async def upload_store_image(
    file: UploadFile = File(...),
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """店舗画像をアップロード"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only stores can upload store images")
    
    ensure_upload_dir()
    
    ext = get_file_extension(file.filename or "")
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400, 
            detail=f"Allowed file types: {', '.join(ALLOWED_EXTENSIONS)}"
        )
    
    file_content = await file.read()
    if len(file_content) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File size exceeds 5MB limit")
    
    filename = generate_unique_filename(file.filename or "image.jpg")
    file_path = f"{UPLOAD_DIR}/stores/{filename}"
    
    with open(file_path, "wb") as f:
        f.write(file_content)
    
    image_url = f"/uploads/stores/{filename}"
    
    profile = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if profile:
        if profile.store_image_url:
            old_path = f"{UPLOAD_DIR}{profile.store_image_url.replace('/uploads', '')}"
            if os.path.exists(old_path):
                os.remove(old_path)
        profile.store_image_url = image_url
        db.commit()
    
    return {"url": image_url, "message": "Store image uploaded successfully"}

@router.post("/product-image/{product_id}")
async def upload_product_image(
    product_id: int,
    file: UploadFile = File(...),
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """商品画像をアップロード"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only stores can upload product images")
    
    # 商品の所有者チェック
    store_profile = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if not store_profile:
        raise HTTPException(status_code=404, detail="Store profile not found")
    
    product = db.query(models.Product).filter(
        models.Product.id == product_id,
        models.Product.store_id == store_profile.id
    ).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    ensure_upload_dir()
    
    ext = get_file_extension(file.filename or "")
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400, 
            detail=f"Allowed file types: {', '.join(ALLOWED_EXTENSIONS)}"
        )
    
    file_content = await file.read()
    if len(file_content) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File size exceeds 5MB limit")
    
    filename = generate_unique_filename(file.filename or "image.jpg")
    file_path = f"{UPLOAD_DIR}/products/{filename}"
    
    with open(file_path, "wb") as f:
        f.write(file_content)
    
    image_url = f"/uploads/products/{filename}"
    
    if product.image_url:
        old_path = f"{UPLOAD_DIR}{product.image_url.replace('/uploads', '')}"
        if os.path.exists(old_path):
            os.remove(old_path)
    
    product.image_url = image_url
    db.commit()
    
    return {"url": image_url, "message": "Product image uploaded successfully"}

@router.delete("/{image_type}/{filename}")
async def delete_image(
    image_type: str,
    filename: str,
    current_user: models.User = Depends(get_current_user),
):
    """画像を削除"""
    if image_type not in ["profiles", "stores", "products"]:
        raise HTTPException(status_code=400, detail="Invalid image type")
    
    file_path = f"{UPLOAD_DIR}/{image_type}/{filename}"
    
    if os.path.exists(file_path):
        os.remove(file_path)
        return {"message": "Image deleted successfully"}
    else:
        raise HTTPException(status_code=404, detail="Image not found")
