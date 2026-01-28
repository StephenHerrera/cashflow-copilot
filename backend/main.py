from fastapi import FastAPI

# Main server object that will handle incoming requests.
app = FastAPI()

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
def add_transaction(transaction: dict):
    transactions.append(transaction)
    return {"message": "Transaction added"}