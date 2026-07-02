from abc import ABC, abstractmethod
from typing import List, Dict, Any, Generator

class BaseLLMProvider(ABC):
    @abstractmethod
    def generate_text(self, system_prompt: str, prompt: str, history: List[Dict[str, str]] = None) -> str:
        """
        Sends system prompt, user prompt, and conversation history to the model, returning the text reply.
        """
        pass

    @abstractmethod
    def generate_stream(self, system_prompt: str, prompt: str, history: List[Dict[str, str]] = None) -> Generator[str, None, None]:
        """
        Sends system prompt, user prompt, and conversation history to the model, yielding text chunks.
        """
        pass
