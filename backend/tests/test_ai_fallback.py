from fastapi.testclient import TestClient
from unittest.mock import patch

from backend.main import app

client = TestClient(app)


def test_ai_not_called_when_rules_match():
    """
    If rules can categorize the transaction (e.g., Starbucks -> coffee),
    we should NOT call the AI function at all.
    """
    payload = {"description": "STARBUCKS 1287", "amount": 7.45}

    # Patch the AI function where it is USED (backend.main),
    # not where it is defined.
    with patch("backend.main.ai_categorize_transaction") as mock_ai:
        res = client.post("/categorize", json=payload)

        assert res.status_code == 200
        data = res.json()

        assert data["category"] == "coffee"
        assert data["method"] == "rules"

        # AI should not be called because rules already succeeded
        mock_ai.assert_not_called()


def test_ai_called_when_rules_uncategorized():
    """
    If rules return 'uncategorized', the endpoint should attempt AI fallback.
    We'll mock the AI response so the test never calls the network.
    """
    payload = {"description": "SOME RANDOM MERCHANT 123", "amount": 12.00}

    fake_ai_result = {
        "category": "shopping",
        "confidence": 0.77,
        "method": "ai",
    }

    with patch("backend.main.ai_categorize_transaction") as mock_ai:
        # Configure our mock to return a fake object with attributes
        # that match what the real function returns.
        mock_ai.return_value = type("Obj", (), fake_ai_result)()

        res = client.post("/categorize", json=payload)

        assert res.status_code == 200
        data = res.json()

        assert data["category"] == "shopping"
        assert data["method"] == "ai"
        assert data["confidence"] == 0.77

        # AI should have been called exactly once
        mock_ai.assert_called_once()
