from pydantic import BaseModel, EmailStr, field_validator
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
    onboarding_completed: bool = False

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
    onboarding_completed: bool

    class Config:
        from_attributes = True

class ProfileUpdate(BaseModel):
    name: Optional[str] = None
    daily_learning_time_min: Optional[int] = None
    preferred_language: Optional[str] = None
    career_slug: Optional[str] = None
    skill_level: Optional[str] = None
    onboarding_completed: Optional[bool] = None

    @field_validator("career_slug")
    @classmethod
    def validate_career_slug(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return v
        valid_goals = {
            "ai_engineer", "data_scientist", "software_engineer", "full_stack_developer",
            "backend_engineer", "frontend_engineer", "ux_designer", "product_manager",
            "cyber_security_engineer", "devops_engineer", "cloud_engineer", "startup_founder",
            "entrepreneur", "digital_marketer", "content_creator", "ias_officer", "doctor", "lawyer"
        }
        if v not in valid_goals:
            raise ValueError(f"Invalid career goal / slug: '{v}'. Must be one of {valid_goals}")
        return v

    @field_validator("skill_level")
    @classmethod
    def validate_skill_level(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return v
        normalized = v.lower()
        valid_levels = {"beginner", "intermediate", "advanced"}
        if normalized not in valid_levels:
            raise ValueError(f"Invalid skill level: '{v}'. Must be one of {valid_levels}")
        return normalized.capitalize()

    @field_validator("preferred_language")
    @classmethod
    def validate_preferred_language(cls, v: Optional[str]) -> Optional[str]:
        if v is None:
            return v
        normalized = v.lower()
        valid_languages = {"english", "hindi", "both"}
        if normalized not in valid_languages:
            raise ValueError(f"Invalid preferred language: '{v}'. Must be one of {valid_languages}")
        return normalized.capitalize()

    @field_validator("daily_learning_time_min")
    @classmethod
    def validate_daily_time(cls, v: Optional[int]) -> Optional[int]:
        if v is None:
            return v
        valid_times = {30, 60, 120, 240}
        if v not in valid_times:
            raise ValueError(f"Invalid daily learning time: {v} minutes. Must be one of {valid_times}")
        return v

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
