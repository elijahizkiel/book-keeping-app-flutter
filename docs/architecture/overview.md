# Architecture Overview

The **BookKeeping App** is structured following **Domain-Driven Design (DDD)** and **Clean Architecture** patterns adapted for idiomatic, performant Flutter development.

---

## 🏛 System Architecture & Layers

```text
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   (Features / Views / Core Widgets / Material 3 Theme) │
└───────────────────────────▲────────────────────────────┘
                            │ (watches / dispatches)
┌───────────────────────────┴────────────────────────────┐
│                    State Layer (Riverpod)              │
│     (AsyncNotifiers / StateProviders / Computed State) │
└───────────────────────────▲────────────────────────────┘
                            │ (invokes)
┌───────────────────────────┴────────────────────────────┐
│                    Domain Layer (Pure)                 │
│      (Entities / Value Objects / Repository Contracts) │
└───────────────────────────▲────────────────────────────┘
                            │ (implements)
┌───────────────────────────┴────────────────────────────┐
│                     Data Layer                         │
│     (Persistent Repositories / JSON Models / Storage)  │
└────────────────────────────────────────────────────────┘
```

### 1. Domain Layer (`lib/domain/`)
The domain layer is completely decoupled from UI widgets, frameworks, and database implementations.
* **Entities**:
  * `Transaction`: Represents an individual debt, credit, or expense event.
  * `Friend`: Represents a contact who shares financial transactions with the user.
  * `BalanceSummary`: Dynamic financial summary (`owedToUserMinor`, `owedByUserMinor`, and signed `netBalanceMinor`).
  * `FilterCriteria`: Criteria for filtering transactions by search term, direction, and date ranges.
  * `UserPreferences`: Configuration for appearance theme, currency code/symbol, and onboarding completion.
* **Repository Contracts**:
  * `TransactionsRepository`: Interface defining CRUD and settlement operations.
  * `FriendsRepository`: Interface defining contact management operations.
  * `PreferencesRepository`: Interface defining settings and preferences storage.

### 2. Data Layer (`lib/data/`)
The data layer implements repository contracts and handles offline persistence and serialization.
* **Serialization Models**:
  * `TransactionModel`: Type-safe JSON serialization/deserialization for transactions.
  * `FriendModel`: Type-safe JSON serialization/deserialization for friend entities.
* **Adapters**:
  * `PersistentTransactionsRepository`: Disk-backed persistence using structured local storage.
  * `PersistentFriendsRepository`: Disk-backed persistence using structured local storage.
  * `LocalPreferencesRepository`: Backed by `SharedPreferences`.

### 3. State Layer (`lib/app/providers.dart`)
Application state is powered by **Flutter Riverpod 3.x**:
* `transactionsListProvider`: `AsyncNotifierProvider` driving transaction loading, insertion, updating, and settling.
* `friendsListProvider`: `AsyncNotifierProvider` managing contacts.
* `balanceSummaryProvider`: Computed provider that recalculates the user's total net balance strictly from pending transactions.
* `friendBalanceProvider`: Family provider computing real-time net balance with a specific friend.
* `preferencesStateProvider`: `NotifierProvider` managing user preferences and theme settings.

### 4. Presentation Layer (`lib/features/` & `lib/core/widgets/`)
* Feature-first organization (`splash/`, `onboarding/`, `dashboard/`, `transactions/`, `friends/`, `settings/`, `help/`).
* Screens interact **only** with Riverpod providers and use cases, never directly querying persistent storage.
