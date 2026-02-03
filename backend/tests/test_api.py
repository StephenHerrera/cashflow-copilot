from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)

# Test case 1 
def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

# Test case 2
def test_create_transaction_and_summary():
    # Create a transaction
    response = client.post("/transactions", json={
        "amount": -50,
        "description": "Groceries",
        "category": "Food",
        "date": "2026-03-01"
    })

    assert response.status_code == 200

    # Get summary for March 2026
    summary = client.get("/summary?month=2026-03")

    assert summary.status_code == 200

    data = summary.json()

    assert data["total_expenses"] == 50
    assert data["net"] == -50
    assert data["by_category"]["food"] == 50

# Test case 3 
def test_budget_overage_detection():
    # Create transaction (spend $80)
    client.post("/transactions", json={
        "amount": -80,
        "description": "Dinner",
        "category": "Food",
        "date": "2026-04-01"
    })

    # Set budget for April
    client.post("/budgets", json={
        "month": "2026-04",
        "category": "Food",
        "limit_amount": 60
    })

    # Get summary for April
    summary = client.get("/summary?month=2026-04")
    data = summary.json()

    assert data["budget_status"]["food"]["limit"] == 60
    assert data["budget_status"]["food"]["spent"] == 80
    assert data["budget_status"]["food"]["remaining"] == -20
    assert data["budget_status"]["food"]["percentage_used"] == 133.33 or data["budget_status"]["food"]["percentage_used"] == 133.3 or data["budget_status"]["food"]["percentage_used"] == 133
    assert "food" in data["over_budget"]

# Test case 4
def test_trend_endpoint_groups_by_month():
    # 1) Create transactions across multiple months
    # January: +500 income, -200 expense
    client.post("/transactions", json={
        "amount": 500,
        "description": "Paycheck",
        "category": "Income",
        "date": "2026-01-15"
    })
    client.post("/transactions", json={
        "amount": -200,
        "description": "Rent",
        "category": "Rent",
        "date": "2026-01-20"
    })

    # February: -75 expense
    client.post("/transactions", json={
        "amount": -75,
        "description": "Groceries",
        "category": "Food",
        "date": "2026-02-01"
    })

    # 2) Call /trend
    response = client.get("/trend")
    assert response.status_code == 200

    data = response.json()

    # 3) Make sure we got 2 months back, in sorted order
    assert len(data) == 2
    assert data[0]["month"] == "2026-01"
    assert data[1]["month"] == "2026-02"

    # 4) Verify January totals
    jan = data[0]
    assert jan["income"] == 500
    assert jan["expenses"] == 200
    assert jan["net"] == 300

    # 5) Verify February totals
    feb = data[1]
    assert feb["income"] == 0
    assert feb["expenses"] == 75
    assert feb["net"] == -75