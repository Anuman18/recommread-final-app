from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from typing import List, Dict, Any

from ...core.database import get_db
from ...api.deps import get_current_user
from ...models.user import User, Profile, UserAchievement, UserXPLedger, UserCoinsLedger
from ...services.gamification import GamificationService

router = APIRouter()

@router.get("/xp", response_model=Dict[str, Any])
def get_user_xp(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
        
    history = db.query(UserXPLedger).filter(UserXPLedger.user_id == current_user.id).all()
    history_list = [{"id": h.id, "amount": h.xp_amount, "source": h.source, "timestamp": h.timestamp} for h in history]
    
    return {
        "total_xp": profile.xp,
        "xp_history": history_list
    }

@router.get("/coins", response_model=Dict[str, Any])
def get_user_coins(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
        
    history = db.query(UserCoinsLedger).filter(UserCoinsLedger.user_id == current_user.id).all()
    history_list = [{"id": h.id, "amount": h.coins_amount, "source": h.source, "timestamp": h.timestamp} for h in history]
    
    return {
        "total_coins": profile.coins,
        "coins_history": history_list
    }

@router.get("/streak", response_model=Dict[str, Any])
def get_user_streak(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
        
    return {
        "daily_streak": profile.streak,
        "coding_streak": profile.streak,
        "project_streak": max(0, profile.streak // 2),
        "mission_streak": profile.streak
    }

@router.get("/level", response_model=Dict[str, Any])
def get_user_level(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    xp_in_level = profile.xp % 2500
    xp_to_next = 2500 - xp_in_level
    title = GamificationService.get_level_title(profile.level)
    
    return {
        "level": profile.level,
        "level_title": title,
        "current_level_xp": xp_in_level,
        "xp_to_next_level": xp_to_next,
        "level_progress_percentage": round((xp_in_level / 2500.0) * 100, 1)
    }

@router.get("/achievements", response_model=List[Dict[str, Any]])
def get_achievements(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    achievements = db.query(UserAchievement).filter(UserAchievement.user_id == current_user.id).all()
    return [{
        "slug": a.achievement_slug,
        "title": a.title,
        "description": a.description,
        "icon": a.icon,
        "unlocked_at": a.unlocked_at
    } for a in achievements]

@router.get("/statistics", response_model=Dict[str, Any])
def get_statistics(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return GamificationService.get_user_statistics(db, current_user.id)

@router.get("/progress", response_model=Dict[str, Any])
def get_progress(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Overall career metrics progress
    stats = GamificationService.get_user_statistics(db, current_user.id)
    return {
        "career_progress_percentage": stats["career_progress_percentage"],
        "completed_missions": stats["completed_missions"],
        "completed_projects": stats["completed_projects"],
        "completed_coding_questions": stats["completed_coding_questions"]
    }

@router.post("/claim-reward", response_model=Dict[str, Any])
def claim_reward(
    reward_source: str = Body(..., embed=True),
    xp_reward: int = Body(150, embed=True),
    coins_reward: int = Body(15, embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return GamificationService.award_xp_and_coins(
        db=db,
        user_id=current_user.id,
        xp_amount=xp_reward,
        coins_amount=coins_reward,
        source=f"Reward Claim: {reward_source}"
    )
