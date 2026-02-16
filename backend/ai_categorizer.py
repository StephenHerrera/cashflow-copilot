# This module is responsible for AI-based categorization.
import os
from dataclasses import dataclass
from typing import Optional, List
from openai import OpenAI


@dataclass
class AICategorizationResult:
    category: str
    confidence: float
    method: str = "ai"

DEFAULT_ALLOWED_CATEGORIES: List[str] = [
    "coffee",
    "groceries",
    "transport",
    "utilities",
    "rent",
    "food",
    "gas",
    "shopping",
    "subscriptions",
    "entertainment",
    "income",
    "uncategorized",
]

# Calls OpenAI to categorize a transaction description.
def ai_categorize_transaction(
    description: str,
    amount: Optional[float] = None,
    allowed_categories: Optional[List[str]] = None,
) -> AICategorizationResult:
    enable_ai = os.getenv("ENABLE_AI_CATEGORIZATION", "false").lower() == "true"
    if not enable_ai:
        return AICategorizationResult(category="uncategorized", confidence=0.0, method="rules")


    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        return AICategorizationResult(category="uncategorized", confidence=0.0, method="rules")


    model = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
    categories = allowed_categories or DEFAULT_ALLOWED_CATEGORIES

    client = OpenAI(api_key=api_key)

        # Build a strict JSON Schema for the model to follow
    json_schema_format = {
        "type": "json_schema",
        "name": "transaction_category",
        "strict": True,
        "schema": {
            "type": "object",
            "properties": {
                "category": {"type": "string", "enum": categories},
                "confidence": {"type": "number", "minimum": 0.0, "maximum": 1.0},
            },
            "required": ["category", "confidence"],
            "additionalProperties": False,
        },
    }

    user_text = (
        f"Description: {description}\n"
        f"Amount: {amount if amount is not None else 'unknown'}\n"
        "Pick the best category from the allowed list and provide confidence."
    )

    response = client.responses.create(
        model=model,
        input=[
            {
                "role": "system",
                "content": (
                    "You categorize personal finance transactions. "
                    "Return only JSON that matches the provided schema."
                ),
            },
            {"role": "user", "content": user_text},
        ],
        text={"format": json_schema_format},
    )

    import json
    output_text = response.output_text

    try:
        data = json.loads(output_text)
    except json.JSONDecodeError:
        return AICategorizationResult(category="uncategorized", confidence=0.0)

    return AICategorizationResult(
        category=data["category"],
        confidence=float(data["confidence"]),
    )
