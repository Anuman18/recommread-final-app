from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from ...core.database import get_db
from ...models.user import User, Profile
from ...models.career import Resource, UserResourceProgress, UserProgress
from ...schemas.career import ResourceResponse
from ..deps import get_current_user

router = APIRouter()

def make_response(r: Resource, progress: Optional[UserResourceProgress]) -> ResourceResponse:
    return ResourceResponse(
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
    )

@router.get("", response_model=List[ResourceResponse])
def get_books(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    resources = db.query(Resource).all()
    response = []
    for r in resources:
        progress = db.query(UserResourceProgress).filter(
            UserResourceProgress.user_id == current_user.id,
            UserResourceProgress.resource_id == r.id
        ).first()
        response.append(make_response(r, progress))
    return response

@router.get("/search", response_model=List[ResourceResponse])
def search_books(
    q: str = Query(..., min_length=1),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    query = f"%{q}%"
    resources = db.query(Resource).filter(
        (Resource.title.ilike(query)) |
        (Resource.description.ilike(query))
    ).all()
    
    response = []
    for r in resources:
        progress = db.query(UserResourceProgress).filter(
            UserResourceProgress.user_id == current_user.id,
            UserResourceProgress.resource_id == r.id
        ).first()
        response.append(make_response(r, progress))
    return response

@router.get("/recent", response_model=List[ResourceResponse])
def get_recent_books(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    progress_records = db.query(UserResourceProgress).filter(
        UserResourceProgress.user_id == current_user.id
    ).order_by(UserResourceProgress.id.desc()).limit(5).all()
    
    response = []
    for p in progress_records:
        r = db.query(Resource).filter(Resource.id == p.resource_id).first()
        if r:
            response.append(make_response(r, p))
    return response

@router.get("/bookmarks", response_model=List[ResourceResponse])
def get_bookmarked_books(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    progress_records = db.query(UserResourceProgress).filter(
        UserResourceProgress.user_id == current_user.id,
        UserResourceProgress.is_bookmarked == True
    ).all()
    
    response = []
    for p in progress_records:
        r = db.query(Resource).filter(Resource.id == p.resource_id).first()
        if r:
            response.append(make_response(r, p))
    return response

@router.get("/continue", response_model=List[ResourceResponse])
def get_continue_books(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    progress_records = db.query(UserResourceProgress).filter(
        UserResourceProgress.user_id == current_user.id,
        UserResourceProgress.is_completed == False
    ).all()
    
    response = []
    for p in progress_records:
        r = db.query(Resource).filter(Resource.id == p.resource_id).first()
        if r:
            response.append(make_response(r, p))
    return response

@router.get("/category/{category}", response_model=List[ResourceResponse])
def get_books_by_category(
    category: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    resources = db.query(Resource).filter(Resource.category.ilike(category)).all()
    response = []
    for r in resources:
        progress = db.query(UserResourceProgress).filter(
            UserResourceProgress.user_id == current_user.id,
            UserResourceProgress.resource_id == r.id
        ).first()
        response.append(make_response(r, progress))
    return response

@router.get("/{id}", response_model=ResourceResponse)
def get_book_by_id(
    id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    r = db.query(Resource).filter(Resource.id == id).first()
    if not r:
        raise HTTPException(status_code=404, detail="Book not found")
    progress = db.query(UserResourceProgress).filter(
        UserResourceProgress.user_id == current_user.id,
        UserResourceProgress.resource_id == r.id
    ).first()
    return make_response(r, progress)
