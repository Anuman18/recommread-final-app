from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional

from ...core.database import get_db
from ...models.user import User, Profile
from ...models.career import Resource, UserResourceProgress
from ...schemas.career import ResourceResponse
from ..deps import get_current_user

router = APIRouter()

@router.get("", response_model=List[ResourceResponse])
def get_resources(
    career: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    career_slug = career or (profile.career_slug if profile else "ai_engineer")

    resources = db.query(Resource).filter(Resource.career_slug == career_slug).all()
    
    response = []
    for r in resources:
        # Check progress
        progress = db.query(UserResourceProgress).filter(
            UserResourceProgress.user_id == current_user.id,
            UserResourceProgress.resource_id == r.id
        ).first()

        response.append(ResourceResponse(
            id=r.id,
            career_slug=r.career_slug,
            title=r.title,
            category=r.category,
            url=r.url,
            description=r.description,
            why_recommended=r.why_recommended,
            skills=r.skills,
            thumbnail_url=r.thumbnail_url,
            is_bookmarked=progress.is_bookmarked if progress else False,
            is_completed=progress.is_completed if progress else False
        ))
    return response

@router.post("/{id}/bookmark", response_model=ResourceResponse)
def bookmark_resource(
    id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    resource = db.query(Resource).filter(Resource.id == id).first()
    if not resource:
        raise HTTPException(status_code=404, detail="Resource not found")

    progress = db.query(UserResourceProgress).filter(
        UserResourceProgress.user_id == current_user.id,
        UserResourceProgress.resource_id == id
    ).first()

    if not progress:
        progress = UserResourceProgress(user_id=current_user.id, resource_id=id, is_bookmarked=True)
        db.add(progress)
    else:
        progress.is_bookmarked = not progress.is_bookmarked
    
    db.commit()
    db.refresh(progress)

    return ResourceResponse(
        id=resource.id,
        career_slug=resource.career_slug,
        title=resource.title,
        category=resource.category,
        url=resource.url,
        description=resource.description,
        why_recommended=resource.why_recommended,
        skills=resource.skills,
        thumbnail_url=resource.thumbnail_url,
        is_bookmarked=progress.is_bookmarked,
        is_completed=progress.is_completed
    )

@router.post("/{id}/complete", response_model=ResourceResponse)
def complete_resource(
    id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    resource = db.query(Resource).filter(Resource.id == id).first()
    if not resource:
        raise HTTPException(status_code=404, detail="Resource not found")

    progress = db.query(UserResourceProgress).filter(
        UserResourceProgress.user_id == current_user.id,
        UserResourceProgress.resource_id == id
    ).first()

    if not progress:
        progress = UserResourceProgress(user_id=current_user.id, resource_id=id, is_completed=True)
        db.add(progress)
    else:
        progress.is_completed = not progress.is_completed
    
    db.commit()
    db.refresh(progress)

    # Award XP if marked complete
    if progress.is_completed:
        profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
        if profile:
            profile.xp += 150
            db.add(profile)
            db.commit()

    return ResourceResponse(
        id=resource.id,
        career_slug=resource.career_slug,
        title=resource.title,
        category=resource.category,
        url=resource.url,
        description=resource.description,
        why_recommended=resource.why_recommended,
        skills=resource.skills,
        thumbnail_url=resource.thumbnail_url,
        is_bookmarked=progress.is_bookmarked,
        is_completed=progress.is_completed
    )
