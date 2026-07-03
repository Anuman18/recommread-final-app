from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
import random
from datetime import datetime

from ...core.database import get_db
from ...models.user import User, Profile
from ...models.career import Topic
from ...models.coding import CodingQuestion, UserQuestionProgress
from ...schemas.coding import CodingQuestionResponse, CodeSubmission, SubmissionResultResponse
from ...schemas.career import TopicResponse
from ..deps import get_current_user
from ...services.coding_execution import CodeExecutionService

router = APIRouter()

@router.get("/topics", response_model=List[TopicResponse])
def get_topics(
    career: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    career_slug = career or (profile.career_slug if profile else "ai_engineer")

    topics = db.query(Topic).filter(Topic.career_slug == career_slug).all()
    return topics

@router.get("/questions", response_model=List[CodingQuestionResponse])
def get_questions(
    topic_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    questions = db.query(CodingQuestion).filter(CodingQuestion.topic_id == topic_id).all()
    
    response = []
    for q in questions:
        progress = db.query(UserQuestionProgress).filter(
            UserQuestionProgress.user_id == current_user.id,
            UserQuestionProgress.question_id == q.id
        ).first()

        response.append(CodingQuestionResponse(
            id=q.id,
            topic_id=q.topic_id,
            title=q.title,
            difficulty=q.difficulty,
            companies=q.companies,
            time_min=q.time_min,
            xp_reward=q.xp_reward,
            coins_reward=q.coins_reward,
            hints=q.hints,
            problem_statement=q.problem_statement,
            examples=q.examples,
            constraints=q.constraints,
            expected_output=q.expected_output,
            editorial=q.editorial,
            doc_url=q.doc_url,
            video_url=q.video_url,
            status=progress.status if progress else "unsolved",
            attempts=progress.attempts if progress else 0,
            runtime_ms=progress.runtime_ms if progress else 0,
            memory_mb=progress.memory_mb if progress else 0.0,
            language=progress.language if progress else None,
            submission_history=progress.submission_history if progress else []
        ))
    return response

@router.post("/questions/{id}/submit", response_model=SubmissionResultResponse)
def submit_question(
    id: str,
    submission: CodeSubmission,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    q = db.query(CodingQuestion).filter(CodingQuestion.id == id).first()
    if not q:
        raise HTTPException(status_code=404, detail="Question not found")

    # Real compilation & execution inside sandbox
    result = CodeExecutionService.execute(id, submission.language, submission.user_code)
    
    passed_all = result["passed_all"]
    passed_test_cases = result["passed_test_cases"]
    total_test_cases = result["total_test_cases"]
    time_ms = result["execution_time_ms"]
    mem_mb = result["memory_usage_mb"]
    status_str = result["status"]
    feedback = result["feedback"]

    progress = db.query(UserQuestionProgress).filter(
        UserQuestionProgress.user_id == current_user.id,
        UserQuestionProgress.question_id == id
    ).first()

    already_solved = progress and progress.status == "solved"

    if submission.is_submit:
        history_log = {
            "language": submission.language,
            "status": status_str,
            "passed_cases": passed_test_cases,
            "total_cases": total_test_cases,
            "runtime_ms": time_ms,
            "memory_mb": mem_mb,
            "timestamp": datetime.utcnow().isoformat()
        }

        if not progress:
            progress = UserQuestionProgress(
                user_id=current_user.id,
                question_id=id,
                status="solved" if passed_all else "in_progress",
                submitted_code=submission.user_code,
                attempts=1,
                runtime_ms=time_ms if passed_all else 0,
                memory_mb=mem_mb if passed_all else 0.0,
                language=submission.language,
                submission_history=[history_log]
            )
            db.add(progress)
        else:
            progress.attempts = (progress.attempts or 0) + 1
            progress.submitted_code = submission.user_code
            progress.language = submission.language
            
            history = list(progress.submission_history) if progress.submission_history else []
            history.append(history_log)
            progress.submission_history = history
            
            if passed_all:
                progress.status = "solved"
                progress.runtime_ms = time_ms
                progress.memory_mb = mem_mb
                
        db.commit()

    # Award rewards ONLY if it's the first time they solve this question successfully
    xp_earned = 0
    coins_earned = 0
    if passed_all and not already_solved:
        profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
        if profile:
            profile.xp += q.xp_reward
            profile.coins += q.coins_reward
            profile.streak += 1
            db.add(profile)
            db.commit()
            xp_earned = q.xp_reward
            coins_earned = q.coins_reward

    return SubmissionResultResponse(
        passed_all=passed_all,
        passed_test_cases=passed_test_cases,
        total_test_cases=total_test_cases,
        execution_time_ms=time_ms,
        memory_usage_mb=mem_mb,
        xp_earned=xp_earned,
        coins_earned=coins_earned,
        feedback=f"[{status_str}] {feedback}"
    )

@router.get("/daily-challenge", response_model=CodingQuestionResponse)
def get_daily_challenge(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Retrieve the first question as a fallback featured daily challenge
    q = db.query(CodingQuestion).first()
    if not q:
        raise HTTPException(status_code=404, detail="No questions found")

    progress = db.query(UserQuestionProgress).filter(
        UserQuestionProgress.user_id == current_user.id,
        UserQuestionProgress.question_id == q.id
    ).first()

    return CodingQuestionResponse(
        id=q.id,
        topic_id=q.topic_id,
        title=q.title,
        difficulty=q.difficulty,
        companies=q.companies,
        time_min=q.time_min,
        xp_reward=q.xp_reward,
        coins_reward=q.coins_reward,
        hints=q.hints,
        problem_statement=q.problem_statement,
        examples=q.examples,
        constraints=q.constraints,
        expected_output=q.expected_output,
        editorial=q.editorial,
        doc_url=q.doc_url,
        video_url=q.video_url,
        status=progress.status if progress else "unsolved",
        attempts=progress.attempts if progress else 0,
        runtime_ms=progress.runtime_ms if progress else 0,
        memory_mb=progress.memory_mb if progress else 0.0,
        language=progress.language if progress else None,
        submission_history=progress.submission_history if progress else []
    )

@router.post("/daily-challenge/complete", response_model=Dict[str, Any])
def complete_daily_challenge(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")

    profile.xp += 250
    profile.coins += 30
    profile.streak += 1
    db.add(profile)
    db.commit()

    return {
        "success": True,
        "bonus_xp": 250,
        "bonus_coins": 30,
        "streak": profile.streak
    }
