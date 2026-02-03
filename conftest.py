import os
import pytest
from backend.database import Base, engine

# Force tests to use separate DB
os.environ["DATABASE_URL"] = "sqlite:///./cashflow_test.db"


@pytest.fixture(autouse=True)
def reset_database():
    # Drop all tables
    Base.metadata.drop_all(bind=engine)

    # Recreate all tables
    Base.metadata.create_all(bind=engine)

    yield
