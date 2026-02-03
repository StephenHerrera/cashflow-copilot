import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# If DATABASE_URL is set (in tests), use it.
# Otherwise default to normal database.
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./cashflow.db")

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

Base = declarative_base()
