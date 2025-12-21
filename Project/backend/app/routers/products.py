from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas, database

router = APIRouter(
    prefix="/products",
    tags=["products"],
)

@router.get("/", response_model=List[schemas.Product])
def get_products(skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db)):
    products = db.query(models.Product).offset(skip).limit(limit).all()
    return products

@router.post("/", response_model=schemas.Product)
def create_product(product: schemas.ProductCreate, store_id: int, db: Session = Depends(database.get_db)):
    # TODO: Check if user is store owner
    db_product = models.Product(**product.dict(), store_id=store_id)
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    return db_product

@router.get("/store/{store_id}", response_model=List[schemas.Product])
def get_store_products(store_id: int, db: Session = Depends(database.get_db)):
    products = db.query(models.Product).filter(models.Product.store_id == store_id).all()
    return products
