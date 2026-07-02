from typing import Optional
from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from ...core.database import get_db
from ...core.security import get_password_hash, verify_password, create_access_token
from ...core.config import settings
from ...models.user import User, Profile, UserSettings
from ...schemas.user import UserCreate, UserResponse, Token, UserLogin
from ..deps import get_current_user

router = APIRouter()

@router.post("/signup", response_model=UserResponse)
def signup(user_in: UserCreate, db: Session = Depends(get_db)):
    # Check if user exists
    db_user = db.query(User).filter(User.email == user_in.email).first()
    if db_user:
        raise HTTPException(
            status_code=400,
            detail="The user with this email already exists in the system",
        )
    
    # Create user
    hashed_password = get_password_hash(user_in.password)
    user = User(email=user_in.email, hashed_password=hashed_password)
    db.add(user)
    db.commit()
    db.refresh(user)

    # Initialize Profile
    profile = Profile(user_id=user.id, name=user.email.split("@")[0].capitalize())
    db.add(profile)

    # Initialize Settings
    settings_obj = UserSettings(user_id=user.id)
    db.add(settings_obj)
    db.commit()

    return user

@router.post("/login", response_model=Token)
def login(
    user_in: Optional[UserLogin] = None,
    form_data: Optional[OAuth2PasswordRequestForm] = Depends(None),
    db: Session = Depends(get_db)
):
    # Support both JSON login and Form-data OAuth2 login
    email = ""
    password = ""
    if form_data:
        email = form_data.username
        password = form_data.password
    elif user_in:
        email = user_in.email
        password = user_in.password
    else:
        raise HTTPException(
            status_code=400,
            detail="Login credentials must be provided as JSON or Form parameters",
        )

    user = db.query(User).filter(User.email == email).first()
    if not user or not verify_password(password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect email or password",
        )
    elif not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user",
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        subject=user.id, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user
