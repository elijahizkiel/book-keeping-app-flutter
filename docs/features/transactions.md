# Transaction Feature Specification

This document details the transaction management workflows, business logic, directional models, and filtering criteria.

---

## 1. Domain Model: `Transaction`

Each transaction represents a financial record between the user and a friend.

### Directional Types:
* `TransactionDirection.owedToUser` (Credit):
  * **Semantics**: The user paid for an expense on behalf of a friend.
  * **Balance Impact**: Increases `owedToUserMinor` (positive financial asset).
* `TransactionDirection.owes` (Debt):
  * **Semantics**: A friend paid for an expense on behalf of the user.
  * **Balance Impact**: Increases `owedByUserMinor` (liability).

### Status Types:
* `SettlementStatus.pending`: Active debt/credit that directly impacts dashboard and friend balance calculations.
* `SettlementStatus.settled`: Repaid or balanced transaction that is excluded from ongoing balance aggregations.

---

## 2. Workflows

### A. Creating a Transaction (`AddTransactionView`)
* **Route**: `/transactions/new` (or `/transactions/new?friendId=<id>`)
* **Validation**:
  * Amount must be non-empty, strictly positive decimal string, max 2 decimals.
  * Description is mandatory (1–100 characters).
  * Friend selection is mandatory.
* **Fields**: Direction toggle, Friend picker, Amount, Description, Category, Date picker, Optional Notes.

### B. Editing a Transaction
* **Route**: `/transactions/edit/:id`
* **Behavior**: Loads existing data, permits editing all fields, and updates persistent storage.

### C. Settling a Transaction
* **Action**: "Mark as Settled" on `TransactionDetailView`.
* **Behavior**: Updates transaction status to `SettlementStatus.settled` and recalculates all net balances.

### D. Deleting a Transaction
* **Action**: "Delete Transaction" with immediate persistent deletion and notifier invalidation.
