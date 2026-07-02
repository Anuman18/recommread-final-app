from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    email: EmailStr
    is_active: bool
    created_at: datetime
    name: str = "User"
    reading_goal: str = "selfGrowth"
    reading_level: str = "intermediate"
    streak: int = 0
    books_completed: int = 0
    books_saved: int = 0
    favorite_genres: str = ""
    avatar_letter: str = "AR"

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    user_id: Optional[int] = None

class ProfileResponse(BaseModel):
    name: str
    streak: int
    xp: int
    coins: int
    level: int
    daily_learning_time_min: int
    preferred_language: str
    career_slug: str
    skill_level: str
    readiness_score: float

    class Config:
        from_attributes = True

class ProfileUpdate(BaseModel):
    name: Optional[str] = None
    daily_learning_time_min: Optional[int] = None
    preferred_language: Optional[str] = None
    career_slug: Optional[str] = None
    skill_level: Optional[str] = None

class SettingsResponse(BaseModel):
    email_notifications: bool
    push_notifications: bool
    daily_reminder_enabled: bool
    dark_mode: bool
    sound_effects: bool

    class Config:
        from_attributes = True

class SettingsUpdate(BaseModel):
    email_notifications: Optional[bool] = None
    push_notifications: Optional[bool] = None
    daily_reminder_enabled: Optional[bool] = None
    dark_mode: Optional[bool] = None
    sound_effects: Optional[bool] = None

class AchievementResponse(BaseModel):
    achievement_slug: str
    title: str
    description: str
    icon: str
    unlocked_at: datetime

    class Config:
        from_attributes = True
