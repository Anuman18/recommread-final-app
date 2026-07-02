from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import Dict, Any, List

from ..models.user import Profile, UserSkill, UserXPLedger, UserCoinsLedger, ActivityHistory, UserAchievement
from ..models.career import Topic, LearningResource, Mission, Project, Quiz, UserProgress, UserResourceProgress, UserProjectProgress
from ..models.coding import CodingQuestion, UserQuestionProgress
from ..models.interview import UserInterviewRound, Badge, UserBadge

class GamificationService:
    @staticmethod
    def get_level_title(level: int) -> str:
        if level <= 2:
            return "Beginner"
        elif level <= 4:
            return "Explorer"
        elif level <= 6:
            return "Learner"
        elif level <= 9:
            return "Practitioner"
        elif level <= 12:
            return "Advanced"
        elif level <= 15:
            return "Professional"
        elif level <= 19:
            return "Expert"
        elif level <= 24:
            return "Master"
        else:
            return "Legend"

    @staticmethod
    def award_xp_and_coins(
        db: Session,
        user_id: int,
        xp_amount: int,
        coins_amount: int,
        source: str
    ) -> Dict[str, Any]:
        # 1. Log XP
        new_xp_log = UserXPLedger(user_id=user_id, xp_amount=xp_amount, source=source)
        db.add(new_xp_log)
        
        # 2. Log Coins
        new_coins_log = UserCoinsLedger(user_id=user_id, coins_amount=coins_amount, source=source)
        db.add(new_coins_log)
        
        # 3. Update User Profile
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if profile:
            profile.xp += xp_amount
            profile.coins += coins_amount
            
            # Recalculate level (e.g. 1 level per 2500 XP)
            new_level = 1 + (profile.xp // 2500)
            if new_level != profile.level:
                profile.level = new_level
                # Log level up event
                level_up_history = ActivityHistory(
                    user_id=user_id,
                    activity_type="level_up",
                    description=f"Promoted to Level {new_level} ({GamificationService.get_level_title(new_level)})!"
                )
                db.add(level_up_history)
            db.add(profile)
            
        db.commit()
        db.refresh(profile)

        # 4. Trigger Achievement Checks
        GamificationService.check_and_unlock_achievements(db, user_id)
        
        return {
            "xp_gained": xp_amount,
            "coins_gained": coins_amount,
            "source": source,
            "current_xp": profile.xp if profile else 0,
            "current_coins": profile.coins if profile else 0,
            "level": profile.level if profile else 1,
            "level_title": GamificationService.get_level_title(profile.level if profile else 1)
        }

    @staticmethod
    def update_streak(db: Session, user_id: int, activity_type: str) -> int:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return 0

        # Simple increment check
        profile.streak += 1
        
        # Log activity
        history = ActivityHistory(
            user_id=user_id,
            activity_type=activity_type,
            description=f"Completed consistency challenge activity: {activity_type}"
        )
        db.add(history)
        db.add(profile)
        db.commit()
        db.refresh(profile)
        
        # Trigger streak achievement check
        GamificationService.check_and_unlock_achievements(db, user_id)
        
        return profile.streak

    @staticmethod
    def check_and_unlock_achievements(db: Session, user_id: int) -> List[Dict[str, Any]]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return []

        unlocked_list = []
        
        # Helper to check if already unlocked
        def is_unlocked(slug: str) -> bool:
            return db.query(UserAchievement).filter(
                UserAchievement.user_id == user_id,
                UserAchievement.achievement_slug == slug
            ).first() is not None

        # Helper to create achievement
        def unlock(slug: str, title: str, desc: str, icon: str):
            if not is_unlocked(slug):
                new_ach = UserAchievement(
                    user_id=user_id,
                    achievement_slug=slug,
                    title=title,
                    description=desc,
                    icon=icon
                )
                db.add(new_ach)
                
                # Award bonus XP/Coins
                GamificationService.award_xp_and_coins(
                    db, user_id, xp_amount=300, coins_amount=30, source=f"Achievement Unlocked: {title}"
                )
                unlocked_list.append({"slug": slug, "title": title, "icon": icon})

        # 1. Level Up checks
        if profile.level >= 5:
            unlock("level_5", "Level Explorer", "Achieve Level 5 in RecommRead.", "🚀")
        if profile.level >= 10:
            unlock("level_10", "Level Practitioner", "Achieve Level 10 in RecommRead.", "🛡️")

        # 2. Streak checks
        if profile.streak >= 7:
            unlock("streak_7", "7 Day Streak Master", "Maintain a continuous 7-day consistency streak.", "🔥")
        if profile.streak >= 30:
            unlock("streak_30", "30 Day Streak Champion", "Maintain a continuous 30-day consistency streak.", "👑")

        # 3. Coding Problems count
        solved_qs = db.query(UserQuestionProgress).filter(
            UserQuestionProgress.user_id == user_id,
            UserQuestionProgress.status == "solved"
        ).count()
        if solved_qs >= 1:
            unlock("first_problem", "First Problem Solved", "Successfully execute compile checks on your first coding practice challenge.", "🧩")
        if solved_qs >= 10:
            unlock("coding_10", "Code Enthusiast", "Solve 10 algorithm coding practice questions.", "💻")

        # 4. Projects count
        completed_projs = db.query(UserProjectProgress).filter(
            UserProjectProgress.user_id == user_id,
            UserProjectProgress.status == "completed"
        ).count()
        if completed_projs >= 1:
            unlock("first_project", "First Portfolio project", "Complete your first dynamic developer project track.", "💼")

        # 5. Interview checks
        rounds = db.query(UserInterviewRound).filter(
            UserInterviewRound.user_id == user_id,
            UserInterviewRound.overall_score >= 85.0
        ).count()
        if rounds >= 1:
            unlock("interview_master", "Interview Master", "Pass any mock interview simulation with an overall score above 85%.", "🎤")

        if unlocked_list:
            db.commit()
            
        return unlocked_list

    @staticmethod
    def get_user_statistics(db: Session, user_id: int) -> Dict[str, Any]:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return {}

        solved_qs = db.query(UserQuestionProgress).filter(
            UserQuestionProgress.user_id == user_id,
            UserQuestionProgress.status == "solved"
        ).count()
        
        completed_projs = db.query(UserProjectProgress).filter(
            UserProjectProgress.user_id == user_id,
            UserProjectProgress.status == "completed"
        ).count()

        completed_resources = db.query(UserResourceProgress).filter(
            UserResourceProgress.user_id == user_id,
            UserResourceProgress.is_completed == True
        ).count()

        rounds = db.query(UserInterviewRound).filter(UserInterviewRound.user_id == user_id).all()
        avg_interview = sum(r.overall_score for r in rounds) / len(rounds) if rounds else 74.0

        completed_missions = db.query(UserProgress).filter(
            UserProgress.user_id == user_id,
            UserProgress.item_type == "mission",
            UserProgress.status == "completed"
        ).count()

        return {
            "learning_hours": round(15.4 + (profile.xp / 1000.0), 1),
            "xp": profile.xp,
            "coins": profile.coins,
            "completed_missions": completed_missions,
            "completed_projects": completed_projs,
            "completed_coding_questions": solved_qs,
            "completed_courses": completed_resources // 3,
            "completed_documentation": completed_resources,
            "interview_score": round(avg_interview, 1),
            "quiz_accuracy": 82.5,
            "career_progress_percentage": min(100.0, round(completed_projs * 25.0 + solved_qs * 5.0, 1))
        }
