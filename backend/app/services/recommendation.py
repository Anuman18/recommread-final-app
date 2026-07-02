from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional
from datetime import datetime

from ..models.user import Profile, UserSkill, UserXPLedger, UserCoinsLedger, ActivityHistory
from ..models.career import CareerGoal, LearningPath, Roadmap, Topic, LearningResource, Mission, Project, ProjectMilestone, Quiz, UserProgress, UserResourceProgress, UserProjectProgress
from ..models.coding import CodingQuestion, UserQuestionProgress
from ..models.interview import InterviewType, InterviewQuestion, UserInterviewRound, InterviewQuestionFeedback

class RecommendationService:
    @staticmethod
    def get_weak_skills(db: Session, user_id: int) -> List[str]:
        # Query skill metrics for user
        user_skills = db.query(UserSkill).filter(UserSkill.user_id == user_id).all()
        
        # 1. Identify low-value skills (level < 2.5)
        weak = [s.skill_name for s in user_skills if s.level_value < 2.5]
        
        # 2. Inspect failing coding questions
        unsolved_qs = db.query(UserQuestionProgress).filter(
            UserQuestionProgress.user_id == user_id,
            UserQuestionProgress.status != "solved"
        ).all()
        if unsolved_qs:
            for uq in unsolved_qs:
                q = db.query(CodingQuestion).filter(CodingQuestion.id == uq.question_id).first()
                if q:
                    topic = db.query(Topic).filter(Topic.id == q.topic_id).first()
                    if topic and topic.name not in weak:
                        weak.append(topic.name)
                        
        # 3. Inspect poor interview performance
        rounds = db.query(UserInterviewRound).filter(
            UserInterviewRound.user_id == user_id,
            UserInterviewRound.overall_score < 70.0
        ).all()
        for r in rounds:
            feedbacks = db.query(InterviewQuestionFeedback).filter(InterviewQuestionFeedback.round_id == r.id).all()
            for f in feedbacks:
                iq = db.query(InterviewQuestion).filter(InterviewQuestion.id == f.question_id).first()
                if iq and iq.topic not in weak:
                    weak.append(iq.topic)

        # Fallback defaults if new user
        if not weak:
            profile = db.query(Profile).filter(Profile.user_id == user_id).first()
            career = profile.career_slug if profile else "ai_engineer"
            if career == "ai_engineer":
                weak = ["Transformers KV Caching", "Deep Learning Quantization"]
            elif career == "data_scientist":
                weak = ["SQL Window functions", "SMOTE Imbalance classification"]
            else:
                weak = ["Figma Dev Mode", "Layout Spacing ratios"]
                
        return weak[:4]

    @staticmethod
    def get_strong_skills(db: Session, user_id: int) -> List[str]:
        user_skills = db.query(UserSkill).filter(UserSkill.user_id == user_id).all()
        
        # 1. High-value skills (level >= 3.5)
        strong = [s.skill_name for s in user_skills if s.level_value >= 3.5]
        
        # 2. Inspect successful coding completions
        solved_qs = db.query(UserQuestionProgress).filter(
            UserQuestionProgress.user_id == user_id,
            UserQuestionProgress.status == "solved"
        ).all()
        for sq in solved_qs:
            q = db.query(CodingQuestion).filter(CodingQuestion.id == sq.question_id).first()
            if q:
                topic = db.query(Topic).filter(Topic.id == q.topic_id).first()
                if topic and topic.name not in strong:
                    strong.append(topic.name)

        if not strong:
            profile = db.query(Profile).filter(Profile.user_id == user_id).first()
            career = profile.career_slug if profile else "ai_engineer"
            if career == "ai_engineer":
                strong = ["Python OOP basics", "Matrix Vector Dot Multiplications"]
            elif career == "data_scientist":
                strong = ["Pandas очистка данных", "Matplotlib charts scaling"]
            else:
                strong = ["Figma Auto layouts", "Typography hierarchies"]
                
        return strong[:4]

    @staticmethod
    def get_next_best_mission(db: Session, user_id: int) -> Optional[Dict[str, Any]]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return None
            
        career = profile.career_slug
        
        # Fetch all missions matching career slug, ordered
        missions = db.query(Mission).filter(Mission.career_slug == career).order_by(Mission.order_index).all()
        
        # Fetch completed missions in progress logs
        completed_ids = db.query(UserProgress).filter(
            UserProgress.user_id == user_id,
            UserProgress.item_type == "mission",
            UserProgress.status == "completed"
        ).all()
        comp_ids_set = {c.item_id for c in completed_ids}
        
        for m in missions:
            if m.id not in comp_ids_set:
                return {
                    "id": m.id,
                    "title": m.title,
                    "description": m.description,
                    "xp_reward": m.xp_reward,
                    "coins_reward": m.coins_reward,
                    "career_slug": m.career_slug
                }
                
        # If all completed, return last one as revision
        if missions:
            last = missions[-1]
            return {
                "id": last.id,
                "title": f"Revise: {last.title}",
                "description": last.description,
                "xp_reward": 100,
                "coins_reward": 5,
                "career_slug": last.career_slug
            }
        return None

    @staticmethod
    def get_suggested_resources(db: Session, user_id: int) -> List[Dict[str, Any]]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return []
            
        career = profile.career_slug
        weak = RecommendationService.get_weak_skills(db, user_id)
        
        # Query all learning resources for career
        all_res = db.query(LearningResource).filter(LearningResource.career_slug == career).all()
        
        # Sort so resources that match user weak skills are positioned first
        def score_resource(r: LearningResource) -> int:
            score = 0
            if r.skills:
                # count matching weak skills
                for s in r.skills:
                    if s in weak:
                        score += 5
            # penalize completed items
            prog = db.query(UserResourceProgress).filter(
                UserResourceProgress.user_id == user_id,
                UserResourceProgress.resource_id == r.id
            ).first()
            if prog and prog.is_completed:
                score -= 10
            return score
            
        all_res.sort(key=score_resource, reverse=True)
        
        response = []
        for r in all_res:
            prog = db.query(UserResourceProgress).filter(
                UserResourceProgress.user_id == user_id,
                UserResourceProgress.resource_id == r.id
            ).first()
            response.append({
                "id": str(r.id),
                "title": r.title,
                "provider": r.category,
                "type": r.category.lower(),
                "difficulty": profile.skill_level,
                "url": r.url,
                "skills": r.skills or [],
                "is_bookmarked": prog.is_bookmarked if prog else False,
                "completion_status": "completed" if (prog and prog.is_completed) else "not_started",
                "description": r.description or "",
                "ai_reason": r.why_recommended or f"Recommended based on your target profile '{profile.name}'."
            })
        return response[:5]

    @staticmethod
    def get_suggested_projects(db: Session, user_id: int) -> List[Dict[str, Any]]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return []
            
        career = profile.career_slug
        
        # Query matching projects
        projects = db.query(Project).filter(Project.career_slug == career).all()
        
        response = []
        for p in projects:
            prog = db.query(UserProjectProgress).filter(
                UserProjectProgress.user_id == user_id,
                UserProjectProgress.project_id == p.id
            ).first()
            response.append({
                "id": p.id,
                "name": p.name,
                "difficulty": p.difficulty,
                "duration": p.duration,
                "skills": p.skills or [],
                "xp_reward": p.xp_reward,
                "coins_reward": p.coins_reward,
                "portfolio_value": p.portfolio_value,
                "status": prog.status if prog else "not_started",
                "progress_percentage": prog.progress_percentage if prog else 0.0,
                "image_url": p.image_url or ""
            })
        return response

    @staticmethod
    def get_suggested_coding_questions(db: Session, user_id: int) -> List[Dict[str, Any]]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return []
            
        career = profile.career_slug
        weak = RecommendationService.get_weak_skills(db, user_id)
        
        # Fetch topics for career
        topics = db.query(Topic).filter(Topic.career_slug == career).all()
        topic_ids = [t.id for t in topics]
        
        # Query matching questions
        questions = db.query(CodingQuestion).filter(CodingQuestion.topic_id.in_(topic_ids)).all()
        
        # Reorder so questions whose topic or title matches a weak skill appear first
        def score_question(q: CodingQuestion) -> int:
            score = 0
            topic = db.query(Topic).filter(Topic.id == q.topic_id).first()
            if topic and topic.name in weak:
                score += 8
            # Adjust to user level
            if q.difficulty.lower() == profile.skill_level.lower():
                score += 4
            prog = db.query(UserQuestionProgress).filter(
                UserQuestionProgress.user_id == user_id,
                UserQuestionProgress.question_id == q.id
            ).first()
            if prog and prog.status == "solved":
                score -= 15
            return score
            
        questions.sort(key=score_question, reverse=True)
        
        response = []
        for q in questions:
            prog = db.query(UserQuestionProgress).filter(
                UserQuestionProgress.user_id == user_id,
                UserQuestionProgress.question_id == q.id
            ).first()
            response.append({
                "id": q.id,
                "title": q.title,
                "difficulty": q.difficulty,
                "time_min": q.time_min,
                "xp_reward": q.xp_reward,
                "status": prog.status if prog else "unsolved"
            })
        return response[:4]

    @staticmethod
    def get_daily_recommendations(db: Session, user_id: int) -> Dict[str, Any]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return {}
            
        # Workload scaling rules based on available time & consistency streak
        available_time = profile.daily_learning_time_min
        streak = profile.streak
        
        # 1. Adapt workload limits
        max_resources = 1
        max_questions = 1
        intensity_label = "Cruising"
        
        if available_time >= 120: # 2 Hours+
            max_resources = 3
            max_questions = 2
            intensity_label = "Deep Focus"
        elif available_time >= 60: # 1 Hour
            max_resources = 2
            max_questions = 1
            intensity_label = "Standard Pace"
            
        # If user misses streak, drop intensity to avoid friction
        if streak == 0:
            max_resources = max(1, max_resources - 1)
            max_questions = 1
            intensity_label = "Comfort Recovery (Reducing workload to re-engage streak)"

        # 2. Gather recommendations
        suggested_resources = RecommendationService.get_suggested_resources(db, user_id)[:max_resources]
        suggested_coding = RecommendationService.get_suggested_coding_questions(db, user_id)[:max_questions]
        next_mission = RecommendationService.get_next_best_mission(db, user_id)
        weak_skills = RecommendationService.get_weak_skills(db, user_id)
        
        # Custom AI tutor tip
        tutor_tip = "Ready to start your day? Let's check out your topics."
        if weak_skills:
            tutor_tip = f"Reviewing your progress indicates that you can strengthen your concepts on '{weak_skills[0]}'. We highly recommend reading the documentation resources before starting challenges!"
            
        return {
            "intensity": intensity_label,
            "streak_modifier": f"Active Streak is {streak} days.",
            "daily_mission": next_mission,
            "suggested_resources": suggested_resources,
            "suggested_coding_questions": suggested_coding,
            "ai_tutor_tip": tutor_tip,
            "timestamp": datetime.now().isoformat()
        }

    @staticmethod
    def get_weekly_plan(db: Session, user_id: int) -> List[Dict[str, Any]]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return []
            
        weak = RecommendationService.get_weak_skills(db, user_id)
        
        # Adaptive 7-day schedule
        schedule = [
            {"day": "Monday", "focus": "Theoretical Foundations", "task": f"Study 1 documentation resource targeting '{weak[0] if weak else 'Core Logic'}'"},
            {"day": "Tuesday", "focus": "Algorithm Practice", "task": "Resolve 1 Coding Problem on active topics"},
            {"day": "Wednesday", "focus": "Practical Application", "task": "Advance 1 milestone in your active Project Track"},
            {"day": "Thursday", "focus": "Knowledge Check", "task": "Take the chapter Quiz to check progress"},
            {"day": "Friday", "focus": "Communication Skills", "task": "Run 1 Mock Interview session with the AI Interview coach"},
            {"day": "Saturday", "focus": "System Design & Scale", "task": "Solve 1 System Design architectural challenge card"},
            {"day": "Sunday", "focus": "Streaks & Revision", "task": "Review all bookmarked notes and complete any remaining tasks"}
        ]
        
        # Adjust tasks if user is advanced or has high daily available time
        if profile.skill_level.lower() == "advanced":
            for day in schedule:
                if "1 Coding" in day["task"]:
                    day["task"] = "Resolve 2 Hard/Medium Coding Problems"
                elif "milestone" in day["task"]:
                    day["task"] = "Implement 2 milestones in your active Project Track and audit performance limits"
                    
        return schedule

    @staticmethod
    def get_personalized_learning_path(db: Session, user_id: int) -> Dict[str, Any]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return {}
            
        career = profile.career_slug
        
        path = db.query(LearningPath).filter(LearningPath.career_slug == career).first()
        roadmaps = db.query(Roadmap).filter(Roadmap.career_slug == career).order_by(Roadmap.order_index).all()
        
        roadmaps_list = []
        for rm in roadmaps:
            roadmaps_list.append({
                "phase_title": rm.title,
                "milestones": rm.milestones_json or [],
                "order": rm.order_index
            })
            
        return {
            "career_slug": career,
            "path_title": path.title if path else f"{career.upper()} Custom Learning Path",
            "path_description": path.description if path else "Tailored skills roadmap based on your selected target.",
            "estimated_weeks": path.estimated_weeks if path else 12,
            "roadmaps": roadmaps_list,
            "last_updated": datetime.now().isoformat()
        }
