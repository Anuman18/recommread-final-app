from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from typing import Dict, Any, Optional

from ...core.database import get_db
from ...api.deps import get_current_user
from ...models.user import User
from ...services.ai.tutor import ai_tutor_service

router = APIRouter()

@router.post("/chat/start", response_model=Dict[str, Any])
def start_chat(
    context_type: str = Body(..., embed=True),
    context_id: Optional[str] = Body(None, embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return ai_tutor_service.start_chat(db, current_user.id, context_type, context_id)

@router.post("/chat/continue", response_model=Dict[str, Any])
def continue_chat(
    context_type: str = Body(..., embed=True),
    context_id: Optional[str] = Body(None, embed=True),
    message: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    if not message.strip():
        raise HTTPException(status_code=400, detail="Message cannot be empty")
    return ai_tutor_service.continue_chat(db, current_user.id, context_type, context_id, message)

@router.post("/explain", response_model=Dict[str, Any])
def explain_concept(
    concept: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reply = ai_tutor_service.generate_explanation(db, current_user.id, concept)
    return {"reply": reply}

@router.post("/summary", response_model=Dict[str, Any])
def summarize_resource(
    resource_title: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reply = ai_tutor_service.generate_summary(db, current_user.id, resource_title)
    return {"reply": reply}

@router.post("/quiz", response_model=Dict[str, Any])
def generate_quiz(
    topic: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reply = ai_tutor_service.generate_quiz(db, current_user.id, topic)
    return {"reply": reply}

@router.post("/flashcards", response_model=Dict[str, Any])
def generate_flashcards(
    topic: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reply = ai_tutor_service.generate_flashcards(db, current_user.id, topic)
    return {"reply": reply}

@router.post("/revision", response_model=Dict[str, Any])
def generate_revision(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reply = ai_tutor_service.generate_revision(db, current_user.id)
    return {"reply": reply}

@router.post("/coding-hint", response_model=Dict[str, Any])
def generate_coding_hint(
    question_title: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reply = ai_tutor_service.generate_coding_hint(db, current_user.id, question_title)
    return {"reply": reply}

@router.post("/review-code", response_model=Dict[str, Any])
def review_code(
    question_title: str = Body(..., embed=True),
    code: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reply = ai_tutor_service.review_code(db, current_user.id, question_title, code)
    return {"reply": reply}

@router.post("/interview-questions", response_model=Dict[str, Any])
def generate_interview_questions(
    type_name: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reply = ai_tutor_service.generate_interview_questions(db, current_user.id, type_name)
    return {"reply": reply}

@router.post("/daily-advice", response_model=Dict[str, Any])
def generate_daily_advice(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    reply = ai_tutor_service.generate_daily_advice(db, current_user.id)
    return {"reply": reply}
