from sqlalchemy.orm import Session
from typing import List, Dict, Any, Optional

from ...models.user import Profile
from ...models.interview import AIChat
from ...services.recommendation import RecommendationService
from .providers import MockLLMProvider
from .base import BaseLLMProvider

class AITutorService:
    def __init__(self, provider: Optional[BaseLLMProvider] = None):
        # Allow pluggable model provider (defaults to Mock/Local)
        self.provider = provider or MockLLMProvider()

    def _assemble_system_prompt(self, db: Session, user_id: int) -> str:
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            return "You are a helpful AI Tutor."
            
        career = profile.career_slug
        level = profile.skill_level
        lang = profile.preferred_language # English, Hindi, Hinglish
        
        weak = RecommendationService.get_weak_skills(db, user_id)
        strong = RecommendationService.get_strong_skills(db, user_id)
        
        system = f"You are RecommRead's AI Tutor. The user is on the '{career}' track.\n"
        system += f"User Skill Level: '{level}'.\n"
        system += f"Language preference: '{lang}'. You must reply strictly in '{lang}'!\n"
        system += f"User's Weak Skills: {', '.join(weak) if weak else 'None'}.\n"
        system += f"User's Strong Skills: {', '.join(strong) if strong else 'None'}.\n"
        system += "Answer questions, explain concepts, and format code hints using these profile constraints."
        
        return system

    def start_chat(self, db: Session, user_id: int, context_type: str, context_id: Optional[str] = None) -> Dict[str, Any]:
        system = self._assemble_system_prompt(db, user_id)
        
        # Query welcome message from model provider
        welcome = self.provider.generate_text(
            system_prompt=system,
            prompt="Hello! Introduce yourself briefly."
        )
        
        # Save greeting log in AIChat
        log = AIChat(
            user_id=user_id,
            context_type=context_type,
            context_id=context_id,
            message_text=welcome,
            sender="ai"
        )
        db.add(log)
        db.commit()
        db.refresh(log)
        
        return {
            "chat_id": log.id,
            "message": welcome,
            "sender": "ai",
            "timestamp": log.timestamp.isoformat()
        }

    def continue_chat(
        self,
        db: Session,
        user_id: int,
        context_type: str,
        context_id: Optional[str],
        message_text: str
    ) -> Dict[str, Any]:
        system = self._assemble_system_prompt(db, user_id)
        
        # Save user message
        user_log = AIChat(
            user_id=user_id,
            context_type=context_type,
            context_id=context_id,
            message_text=message_text,
            sender="user"
        )
        db.add(user_log)
        db.commit()
        
        # Retrieve past conversation history logs for context
        history_logs = db.query(AIChat).filter(
            AIChat.user_id == user_id,
            AIChat.context_type == context_type,
            AIChat.context_id == context_id
        ).order_by(AIChat.timestamp.desc()).limit(10).all()
        
        history_list = [{"role": h.sender, "content": h.message_text} for h in reversed(history_logs)]
        
        # Generate response
        reply = self.provider.generate_text(
            system_prompt=system,
            prompt=message_text,
            history=history_list
        )
        
        # Save AI reply
        ai_log = AIChat(
            user_id=user_id,
            context_type=context_type,
            context_id=context_id,
            message_text=reply,
            sender="ai"
        )
        db.add(ai_log)
        db.commit()
        db.refresh(ai_log)
        
        return {
            "chat_id": ai_log.id,
            "message": reply,
            "sender": "ai",
            "timestamp": ai_log.timestamp.isoformat()
        }

    def generate_explanation(self, db: Session, user_id: int, concept: str) -> str:
        system = self._assemble_system_prompt(db, user_id)
        return self.provider.generate_text(
            system_prompt=system,
            prompt=f"Explain concept: {concept}"
        )

    def generate_summary(self, db: Session, user_id: int, resource_title: str) -> str:
        system = self._assemble_system_prompt(db, user_id)
        return self.provider.generate_text(
            system_prompt=system,
            prompt=f"Generate a clear summary of resource: {resource_title}"
        )

    def generate_quiz(self, db: Session, user_id: int, topic: str) -> str:
        system = self._assemble_system_prompt(db, user_id)
        return self.provider.generate_text(
            system_prompt=system,
            prompt=f"Generate a multiple choice quiz challenge for topic: {topic}"
        )

    def generate_flashcards(self, db: Session, user_id: int, topic: str) -> str:
        system = self._assemble_system_prompt(db, user_id)
        return self.provider.generate_text(
            system_prompt=system,
            prompt=f"Generate a flashcards deck for topic: {topic}"
        )

    def generate_revision(self, db: Session, user_id: int) -> str:
        system = self._assemble_system_prompt(db, user_id)
        return self.provider.generate_text(
            system_prompt=system,
            prompt="Generate a customized revision list of weak skills."
        )

    def generate_coding_hint(self, db: Session, user_id: int, question_title: str) -> str:
        system = self._assemble_system_prompt(db, user_id)
        return self.provider.generate_text(
            system_prompt=system,
            prompt=f"Generate coding-hint for question: {question_title}"
        )

    def review_code(self, db: Session, user_id: int, question_title: str, code: str) -> str:
        system = self._assemble_system_prompt(db, user_id)
        return self.provider.generate_text(
            system_prompt=system,
            prompt=f"Review code for question '{question_title}':\n```\n{code}\n```"
        )

    def generate_interview_questions(self, db: Session, user_id: int, type_name: str) -> str:
        system = self._assemble_system_prompt(db, user_id)
        return self.provider.generate_text(
            system_prompt=system,
            prompt=f"Generate mock interview question for type: {type_name}"
        )

    def generate_daily_advice(self, db: Session, user_id: int) -> str:
        system = self._assemble_system_prompt(db, user_id)
        return self.provider.generate_text(
            system_prompt=system,
            prompt="Welcome the user and give them quick advice for the day."
        )

# Global singleton tutor service
ai_tutor_service = AITutorService()
