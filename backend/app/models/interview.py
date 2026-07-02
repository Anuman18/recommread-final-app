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
    career_slug = Column(String, ForeignKey("careers.slug", ondelete="CASCADE"), nullable=False)
    type_id = Column(String, ForeignKey("interview_types.id", ondelete="CASCADE"), nullable=False)
    text = Column(String, nullable=False)
    difficulty = Column(String, nullable=False) # Easy, Medium, Hard
    topic = Column(String, nullable=False)


class UserInterviewRound(Base):
    __tablename__ = "user_interview_rounds"

    id = Column(String, primary_key=True, index=True) # e.g. "rep_..."
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    type_id = Column(String, ForeignKey("interview_types.id", ondelete="CASCADE"), nullable=False)
    overall_score = Column(Float, nullable=False)
    date = Column(String, nullable=False)
    readiness_gained = Column(Float, default=3.5)

    user = relationship("User", back_populates="interview_history")
    feedbacks = relationship("InterviewQuestionFeedback", back_populates="round", cascade="all, delete-orphan")


class InterviewQuestionFeedback(Base):
    __tablename__ = "interview_question_feedbacks"

    id = Column(Integer, primary_key=True, index=True)
    round_id = Column(String, ForeignKey("user_interview_rounds.id", ondelete="CASCADE"), nullable=False)
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
