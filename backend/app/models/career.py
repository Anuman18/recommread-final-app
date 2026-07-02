from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Float, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..core.database import Base

class Career(Base):
    __tablename__ = "careers"

    slug = Column(String, primary_key=True, index=True) # e.g. "ai_engineer", "data_scientist", "ux_designer"
    name = Column(String, nullable=False)
    description = Column(String, nullable=False)


class Topic(Base):
    __tablename__ = "topics"

    id = Column(String, primary_key=True, index=True) # e.g. "ai_pytorch"
    career_slug = Column(String, ForeignKey("careers.slug", ondelete="CASCADE"), nullable=False)
    name = Column(String, nullable=False)
    total_questions = Column(Integer, default=5)
    difficulty_distribution = Column(JSON, nullable=True) # e.g. {"Easy": 2, "Medium": 2, "Hard": 1}


class Resource(Base):
    __tablename__ = "resources"

    id = Column(Integer, primary_key=True, index=True)
    career_slug = Column(String, ForeignKey("careers.slug", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    category = Column(String, nullable=False) # e.g. "Documentation", "YouTube", "Courses"
    url = Column(String, nullable=False)
    description = Column(String, nullable=True)
    why_recommended = Column(String, nullable=True)
    skills = Column(JSON, nullable=True) # list of skills: ["Python", "Numpy"]
    thumbnail_url = Column(String, nullable=True)


class UserResourceProgress(Base):
    __tablename__ = "user_resource_progress"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    resource_id = Column(Integer, ForeignKey("resources.id", ondelete="CASCADE"), nullable=False)
    is_bookmarked = Column(Boolean, default=False)
    is_completed = Column(Boolean, default=False)
    progress_percentage = Column(Float, default=0.0)


class Project(Base):
    __tablename__ = "projects"

    id = Column(String, primary_key=True, index=True) # e.g. "ds_proj_1"
    career_slug = Column(String, ForeignKey("careers.slug", ondelete="CASCADE"), nullable=False)
    name = Column(String, nullable=False)
    difficulty = Column(String, nullable=False) # Easy, Medium, Hard
    duration = Column(String, nullable=False) # e.g. "2 weeks"
    skills = Column(JSON, nullable=True) # list of strings
    xp_reward = Column(Integer, default=500)
    coins_reward = Column(Integer, default=50)
    portfolio_value = Column(String, default="High")
    problem_statement = Column(String, nullable=False)
    what_you_build = Column(String, nullable=False)
    tech_stack = Column(JSON, nullable=True)
    prerequisites = Column(JSON, nullable=True)
    dataset_url = Column(String, nullable=True)
    image_url = Column(String, nullable=True)

    milestones = relationship("ProjectMilestone", back_populates="project", cascade="all, delete-orphan")


class ProjectMilestone(Base):
    __tablename__ = "project_milestones"

    id = Column(String, primary_key=True, index=True) # e.g. "ds_proj_1_ms1"
    project_id = Column(String, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    text = Column(String, nullable=False)
    xp_reward = Column(Integer, default=100)
    coins_reward = Column(Integer, default=10)

    project = relationship("Project", back_populates="milestones")


class UserProjectProgress(Base):
    __tablename__ = "user_project_progress"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    project_id = Column(String, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    status = Column(String, default="unstarted") # unstarted, in_progress, completed
    progress_percentage = Column(Float, default=0.0)

    user = relationship("User", back_populates="project_progress")


class UserMilestoneProgress(Base):
    __tablename__ = "user_milestone_progress"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    milestone_id = Column(String, ForeignKey("project_milestones.id", ondelete="CASCADE"), nullable=False)
    is_completed = Column(Boolean, default=False)
