from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

# User Schemas
class UserBase(BaseModel):
    email: str
    role: str

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    is_active: bool
    created_at: datetime

    class Config:
        orm_mode = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

# Product Schemas
class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: int
    image_url: Optional[str] = None
    is_available: bool = True

class ProductCreate(ProductBase):
    pass

class Product(ProductBase):
    id: int
    store_id: int

    class Config:
        orm_mode = True

# Order Schemas
class OrderDetailBase(BaseModel):
    product_id: int
    quantity: int

class OrderCreate(BaseModel):
    store_id: int
    details: List[OrderDetailBase]

class OrderDetail(OrderDetailBase):
    id: int
    price: int
    product_name: str # For convenience

    class Config:
        orm_mode = True

class Order(BaseModel):
    id: int
    requester_id: int
    store_id: int
    status: str
    total_amount: int
    created_at: datetime
    # details: List[OrderDetail] = []

    class Config:
        orm_mode = True

# Delivery Schemas
class DeliveryJob(BaseModel):
    id: int
    order_id: int
    store_name: str
    store_address: str
    delivery_address: str
    reward: int
    distance: float

    class Config:
        orm_mode = True
