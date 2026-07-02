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
