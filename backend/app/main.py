from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from .core.config import settings
from .core.database import engine, Base, SessionLocal
from .core.seed import seed_database
from .api.router import api_router

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize SQL database tables on startup
    print("Initializing database tables...")
    Base.metadata.create_all(bind=engine)
    
    # Verify/create onboarding_completed column in profiles table
    with engine.begin() as connection:
        try:
            from sqlalchemy import text
            connection.execute(text("ALTER TABLE profiles ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT FALSE;"))
            connection.execute(text("ALTER TABLE user_resource_progress ADD COLUMN IF NOT EXISTS current_chapter_index INTEGER DEFAULT 0;"))
            connection.execute(text("ALTER TABLE user_resource_progress ADD COLUMN IF NOT EXISTS active_reading_seconds INTEGER DEFAULT 0;"))
            connection.execute(text("ALTER TABLE user_resource_progress ADD COLUMN IF NOT EXISTS bookmarks JSONB;"))
            connection.execute(text("ALTER TABLE user_resource_progress ADD COLUMN IF NOT EXISTS highlights JSONB;"))
            connection.execute(text("ALTER TABLE user_resource_progress ADD COLUMN IF NOT EXISTS notes JSONB;"))
            print("Successfully verified onboarding_completed and reading engine columns.")
        except Exception as e:
            print(f"Error checking/adding db columns: {e}")
    
    # Auto-seed mock data if empty
    db = SessionLocal()
    try:
        seed_database(db)
    finally:
        db.close()
        
    yield

app = FastAPI(
    title=settings.PROJECT_NAME,
    lifespan=lifespan,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# CORS configuration for simulator query calls
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routes
app.include_router(api_router, prefix=settings.API_V1_STR)
app.include_router(api_router, prefix="")

@app.get("/")
def read_root():
    return {"message": f"Welcome to the {settings.PROJECT_NAME} API. Access docs at /docs"}
