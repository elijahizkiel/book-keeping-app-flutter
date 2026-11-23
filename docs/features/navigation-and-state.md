# Navigation & State Management Architecture

This document describes the routing structure and reactive state management implementation.

---

## 1. Declarative Routing with GoRouter

The navigation architecture is declared in `lib/app/router.dart`.

### Bottom Navigation Tab Shell (`StatefulShellRoute.indexedStack`)
Maintains independent navigation state and preserved scroll positions across tabs:
1. **Branch 0**: Home Dashboard (`/dashboard`)
2. **Branch 1**: Transactions List (`/transactions`)
3. **Branch 2**: Friends Directory (`/friends`)
4. **Branch 3**: Preferences & Settings (`/settings`)

### Modal & Full-Screen Sub-Routes
Routes outside the bottom navigation shell:
* `/`: Initial splash screen with automated onboarding status redirection.
* `/onboarding`: Feature education slides and setup wizard.
* `/transactions/new`: Create expense/transaction.
* `/transactions/edit/:id`: Edit existing transaction.
* `/transactions/detail/:id`: Transaction details & settlement actions.
* `/friends/new`: Add friend form.
* `/friends/detail/:id`: Friend profile & dedicated transaction ledger.
* `/help`: FAQ accordion guide.

---

## 2. Reactive State Management with Riverpod 3

All state is managed through immutable state notifiers:

| Provider | Type | Purpose |
| :--- | :--- | :--- |
| `transactionsListProvider` | `AsyncNotifierProvider` | Fetches, adds, updates, and settles transactions |
| `friendsListProvider` | `AsyncNotifierProvider` | Manages contacts directory and CRUD operations |
| `transactionFilterProvider` | `NotifierProvider` | Holds active search text, direction filter, and date ranges |
| `balanceSummaryProvider` | `Provider` | Derives global financial balance strictly from pending transactions |
| `friendBalanceProvider` | `Provider.family` | Derives per-friend financial balance strictly from pending transactions |
| `preferencesStateProvider` | `NotifierProvider` | Manages theme mode, currency selection, and onboarding status |
