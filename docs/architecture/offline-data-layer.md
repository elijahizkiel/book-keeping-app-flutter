# Offline Data Layer & Money System

Reliability and precision are critical in financial applications. This document details the integer minor-unit money engine and the offline-first persistence layer.

---

## 💰 The Minor-Unit Money System (`Money`)

### Why Not `double`?
Standard IEEE 754 floating-point numbers (`double` in Dart) cannot accurately represent decimal fractions:
```dart
0.1 + 0.2 = 0.30000000000000004 // Floating-point rounding drift
```
In bookkeeping, rounding drift leads to missing cents and inaccurate financial balances over time.

### The `Money` Class Solution
All currency values throughout the app are stored, calculated, and persisted as **integer minor units** (cents):
* `$1.00` = `100` minor units.
* `$25.50` = `2550` minor units.
* `$0.05` = `5` minor units.

#### Key Rules:
1. **Validation & Parsing**:
   * Accepts formatted decimal strings (`"25.50"`, `"1,200.00"`, `"45"`).
   * Strictly rejects zero (`"0.00"`), negative values (`"-10"`), and malformed strings with `ValidationFailure`.
   * Enforces a maximum of 2 decimal places.
2. **Exact Arithmetic**:
   * Addition and subtraction operate purely on integer minor units without precision loss.
3. **Deterministic Formatting**:
   * Formatted using `intl` `NumberFormat.currency`, ensuring exact two decimal places and user-configured currency symbols.

---

## 💾 Offline-First Persistence

The application is engineered to function completely offline without external server dependencies.

### 1. Data Schema & Models
* **Friends**:
  ```json
  {
    "id": "uuid-string",
    "name": "Sarah Connor",
    "email": "sarah@example.com",
    "phone": "+1 555-0101",
    "avatarUrl": null,
    "createdAt": "2026-03-01T12:00:00.000Z"
  }
  ```
* **Transactions**:
  ```json
  {
    "id": "uuid-string",
    "friendId": "friend-uuid-string",
    "description": "Dinner at Bistro",
    "amountMinor": 4500,
    "direction": 0,
    "status": 0,
    "category": "Food & Drinks",
    "date": "2026-03-01T19:30:00.000Z",
    "notes": "Shared pizza and drinks",
    "createdAt": "2026-03-01T19:30:00.000Z"
  }
  ```

### 2. Repositories
* `PersistentFriendsRepository`: Reads from disk on bootstrap, caches in memory for $O(1)$ reads, and persists changes asynchronously on every mutation.
* `PersistentTransactionsRepository`: Manages durable transactions, sorts by date descending, and broadcasts state changes to Riverpod stream listeners.
* `LocalPreferencesRepository`: Stores onboarding status, theme mode index, and currency configurations.

### 3. Restart Resilience
Persistence is verified by unit test `test/repositories/persistent_persistence_test.dart`, confirming that transactions and friends survive application disposal and re-instantiation.
