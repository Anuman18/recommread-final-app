from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Any

from ...core.database import get_db
from ...api.deps import get_current_user
from ...models.user import User
from ...services.recommendation import RecommendationService

router = APIRouter()

@router.get("/daily", response_model=Dict[str, Any])
def get_daily_recommendations(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return RecommendationService.get_daily_recommendations(db, current_user.id)

@router.get("/weekly", response_model=List[Dict[str, Any]])
def get_weekly_plan(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return RecommendationService.get_weekly_plan(db, current_user.id)

@router.get("/learning-path", response_model=Dict[str, Any])
def get_learning_path(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return RecommendationService.get_personalized_learning_path(db, current_user.id)

@router.get("/next-mission", response_model=Dict[str, Any])
def get_next_mission(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    mission = RecommendationService.get_next_best_mission(db, current_user.id)
    if not mission:
        raise HTTPException(status_code=404, detail="No missions found for this career path")
    return mission

@router.get("/weak-skills", response_model=List[str])
def get_weak_skills(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return RecommendationService.get_weak_skills(db, current_user.id)

@router.get("/strong-skills", response_model=List[str])
def get_strong_skills(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return RecommendationService.get_strong_skills(db, current_user.id)

@router.get("/resources", response_model=List[Dict[str, Any]])
def get_suggested_resources(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return RecommendationService.get_suggested_resources(db, current_user.id)

@router.get("/projects", response_model=List[Dict[str, Any]])
def get_suggested_projects(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return RecommendationService.get_suggested_projects(db, current_user.id)

@router.get("/coding-questions", response_model=List[Dict[str, Any]])
def get_suggested_coding_questions(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return RecommendationService.get_suggested_coding_questions(db, current_user.id)
