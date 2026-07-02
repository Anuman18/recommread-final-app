from pydantic import BaseModel
from typing import Optional, List

class InterviewTypeResponse(BaseModel):
    id: str
    name: str
    description: str
    icon: str
    question_count: int
    duration_min: int

    class Config:
        from_attributes = True

class InterviewQuestionResponse(BaseModel):
    id: str
    text: str
    difficulty: str
    topic: str

    class Config:
        from_attributes = True

class AnswerSubmission(BaseModel):
    answer: str
    is_mock_voice: bool = False
    is_mock_video: bool = False

class QuestionFeedbackResponse(BaseModel):
    question_text: str
    user_answer: str
    communication_score: int
    technical_score: int
    confidence_score: int
    problem_solving_score: int
    overall_rating: float
    feedback_text: str
    improvement_suggestions: List[str]

    class Config:
        from_attributes = True

class InterviewReportResponse(BaseModel):
    id: str
    type_name: str
    overall_score: float
    strengths: List[str]
    weak_areas: List[str]
    topics_to_revise: List[str]
    recommended_projects: List[str]
    recommended_coding: List[str]
    xp_gained: int
    coins_gained: int

    class Config:
        from_attributes = True

class InterviewHistoryResponse(BaseModel):
    id: str
    type_name: str
    date: str
    score: float
    readiness_gained: float

    class Config:
        from_attributes = True
