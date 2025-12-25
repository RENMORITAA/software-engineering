from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm, OAuth2PasswordBearer
from datetime import timedelta, datetime
from .. import models, schemas, database
from passlib.context import CryptContext
from jose import JWTError, jwt
import os

router = APIRouter(
    prefix="/auth",
    tags=["auth"],
)

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(database.get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
        token_data = schemas.TokenData(email=email)
    except JWTError:
        raise credentials_exception
    user = db.query(models.User).filter(models.User.email == token_data.email).first()
    if user is None:
        raise credentials_exception
    return user

@router.post("/register", response_model=schemas.User)
def register(user: schemas.UserCreate, db: Session = Depends(database.get_db)):
    db_user = db.query(models.User).filter(models.User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = get_password_hash(user.password)
    new_user = models.User(email=user.email, hashed_password=hashed_password, role=user.role)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Create profile based on role
    if user.role == "requester":
        profile = models.RequesterProfile(user_id=new_user.id, name="新規ユーザー")
        db.add(profile)
    elif user.role == "deliverer":
        profile = models.DelivererProfile(user_id=new_user.id, name="新規配達員")
        db.add(profile)
    elif user.role == "store":
        profile = models.StoreProfile(user_id=new_user.id, store_name="新規店舗", address="未設定")
        db.add(profile)
    
    db.commit()
    return new_user

@router.post("/login", response_model=schemas.Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(database.get_db)):
    user = db.query(models.User).filter(models.User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email, "role": user.role, "user_id": user.id}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=schemas.User)
def read_users_me(current_user: models.User = Depends(get_current_user)):
    return current_user

@router.get("/me/profile")
def get_user_profile(current_user: models.User = Depends(get_current_user), db: Session = Depends(database.get_db)):
    """Get user profile based on role"""
    if current_user.role == "requester":
        profile = db.query(models.RequesterProfile).filter(
            models.RequesterProfile.user_id == current_user.id
        ).first()
        if profile:
            return {
                "id": profile.id,
                "user_id": profile.user_id,
                "name": profile.name,
                "phone_number": profile.phone_number,
                "role": "requester"
            }
    elif current_user.role == "deliverer":
        profile = db.query(models.DelivererProfile).filter(
            models.DelivererProfile.user_id == current_user.id
        ).first()
        if profile:
            return {
                "id": profile.id,
                "user_id": profile.user_id,
                "name": profile.name,
                "phone_number": profile.phone_number,
                "work_status": profile.work_status,
                "vehicle_type": profile.vehicle_type,
                "role": "deliverer"
            }
    elif current_user.role == "store":
        profile = db.query(models.StoreProfile).filter(
            models.StoreProfile.user_id == current_user.id
        ).first()
        if profile:
            return {
                "id": profile.id,
                "user_id": profile.user_id,
                "store_name": profile.store_name,
                "address": profile.address,
                "phone_number": profile.phone_number,
                "business_hours": profile.business_hours,
                "is_open": profile.is_open,
                "role": "store"
            }
    elif current_user.role == "admin":
        return {
            "id": current_user.id,
            "user_id": current_user.id,
            "name": "管理者",
            "role": "admin"
        }
    
    raise HTTPException(status_code=404, detail="Profile not found")
