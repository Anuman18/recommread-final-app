import os
import random
from typing import List, Dict, Any, Generator
import google.generativeai as genai
from openai import OpenAI
from .base import BaseLLMProvider

class MockLLMProvider(BaseLLMProvider):
    def generate_text(self, system_prompt: str, prompt: str, history: List[Dict[str, str]] = None) -> str:
        prompt_lower = prompt.lower()
        
        is_hindi = "hindi" in system_prompt.lower() or "hindi" in prompt_lower
        is_hinglish = "hinglish" in system_prompt.lower() or "hinglish" in prompt_lower
        
        is_ai = "ai_engineer" in system_prompt.lower()
        is_ds = "data_scientist" in system_prompt.lower()
        is_ux = "ux_designer" in system_prompt.lower()

        if "explain" in prompt_lower or "concept" in prompt_lower:
            if is_ds:
                if is_hindi:
                    return "डाटा साइंस में, Gradient Descent एक optimization algorithm है। यह मॉडल के loss function को minimize करने के लिए parameters को adjust करता है।"
                elif is_hinglish:
                    return "Data Science mein, Gradient Descent ek standard optimization loop hai. Loss function ko minimum value tak scroll down karne ke liye weights aur bias adjust kiye jaate hain."
                else:
                    return "In Data Science, Gradient Descent is an iterative optimization algorithm used to minimize a loss function. It updates model coefficients by moving in the direction of the steepest descent."
            elif is_ai:
                if is_hinglish:
                    return "AI Engineers ke liye, Self-Attention mechanism transformers ka core brain hai. Yeh inputs ke different words ke beech key-value mapping score evaluate karta hai."
                else:
                    return "For AI Engineers, the Self-Attention mechanism is the backbone of Transformers. It calculates relevance weights between tokens by computing Query, Key, and Value matrix multiplications."
            else:
                return "In UI/UX Design, Auto Layout allows creators to establish relative constraints, ensuring responsive page rendering across multiple browser dimensions."

        if "coding-hint" in prompt_lower or "hint" in prompt_lower:
            if is_ds:
                return "💡 Pandas DataFrame hint: Use df.dropna(subset=['column']) to clean missing rows, or fill missing cells via df.fillna()."
            elif is_ai:
                return "💡 PyTorch Tensor hint: When scaling shapes, verify that your outer matrix dimensions match: A.shape[1] must equal B.shape[0]. Use tensor.view() or tensor.reshape()."
            else:
                return "💡 UI Code layout hint: When designing Flexboxes, utilize space-between parameters to push adjacent columns to boundary limits."

        if "review-code" in prompt_lower or "code" in prompt_lower:
            return "🔧 Code Review Report:\n- Complexity: O(N) linear iteration speed.\n- Memory: O(1) space footprint.\n- Suggestion: Avoid multiple loops inside DataFrame checks. Prefer vectorized selections."

        if "quiz" in prompt_lower:
            return "📝 Quiz Challenge:\nWhat is the main advantage of L1 Regularization (Lasso) over L2 (Ridge)?\n1. It creates sparse weights (some weights become exactly zero).\n2. It runs faster.\n3. It prevents overfitting.\nCorrect Option: 1."

        if "flashcard" in prompt_lower:
            return "📇 Flashcards Deck:\n- Front: What does SMOTE stand for?\n- Back: Synthetic Minority Over-sampling Technique, used to balance dataset distributions."

        if "revision" in prompt_lower or "revise" in prompt_lower:
            return "🔄 Revision Checklist:\n1. Verify you understand precision-recall curves tradeoffs.\n2. Re-read Pandas user indexing instructions.\n3. Implement 1 simple matrix dot product in NumPy."

        if "interview" in prompt_lower:
            return "🎤 Interview Practice Question:\n'Can you explain the difference between Bagging and Boosting, and when to use Random Forests?'"

        if is_hindi:
            return "नमस्ते! मैं आपका AI Tutor हूँ। आज आप कौन सा टॉपिक सीखना चाहेंगे?"
        elif is_hinglish:
            return "Hello! Main aapka AI Tutor hoon. Aaj hum kaun sa topic deep-dive karenge?"
        else:
            return "Welcome! I am your AI Tutor. Let me know what concepts, code snippets, or interview questions you'd like to explore today."

    def generate_stream(self, system_prompt: str, prompt: str, history: List[Dict[str, str]] = None) -> Generator[str, None, None]:
        text = self.generate_text(system_prompt, prompt, history)
        words = text.split(" ")
        for i, word in enumerate(words):
            yield (word + " ") if i < len(words) - 1 else word


class OpenAIProvider(BaseLLMProvider):
    def __init__(self, api_key: str):
        self.client = OpenAI(api_key=api_key)

    def generate_text(self, system_prompt: str, prompt: str, history: List[Dict[str, str]] = None) -> str:
        messages = [{"role": "system", "content": system_prompt}]
        if history:
            for h in history:
                role = "assistant" if h["role"] == "ai" else "user"
                messages.append({"role": role, "content": h["content"]})
        messages.append({"role": "user", "content": prompt})

        try:
            response = self.client.chat.completions.create(
                model="gpt-4o-mini",
                messages=messages,
                temperature=0.7
            )
            return response.choices[0].message.content or ""
        except Exception as e:
            return f"OpenAI Error: {str(e)}"

    def generate_stream(self, system_prompt: str, prompt: str, history: List[Dict[str, str]] = None) -> Generator[str, None, None]:
        messages = [{"role": "system", "content": system_prompt}]
        if history:
            for h in history:
                role = "assistant" if h["role"] == "ai" else "user"
                messages.append({"role": role, "content": h["content"]})
        messages.append({"role": "user", "content": prompt})

        try:
            stream = self.client.chat.completions.create(
                model="gpt-4o-mini",
                messages=messages,
                temperature=0.7,
                stream=True
            )
            for chunk in stream:
                content = chunk.choices[0].delta.content
                if content:
                    yield content
        except Exception as e:
            yield f"OpenAI Stream Error: {str(e)}"


class GeminiProvider(BaseLLMProvider):
    def __init__(self, api_key: str):
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel("gemini-1.5-flash")

    def generate_text(self, system_prompt: str, prompt: str, history: List[Dict[str, str]] = None) -> str:
        contents = []
        contents.append({"role": "user", "parts": [f"System Instruction: {system_prompt}"]})
        contents.append({"role": "model", "parts": ["Acknowledged. I will strictly follow this guidance."]})

        if history:
            for h in history:
                role = "model" if h["role"] == "ai" else "user"
                contents.append({"role": role, "parts": [h["content"]]})
        contents.append({"role": "user", "parts": [prompt]})

        try:
            response = self.model.generate_content(contents)
            return response.text or ""
        except Exception as e:
            return f"Gemini Error: {str(e)}"

    def generate_stream(self, system_prompt: str, prompt: str, history: List[Dict[str, str]] = None) -> Generator[str, None, None]:
        contents = []
        contents.append({"role": "user", "parts": [f"System Instruction: {system_prompt}"]})
        contents.append({"role": "model", "parts": ["Acknowledged. I will strictly follow this guidance."]})

        if history:
            for h in history:
                role = "model" if h["role"] == "ai" else "user"
                contents.append({"role": role, "parts": [h["content"]]})
        contents.append({"role": "user", "parts": [prompt]})

        try:
            response = self.model.generate_content(contents, stream=True)
            for chunk in response:
                if chunk.text:
                    yield chunk.text
        except Exception as e:
            yield f"Gemini Stream Error: {str(e)}"


def get_provider() -> BaseLLMProvider:
    openai_key = os.getenv("OPENAI_API_KEY", "")
    gemini_key = os.getenv("GEMINI_API_KEY", "")
    if gemini_key:
        return GeminiProvider(api_key=gemini_key)
    elif openai_key:
        return OpenAIProvider(api_key=openai_key)
    else:
        return MockLLMProvider()
