from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .database import engine, Base
from .routers import auth, products, orders, delivery

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Stellar Delivery API")

# CORS configuration
origins = [
    "http://localhost:8080",
    "http://127.0.0.1:8080",
    "http://localhost:3000",
    "*" # For development convenience
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

@app.get("/")
def read_root():
    return {"message": "Welcome to Stellar Delivery API"}
