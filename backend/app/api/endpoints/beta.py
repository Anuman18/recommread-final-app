from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from typing import Dict, Any, Optional

from ...core.database import get_db
from ...api.deps import get_current_user
from ...models.user import User
from ...services.beta import BetaService

router = APIRouter()

@router.post("/feedback", response_model=Dict[str, Any])
def submit_feedback(
    feedback_type: str = Body(..., description="bug, feature_request, resource_rating, ai_rating, general"),
    content: str = Body(..., description="Details and contents description"),
    target_id: Optional[str] = Body(None, description="Resource or chat ID reference"),
    rating: Optional[int] = Body(None, description="Rating score 1-5"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if feedback_type not in ["bug", "feature_request", "resource_rating", "ai_rating", "general"]:
        raise HTTPException(status_code=400, detail="Invalid feedback type")
    if not content.strip():
        raise HTTPException(status_code=400, detail="Content cannot be empty")
        
    return BetaService.submit_feedback(
        db=db,
        user_id=current_user.id,
        feedback_type=feedback_type,
        target_id=target_id,
        rating=rating,
        content=content
    )

@router.post("/analytics/log", response_model=Dict[str, Any])
def log_analytics_event(
    event_name: str = Body(..., description="Action click event identifier"),
    properties: Optional[Dict[str, Any]] = Body(None, description="Properties detail dictionary"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return BetaService.log_analytics_event(
        db=db,
        user_id=current_user.id,
        event_name=event_name,
        properties=properties
    )

@router.get("/admin/dashboard", response_model=Dict[str, Any])
def get_admin_dashboard(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Verify user is active (or check admin role if applicable)
    if not current_user.is_active:
        raise HTTPException(status_code=403, detail="Not authorized to access admin view")
    return BetaService.get_admin_dashboard(db)
