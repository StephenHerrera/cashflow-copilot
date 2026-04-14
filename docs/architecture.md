# Architecture Overview – Cashflow Copilot

## Overview

Cashflow Copilot is a full-stack personal finance application built with a FastAPI backend and a SwiftUI frontend. The goal of the project is to provide users with a simple way to track transactions, manage budgets, and view financial summaries.

The system is structured in a way that separates concerns between the backend (data + logic) and the frontend (UI + user interaction).

---

## High-Level Structure

The project is divided into three main parts:

- `backend/` → API, database, and business logic
- `frontend/` → SwiftUI iOS application
- `docs/` → documentation (architecture + test plan)

---

## Backend Architecture (FastAPI)

The backend is built using FastAPI and follows a modular structure.

### Key Components

- **main.py**
  - Entry point of the API
  - Defines all endpoints (transactions, budgets, summary, etc.)

- **models.py**
  - SQLAlchemy database models
  - Represents tables like `TransactionDB` and `BudgetDB`

- **schemas.py**
  - Pydantic models for request/response validation
  - Ensures clean and structured API data

- **database.py**
  - Handles database connection and session management

- **categorization.py**
  - Rule-based transaction categorization logic

- **ai_categorizer.py**
  - Optional AI-based categorization fallback (disabled in tests)

---

### API Design

The backend exposes RESTful endpoints such as:

- `/transactions`
- `/budgets`
- `/summary`
- `/categorize`

Each endpoint:
- accepts structured input (Pydantic)
- interacts with the database via SQLAlchemy
- returns JSON responses

---

### Data Flow (Backend)

1. Request comes in from frontend
2. FastAPI validates input using schemas
3. Logic executes (CRUD or summary calculations)
4. SQLAlchemy interacts with SQLite database
5. Response is returned as JSON

---

## Frontend Architecture (SwiftUI)

The frontend is built using SwiftUI and follows a simple, modular design.

### Key Concepts Used

- State management using `@State`
- API communication via `URLSession`
- Reusable UI components (cards, rows, chips)
- Navigation using `NavigationStack`
- Sheets for add/edit flows
- Swipe actions for edit/delete

---

### Important Files

- **APIClient.swift**
  - Handles all API calls to backend
  - Central place for networking logic

- **Models.swift**
  - Swift representations of backend data

- **Views**
  - `HomeView` → dashboard
  - `TransactionsView` → list + search/filter
  - `BudgetsView` → budget management
  - `SummaryView` → financial breakdown

- **Reusable Components**
  - `Card`
  - `TransactionRow`
  - `MonthPickerRow`
  - `WrapChips`

---

### Data Flow (Frontend)

1. User interacts with UI (button, form, etc.)
2. APIClient sends request to backend
3. Response is received asynchronously
4. UI updates via state variables
5. Views re-render automatically

---

## Database

- SQLite database (local)
- Managed using SQLAlchemy
- Tables:
  - Transactions
  - Budgets

---

## Design Decisions

Some key choices made:

- **FastAPI** for simplicity and speed of development
- **SwiftUI** to build a modern mobile UI
- **SQLite** for lightweight local storage
- **REST API** for clear separation between frontend and backend
- **Rule-based categorization first, AI fallback second**

---

## Summary

The architecture focuses on simplicity, clarity, and separation of concerns.  
Each part of the system has a clear responsibility, making the application easier to understand, maintain, and extend.