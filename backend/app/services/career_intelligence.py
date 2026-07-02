from sqlalchemy.orm import Session
from typing import Dict, Any, List

from ..models.user import Profile, UserSkill
from ..models.career import CareerGoal, UserProgress, UserProjectProgress
from ..models.coding import UserQuestionProgress
from ..models.interview import UserInterviewRound
from ..services.gamification import GamificationService

class CareerIntelligenceService:
    # Industry skill set mappings per career track
    REQUIRED_SKILLS = {
        "ai_engineer": ["Python", "PyTorch", "Linear Algebra", "Transformers", "Neural Networks", "LLM Fine-Tuning", "Vector DBs"],
        "data_scientist": ["Python", "NumPy", "Pandas", "SQL", "Statistics", "Machine Learning", "Data Visualization", "Deep Learning"],
        "ux_designer": ["Figma", "Design Systems", "Handoff", "UX Research", "Wireframing", "Typography", "Prototyping"]
    }

    @staticmethod
    def get_skill_gap_analysis(db: Session, user_id: int) -> Dict[str, Any]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return {}
            
        career = profile.career_slug
        required = CareerIntelligenceService.REQUIRED_SKILLS.get(career, ["Python", "Algorithms"])
        
        # Query completed skills (proficiency > 3.0)
        user_skills = db.query(UserSkill).filter(UserSkill.user_id == user_id).all()
        completed = [s.skill_name for s in user_skills if s.level_value >= 3.0]
        
        # Compile missing skills
        missing = [s for s in required if s not in completed]
        
        # Priority skills (the first missing skills in required list)
        priority = missing[:2] if missing else []
        
        recommended_next = missing[0] if missing else "Continuous Revision"
        
        return {
            "completed_skills": completed,
            "missing_skills": missing,
            "priority_skills": priority,
            "recommended_next_skill": recommended_next,
            "estimated_learning_time_days": len(missing) * 4 if missing else 2
        }

    @staticmethod
    def get_career_roadmap(db: Session, user_id: int) -> List[Dict[str, Any]]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return []
            
        career = profile.career_slug
        required = CareerIntelligenceService.REQUIRED_SKILLS.get(career, ["Python"])
        
        # Query user skills levels mapping
        user_skills = db.query(UserSkill).filter(UserSkill.user_id == user_id).all()
        skills_map = {s.skill_name: s.level_value for s in user_skills}
        
        roadmap_stages = []
        previous_completed = True
        
        for idx, skill in enumerate(required):
            level = skills_map.get(skill, 0.0)
            is_completed = level >= 3.0
            is_unlocked = idx == 0 or previous_completed
            status = "completed" if is_completed else ("in_progress" if is_unlocked else "locked")
            
            roadmap_stages.append({
                "stage_name": skill,
                "status": status,
                "current_level": round(level, 1),
                "required_level": 3.0,
                "order": idx + 1
            })
            
            previous_completed = is_completed

        # Add portfolio/job ready steps at the end
        completed_projs = db.query(UserProjectProgress).filter(
            UserProjectProgress.user_id == user_id,
            UserProjectProgress.status == "completed"
        ).count()
        
        roadmap_stages.append({
            "stage_name": "Portfolio Projects Completion",
            "status": "completed" if completed_projs >= 2 else ("in_progress" if previous_completed else "locked"),
            "current_level": float(completed_projs),
            "required_level": 2.0,
            "order": len(required) + 1
        })
        
        return roadmap_stages

    @staticmethod
    def get_interview_readiness(db: Session, user_id: int) -> float:
        rounds = db.query(UserInterviewRound).filter(UserInterviewRound.user_id == user_id).all()
        if not rounds:
            return 40.0 # baseline readiness
            
        avg_score = sum(r.overall_score for r in rounds) / len(rounds)
        # Cap readiness score between 0.0 and 100.0
        readiness = min(100.0, avg_score + len(rounds) * 2.5)
        return round(readiness, 1)

    @staticmethod
    def get_portfolio_readiness(db: Session, user_id: int) -> float:
        completed_projs = db.query(UserProjectProgress).filter(
            UserProjectProgress.user_id == user_id,
            UserProjectProgress.status == "completed"
        ).count()
        
        # 1 completed project = 40% readiness, 2+ = 90%+
        readiness = min(100.0, completed_projs * 45.0 + 10.0)
        return round(readiness, 1)

    @staticmethod
    def get_job_readiness_score(db: Session, user_id: int) -> Dict[str, Any]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return {}

        # 1. Skill Mastery completion
        gap = CareerIntelligenceService.get_skill_gap_analysis(db, user_id)
        req_count = len(CareerIntelligenceService.REQUIRED_SKILLS.get(profile.career_slug, [1]))
        comp_count = len(gap.get("completed_skills", []))
        skill_mastery_pct = round((comp_count / req_count) * 100.0, 1) if req_count else 0.0

        # 2. Projects completion
        completed_projs = db.query(UserProjectProgress).filter(
            UserProjectProgress.user_id == user_id,
            UserProjectProgress.status == "completed"
        ).count()
        project_pct = min(100.0, completed_projs * 50.0)

        # 3. Coding progress
        solved_qs = db.query(UserQuestionProgress).filter(
            UserQuestionProgress.user_id == user_id,
            UserQuestionProgress.status == "solved"
        ).count()
        coding_pct = min(100.0, solved_qs * 20.0)

        # 4. Interview Readiness
        interview_pct = CareerIntelligenceService.get_interview_readiness(db, user_id)

        # 5. Portfolio Readiness
        portfolio_pct = CareerIntelligenceService.get_portfolio_readiness(db, user_id)

        # 6. Overall Job Readiness (weighted average)
        overall = (skill_mastery_pct * 0.3) + (project_pct * 0.2) + (coding_pct * 0.1) + (interview_pct * 0.2) + (portfolio_pct * 0.2)
        
        return {
            "career_completion_percentage": round(overall, 1),
            "learning_progress_percentage": skill_mastery_pct,
            "skill_mastery_percentage": skill_mastery_pct,
            "project_completion_percentage": project_pct,
            "coding_progress_percentage": coding_pct,
            "interview_readiness_percentage": interview_pct,
            "portfolio_readiness_percentage": portfolio_pct,
            "overall_job_readiness_percentage": round(overall, 1)
        }

    @staticmethod
    def get_weekly_goals(db: Session, user_id: int) -> List[str]:
        gap = CareerIntelligenceService.get_skill_gap_analysis(db, user_id)
        next_skill = gap.get("recommended_next_skill", "Algorithms")
        
        return [
            f"Complete 2 dynamic learning resources for '{next_skill}'",
            "Solve 3 coding practice problems matching your active stage difficulty",
            "Complete 1 mock interview simulation and evaluate your readiness rating score"
        ]

    @staticmethod
    def get_monthly_goals(db: Session, user_id: int) -> List[str]:
        gap = CareerIntelligenceService.get_skill_gap_analysis(db, user_id)
        missing = gap.get("missing_skills", [])
        
        goals = []
        if len(missing) >= 2:
            goals.append(f"Master skills: '{missing[0]}' and '{missing[1]}'")
        else:
            goals.append("Strengthen all core career profile concepts")
            
        goals.extend([
            "Complete 1 high-fidelity portfolio developer project track",
            "Achieve an overall job readiness index score above 75%"
        ])
        return goals
