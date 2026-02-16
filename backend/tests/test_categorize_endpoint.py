from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)


def test_categorize_endpoint_rules_match():
    payload = {"description": "STARBUCKS 1287 WILMINGTON NC", "amount": 7.45}
    res = client.post("/categorize", json=payload)

    assert res.status_code == 200
    data = res.json()

    assert data["category"] == "coffee"
    assert data["method"] == "rules"
    assert data["confidence"] >= 0.8


def test_categorize_endpoint_unknown_returns_uncategorized():
    payload = {"description": "SOME RANDOM MERCHANT 123", "amount": 12.00}
    res = client.post("/categorize", json=payload)

    assert res.status_code == 200
    data = res.json()

    assert data["category"] == "uncategorized"
    assert data["method"] == "rules"
    assert data["confidence"] <= 0.3
