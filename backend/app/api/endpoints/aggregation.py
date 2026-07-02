from fastapi import APIRouter, Depends, Query
from typing import List, Dict, Any, Optional

from ...core.database import get_db
from ...api.deps import get_current_user
from ...models.user import User
from ...services.aggregation.service import aggregation_service

router = APIRouter()

@router.get("/docs", response_model=Dict[str, Any])
def get_official_docs(
    career: str = Query(..., description="Career goal slug e.g. ai_engineer"),
    query: str = Query("", description="Keyword search query"),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1),
    current_user: User = Depends(get_current_user)
):
    return aggregation_service.aggregate_resources(
        career_slug=career,
        query=query,
        provider_filter="Official Documentation",
        page=page,
        page_size=page_size
    )

@router.get("/youtube", response_model=Dict[str, Any])
def get_youtube_resources(
    career: str = Query(..., description="Career goal slug e.g. ai_engineer"),
    query: str = Query("", description="Keyword search query"),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1),
    current_user: User = Depends(get_current_user)
):
    return aggregation_service.aggregate_resources(
        career_slug=career,
        query=query,
        provider_filter="YouTube",
        page=page,
        page_size=page_size
    )

@router.get("/github", response_model=Dict[str, Any])
def get_github_resources(
    career: str = Query(..., description="Career goal slug e.g. ai_engineer"),
    query: str = Query("", description="Keyword search query"),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1),
    current_user: User = Depends(get_current_user)
):
    return aggregation_service.aggregate_resources(
        career_slug=career,
        query=query,
        provider_filter="GitHub",
        page=page,
        page_size=page_size
    )

@router.get("/courses", response_model=Dict[str, Any])
def get_courses(
    career: str = Query(..., description="Career goal slug e.g. ai_engineer"),
    query: str = Query("", description="Keyword search query"),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1),
    current_user: User = Depends(get_current_user)
):
    # Standard courses catalog
    courses = [
        {
            "title": "Deep Learning Specialization (Coursera)",
            "description": "Andrew Ng's flagship deep learning course series detailing Neural Networks backprop and Transformers models.",
            "thumbnail_url": "https://coursera.org/logo.png",
            "url": "https://coursera.org/specialization/deep-learning",
            "provider": "Coursera",
            "difficulty": "Intermediate",
            "estimated_learning_time_min": 2400,
            "language": "English",
            "tags": ["AI", "Neural Networks"],
            "career_slug": "ai_engineer",
            "skills": ["Neural Networks"],
            "topic": "Deep Learning",
            "popularity_score": 99.0,
            "published_date": "2024-01-01"
        },
        {
            "title": "Introduction to Machine Learning (Udacity)",
            "description": "High-quality introduction to algorithms, regression analysis, classification, and data parsing cleansing.",
            "thumbnail_url": "https://udacity.com/logo.png",
            "url": "https://udacity.com/course/intro-to-ml",
            "provider": "Udacity",
            "difficulty": "Beginner",
            "estimated_learning_time_min": 1800,
            "language": "English",
            "tags": ["Data Science", "ML Theory"],
            "career_slug": "data_scientist",
            "skills": ["ML Theory"],
            "topic": "Machine Learning",
            "popularity_score": 93.0,
            "published_date": "2024-02-15"
        }
    ]
    filtered = [c for c in courses if c["career_slug"] == career]
    if query:
        filtered = [c for c in filtered if query.lower() in c["title"].lower() or query.lower() in c["description"].lower()]
    
    total = len(filtered)
    start_idx = (page - 1) * page_size
    paginated = filtered[start_idx:start_idx+page_size]
    
    return {
        "total_count": total,
        "page": page,
        "page_size": page_size,
        "results": paginated
    }

@router.get("/blogs", response_model=Dict[str, Any])
def get_blogs(
    career: str = Query(..., description="Career goal slug e.g. ai_engineer"),
    query: str = Query("", description="Keyword search query"),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1),
    current_user: User = Depends(get_current_user)
):
    blogs = [
        {
            "title": "Lilian Weng: LLM Agents Overview",
            "description": "In-depth blog post detailing reasoning loops, planning algorithms, tool usage integrations, and prompt architectures.",
            "thumbnail_url": "https://lilianweng.github.io/logo.png",
            "url": "https://lilianweng.github.io/posts/2023-06-23-agent/",
            "provider": "Lil'Log",
            "difficulty": "Advanced",
            "estimated_learning_time_min": 60,
            "language": "English",
            "tags": ["AI", "Agents", "Prompting"],
            "career_slug": "ai_engineer",
            "skills": ["Transformers"],
            "topic": "Transformers",
            "popularity_score": 98.0,
            "published_date": "2023-06-23"
        }
    ]
    filtered = [b for b in blogs if b["career_slug"] == career]
    if query:
        filtered = [b for b in filtered if query.lower() in b["title"].lower() or query.lower() in b["description"].lower()]
    
    total = len(filtered)
    start_idx = (page - 1) * page_size
    paginated = filtered[start_idx:start_idx+page_size]
    
    return {
        "total_count": total,
        "page": page,
        "page_size": page_size,
        "results": paginated
    }

@router.get("/papers", response_model=Dict[str, Any])
def get_research_papers(
    career: str = Query(..., description="Career goal slug e.g. ai_engineer"),
    query: str = Query("", description="Keyword search query"),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1),
    current_user: User = Depends(get_current_user)
):
    papers = [
        {
            "title": "Attention Is All You Need",
            "description": "The seminal paper introducing Transformer networks, multi-head self-attention, and sequence-to-sequence translation optimization.",
            "thumbnail_url": "https://arxiv.org/logo.png",
            "url": "https://arxiv.org/abs/1706.03762",
            "provider": "arXiv",
            "difficulty": "Advanced",
            "estimated_learning_time_min": 120,
            "language": "English",
            "tags": ["AI", "Transformers", "Math"],
            "career_slug": "ai_engineer",
            "skills": ["Transformers", "Neural Networks"],
            "topic": "Transformers",
            "popularity_score": 99.9,
            "published_date": "2017-06-12"
        }
    ]
    filtered = [p for p in papers if p["career_slug"] == career]
    if query:
        filtered = [p for p in filtered if query.lower() in p["title"].lower() or query.lower() in p["description"].lower()]
    
    total = len(filtered)
    start_idx = (page - 1) * page_size
    paginated = filtered[start_idx:start_idx+page_size]
    
    return {
        "total_count": total,
        "page": page,
        "page_size": page_size,
        "results": paginated
    }

@router.get("/search", response_model=Dict[str, Any])
def search_resources(
    career: str = Query(..., description="Career goal slug e.g. ai_engineer"),
    query: str = Query("", description="Search term keyword"),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1),
    current_user: User = Depends(get_current_user)
):
    return aggregation_service.aggregate_resources(
        career_slug=career,
        query=query,
        page=page,
        page_size=page_size
    )

@router.get("/filter", response_model=Dict[str, Any])
def filter_resources(
    career: str = Query(..., description="Career goal slug e.g. ai_engineer"),
    provider: Optional[str] = Query(None, description="Filter by provider name"),
    difficulty: Optional[str] = Query(None, description="Filter by difficulty level e.g. Beginner"),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1),
    current_user: User = Depends(get_current_user)
):
    return aggregation_service.aggregate_resources(
        career_slug=career,
        provider_filter=provider,
        difficulty_filter=difficulty,
        page=page,
        page_size=page_size
    )
