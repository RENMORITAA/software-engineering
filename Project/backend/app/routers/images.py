from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from typing import List
import os
import uuid
from datetime import datetime
from .. import models, database
from .auth import get_current_user

router = APIRouter(
    prefix="/images",
    tags=["images"],
)

# 画像保存先ディレクトリ（本番ではS3に変更）
UPLOAD_DIR = "/app/uploads"

# 許可するMIMEタイプ
ALLOWED_MIME_TYPES = ["image/jpeg", "image/png", "image/gif", "image/webp"]


@router.post("/upload")
async def upload_image(
    file: UploadFile = File(...),
    entity_type: str = None,
    entity_id: int = None,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """画像をアップロード"""
    # MIMEタイプチェック
    if file.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type. Allowed: {', '.join(ALLOWED_MIME_TYPES)}"
        )
    
    # ファイルサイズチェック（5MB制限）
    contents = await file.read()
    if len(contents) > 5 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="File too large. Max 5MB allowed.")
    
    # ユニークなファイル名を生成
    ext = os.path.splitext(file.filename)[1]
    unique_filename = f"{uuid.uuid4()}{ext}"
    
    # 保存ディレクトリを作成
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    file_path = os.path.join(UPLOAD_DIR, unique_filename)
    
    # ファイルを保存
    with open(file_path, "wb") as f:
        f.write(contents)
    
    # DBに記録
    image = models.Image(
        filename=unique_filename,
        original_filename=file.filename,
        file_path=f"/uploads/{unique_filename}",  # 相対パス
        file_size=len(contents),
        mime_type=file.content_type,
        uploaded_by=current_user.id,
        entity_type=entity_type,
        entity_id=entity_id
    )
    db.add(image)
    db.commit()
    db.refresh(image)
    
    return {
        "id": image.id,
        "filename": image.filename,
        "file_path": image.file_path,
        "mime_type": image.mime_type,
        "file_size": image.file_size
    }


@router.get("/{image_id}")
def get_image(image_id: int, db: Session = Depends(database.get_db)):
    """画像情報を取得"""
    image = db.query(models.Image).filter(models.Image.id == image_id).first()
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    return {
        "id": image.id,
        "filename": image.filename,
        "original_filename": image.original_filename,
        "file_path": image.file_path,
        "mime_type": image.mime_type,
        "file_size": image.file_size,
        "created_at": image.created_at
    }


@router.get("/entity/{entity_type}/{entity_id}")
def get_entity_images(
    entity_type: str,
    entity_id: int,
    db: Session = Depends(database.get_db)
):
    """特定のエンティティに紐づく画像一覧を取得"""
    images = db.query(models.Image).filter(
        models.Image.entity_type == entity_type,
        models.Image.entity_id == entity_id
    ).all()
    
    return [
        {
            "id": img.id,
            "filename": img.filename,
            "file_path": img.file_path,
            "mime_type": img.mime_type
        }
        for img in images
    ]


@router.delete("/{image_id}")
def delete_image(
    image_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """画像を削除"""
    image = db.query(models.Image).filter(models.Image.id == image_id).first()
    if not image:
        raise HTTPException(status_code=404, detail="Image not found")
    
    # 所有者チェック（管理者は誰でも削除可能）
    if image.uploaded_by != current_user.id and current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Not authorized to delete this image")
    
    # ファイルを削除
    full_path = os.path.join("/app", image.file_path.lstrip("/"))
    if os.path.exists(full_path):
        os.remove(full_path)
    
    # DBから削除
    db.delete(image)
    db.commit()
    
    return {"message": "Image deleted successfully"}
