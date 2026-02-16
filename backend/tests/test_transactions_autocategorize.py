from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)


def test_add_transaction_autocategorizes_when_category_missing():
    payload = {
        "amount": -7.45,
        "description": "STARBUCKS 1287",
        "date": "2026-02-04"
        # category omitted on purpose
    }

    res = client.post("/transactions", json=payload)
    assert res.status_code == 200

    # Now fetch transactions and confirm category was saved as "coffee"
    res2 = client.get("/transactions")
    assert res2.status_code == 200
    rows = res2.json()

    assert len(rows) == 1
    assert rows[0]["category"] == "coffee"


def test_add_transaction_respects_category_if_provided():
    payload = {
        "amount": -20.00,
        "description": "Some restaurant",
        "category": "  FooD  ",
        "date": "2026-02-04"
    }

    res = client.post("/transactions", json=payload)
    assert res.status_code == 200

    res2 = client.get("/transactions")
    assert res2.status_code == 200
    rows = res2.json()

    assert len(rows) == 1
    assert rows[0]["category"] == "food"