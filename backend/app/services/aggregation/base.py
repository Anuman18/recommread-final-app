from abc import ABC, abstractmethod
from typing import List, Dict, Any

class BaseProvider(ABC):
    @property
    @abstractmethod
    def provider_name(self) -> str:
        pass

    @abstractmethod
    def fetch_resources(self, career_slug: str, query: str = "", limit: int = 10) -> List[Dict[str, Any]]:
        """
        Fetch learning resources matching query/career.
        Should return a list of dictionaries with standard keys:
        - title, description, thumbnail_url, url, provider, difficulty,
          estimated_learning_time_min, language, tags, career_slug,
          skills, topic, popularity_score, published_date
        """
        pass
