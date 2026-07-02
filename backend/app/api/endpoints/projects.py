from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
import random

from ...core.database import get_db
from ...models.user import User, Profile
from ...models.career import Project, ProjectMilestone, UserProjectProgress, UserMilestoneProgress
from ...schemas.career import ProjectResponse, ProjectMilestoneResponse
from ..deps import get_current_user

router = APIRouter()

@router.get("", response_model=List[ProjectResponse])
def get_projects(
    career: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    career_slug = career or (profile.career_slug if profile else "ai_engineer")

    projects = db.query(Project).filter(Project.career_slug == career_slug).all()
    
    response = []
    for p in projects:
        # User Progress
        progress = db.query(UserProjectProgress).filter(
            UserProjectProgress.user_id == current_user.id,
            UserProjectProgress.project_id == p.id
        ).first()

        milestones_list = []
        for m in p.milestones:
            m_prog = db.query(UserMilestoneProgress).filter(
                UserMilestoneProgress.user_id == current_user.id,
                UserMilestoneProgress.milestone_id == m.id
            ).first()
            milestones_list.append(ProjectMilestoneResponse(
                id=m.id,
                text=m.text,
                xp_reward=m.xp_reward,
                coins_reward=m.coins_reward,
                is_completed=m_prog.is_completed if m_prog else False
            ))

        response.append(ProjectResponse(
            id=p.id,
            career_slug=p.career_slug,
            name=p.name,
            difficulty=p.difficulty,
            duration=p.duration,
            skills=p.skills,
            xp_reward=p.xp_reward,
            coins_reward=p.coins_reward,
            portfolio_value=p.portfolio_value,
            problem_statement=p.problem_statement,
            what_you_build=p.what_you_build,
            tech_stack=p.tech_stack,
            prerequisites=p.prerequisites,
            dataset_url=p.dataset_url,
            image_url=p.image_url,
            status=progress.status if progress else "unstarted",
            progress_percentage=progress.progress_percentage if progress else 0.0,
            milestones=milestones_list
        ))
    return response

@router.get("/{id}", response_model=ProjectResponse)
def get_project(
    id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    p = db.query(Project).filter(Project.id == id).first()
    if not p:
        raise HTTPException(status_code=404, detail="Project not found")

    progress = db.query(UserProjectProgress).filter(
        UserProjectProgress.user_id == current_user.id,
        UserProjectProgress.project_id == id
    ).first()

    milestones_list = []
    for m in p.milestones:
        m_prog = db.query(UserMilestoneProgress).filter(
            UserMilestoneProgress.user_id == current_user.id,
            UserMilestoneProgress.milestone_id == m.id
        ).first()
        milestones_list.append(ProjectMilestoneResponse(
            id=m.id,
            text=m.text,
            xp_reward=m.xp_reward,
            coins_reward=m.coins_reward,
            is_completed=m_prog.is_completed if m_prog else False
        ))

    return ProjectResponse(
        id=p.id,
        career_slug=p.career_slug,
        name=p.name,
        difficulty=p.difficulty,
        duration=p.duration,
        skills=p.skills,
        xp_reward=p.xp_reward,
        coins_reward=p.coins_reward,
        portfolio_value=p.portfolio_value,
        problem_statement=p.problem_statement,
        what_you_build=p.what_you_build,
        tech_stack=p.tech_stack,
        prerequisites=p.prerequisites,
        dataset_url=p.dataset_url,
        image_url=p.image_url,
        status=progress.status if progress else "unstarted",
        progress_percentage=progress.progress_percentage if progress else 0.0,
        milestones=milestones_list
    )

@router.post("/{id}/milestones/complete", response_model=ProjectResponse)
def complete_milestone(
    id: str,
    milestone_id: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    project = db.query(Project).filter(Project.id == id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    milestone = db.query(ProjectMilestone).filter(
        ProjectMilestone.id == milestone_id,
        ProjectMilestone.project_id == id
    ).first()
    if not milestone:
        raise HTTPException(status_code=404, detail="Milestone not found")

    m_prog = db.query(UserMilestoneProgress).filter(
        UserMilestoneProgress.user_id == current_user.id,
        UserMilestoneProgress.milestone_id == milestone_id
    ).first()

    if not m_prog:
        m_prog = UserMilestoneProgress(user_id=current_user.id, milestone_id=milestone_id, is_completed=True)
        db.add(m_prog)
    else:
        m_prog.is_completed = not m_prog.is_completed

    db.commit()
    db.refresh(m_prog)

    # Award milestone rewards
    profile = db.query(Profile).filter(Profile.user_id == current_user.id).first()
    if profile and m_prog.is_completed:
        profile.xp += milestone.xp_reward
        profile.coins += milestone.coins_reward
        db.add(profile)

    # Recalculate Project completion status
    all_milestones = db.query(ProjectMilestone).filter(ProjectMilestone.project_id == id).all()
    completed_count = 0
    for m in all_milestones:
        mp = db.query(UserMilestoneProgress).filter(
            UserMilestoneProgress.user_id == current_user.id,
            UserMilestoneProgress.milestone_id == m.id
        ).first()
        if mp and mp.is_completed:
            completed_count += 1

    percentage = (completed_count / len(all_milestones)) * 100.0 if all_milestones else 0.0
    
    status_str = "unstarted"
    if completed_count == len(all_milestones):
        status_str = "completed"
        # Award final project completion bonus
        if profile and m_prog.is_completed:
            profile.xp += project.xp_reward
            profile.coins += project.coins_reward
            db.add(profile)
    elif completed_count > 0:
        status_str = "in_progress"

    progress = db.query(UserProjectProgress).filter(
        UserProjectProgress.user_id == current_user.id,
        UserProjectProgress.project_id == id
    ).first()

    if not progress:
        progress = UserProjectProgress(
            user_id=current_user.id,
            project_id=id,
            status=status_str,
            progress_percentage=percentage
        )
        db.add(progress)
    else:
        progress.status = status_str
        progress.progress_percentage = percentage
        
    db.commit()

    return get_project(id, current_user, db)

@router.post("/{id}/mentor/chat", response_model=Dict[str, Any])
def mentor_chat(
    id: str,
    message: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    project = db.query(Project).filter(Project.id == id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # Generate custom mentor AI responses
    responses = [
        f"Regarding your query on '{project.name}': to resolve this error, check that your local environment ports match. You should verify your database drivers are initialized properly.",
        f"Excellent question! When styling or building layouts for '{project.name}', make sure your flex container parameters don't overlay. Try using relative constraints.",
        f"I recommend auditing the configuration files inside the setup subdirectory. It seems some dependencies might have mismatched versions.",
    ]
    return {
        "reply": random.choice(responses),
        "sender": "mentor",
        "timestamp": "Just Now"
    }
