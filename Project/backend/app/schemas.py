from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime, date
from decimal import Decimal

# ==========================================
# User Schemas
# ==========================================

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
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None


# ==========================================
# RequesterProfile Schemas
# ==========================================

class RequesterAddressBase(BaseModel):
    label: Optional[str] = "自宅"
    postal_code: Optional[str] = None
    prefecture: Optional[str] = None
    city: Optional[str] = None
    address_line1: str
    address_line2: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    is_default: bool = False

class RequesterAddressCreate(RequesterAddressBase):
    pass

class RequesterAddress(RequesterAddressBase):
    id: int
    requester_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class RequesterProfileBase(BaseModel):
    name: str
    phone_number: Optional[str] = None

class RequesterProfileCreate(RequesterProfileBase):
    pass

class RequesterProfileUpdate(BaseModel):
    name: Optional[str] = None
    phone_number: Optional[str] = None
    default_address_id: Optional[int] = None

class RequesterProfile(RequesterProfileBase):
    id: int
    user_id: int
    default_address_id: Optional[int] = None
    addresses: List[RequesterAddress] = []

    class Config:
        from_attributes = True


# ==========================================
# DelivererProfile Schemas
# ==========================================

class DelivererProfileBase(BaseModel):
    name: str
    phone_number: Optional[str] = None
    vehicle_type: Optional[str] = None

class DelivererProfileCreate(DelivererProfileBase):
    pass

class DelivererProfileUpdate(BaseModel):
    name: Optional[str] = None
    phone_number: Optional[str] = None
    resume: Optional[str] = None
    work_status: Optional[str] = None
    bank_name: Optional[str] = None
    bank_branch: Optional[str] = None
    bank_account_type: Optional[str] = None
    bank_account_number: Optional[str] = None
    bank_account_holder: Optional[str] = None
    vehicle_type: Optional[str] = None
    license_number: Optional[str] = None

class DelivererProfile(DelivererProfileBase):
    id: int
    user_id: int
    work_status: str = "offline"
    resume: Optional[str] = None
    bank_name: Optional[str] = None
    bank_branch: Optional[str] = None
    bank_account_type: Optional[str] = None
    bank_account_number: Optional[str] = None
    bank_account_holder: Optional[str] = None
    license_number: Optional[str] = None
    profile_image_url: Optional[str] = None

    class Config:
        from_attributes = True


# ==========================================
# StoreProfile Schemas
# ==========================================

class StoreProfileBase(BaseModel):
    store_name: str
    description: Optional[str] = None
    address: str
    phone_number: Optional[str] = None
    business_hours: Optional[str] = None

class StoreProfileCreate(StoreProfileBase):
    pass

class StoreProfileUpdate(BaseModel):
    store_name: Optional[str] = None
    description: Optional[str] = None
    address: Optional[str] = None
    postal_code: Optional[str] = None
    phone_number: Optional[str] = None
    business_hours: Optional[str] = None
    is_open: Optional[bool] = None

class StoreProfile(StoreProfileBase):
    id: int
    user_id: int
    postal_code: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    business_license: Optional[str] = None
    store_image_url: Optional[str] = None
    is_open: bool = True

    class Config:
        from_attributes = True


# ==========================================
# Product Schemas
# ==========================================

class ProductCategoryBase(BaseModel):
    name: str
    display_order: int = 0

class ProductCategoryCreate(ProductCategoryBase):
    pass

class ProductCategory(ProductCategoryBase):
    id: int
    store_id: int

    class Config:
        from_attributes = True

class ProductBase(BaseModel):
    name: str
    description: Optional[str] = None
    price: int
    image_url: Optional[str] = None
    is_available: bool = True
    stock_quantity: int = 0

class ProductCreate(ProductBase):
    category_id: Optional[int] = None

class ProductUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    price: Optional[int] = None
    image_url: Optional[str] = None
    is_available: Optional[bool] = None
    stock_quantity: Optional[int] = None
    category_id: Optional[int] = None

class Product(ProductBase):
    id: int
    store_id: int
    category_id: Optional[int] = None
    display_order: int = 0

    class Config:
        from_attributes = True


# ==========================================
# Order Schemas
# ==========================================

class OrderDetailBase(BaseModel):
    product_id: int
    quantity: int
    notes: Optional[str] = None

class OrderDetailCreate(OrderDetailBase):
    pass

class OrderDetail(BaseModel):
    id: int
    order_id: int
    product_id: int
    product_name: str
    quantity: int
    unit_price: int
    subtotal: int
    notes: Optional[str] = None

    class Config:
        from_attributes = True

class OrderCreate(BaseModel):
    store_id: int
    delivery_address: str
    delivery_latitude: Optional[float] = None
    delivery_longitude: Optional[float] = None
    notes: Optional[str] = None
    details: List[OrderDetailCreate]

class OrderUpdate(BaseModel):
    status: Optional[str] = None
    notes: Optional[str] = None

class Order(BaseModel):
    id: int
    requester_id: int
    store_id: int
    deliverer_id: Optional[int] = None
    status: str
    subtotal: int
    delivery_fee: int
    total_price: int
    delivery_address: str
    notes: Optional[str] = None
    ordered_at: datetime
    accepted_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    order_details: List[OrderDetail] = []

    class Config:
        from_attributes = True


# ==========================================
# Delivery Schemas
# ==========================================

class DeliveryLocationUpdate(BaseModel):
    latitude: float
    longitude: float

class DeliveryStatusUpdate(BaseModel):
    status: str

class DeliveryJob(BaseModel):
    id: int
    order_id: int
    store_name: str
    store_address: str
    delivery_address: str
    reward: int
    distance: Optional[float] = None
    items_count: int = 0

    class Config:
        from_attributes = True

class Delivery(BaseModel):
    id: int
    order_id: int
    deliverer_id: int
    status: str
    pickup_time: Optional[datetime] = None
    delivery_time: Optional[datetime] = None
    current_latitude: Optional[float] = None
    current_longitude: Optional[float] = None
    distance_km: Optional[float] = None
    delivery_fee: Optional[int] = None

    class Config:
        from_attributes = True


# ==========================================
# Notification Schemas
# ==========================================

class NotificationBase(BaseModel):
    title: str
    message: str
    type: str
    related_order_id: Optional[int] = None

class NotificationCreate(NotificationBase):
    user_id: int

class Notification(NotificationBase):
    id: int
    user_id: int
    is_read: bool = False
    created_at: datetime

    class Config:
        from_attributes = True


# ==========================================
# Payment Schemas
# ==========================================

class PaymentCreate(BaseModel):
    order_id: int
    amount: int
    payment_method: str

class Payment(BaseModel):
    id: int
    order_id: int
    amount: int
    payment_method: str
    payment_status: str
    transaction_id: Optional[str] = None
    paid_at: Optional[datetime] = None

    class Config:
        from_attributes = True


# ==========================================
# Payout/Sales Schemas
# ==========================================

class DelivererPayout(BaseModel):
    id: int
    deliverer_id: int
    period_start: date
    period_end: date
    total_deliveries: int
    total_amount: int
    status: str
    paid_at: Optional[datetime] = None

    class Config:
        from_attributes = True

class StoreSales(BaseModel):
    id: int
    store_id: int
    period_start: date
    period_end: date
    total_orders: int
    total_amount: int
    commission_rate: float
    commission_amount: int
    net_amount: int
    status: str
    paid_at: Optional[datetime] = None

    class Config:
        from_attributes = True
