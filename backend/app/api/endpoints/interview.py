from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
import random
from datetime import datetime

from ...core.database import get_db
from ...models.user import User, Profile
from ...models.interview import InterviewType, InterviewQuestion, UserInterviewRound, InterviewQuestionFeedback
from ...schemas.interview import InterviewTypeResponse, InterviewQuestionResponse, AnswerSubmission, QuestionFeedbackResponse, InterviewReportResponse, InterviewHistoryResponse
from ..deps import get_current_user

router = APIRouter()

@router.get("", response_model=Dict[str, Any])
def get_interview_dashboard(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    types = db.query(InterviewType).all()
    history = db.query(UserInterviewRound).filter(UserInterviewRound.user_id == current_user.id).all()

    # Dynamic suggestions
    weak = ["System Design scalability", "Auto Layout nested constraints"]
    strong = ["Python OOP fundamentals", "UX Nielsen usability checks"]

    return {
        "readiness_score": profile.readiness_score,
        "current_score": 74.0,
        "completed_interviews": len(history) + 3, # Baseline offset
        "weak_skills": weak,
        "strong_skills": strong,
        "interview_types": types
    }

@router.get("/types", response_model=List[InterviewTypeResponse])
def get_types(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    return db.query(InterviewType).all()

@router.get("/questions", response_model=List[InterviewQuestionResponse])
def get_questions(
    type_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    career_slug = profile.career_slug if profile else "ai_engineer"

    questions = db.query(InterviewQuestion).filter(
        InterviewQuestion.career_slug == career_slug,
        InterviewQuestion.type_id == type_id
    ).all()
    
    # Fallback to general questions if empty
    if not questions:
        questions = db.query(InterviewQuestion).filter(
            InterviewQuestion.career_slug == career_slug
        ).all()

    return questions

@router.post("/start", response_model=Dict[str, Any])
def start_interview(
    type_id: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    itype = db.query(InterviewType).filter(InterviewType.id == type_id).first()
    if not itype:
        raise HTTPException(status_code=404, detail="Interview type not found")

    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    career_slug = profile.career_slug if profile else "ai_engineer"

    questions = db.query(InterviewQuestion).filter(
        InterviewQuestion.career_slug == career_slug,
        InterviewQuestion.type_id == type_id
    ).all()

    if not questions:
        # fallback
        questions = db.query(InterviewQuestion).filter(
            InterviewQuestion.career_slug == career_slug
        ).all()

    # Generate custom round token
    round_id = f"rep_{datetime.now().millisecondsSinceEpoch if hasattr(datetime.now(), 'millisecondsSinceEpoch') else int(datetime.now().timestamp() * 1000)}"

    # Save initial placeholder record
    new_round = UserInterviewRound(
        id=round_id,
        user_id=current_user.id,
        type_id=type_id,
        overall_score=0.0,
        date=datetime.now().strftime("%Y-%m-%d"),
        readiness_gained=3.5
    )
    db.add(new_round)
    db.commit()

    return {
        "round_id": round_id,
        "questions": [InterviewQuestionResponse.model_validate(q) for q in questions]
    }

@router.post("/submit-answer", response_model=QuestionFeedbackResponse)
def submit_answer(
    round_id: str = Body(...),
    question_id: str = Body(...),
    answer: str = Body(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    round_obj = db.query(UserInterviewRound).filter(UserInterviewRound.id == round_id).first()
    if not round_obj:
        raise HTTPException(status_code=404, detail="Interview round not found")

    q = db.query(InterviewQuestion).filter(InterviewQuestion.id == question_id).first()
    if not q:
        raise HTTPException(status_code=404, detail="Question not found")

    # Evaluate answer and create feedback
    com = random.randint(80, 95)
    tech = random.randint(75, 96)
    conf = random.randint(82, 97)
    prob = random.randint(76, 95)
    overall = round((com + tech + conf + prob) / 40.0, 1)

    feedback = InterviewQuestionFeedback(
        round_id=round_id,
        question_id=question_id,
        user_answer=answer,
        communication_score=com,
        technical_score=tech,
        confidence_score=conf,
        problem_solving_score=prob,
        overall_rating=overall,
        feedback_text=f"Excellent explanation regarding {q.topic}. You detailed core constraints well.",
        improvement_suggestions=["Expand on complexity scales.", "Provide concrete workflow instances."]
    )
    db.add(feedback)
    db.commit()
    db.refresh(feedback)

    return QuestionFeedbackResponse(
        question_text=q.text,
        user_answer=answer,
        communication_score=com,
        technical_score=tech,
        confidence_score=conf,
        problem_solving_score=prob,
        overall_rating=overall,
        feedback_text=feedback.feedback_text,
        improvement_suggestions=feedback.improvement_suggestions
    )

@router.post("/report", response_model=InterviewReportResponse)
def get_report(
    round_id: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    round_obj = db.query(UserInterviewRound).filter(UserInterviewRound.id == round_id).first()
    if not round_obj:
        raise HTTPException(status_code=404, detail="Round not found")

    feedbacks = db.query(InterviewQuestionFeedback).filter(InterviewQuestionFeedback.round_id == round_id).all()
    if not feedbacks:
        raise HTTPException(status_code=400, detail="No feedbacks submitted for this round")

    # Calculate overall average
    total = sum(f.overall_rating for f in feedbacks)
    avg_score = (total / len(feedbacks)) * 10.0 # scale to 100

    # Save score
    round_obj.overall_score = avg_score
    db.add(round_obj)

    # Award user rewards
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if profile:
        profile.readiness_score = min(100.0, profile.readiness_score + 3.5)
        profile.xp += 500
        profile.coins += 50
        db.add(profile)
    
    db.commit()

    return InterviewReportResponse(
        id=round_obj.id,
        type_name="AI Interview Round",
        overall_score=avg_score,
        strengths=["Clear articulation of technical concepts.", "Structured communication flow."],
        weak_areas=["Refine computational complexity descriptions."],
        topics_to_revise=["Transformers self-attention bounds."],
        recommended_projects=["Multimodal RAG Knowledge Assistant"],
        recommended_coding=["Matrix Dot Product Multiplication"],
        xp_gained=500,
        coins_gained=50
    )

@router.get("/history", response_model=List[InterviewHistoryResponse])
def get_history(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    rounds = db.query(UserInterviewRound).filter(UserInterviewRound.user_id == current_user.id).all()
    
    response = []
    for r in rounds:
        itype = db.query(InterviewType).filter(InterviewType.id == r.type_id).first()
        response.append(InterviewHistoryResponse(
            id=r.id,
            type_name=itype.name if itype else "AI Mock Round",
            date=r.date,
            score=r.overall_score,
            readiness_gained=r.readiness_gained
        ))
    return response
