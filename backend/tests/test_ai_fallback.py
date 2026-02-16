from fastapi.testclient import TestClient
from unittest.mock import patch

from backend.main import app

client = TestClient(app)

# If rules can categorize the transaction do not call AI falback
def test_ai_not_called_when_rules_match():
    
    payload = {"description": "STARBUCKS 1287", "amount": 7.45}

    with patch("backend.main.ai_categorize_transaction") as mock_ai:
        res = client.post("/categorize", json=payload)

        assert res.status_code == 200
        data = res.json()

        assert data["category"] == "coffee"
        assert data["method"] == "rules"

        mock_ai.assert_not_called()

# If rules return 'uncategorized', the endpoint should attempt AI fallback.
def test_ai_called_when_rules_uncategorized():
   
    payload = {"description": "SOME RANDOM MERCHANT 123", "amount": 12.00}

    fake_ai_result = {
        "category": "shopping",
        "confidence": 0.77,
        "method": "ai",
    }

    with patch("backend.main.ai_categorize_transaction") as mock_ai:
        mock_ai.return_value = type("Obj", (), fake_ai_result)()

        res = client.post("/categorize", json=payload)

        assert res.status_code == 200
        data = res.json()

        assert data["category"] == "shopping"
        assert data["method"] == "ai"
        assert data["confidence"] == 0.77

        mock_ai.assert_called_once()
