from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime, Float, JSON
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..core.database import Base

class CareerGoal(Base):
    __tablename__ = "career_goals"

    slug = Column(String, primary_key=True, index=True) # e.g. "ai_engineer", "data_scientist", "ux_designer"
    name = Column(String, nullable=False)
    description = Column(String, nullable=False)

    learning_paths = relationship("LearningPath", back_populates="career_goal", cascade="all, delete-orphan")
    roadmaps = relationship("Roadmap", back_populates="career_goal", cascade="all, delete-orphan")


class LearningPath(Base):
    __tablename__ = "learning_paths"

    id = Column(Integer, primary_key=True, index=True)
    career_slug = Column(String, ForeignKey("career_goals.slug", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    estimated_weeks = Column(Integer, default=12)

    career_goal = relationship("CareerGoal", back_populates="learning_paths")


class Roadmap(Base):
    __tablename__ = "roadmaps"

    id = Column(Integer, primary_key=True, index=True)
    career_slug = Column(String, ForeignKey("career_goals.slug", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False) # e.g. "Phase 1: Foundations"
    milestones_json = Column(JSON, nullable=True) # list of milestones text
    order_index = Column(Integer, default=0)

    career_goal = relationship("CareerGoal", back_populates="roadmaps")


class Topic(Base):
    __tablename__ = "topics"

    id = Column(String, primary_key=True, index=True) # e.g. "ai_pytorch"
    career_slug = Column(String, ForeignKey("career_goals.slug", ondelete="CASCADE"), nullable=False)
    name = Column(String, nullable=False)
    total_questions = Column(Integer, default=5)
    difficulty_distribution = Column(JSON, nullable=True) # e.g. {"Easy": 2, "Medium": 2, "Hard": 1}


class LearningResource(Base):
    __tablename__ = "learning_resources"

    id = Column(Integer, primary_key=True, index=True)
    career_slug = Column(String, ForeignKey("career_goals.slug", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    category = Column(String, nullable=False, index=True) # e.g. "Documentation", "YouTube", "Courses"
    url = Column(String, nullable=False)
    description = Column(String, nullable=True)
    why_recommended = Column(String, nullable=True)
    skills = Column(JSON, nullable=True) # list of skills
    thumbnail_url = Column(String, nullable=True)


class Bookmark(Base):
    __tablename__ = "bookmarks"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    resource_id = Column(Integer, ForeignKey("learning_resources.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    user = relationship("User", back_populates="bookmarks")


class UserResourceProgress(Base):
    __tablename__ = "user_resource_progress"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    resource_id = Column(Integer, ForeignKey("learning_resources.id", ondelete="CASCADE"), nullable=False)
    is_bookmarked = Column(Boolean, default=False)
    is_completed = Column(Boolean, default=False)
    progress_percentage = Column(Float, default=0.0)
    current_chapter_index = Column(Integer, default=0)
    active_reading_seconds = Column(Integer, default=0)
    bookmarks = Column(JSON, nullable=True) # list of bookmarked chapters
    highlights = Column(JSON, nullable=True) # list of dicts: [{"chapterIndex": 0, "text": "...", "colorHex": 123}]
    notes = Column(JSON, nullable=True) # list of dicts: [{"chapterIndex": 0, "selectedText": "...", "noteText": "...", "createdAt": "..."}]


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



class Mission(Base):
    __tablename__ = "missions"

    id = Column(String, primary_key=True, index=True) # e.g. "mission_1"
    career_slug = Column(String, ForeignKey("career_goals.slug", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    xp_reward = Column(Integer, default=300)
    coins_reward = Column(Integer, default=30)
    order_index = Column(Integer, default=0)


class Project(Base):
    __tablename__ = "projects"

    id = Column(String, primary_key=True, index=True) # e.g. "ds_proj_1"
    career_slug = Column(String, ForeignKey("career_goals.slug", ondelete="CASCADE"), nullable=False)
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


class Quiz(Base):
    __tablename__ = "quizzes"

    id = Column(Integer, primary_key=True, index=True)
    career_slug = Column(String, ForeignKey("career_goals.slug", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False) # e.g. "Data Science Basics Quiz"
    chapter_info = Column(String, nullable=True)

    questions = relationship("QuizQuestion", back_populates="quiz", cascade="all, delete-orphan")


class QuizQuestion(Base):
    __tablename__ = "quiz_questions"

    id = Column(Integer, primary_key=True, index=True)
    quiz_id = Column(Integer, ForeignKey("quizzes.id", ondelete="CASCADE"), nullable=False)
    text = Column(String, nullable=False)
    options_json = Column(JSON, nullable=False) # list of strings
    correct_option_index = Column(Integer, nullable=False)
    explanation = Column(String, nullable=True)

    quiz = relationship("Quiz", back_populates="questions")


class UserProgress(Base):
    __tablename__ = "progress"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    item_type = Column(String, nullable=False, index=True) # e.g. "project", "resource", "quiz"
    item_id = Column(String, nullable=False, index=True) # ID of project/resource/quiz
    status = Column(String, default="in_progress") # in_progress, completed
    progress_percentage = Column(Float, default=0.0)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now())

    user = relationship("User", back_populates="progress_records")


# Aliases for backwards compatibility with API endpoints
Career = CareerGoal
Resource = LearningResource

