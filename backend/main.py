from fastapi import FastAPI
from pydantic import BaseModel
from .database import engine, Base, SessionLocal
from .models import TransactionDB, BudgetDB
from datetime import date, datetime
from .categorization import categorize_transaction
from .schemas import CategorizeRequest, CategorizeResponse
from .ai_categorizer import ai_categorize_transaction

# Main server object that will handle incoming requests
app = FastAPI()

# Create database tables if they do not already exist
Base.metadata.create_all(bind=engine)

# Creating data model to only accept valid input from the user
class Transaction(BaseModel):
    amount: float
    description: str
    category: str
    date: date

# Creating data model to only accept valid input from the user
class Budget(BaseModel):
    month: str
    category: str
    limit_amount: float

# Creates a new database session
def get_db():
    return SessionLocal()

# Health check endpoint
@app.get("/health")
def health_check():
    return {"status": "ok"}

# Get all transactions.
@app.get("/transactions")
def get_transactions():
    db = get_db()
    # Query all rows from the transactions table
    rows = db.query(TransactionDB).all()
    db.close()

    # Convert database objects into plain dictionaries for JSON response
    return [
        {
            "id": row.id,
            "amount": row.amount,
            "description": row.description,
            "category": row.category,
            "date": row.date.isoformat()
        }
        for row in rows
    ]

# Accepts a Transaction object and saves it to the database
@app.post("/transactions")
def add_transaction(transaction: Transaction):
    db = get_db()

    # Create a new database row using validated input data
    new_transaction = TransactionDB(
        amount=transaction.amount,
        description=transaction.description,
        category=transaction.category,
        date=transaction.date
    )

    db.add(new_transaction)
    db.commit()
    db.refresh(new_transaction)
    db.close()

    return {
        "message": "Transaction added",
        "id": new_transaction.id
    }
@app.get("/budgets")
def get_budgets(month: str | None = None):
    db = get_db()
    query = db.query(BudgetDB)

    if month:
        query = query.filter(BudgetDB.month == month)

    rows = query.all()
    db.close()

    return [
        {
            "id": row.id,
            "month": row.month,
            "category": row.category,
            "limit_amount": row.limit_amount
        }
        for row in rows
    ]

@app.post("/budgets")
def set_budget(budget: Budget):
    db = get_db()

    month = budget.month.strip()
    category = budget.category.strip().lower()

    # Validate month format (must be YYYY-MM)
    try:
        datetime.strptime(month, "%Y-%m")
    except ValueError:
        db.close()
        return {"error": "Month must be in YYYY-MM format (example: 2026-02)"}

    existing = db.query(BudgetDB).filter(
        BudgetDB.month == month,
        BudgetDB.category == category
    ).first()

    if existing:
        existing.limit_amount = budget.limit_amount
        db.commit()
        db.close()
        return {"message": "Budget updated"}

    new_budget = BudgetDB(
        month=month,
        category=category,
        limit_amount=budget.limit_amount
    )

    db.add(new_budget)
    db.commit()
    db.refresh(new_budget)
    db.close()

    return {"message": "Budget created", "id": new_budget.id}

# Display summary of of all transaction
@app.get("/summary")
def get_summary(month: str | None = None):
    db = get_db()
    rows = db.query(TransactionDB).all()
   
   # Filtering by month if provided
    if month:
        rows = [                
            row for row in rows
            if row.date.strftime("%Y-%m") == month
        ]

    total_income = 0
    total_expenses = 0
    by_category = {}

    for row in rows:
        amt = row.amount

        # Income vs Expense
        if amt >= 0:
            total_income += amt
        else:
            total_expenses += abs(amt)

        # Normalizing category names
        cat = row.category.strip().lower()
        if cat not in by_category:
            by_category[cat] = 0
        by_category[cat] += abs(amt)

    net = total_income - total_expenses

    # Budget check
    budget_status = {}
    over_budget = []

    if month:
        budget_rows = db.query(BudgetDB).filter(BudgetDB.month == month).all()

        # Turn budget rows into a lookup dictionary:
        budget_limits = {b.category: b.limit_amount for b in budget_rows}

        for cat, spent in by_category.items():
            limit_amt = budget_limits.get(cat)

             # Only compare categories that actually have a budget set
            if limit_amt is not None:
                remaining = limit_amt - spent

                percentage_used = 0
                if limit_amt > 0:
                    percentage_used = round((spent / limit_amt) * 100, 2)


                budget_status[cat] = {
                    "limit": limit_amt,
                    "spent": spent,
                    "remaining": remaining,
                    "percentage_used": percentage_used
                }

                if remaining < 0:
                    over_budget.append(cat)
    db.close()

    return {
        "total_income": total_income,
        "total_expenses": total_expenses,
        "net": net,
        "by_category": by_category,
        "transaction_count": len(rows),
        "month_filtered": month,
        "budget_status": budget_status,
        "over_budget": over_budget
    }

# Monthly trend endpoint
@app.get("/trend")
def get_trend(months: int | None = None):
    db = get_db()
    rows = db.query(TransactionDB).all()
    db.close()

    # formatting: {"2026-02": {"income": 0, "expenses": 0}}
    trend = {}

    for row in rows:
        month = row.date.strftime("%Y-%m")
        amt = row.amount

        if month not in trend:
            trend[month] = {"income": 0, "expenses": 0}

        if amt >= 0:
            trend[month]["income"] += amt
        else:
            trend[month]["expenses"] += abs(amt)

    # Convert to sorted list so frontend gets clean chart data
    result = []
    for month in sorted(trend.keys()):
        income = trend[month]["income"]
        expenses = trend[month]["expenses"]
        result.append({
            "month": month,
            "income": income,
            "expenses": expenses,
            "net": income - expenses
        })

    # Allow filtering for a certain amount of months
    if months:
        result = result[-months:]

    return result

# Returns a suggested category - Rules based first / fallbacks to AI 
@app.post("/categorize", response_model=CategorizeResponse)
def categorize(payload: CategorizeRequest):
    # 1) Rules-first
    rules_result = categorize_transaction(payload.description, payload.amount)

    # If rules matched, return immediately
    if rules_result.category != "uncategorized":
        return CategorizeResponse(
            category=rules_result.category,
            confidence=rules_result.confidence,
            method=rules_result.method,
        )

    # 2) AI fallback only if rules couldn't decide
    ai_result = ai_categorize_transaction(payload.description, payload.amount)

    return CategorizeResponse(
        category=ai_result.category,
        confidence=ai_result.confidence,
        method=ai_result.method,
    )
