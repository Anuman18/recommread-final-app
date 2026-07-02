from typing import List, Dict, Any
from datetime import datetime
from .base import BaseProvider

class DocumentationProvider(BaseProvider):
    @property
    def provider_name(self) -> str:
        return "Official Documentation"

    def fetch_resources(self, career_slug: str, query: str = "", limit: int = 10) -> List[Dict[str, Any]]:
        # Structured static database representing official resources to avoid raw scraping
        docs = [
            {
                "title": "PyTorch Tensor Documentation",
                "description": "Official reference guide explaining PyTorch Tensor API classes, arithmetic operations, and autograd layers.",
                "thumbnail_url": "https://pytorch.org/assets/images/pytorch-logo.png",
                "url": "https://pytorch.org/docs/stable/tensors.html",
                "provider": "PyTorch",
                "difficulty": "Beginner",
                "estimated_learning_time_min": 45,
                "language": "English",
                "tags": ["AI", "Deep Learning", "Tensors"],
                "career_slug": "ai_engineer",
                "skills": ["PyTorch", "Python"],
                "topic": "Tensors",
                "popularity_score": 98.0,
                "published_date": "2025-01-10"
            },
            {
                "title": "Hugging Face Transformers Overview",
                "description": "Guides detailing Pipeline API, PretrainedModels, Tokenizers, and custom model initialization.",
                "thumbnail_url": "https://huggingface.co/front/assets/huggingface_logo.svg",
                "url": "https://huggingface.co/docs/transformers/index",
                "provider": "Hugging Face",
                "difficulty": "Intermediate",
                "estimated_learning_time_min": 60,
                "language": "English",
                "tags": ["AI", "NLP", "LLM"],
                "career_slug": "ai_engineer",
                "skills": ["Transformers", "Hugging Face"],
                "topic": "Transformers",
                "popularity_score": 95.0,
                "published_date": "2025-02-15"
            },
            {
                "title": "MDN Web Docs: CSS Flexbox Guide",
                "description": "Complete reference explaining Flex containers, wrap rules, sizing factors, and alignment parameters.",
                "thumbnail_url": "https://developer.mozilla.org/static/media/mdn-logo-social.png",
                "url": "https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_flexible_box_layout/Basic_concepts_of_flexbox",
                "provider": "MDN Web Docs",
                "difficulty": "Beginner",
                "estimated_learning_time_min": 30,
                "language": "English",
                "tags": ["UI/UX", "Frontend", "CSS"],
                "career_slug": "ux_designer",
                "skills": ["CSS", "Handoff"],
                "topic": "Layouts",
                "popularity_score": 99.0,
                "published_date": "2024-11-20"
            },
            {
                "title": "Pandas DataFrame API Reference",
                "description": "Official docs detailing index alignment, sorting, merges, selections, and missing items filtration.",
                "thumbnail_url": "https://pandas.pydata.org/static/img/pandas_logo.png",
                "url": "https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.html",
                "provider": "Python Documentation",
                "difficulty": "Beginner",
                "estimated_learning_time_min": 40,
                "language": "English",
                "tags": ["Data Science", "Pandas", "Analytics"],
                "career_slug": "data_scientist",
                "skills": ["Pandas", "Python"],
                "topic": "Data Cleaning",
                "popularity_score": 97.0,
                "published_date": "2025-03-01"
            }
        ]
        
        # Filter by career and query
        filtered = [d for d in docs if d["career_slug"] == career_slug]
        if query:
            filtered = [d for d in filtered if query.lower() in d["title"].lower() or query.lower() in d["description"].lower()]
        return filtered[:limit]


class YouTubeProvider(BaseProvider):
    @property
    def provider_name(self) -> str:
        return "YouTube"

    def fetch_resources(self, career_slug: str, query: str = "", limit: int = 10) -> List[Dict[str, Any]]:
        videos = [
            {
                "title": "Andrej Karpathy: Neural Networks Zero to Hero",
                "description": "A complete masterclass on building custom neural nets, backpropagation engine, and GPT transformers from scratch.",
                "thumbnail_url": "https://i.ytimg.com/vi/VMj-3S1tku0/hqdefault.jpg",
                "url": "https://www.youtube.com/watch?v=VMj-3S1tku0",
                "provider": "YouTube",
                "difficulty": "Intermediate",
                "estimated_learning_time_min": 180,
                "language": "English",
                "tags": ["AI", "Neural Networks", "GPT"],
                "career_slug": "ai_engineer",
                "skills": ["Neural Networks", "Python"],
                "topic": "Deep Learning",
                "popularity_score": 99.5,
                "published_date": "2023-10-15"
            },
            {
                "title": "StatQuest: Machine Learning Fundamentals",
                "description": "Excellent visual breakdown of linear regression models, Bias-Variance balance, and SMOTE datasets.",
                "thumbnail_url": "https://i.ytimg.com/vi/Gv9_4yMHFhI/hqdefault.jpg",
                "url": "https://www.youtube.com/watch?v=Gv9_4yMHFhI",
                "provider": "YouTube",
                "difficulty": "Beginner",
                "estimated_learning_time_min": 75,
                "language": "English",
                "tags": ["Data Science", "Statistics", "ML Theory"],
                "career_slug": "data_scientist",
                "skills": ["Statistics", "ML Theory"],
                "topic": "Machine Learning",
                "popularity_score": 96.0,
                "published_date": "2024-05-22"
            },
            {
                "title": "FreeCodeCamp: Figma UI Design Course",
                "description": "Learn Auto layout parameters, interactive micro-animations components, and layout handoff to developers.",
                "thumbnail_url": "https://i.ytimg.com/vi/jwDmEE-1m3M/hqdefault.jpg",
                "url": "https://www.youtube.com/watch?v=jwDmEE-1m3M",
                "provider": "YouTube",
                "difficulty": "Beginner",
                "estimated_learning_time_min": 120,
                "language": "English",
                "tags": ["UI/UX", "Figma", "Design Systems"],
                "career_slug": "ux_designer",
                "skills": ["Figma", "Design Systems"],
                "topic": "UI Design",
                "popularity_score": 94.0,
                "published_date": "2024-08-01"
            }
        ]
        
        filtered = [v for v in videos if v["career_slug"] == career_slug]
        if query:
            filtered = [v for v in filtered if query.lower() in v["title"].lower() or query.lower() in v["description"].lower()]
        return filtered[:limit]


class GitHubProvider(BaseProvider):
    @property
    def provider_name(self) -> str:
        return "GitHub"

    def fetch_resources(self, career_slug: str, query: str = "", limit: int = 10) -> List[Dict[str, Any]]:
        repos = [
            {
                "title": "Awesome Deep Learning tutorials",
                "description": "Curated repository containing tutorial links, sample notebooks, and PyTorch models scripts.",
                "thumbnail_url": "https://github.com/fluidicon.png",
                "url": "https://github.com/awesome-deep-learning/tutorials",
                "provider": "GitHub",
                "difficulty": "Advanced",
                "estimated_learning_time_min": 240,
                "language": "English",
                "tags": ["AI", "Deep Learning", "Research"],
                "career_slug": "ai_engineer",
                "skills": ["PyTorch", "Neural Networks"],
                "topic": "Tensors",
                "popularity_score": 90.0,
                "published_date": "2025-02-28"
            },
            {
                "title": "Data Science Notebooks Templates",
                "description": "Standard notebooks templates for Pandas analysis, cleansing, SMOTE classification, and regression plots.",
                "thumbnail_url": "https://github.com/fluidicon.png",
                "url": "https://github.com/notebooks/data-science-templates",
                "provider": "GitHub",
                "difficulty": "Intermediate",
                "estimated_learning_time_min": 90,
                "language": "English",
                "tags": ["Data Science", "Jupyter", "Pandas"],
                "career_slug": "data_scientist",
                "skills": ["Pandas", "Python"],
                "topic": "Data Cleaning",
                "popularity_score": 88.0,
                "published_date": "2025-01-20"
            }
        ]
        
        filtered = [r for r in repos if r["career_slug"] == career_slug]
        if query:
            filtered = [r for r in filtered if query.lower() in r["title"].lower() or query.lower() in r["description"].lower()]
        return filtered[:limit]
