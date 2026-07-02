from pydantic import BaseModel
from typing import Optional, List, Dict, Any

class CareerResponse(BaseModel):
    slug: str
    name: str
    description: str

    class Config:
        from_attributes = True

class TopicResponse(BaseModel):
    id: str
    career_slug: str
    name: str
    total_questions: int
    difficulty_distribution: Optional[Dict[str, int]] = None

    class Config:
        from_attributes = True

class ResourceResponse(BaseModel):
    id: int
    career_slug: str
    title: str
    category: str
    url: str
    description: Optional[str] = None
    why_recommended: Optional[str] = None
    skills: Optional[List[str]] = None
    thumbnail_url: Optional[str] = None
    is_bookmarked: bool = False
    is_completed: bool = False
    current_chapter_index: int = 0
    active_reading_seconds: int = 0
    bookmarks: Optional[List[int]] = None
    highlights: Optional[List[Dict[str, Any]]] = None
    notes: Optional[List[Dict[str, Any]]] = None

    class Config:
        from_attributes = True

class ProjectMilestoneResponse(BaseModel):
    id: str
    text: str
    xp_reward: int
    coins_reward: int
    is_completed: bool = False

    class Config:
        from_attributes = True

class ProjectResponse(BaseModel):
    id: str
    career_slug: str
    name: str
    difficulty: str
    duration: str
    skills: Optional[List[str]] = None
    xp_reward: int
    coins_reward: int
    portfolio_value: str
    problem_statement: str
    what_you_build: str
    tech_stack: Optional[List[str]] = None
    prerequisites: Optional[List[str]] = None
    dataset_url: Optional[str] = None
    image_url: Optional[str] = None
    status: str = "unstarted" # unstarted, in_progress, completed
    progress_percentage: float = 0.0
    milestones: List[ProjectMilestoneResponse] = []

    class Config:
        from_attributes = True
