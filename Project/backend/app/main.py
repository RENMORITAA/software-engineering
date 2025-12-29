from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import os
from .database import engine, Base
from .routers import auth, products, orders, delivery, stores, notifications, profile, images, recipes

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Stellar Delivery API")

# 画像アップロードディレクトリを静的ファイルとして配信
UPLOAD_DIR = "/app/uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")

# CORS configuration
origins = [
    "http://localhost:8080",
    "http://127.0.0.1:8080",
    "http://localhost:3000",
    "*"  # For development convenience
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(products.router)
app.include_router(orders.router)
app.include_router(delivery.router)
app.include_router(stores.router)
app.include_router(notifications.router)
app.include_router(profile.router)
app.include_router(images.router)
app.include_router(recipes.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to Stellar Delivery API"}
