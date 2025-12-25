from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from .. import models, schemas, database
from .auth import get_current_user

router = APIRouter(
    prefix="/products",
    tags=["products"],
)

@router.get("/", response_model=List[schemas.Product])
def get_products(skip: int = 0, limit: int = 100, db: Session = Depends(database.get_db)):
    """Get all available products"""
    products = db.query(models.Product).filter(
        models.Product.is_available == True
    ).offset(skip).limit(limit).all()
    return products

@router.get("/{product_id}", response_model=schemas.Product)
def get_product(product_id: int, db: Session = Depends(database.get_db)):
    """Get a specific product by ID"""
    product = db.query(models.Product).filter(models.Product.id == product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product

@router.get("/store/{store_id}", response_model=List[schemas.Product])
def get_store_products(store_id: int, db: Session = Depends(database.get_db)):
    """Get all products for a specific store"""
    products = db.query(models.Product).filter(
        models.Product.store_id == store_id
    ).order_by(models.Product.display_order).all()
    return products

@router.get("/store/{store_id}/categories", response_model=List[schemas.ProductCategory])
def get_store_categories(store_id: int, db: Session = Depends(database.get_db)):
    """Get all product categories for a store"""
    categories = db.query(models.ProductCategory).filter(
        models.ProductCategory.store_id == store_id
    ).order_by(models.ProductCategory.display_order).all()
    return categories

@router.post("/", response_model=schemas.Product)
def create_product(
    product: schemas.ProductCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Create a new product (store owner only)"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only store owners can create products")
    
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store profile not found")
    
    db_product = models.Product(
        store_id=store.id,
        name=product.name,
        description=product.description,
        price=product.price,
        image_url=product.image_url,
        is_available=product.is_available,
        stock_quantity=product.stock_quantity,
        category_id=product.category_id
    )
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    return db_product

@router.put("/{product_id}", response_model=schemas.Product)
def update_product(
    product_id: int,
    product_update: schemas.ProductUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Update a product (store owner only)"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only store owners can update products")
    
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    
    product = db.query(models.Product).filter(
        models.Product.id == product_id,
        models.Product.store_id == store.id
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    update_data = product_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(product, field, value)
    
    db.commit()
    db.refresh(product)
    return product

@router.delete("/{product_id}")
def delete_product(
    product_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Delete a product (store owner only)"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only store owners can delete products")
    
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    
    product = db.query(models.Product).filter(
        models.Product.id == product_id,
        models.Product.store_id == store.id
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    db.delete(product)
    db.commit()
    return {"message": "Product deleted"}

@router.post("/categories", response_model=schemas.ProductCategory)
def create_category(
    category: schemas.ProductCategoryCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """Create a new product category (store owner only)"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only store owners can create categories")
    
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    if not store:
        raise HTTPException(status_code=404, detail="Store profile not found")
    
    db_category = models.ProductCategory(
        store_id=store.id,
        name=category.name,
        display_order=category.display_order
    )
    db.add(db_category)
    db.commit()
    db.refresh(db_category)
    return db_category
