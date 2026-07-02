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
    skills = relationship("UserSkill", back_populates="user", cascade="all, delete-orphan")
    xp_history = relationship("UserXPLedger", back_populates="user", cascade="all, delete-orphan")
    coins_history = relationship("UserCoinsLedger", back_populates="user", cascade="all, delete-orphan")
    history_logs = relationship("ActivityHistory", back_populates="user", cascade="all, delete-orphan")
    achievements = relationship("UserAchievement", back_populates="user", cascade="all, delete-orphan")
    badges = relationship("UserBadge", back_populates="user", cascade="all, delete-orphan")
    progress_records = relationship("UserProgress", back_populates="user", cascade="all, delete-orphan")
    bookmarks = relationship("Bookmark", back_populates="user", cascade="all, delete-orphan")
    ai_chats = relationship("AIChat", back_populates="user", cascade="all, delete-orphan")
    interview_history = relationship("UserInterviewRound", back_populates="user", cascade="all, delete-orphan")
    project_progress = relationship("UserProjectProgress", back_populates="user", cascade="all, delete-orphan")
    question_progress = relationship("UserQuestionProgress", back_populates="user", cascade="all, delete-orphan")

    @property
    def name(self) -> str:
        return self.profile.name if self.profile else "User"

    @property
    def reading_goal(self) -> str:
        return self.profile.career_slug if self.profile else "selfGrowth"

    @property
    def reading_level(self) -> str:
        return self.profile.skill_level if self.profile else "intermediate"

    @property
    def streak(self) -> int:
        return self.profile.streak if self.profile else 0

    @property
    def books_completed(self) -> int:
        if not self.progress_records:
            return 0
        return sum(1 for p in self.progress_records if p.status == "completed")

    @property
    def books_saved(self) -> int:
        if not self.bookmarks:
            return 0
        return len(self.bookmarks)

    @property
    def favorite_genres(self) -> str:
        return "Self Growth,Finance,Psychology,Technology"

    @property
    def avatar_letter(self) -> str:
        if self.profile and self.profile.name and len(self.profile.name) > 0:
            return self.profile.name[0].upper()
        return "AR"


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
    skill_level = Column(String, default="Beginner")
    readiness_score = Column(Float, default=40.0)

    user = relationship("User", back_populates="profile")


class UserSettings(Base):
    __tablename__ = "settings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), unique=True, nullable=False)
    email_notifications = Column(Boolean, default=True)
    push_notifications = Column(Boolean, default=True)
    daily_reminder_enabled = Column(Boolean, default=True)
    dark_mode = Column(Boolean, default=True)
    sound_effects = Column(Boolean, default=True)

    user = relationship("User", back_populates="settings")


class UserSkill(Base):
    __tablename__ = "user_skills"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    skill_name = Column(String, nullable=False, index=True) # e.g. "Python", "SQL", "Auto Layout"
    level_value = Column(Float, default=1.0) # proficiency index e.g. 3.4
    last_updated = Column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now())

    user = relationship("User", back_populates="skills")


class UserXPLedger(Base):
    __tablename__ = "user_xp"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    xp_amount = Column(Integer, nullable=False)
    source = Column(String, nullable=False) # e.g. "Coding Challenge q1", "Project Track Completion"
    timestamp = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="xp_history")


class UserCoinsLedger(Base):
    __tablename__ = "user_coins"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    coins_amount = Column(Integer, nullable=False)
    source = Column(String, nullable=False) # e.g. "Confetti complete"
    timestamp = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="coins_history")


class ActivityHistory(Base):
    __tablename__ = "history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    activity_type = Column(String, nullable=False, index=True) # e.g. "quiz_complete", "resource_read"
    description = Column(String, nullable=False)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="history_logs")


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

