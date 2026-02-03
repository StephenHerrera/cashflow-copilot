import os

# This forces tests to use a separate database
os.environ["DATABASE_URL"] = "sqlite:///./cashflow_test.db"
