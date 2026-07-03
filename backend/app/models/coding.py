from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Float, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..core.database import Base

class CodingQuestion(Base):
    __tablename__ = "coding_questions"

    id = Column(String, primary_key=True, index=True)
    topic_id = Column(String, ForeignKey("topics.id", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    difficulty = Column(String, nullable=False) # Easy, Medium, Hard
    companies = Column(JSON, nullable=True) # list of companies
    time_min = Column(Integer, default=15)
    xp_reward = Column(Integer, default=100)
    coins_reward = Column(Integer, default=10)
    hints = Column(JSON, nullable=True) # list of hints
    problem_statement = Column(String, nullable=False)
    examples = Column(JSON, nullable=True) # list of dicts: {"input": "...", "output": "..."}
    constraints = Column(JSON, nullable=True) # list of constraints
    expected_output = Column(String, nullable=False)
    editorial = Column(String, nullable=True)
    doc_url = Column(String, nullable=True)
    video_url = Column(String, nullable=True)


class UserQuestionProgress(Base):
    __tablename__ = "user_question_progress"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    question_id = Column(String, ForeignKey("coding_questions.id", ondelete="CASCADE"), nullable=False)
    status = Column(String, default="unsolved") # unsolved, in_progress, solved
    submitted_code = Column(String, nullable=True)
    solved_at = Column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now())
    attempts = Column(Integer, default=0)
    runtime_ms = Column(Integer, default=0)
    memory_mb = Column(Float, default=0.0)
    language = Column(String, nullable=True)
    submission_history = Column(JSON, nullable=True) # list of dicts

    user = relationship("User", back_populates="question_progress")


class LeaderboardEntry(Base):
    __tablename__ = "leaderboard"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=True) # None for seed mock leaders
    name = Column(String, nullable=False)
    xp = Column(Integer, default=0, index=True)
    avatar = Column(String, default="⚡")
    rank = Column(Integer, default=0)
    last_updated = Column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now())
