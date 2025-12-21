from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Float, DateTime, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column("password", String)
    role = Column(String) # requester, deliverer, store, admin
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    requester_profile = relationship("RequesterProfile", back_populates="user", uselist=False)
    deliverer_profile = relationship("DelivererProfile", back_populates="user", uselist=False)
    store_profile = relationship("StoreProfile", back_populates="user", uselist=False)

class RequesterProfile(Base):
    __tablename__ = "requester_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    name = Column(String)
    phone_number = Column(String)

    user = relationship("User", back_populates="requester_profile")
    orders = relationship("Order", back_populates="requester")

class DelivererProfile(Base):
    __tablename__ = "deliverer_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    name = Column(String)
    phone_number = Column(String)
    is_online = Column(Boolean, default=False)
    current_location_lat = Column(Float, nullable=True)
    current_location_lng = Column(Float, nullable=True)

    user = relationship("User", back_populates="deliverer_profile")
    deliveries = relationship("Delivery", back_populates="deliverer")

class StoreProfile(Base):
    __tablename__ = "store_profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    name = Column("store_name", String)
    address = Column(String)
    phone_number = Column(String)
    description = Column(Text)
    is_open = Column(Boolean, default=True)

    user = relationship("User", back_populates="store_profile")
    products = relationship("Product", back_populates="store")
    orders = relationship("Order", back_populates="store")

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    store_id = Column(Integer, ForeignKey("store_profiles.id"))
    name = Column(String)
    description = Column(Text)
    price = Column(Integer)
    image_url = Column(String, nullable=True)
    is_available = Column(Boolean, default=True)

    store = relationship("StoreProfile", back_populates="products")
    order_details = relationship("OrderDetail", back_populates="product")

class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    requester_id = Column(Integer, ForeignKey("requester_profiles.id"))
    store_id = Column(Integer, ForeignKey("store_profiles.id"))
    status = Column(String) # pending, accepted, cooking, ready, delivering, completed, cancelled
    total_amount = Column(Integer)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    requester = relationship("RequesterProfile", back_populates="orders")
    store = relationship("StoreProfile", back_populates="orders")
    order_details = relationship("OrderDetail", back_populates="order")
    delivery = relationship("Delivery", back_populates="order", uselist=False)

class OrderDetail(Base):
    __tablename__ = "order_details"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    product_id = Column(Integer, ForeignKey("products.id"))
    quantity = Column(Integer)
    price = Column(Integer) # Price at the time of order

    order = relationship("Order", back_populates="order_details")
    product = relationship("Product", back_populates="order_details")

class Delivery(Base):
    __tablename__ = "deliveries"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    deliverer_id = Column(Integer, ForeignKey("deliverer_profiles.id"), nullable=True)
    status = Column(String) # searching, assigned, picked_up, delivered
    pickup_time = Column(DateTime, nullable=True)
    delivery_time = Column(DateTime, nullable=True)

    order = relationship("Order", back_populates="delivery")
    deliverer = relationship("DelivererProfile", back_populates="deliveries")
