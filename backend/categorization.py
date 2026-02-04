from __future__ import annotations
from dataclasses import dataclass
from typing import Optional


@dataclass
class CategorizationResult:
    category: str
    confidence: float
    method: str


# Keyword-Based Rules
KEYWORD_TO_CATEGORY = {
    # coffee
    "starbucks": "coffee",
    "dunkin": "coffee",
    "coffee": "coffee",

    # groceries / retail
    "walmart": "groceries",
    "target": "groceries",
    "aldi": "groceries",
    "costco" : "groceries",

    # transport
    "uber": "transport",
    "lyft": "transport",
    "shell": "gas",
    "exxon": "gas",

    # food
    "mcdonald": "food",
    "chipotle": "food",
    "restaurant": "food",

    # utilities
    "duke energy": "utilities",
    "spectrum": "utilities",
    "verizon": "utilities",
    "at&t": "utilities",

    # rent/housing
    "rent": "rent",
    "apartment": "rent",
}

# Normalizes transaction description for consistent matching.
def _normalize_text(text: str) -> str:
    return " ".join(text.lower().strip().split())



# Attempts to categorize a transaction using deterministic rules.
def categorize_transaction(
    description: str,
    amount: Optional[float] = None
) -> CategorizationResult:

    # Step 1: Normalize description
    normalized_description = _normalize_text(description)

    # Step 2: Attempt keyword-based matching
    for keyword, category in KEYWORD_TO_CATEGORY.items():
        if keyword in normalized_description:
            return CategorizationResult(
                category=category,
                confidence=0.90, 
                method="rules",
            )

    # Step 3: If no rule matched, return fallback
    return CategorizationResult(
        category="uncategorized",
        confidence=0.20,
        method="rules",
    )
