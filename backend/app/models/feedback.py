from sqlalchemy import Column, Integer, String, Text, DateTime, Float, ForeignKey
from datetime import datetime
from app.core.database import Base

class UserFeedback(Base):
    __tablename__ = "user_feedbacks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    feedback_type = Column(String(50), nullable=False) # bug, feature_request, resource_rating, ai_rating, general
    target_id = Column(String(100), nullable=True) # e.g. resource_id or ai_chat_id
    rating = Column(Integer, nullable=True) # rating scale 1-5
    content = Column(Text, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow)


class AnalyticsEvent(Base):
    __tablename__ = "analytics_events"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, index=True)
    event_name = Column(String(100), index=True, nullable=False) # signup, career_select, mission_start, etc.
    properties = Column(Text, nullable=True) # JSON details stored as string
    timestamp = Column(DateTime, default=datetime.utcnow)
