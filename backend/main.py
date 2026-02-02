from fastapi import FastAPI
from pydantic import BaseModel
from database import engine, Base, SessionLocal
from models import TransactionDB
from datetime import date

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

# Display summary of of all transaction
@app.get("/summary")
def get_summary(month: str | None = None):
    db = get_db()
    rows = db.query(TransactionDB).all()
    db.close()

   
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

        # Income vs Expense (simple rule)
        if amt >= 0:
            total_income += amt
        else:
            total_expenses += abs(amt)

        # Category totals
        cat = row.category.strip().lower()
        if cat not in by_category:
            by_category[cat] = 0
        by_category[cat] += abs(amt)


    net = total_income - total_expenses
    return {
        "total_income": total_income,
        "total_expenses": total_expenses,
        "net": net,
        "by_category": by_category,
        "transaction_count": len(rows),
        "month_filtered": month
    }