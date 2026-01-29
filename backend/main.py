from fastapi import FastAPI
from pydantic import BaseModel
from database import engine, Base
from models import TransactionDB

# Main server object that will handle incoming requests.
app = FastAPI()

#creating corresponding tables in database that dont exist
Base.metadata.create_all(bind=engine)

# Creating data model to only accept valid input from the user
class Transaction(BaseModel):
    amount: float
    description: str
    category: str

# Temporary storage for transactions.
# Python list to focus on learning APIs.
transactions = []

# Health check endpoint.
@app.get("/health")
def health_check():
    return {"status": "ok"}

# Get all transactions.
@app.get("/transactions")
def get_transactions():
    return transactions

# Add a new transaction.
@app.post("/transactions")
def add_transaction(transaction: Transaction):
    transactions.append(transaction)
    return {"message": "Transaction added"}