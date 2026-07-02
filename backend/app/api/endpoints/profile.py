from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Dict, Any
from datetime import datetime

from ...core.database import get_db
from ...models.user import User, Profile, UserSettings, UserAchievement
from ...models.career import Mission, UserProgress
from ...schemas.user import ProfileResponse, ProfileUpdate, SettingsResponse, SettingsUpdate, AchievementResponse
from ..deps import get_current_user

router = APIRouter()

@router.get("", response_model=ProfileResponse)
def get_profile(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile

@router.put("/update", response_model=ProfileResponse)
def update_profile(
    profile_in: ProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    update_data = profile_in.model_dump(exclude_unset=True)
    for field in update_data:
        setattr(profile, field, update_data[field])
        
    db.commit()
    db.refresh(profile)
    return profile

@router.get("/settings", response_model=SettingsResponse)
def get_settings(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    settings_obj = db.query(UserSettings).filter(UserSettings.user_id == current_user.id).first()
    if not settings_obj:
        # Create default
        settings_obj = UserSettings(user_id=current_user.id)
        db.add(settings_obj)
        db.commit()
        db.refresh(settings_obj)
    return settings_obj

@router.put("/settings", response_model=SettingsResponse)
def update_settings(
    settings_in: SettingsUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    settings_obj = db.query(UserSettings).filter(UserSettings.user_id == current_user.id).first()
    if not settings_obj:
        raise HTTPException(status_code=404, detail="Settings not found")
    
    update_data = settings_in.model_dump(exclude_unset=True)
    for field in update_data:
        setattr(settings_obj, field, update_data[field])
        
    db.commit()
    db.refresh(settings_obj)
    return settings_obj

@router.get("/achievements", response_model=List[AchievementResponse])
def get_achievements(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    achievements = db.query(UserAchievement).filter(UserAchievement.user_id == current_user.id).all()
    # If empty, let's create a default first one
    if not achievements:
        first_ach = UserAchievement(
            user_id=current_user.id,
            achievement_slug="first_step",
            title="First Step Taken",
            description="Created your profile and joined the OS.",
            icon="🎯"
        )
        db.add(first_ach)
        db.commit()
        achievements = [first_ach]
    return achievements

@router.get("/dashboard", response_model=Dict[str, Any])
def get_dashboard_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    # Query database missions matching user's career_slug
    db_missions = db.query(Mission).filter(Mission.career_slug == profile.career_slug).order_by(Mission.order_index).limit(3).all()
    
    daily_missions = []
    if db_missions:
        for m in db_missions:
            # Check progress log to see if claimed
            prog = db.query(UserProgress).filter(
                UserProgress.user_id == current_user.id,
                UserProgress.item_type == "mission",
                UserProgress.item_id == m.id
            ).first()
            claimed = (prog.status == "completed") if prog else False
            daily_missions.append({
                "id": m.id,
                "title": m.title,
                "xp": m.xp_reward,
                "claimed": claimed
            })
            
    # Fallback default values if no seed database records found
    if not daily_missions:
        daily_missions = [
            {"id": "dm1", "title": f"Explore {profile.career_slug.replace('_', ' ').title()} Basics", "xp": 150, "claimed": False},
            {"id": "dm2", "title": "Complete 1 Coding Practice Topic", "xp": 200, "claimed": False},
            {"id": "dm3", "title": "Chat with AI Mentor about Projects", "xp": 250, "claimed": False}
        ]

    # Renders structured details for frontend
    return {
        "greeting": f"Good Morning, {profile.name}",
        "goal_label": profile.career_slug.replace("_", " ").title(),
        "streak": profile.streak,
        "xp": profile.xp,
        "coins": profile.coins,
        "level": profile.level,
        "readiness_score": profile.readiness_score,
        "daily_mission_title": "Today's Agenda",
        "daily_missions": daily_missions
    }
