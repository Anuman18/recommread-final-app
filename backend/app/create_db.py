from app.core.database import engine, Base, SessionLocal
from app.core.seed import seed_database
# Import models to ensure they are registered with Base
from app.models.user import User, Profile, UserSettings, UserAchievement
from app.models.career import Career, Topic, Resource, UserResourceProgress, Project, ProjectMilestone, UserProjectProgress, UserMilestoneProgress
from app.models.coding import CodingQuestion, UserQuestionProgress
from app.models.interview import InterviewType, InterviewQuestion, UserInterviewRound, InterviewQuestionFeedback

def init_db():
    print("Creating tables in PostgreSQL...")
    Base.metadata.create_all(bind=engine)
    
    print("Seeding database...")
    db = SessionLocal()
    try:
        seed_database(db)
    finally:
        db.close()
    print("Database initialization complete.")

if __name__ == "__main__":
    init_db()
