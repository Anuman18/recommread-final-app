from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    profile = relationship("Profile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    settings = relationship("UserSettings", back_populates="user", uselist=False, cascade="all, delete-orphan")
    project_progress = relationship("UserProjectProgress", back_populates="user", cascade="all, delete-orphan")
    question_progress = relationship("UserQuestionProgress", back_populates="user", cascade="all, delete-orphan")
    interview_history = relationship("UserInterviewRound", back_populates="user", cascade="all, delete-orphan")
    achievements = relationship("UserAchievement", back_populates="user", cascade="all, delete-orphan")


class Profile(Base):
    __tablename__ = "profiles"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    name = Column(String, default="User")
    streak = Column(Integer, default=0)
    xp = Column(Integer, default=0)
    coins = Column(Integer, default=100)
    level = Column(Integer, default=1)
    daily_learning_time_min = Column(Integer, default=30)
    preferred_language = Column(String, default="English")
    career_slug = Column(String, default="ai_engineer")
    skill_level = Column(String, default="Beginner") # Beginner, Intermediate, Advanced
    readiness_score = Column(Float, default=40.0)

    user = relationship("User", back_populates="profile")


class UserSettings(Base):
    __tablename__ = "user_settings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    email_notifications = Column(Boolean, default=True)
    push_notifications = Column(Boolean, default=True)
    daily_reminder_enabled = Column(Boolean, default=True)
    dark_mode = Column(Boolean, default=True)
    sound_effects = Column(Boolean, default=True)

    user = relationship("User", back_populates="settings")


class UserAchievement(Base):
    __tablename__ = "user_achievements"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    achievement_slug = Column(String, nullable=False) # e.g. "first_problem"
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    icon = Column(String, nullable=False)
    unlocked_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="achievements")
