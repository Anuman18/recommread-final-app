from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Any

from ...core.database import get_db
from ...api.deps import get_current_user
from ...models.user import User
from ...services.career_intelligence import CareerIntelligenceService

router = APIRouter()

@router.get("/roadmap", response_model=List[Dict[str, Any]])
def get_career_roadmap(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return CareerIntelligenceService.get_career_roadmap(db, current_user.id)

@router.get("/missing-skills", response_model=List[str])
def get_missing_skills(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    gap = CareerIntelligenceService.get_skill_gap_analysis(db, current_user.id)
    return gap.get("missing_skills", [])

@router.get("/skill-gap", response_model=Dict[str, Any])
def get_skill_gap(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return CareerIntelligenceService.get_skill_gap_analysis(db, current_user.id)

@router.get("/weekly-goals", response_model=List[str])
def get_weekly_goals(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return CareerIntelligenceService.get_weekly_goals(db, current_user.id)

@router.get("/monthly-goals", response_model=List[str])
def get_monthly_goals(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return CareerIntelligenceService.get_monthly_goals(db, current_user.id)

@router.get("/recommended-skills", response_model=List[str])
def get_recommended_skills(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    gap = CareerIntelligenceService.get_skill_gap_analysis(db, current_user.id)
    return gap.get("priority_skills", [])

@router.get("/readiness-score", response_model=Dict[str, Any])
def get_readiness_score(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return CareerIntelligenceService.get_job_readiness_score(db, current_user.id)

@router.get("/interview-readiness", response_model=Dict[str, Any])
def get_interview_readiness(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    score = CareerIntelligenceService.get_interview_readiness(db, current_user.id)
    return {"interview_readiness_percentage": score}

@router.get("/portfolio-readiness", response_model=Dict[str, Any])
def get_portfolio_readiness(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    score = CareerIntelligenceService.get_portfolio_readiness(db, current_user.id)
    return {"portfolio_readiness_percentage": score}
