from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Float, DateTime, Text, Numeric, Date
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base

# ==========================================
# ユーザー管理モデル
# ==========================================

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    hashed_password = Column("password", String(255), nullable=False)
    role = Column(String(20), nullable=False)  # requester, deliverer, store, admin
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    requester_profile = relationship("RequesterProfile", back_populates="user", uselist=False)
    deliverer_profile = relationship("DelivererProfile", back_populates="user", uselist=False)
    store_profile = relationship("StoreProfile", back_populates="user", uselist=False)
    notifications = relationship("Notification", back_populates="user")


class RequesterProfile(Base):
    __tablename__ = "requester_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    phone_number = Column(String(20))
    default_address_id = Column(Integer)
    credit_card_info = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="requester_profile")
    addresses = relationship("RequesterAddress", back_populates="requester")
    orders = relationship("Order", back_populates="requester")


class RequesterAddress(Base):
    __tablename__ = "requester_addresses"

    id = Column(Integer, primary_key=True, index=True)
    requester_id = Column(Integer, ForeignKey("requester_profiles.id", ondelete="CASCADE"), nullable=False)
    label = Column(String(50), default="自宅")
    postal_code = Column(String(10))
    prefecture = Column(String(20))
    city = Column(String(50))
    address_line1 = Column(String(255), nullable=False)
    address_line2 = Column(String(255))
    latitude = Column(Numeric(10, 8))
    longitude = Column(Numeric(11, 8))
    is_default = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())

    requester = relationship("RequesterProfile", back_populates="addresses")


class DelivererProfile(Base):
    __tablename__ = "deliverer_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    phone_number = Column(String(20))
    resume = Column(Text)
    work_status = Column(String(20), default="offline")  # online, offline, busy
    bank_name = Column(String(100))
    bank_branch = Column(String(100))
    bank_account_type = Column(String(20))
    bank_account_number = Column(String(20))
    bank_account_holder = Column(String(100))
    vehicle_type = Column(String(50))
    license_number = Column(String(50))
    profile_image_url = Column(String(500))
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="deliverer_profile")
    deliveries = relationship("Delivery", back_populates="deliverer")
    payouts = relationship("DelivererPayout", back_populates="deliverer")


class StoreProfile(Base):
    __tablename__ = "store_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    store_name = Column(String(200), nullable=False)
    description = Column(Text)
    address = Column(String(500), nullable=False)
    postal_code = Column(String(10))
    latitude = Column(Numeric(10, 8))
    longitude = Column(Numeric(11, 8))
    phone_number = Column(String(20))
    business_license = Column(String(100))
    business_hours = Column(String(200))
    bank_name = Column(String(100))
    bank_branch = Column(String(100))
    bank_account_type = Column(String(20))
    bank_account_number = Column(String(20))
    bank_account_holder = Column(String(100))
    store_image_url = Column(String(500))
    is_open = Column(Boolean, default=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    user = relationship("User", back_populates="store_profile")
    categories = relationship("ProductCategory", back_populates="store")
    products = relationship("Product", back_populates="store")
    orders = relationship("Order", back_populates="store")
    sales = relationship("StoreSales", back_populates="store")


# ==========================================
# 商品管理モデル
# ==========================================

class ProductCategory(Base):
    __tablename__ = "product_categories"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("store_profiles.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(100), nullable=False)
    display_order = Column(Integer, default=0)
    created_at = Column(DateTime, server_default=func.now())

    store = relationship("StoreProfile", back_populates="categories")
    products = relationship("Product", back_populates="category")


class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("store_profiles.id", ondelete="CASCADE"), nullable=False)
    category_id = Column(Integer, ForeignKey("product_categories.id", ondelete="SET NULL"))
    name = Column(String(200), nullable=False)
    description = Column(Text)
    price = Column(Integer, nullable=False)
    image_url = Column(String(500))
    is_available = Column(Boolean, default=True)
    stock_quantity = Column(Integer, default=0)
    display_order = Column(Integer, default=0)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    store = relationship("StoreProfile", back_populates="products")
    category = relationship("ProductCategory", back_populates="products")
    order_details = relationship("OrderDetail", back_populates="product")


# ==========================================
# 注文管理モデル
# ==========================================

class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    requester_id = Column(Integer, ForeignKey("requester_profiles.id"), nullable=False)
    store_id = Column(Integer, ForeignKey("store_profiles.id"), nullable=False)
    deliverer_id = Column(Integer, ForeignKey("deliverer_profiles.id"))
    status = Column(String(30), nullable=False, default="pending")
    # pending, accepted, preparing, ready_for_pickup, picked_up, delivering, delivered, cancelled
    subtotal = Column(Integer, nullable=False)
    delivery_fee = Column(Integer, nullable=False, default=0)
    total_price = Column(Integer, nullable=False)
    delivery_address = Column(String(500), nullable=False)
    delivery_latitude = Column(Numeric(10, 8))
    delivery_longitude = Column(Numeric(11, 8))
    notes = Column(Text)
    estimated_delivery_time = Column(DateTime)
    ordered_at = Column(DateTime, server_default=func.now())
    accepted_at = Column(DateTime)
    completed_at = Column(DateTime)
    cancelled_at = Column(DateTime)
    cancel_reason = Column(Text)

    requester = relationship("RequesterProfile", back_populates="orders")
    store = relationship("StoreProfile", back_populates="orders")
    order_details = relationship("OrderDetail", back_populates="order")
    delivery = relationship("Delivery", back_populates="order", uselist=False)
    payment = relationship("Payment", back_populates="order", uselist=False)


class OrderDetail(Base):
    __tablename__ = "order_details"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    product_name = Column(String(200), nullable=False)
    quantity = Column(Integer, nullable=False)
    unit_price = Column(Integer, nullable=False)
    subtotal = Column(Integer, nullable=False)
    notes = Column(Text)

    order = relationship("Order", back_populates="order_details")
    product = relationship("Product", back_populates="order_details")


# ==========================================
# 配達管理モデル
# ==========================================

class Delivery(Base):
    __tablename__ = "deliveries"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id", ondelete="CASCADE"), unique=True, nullable=False)
    deliverer_id = Column(Integer, ForeignKey("deliverer_profiles.id"), nullable=False)
    status = Column(String(30), nullable=False, default="assigned")
    # assigned, heading_store, at_store, picked_up, delivering, arrived, completed
    pickup_time = Column(DateTime)
    delivery_time = Column(DateTime)
    current_latitude = Column(Numeric(10, 8))
    current_longitude = Column(Numeric(11, 8))
    distance_km = Column(Numeric(5, 2))
    delivery_fee = Column(Integer)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    order = relationship("Order", back_populates="delivery")
    deliverer = relationship("DelivererProfile", back_populates="deliveries")
    location_history = relationship("DeliveryLocationHistory", back_populates="delivery")


class DeliveryLocationHistory(Base):
    __tablename__ = "delivery_location_history"

    id = Column(Integer, primary_key=True, index=True)
    delivery_id = Column(Integer, ForeignKey("deliveries.id", ondelete="CASCADE"), nullable=False)
    latitude = Column(Numeric(10, 8), nullable=False)
    longitude = Column(Numeric(11, 8), nullable=False)
    recorded_at = Column(DateTime, server_default=func.now())

    delivery = relationship("Delivery", back_populates="location_history")


# ==========================================
# 通知モデル
# ==========================================

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(200), nullable=False)
    message = Column(Text, nullable=False)
    type = Column(String(50), nullable=False)  # order_update, delivery_update, payment, system, promotion
    related_order_id = Column(Integer, ForeignKey("orders.id"))
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, server_default=func.now())

    user = relationship("User", back_populates="notifications")


# ==========================================
# 支払い・売上モデル
# ==========================================

class Payment(Base):
    __tablename__ = "payments"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), unique=True, nullable=False)
    amount = Column(Integer, nullable=False)
    payment_method = Column(String(50), nullable=False)
    payment_status = Column(String(20), nullable=False, default="pending")
    # pending, completed, failed, refunded
    transaction_id = Column(String(100))
    paid_at = Column(DateTime)
    created_at = Column(DateTime, server_default=func.now())

    order = relationship("Order", back_populates="payment")


class DelivererPayout(Base):
    __tablename__ = "deliverer_payouts"

    id = Column(Integer, primary_key=True, index=True)
    deliverer_id = Column(Integer, ForeignKey("deliverer_profiles.id"), nullable=False)
    period_start = Column(Date, nullable=False)
    period_end = Column(Date, nullable=False)
    total_deliveries = Column(Integer, nullable=False, default=0)
    total_amount = Column(Integer, nullable=False, default=0)
    status = Column(String(20), nullable=False, default="pending")
    # pending, processing, completed
    paid_at = Column(DateTime)
    created_at = Column(DateTime, server_default=func.now())

    deliverer = relationship("DelivererProfile", back_populates="payouts")


class StoreSales(Base):
    __tablename__ = "store_sales"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("store_profiles.id"), nullable=False)
    period_start = Column(Date, nullable=False)
    period_end = Column(Date, nullable=False)
    total_orders = Column(Integer, nullable=False, default=0)
    total_amount = Column(Integer, nullable=False, default=0)
    commission_rate = Column(Numeric(5, 2), default=10.00)
    commission_amount = Column(Integer, nullable=False, default=0)
    net_amount = Column(Integer, nullable=False, default=0)
    status = Column(String(20), nullable=False, default="pending")
    paid_at = Column(DateTime)
    created_at = Column(DateTime, server_default=func.now())

    store = relationship("StoreProfile", back_populates="sales")
