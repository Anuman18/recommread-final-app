from fastapi import APIRouter
from .endpoints import auth, profile, resources, projects, coding, interview, leaderboard, recommendations, aggregation

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(profile.router, prefix="/profile", tags=["profile"])
api_router.include_router(resources.router, prefix="/resources", tags=["resources"])
api_router.include_router(projects.router, prefix="/projects", tags=["projects"])
api_router.include_router(coding.router, prefix="/coding", tags=["coding"])
api_router.include_router(interview.router, prefix="/interviews", tags=["interview"])
api_router.include_router(leaderboard.router, prefix="/leaderboards", tags=["leaderboards"])
api_router.include_router(recommendations.router, prefix="/recommendations", tags=["recommendations"])
api_router.include_router(aggregation.router, prefix="/aggregation", tags=["aggregation"])
