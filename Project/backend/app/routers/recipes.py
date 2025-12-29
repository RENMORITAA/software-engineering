from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from pydantic import BaseModel
from .. import models, database
from .auth import get_current_user

router = APIRouter(
    prefix="/recipes",
    tags=["recipes"],
)


# ==========================================
# Pydantic Schemas
# ==========================================

class IngredientBase(BaseModel):
    name: str
    quantity: Optional[str] = None
    display_order: int = 0

class IngredientCreate(IngredientBase):
    pass

class Ingredient(IngredientBase):
    id: int
    
    class Config:
        from_attributes = True


class StepBase(BaseModel):
    step_number: int
    description: str
    image_url: Optional[str] = None

class StepCreate(StepBase):
    pass

class Step(StepBase):
    id: int
    
    class Config:
        from_attributes = True


class RecipeBase(BaseModel):
    preparation_time: Optional[int] = None
    calories: Optional[int] = None
    allergens: Optional[str] = None

class RecipeCreate(RecipeBase):
    ingredients: List[IngredientCreate] = []
    steps: List[StepCreate] = []

class RecipeUpdate(RecipeBase):
    ingredients: Optional[List[IngredientCreate]] = None
    steps: Optional[List[StepCreate]] = None

class Recipe(RecipeBase):
    id: int
    product_id: int
    ingredients: List[Ingredient] = []
    steps: List[Step] = []
    
    class Config:
        from_attributes = True


# ==========================================
# API Endpoints
# ==========================================

@router.get("/product/{product_id}", response_model=Recipe)
def get_product_recipe(product_id: int, db: Session = Depends(database.get_db)):
    """商品のレシピ情報を取得"""
    recipe = db.query(models.ProductRecipe).filter(
        models.ProductRecipe.product_id == product_id
    ).first()
    
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    
    return recipe


@router.post("/product/{product_id}", response_model=Recipe)
def create_product_recipe(
    product_id: int,
    recipe_data: RecipeCreate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """商品のレシピ情報を作成（店舗のみ）"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only store owners can create recipes")
    
    # 店舗の商品か確認
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    
    product = db.query(models.Product).filter(
        models.Product.id == product_id,
        models.Product.store_id == store.id
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found or not owned by you")
    
    # 既存のレシピがあるか確認
    existing_recipe = db.query(models.ProductRecipe).filter(
        models.ProductRecipe.product_id == product_id
    ).first()
    
    if existing_recipe:
        raise HTTPException(status_code=400, detail="Recipe already exists. Use PUT to update.")
    
    # レシピを作成
    recipe = models.ProductRecipe(
        product_id=product_id,
        preparation_time=recipe_data.preparation_time,
        calories=recipe_data.calories,
        allergens=recipe_data.allergens
    )
    db.add(recipe)
    db.flush()
    
    # 材料を追加
    for ing_data in recipe_data.ingredients:
        ingredient = models.RecipeIngredient(
            recipe_id=recipe.id,
            name=ing_data.name,
            quantity=ing_data.quantity,
            display_order=ing_data.display_order
        )
        db.add(ingredient)
    
    # 手順を追加
    for step_data in recipe_data.steps:
        step = models.RecipeStep(
            recipe_id=recipe.id,
            step_number=step_data.step_number,
            description=step_data.description,
            image_url=step_data.image_url
        )
        db.add(step)
    
    db.commit()
    db.refresh(recipe)
    
    return recipe


@router.put("/product/{product_id}", response_model=Recipe)
def update_product_recipe(
    product_id: int,
    recipe_data: RecipeUpdate,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """商品のレシピ情報を更新（店舗のみ）"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only store owners can update recipes")
    
    # 店舗の商品か確認
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    
    product = db.query(models.Product).filter(
        models.Product.id == product_id,
        models.Product.store_id == store.id
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found or not owned by you")
    
    recipe = db.query(models.ProductRecipe).filter(
        models.ProductRecipe.product_id == product_id
    ).first()
    
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found. Use POST to create.")
    
    # レシピ基本情報を更新
    if recipe_data.preparation_time is not None:
        recipe.preparation_time = recipe_data.preparation_time
    if recipe_data.calories is not None:
        recipe.calories = recipe_data.calories
    if recipe_data.allergens is not None:
        recipe.allergens = recipe_data.allergens
    
    # 材料を更新（全削除して再追加）
    if recipe_data.ingredients is not None:
        db.query(models.RecipeIngredient).filter(
            models.RecipeIngredient.recipe_id == recipe.id
        ).delete()
        
        for ing_data in recipe_data.ingredients:
            ingredient = models.RecipeIngredient(
                recipe_id=recipe.id,
                name=ing_data.name,
                quantity=ing_data.quantity,
                display_order=ing_data.display_order
            )
            db.add(ingredient)
    
    # 手順を更新（全削除して再追加）
    if recipe_data.steps is not None:
        db.query(models.RecipeStep).filter(
            models.RecipeStep.recipe_id == recipe.id
        ).delete()
        
        for step_data in recipe_data.steps:
            step = models.RecipeStep(
                recipe_id=recipe.id,
                step_number=step_data.step_number,
                description=step_data.description,
                image_url=step_data.image_url
            )
            db.add(step)
    
    db.commit()
    db.refresh(recipe)
    
    return recipe


@router.delete("/product/{product_id}")
def delete_product_recipe(
    product_id: int,
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(database.get_db)
):
    """商品のレシピ情報を削除（店舗のみ）"""
    if current_user.role != "store":
        raise HTTPException(status_code=403, detail="Only store owners can delete recipes")
    
    # 店舗の商品か確認
    store = db.query(models.StoreProfile).filter(
        models.StoreProfile.user_id == current_user.id
    ).first()
    
    product = db.query(models.Product).filter(
        models.Product.id == product_id,
        models.Product.store_id == store.id
    ).first()
    
    if not product:
        raise HTTPException(status_code=404, detail="Product not found or not owned by you")
    
    recipe = db.query(models.ProductRecipe).filter(
        models.ProductRecipe.product_id == product_id
    ).first()
    
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    
    db.delete(recipe)
    db.commit()
    
    return {"message": "Recipe deleted successfully"}
