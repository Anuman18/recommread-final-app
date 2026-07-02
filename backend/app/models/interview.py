from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Float, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..core.database import Base

class InterviewType(Base):
    __tablename__ = "interview_types"

    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String, nullable=False)
    icon = Column(String, default="🎤")
    question_count = Column(Integer, default=3)
    duration_min = Column(Integer, default=15)


class InterviewQuestion(Base):
    __tablename__ = "interview_questions"

    id = Column(String, primary_key=True, index=True)
    career_slug = Column(String, ForeignKey("career_goals.slug", ondelete="CASCADE"), nullable=False)
    type_id = Column(String, ForeignKey("interview_types.id", ondelete="CASCADE"), nullable=False)
    text = Column(String, nullable=False)
    difficulty = Column(String, nullable=False) # Easy, Medium, Hard
    topic = Column(String, nullable=False)


class UserInterviewRound(Base):
    __tablename__ = "interview_sessions"

    id = Column(String, primary_key=True, index=True) # e.g. "rep_..."
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    type_id = Column(String, ForeignKey("interview_types.id", ondelete="CASCADE"), nullable=False)
    overall_score = Column(Float, nullable=False)
    date = Column(String, nullable=False)
    readiness_gained = Column(Float, default=3.5)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="interview_history")
    feedbacks = relationship("InterviewQuestionFeedback", back_populates="round", cascade="all, delete-orphan")


class InterviewQuestionFeedback(Base):
    __tablename__ = "interview_feedbacks"

    id = Column(Integer, primary_key=True, index=True)
    round_id = Column(String, ForeignKey("interview_sessions.id", ondelete="CASCADE"), nullable=False)
    question_id = Column(String, ForeignKey("interview_questions.id", ondelete="CASCADE"), nullable=False)
    user_answer = Column(String, nullable=False)
    communication_score = Column(Integer, default=80)
    technical_score = Column(Integer, default=80)
    confidence_score = Column(Integer, default=80)
    problem_solving_score = Column(Integer, default=80)
    overall_rating = Column(Float, default=8.0)
    feedback_text = Column(String, nullable=False)
    improvement_suggestions = Column(JSON, nullable=True)

    round = relationship("UserInterviewRound", back_populates="feedbacks")


class DailyMission(Base):
    __tablename__ = "daily_missions"

    id = Column(String, primary_key=True, index=True) # e.g. "dm_..."
    title = Column(String, nullable=False)
    xp_reward = Column(Integer, default=150)
    coins_reward = Column(Integer, default=15)
    is_claimed = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())


class AIChat(Base):
    __tablename__ = "ai_chats"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    context_type = Column(String, nullable=False, index=True) # e.g. "project_mentor", "ai_tutor"
    context_id = Column(String, nullable=True) # e.g. project ID or resource ID
    message_text = Column(String, nullable=False)
    sender = Column(String, default="user") # user, ai
    timestamp = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="ai_chats")


class Badge(Base):
    __tablename__ = "badges"

    slug = Column(String, primary_key=True, index=True) # e.g. "streak_7"
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    icon = Column(String, nullable=False)


class UserBadge(Base):
    __tablename__ = "user_badges"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    badge_slug = Column(String, ForeignKey("badges.slug", ondelete="CASCADE"), nullable=False)
    unlocked_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="badges")
