# Test Plan – Cashflow Copilot

## Overview

This test plan outlines how the backend functionality of Cashflow Copilot is tested to ensure correctness and reliability.

The focus is primarily on API behavior, including CRUD operations, data validation, and business logic.

---

## Testing Approach

The backend is tested using:

- **pytest**
- FastAPI's **TestClient**

Tests are designed to:
- simulate real API requests
- validate responses
- ensure correct data handling

---

## Test Environment

- Python virtual environment
- SQLite test database
- FastAPI TestClient

A separate test setup is used to avoid interfering with real data.

---

## Areas Tested

### 1. Transactions

Tests cover:

- Creating a transaction
- Retrieving all transactions
- Deleting a transaction
- Validating response structure

Example scenarios:
- Add a valid transaction → should return success
- Retrieve transactions → should return list with correct fields

---

### 2. Budgets

Tests cover:

- Creating a budget
- Updating a budget
- Deleting a budget
- Filtering by month

Example scenarios:
- Create budget for a category → should persist in database
- Update existing budget → should overwrite values

---

### 3. Summary Endpoint

Tests verify:

- Total income calculation
- Total expenses calculation
- Net calculation
- Category breakdown

Example scenarios:
- Multiple transactions added → summary reflects correct totals
- Month filter → only returns relevant data

---

### 4. Categorization

Tests cover:

- Rule-based categorization
- AI fallback behavior

Important case:
- Unknown transaction → should return `"uncategorized"` using rules (not AI during tests)

---

## Edge Cases Considered

- Empty transaction list
- Invalid input formats
- Missing fields
- Unknown categories
- Negative vs positive transaction amounts

---

## Test Structure

Tests are organized in:

- `tests/` directory
- Separate test files per feature
- Shared setup via `conftest.py`

---

## Example Test Flow

1. Send POST request to `/transactions`
2. Verify response status = 200
3. Send GET request to `/transactions`
4. Confirm transaction exists in response

---

## What is NOT tested (yet)

- Frontend (SwiftUI UI testing not included)
- Performance/load testing
- Authentication (not implemented)

---

## Future Testing Improvements

- Add frontend UI testing
- Add integration tests for full flows
- Add performance testing for API endpoints
- Add validation for larger datasets

---

## Summary

The current testing strategy ensures that:
- core backend functionality works correctly
- API endpoints behave as expected
- data integrity is maintained

This provides a solid foundation for future expansion and deployment.