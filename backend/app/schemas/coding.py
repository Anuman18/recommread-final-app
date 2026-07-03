from pydantic import BaseModel
from typing import Optional, List, Dict, Any

class CodingQuestionResponse(BaseModel):
    id: str
    topic_id: str
    title: str
    difficulty: str
    companies: Optional[List[str]] = None
    time_min: int
    xp_reward: int
    coins_reward: int
    hints: Optional[List[str]] = None
    problem_statement: str
    examples: Optional[List[Dict[str, Any]]] = None
    constraints: Optional[List[str]] = None
    expected_output: str
    editorial: Optional[str] = None
    doc_url: Optional[str] = None
    video_url: Optional[str] = None
    status: str = "unsolved" # unsolved, in_progress, solved
    attempts: int = 0
    runtime_ms: int = 0
    memory_mb: float = 0.0
    language: Optional[str] = None
    submission_history: Optional[List[Dict[str, Any]]] = None

    class Config:
        from_attributes = True

class CodeSubmission(BaseModel):
    language: str
    user_code: str
    is_submit: bool = True

class SubmissionResultResponse(BaseModel):
    passed_all: bool
    passed_test_cases: int
    total_test_cases: int
    execution_time_ms: int
    memory_usage_mb: float
    xp_earned: int
    coins_earned: int
    feedback: str

class LeaderboardEntryResponse(BaseModel):
    rank: int
    name: str
    xp: int
    avatar: str
    is_me: bool = False
