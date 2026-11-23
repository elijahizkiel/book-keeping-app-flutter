# 📖 BookKeeping App (Flutter)

[![Build and Release Android APK](https://github.com/elijahizkiel/book-keeping-app-flutter/actions/workflows/release-apk.yml/badge.svg)](https://github.com/elijahizkiel/book-keeping-app-flutter/actions/workflows/release-apk.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.50.1-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.14.0-0175C2?logo=dart)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-blue)](#platforms)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A production-ready, offline-first mobile bookkeeping and financial debt/credit tracking application built with **Flutter**, **Riverpod**, and **GoRouter**. 

Designed for individuals, roommates, and small groups to effortlessly track shared expenses, split bills, keep real-time debt and credit ledgers with friends, and settle balances — all stored securely and privately on-device.

---

## 📱 Application Preview & Features

### 1. Financial Dashboard
- **Total Net Balance Hero**: Live aggregation of your financial standing (`+` for net credit, `-` for net debt).
- **Split Summary Cards**: Explicit, accessible breakout of **Owed to you** and **You owe**.
- **Dynamic Time Filters**: Instant toggle between *All Time*, *This Month*, and *Last 30 Days*.
- **Recent Activities Ledger**: Quick-scannable list with semantic status pills and initials avatar badges.
- **Quick Action Bar**: One-tap access to log expenses or add new friends.

### 2. Transaction Management
- **Directional Debt Tracking**: Clear dual-mode logging:
  - `Owed to me (+)`: You paid for a friend (Credit).
  - `I owe (-)`: A friend paid for you (Debt).
- **Categorization & Notes**: Support for Food & Drinks, Shopping, Travel, Entertainment, Groceries, Utilities, and custom categories.
- **Full Lifecycle**: Create, edit, search, filter, view details, mark as settled, or delete.
- **Dynamic Filters**: Instant filtering by search query, direction (`All`, `Owed to me`, `I owe`, `Settled`), and dates.

### 3. Friends & Shared Ledgers
- **Friend Profiles**: Per-contact transaction history and running net balance.
- **Real-time Balance Badges**: Green pill for credit, Red pill for debt, Gray pill when all settled up.
- **Settle All Action**: One-tap settlement clearing all running transactions for a specific contact.

### 4. Settings & Personalization
- **Theme Support**: Seamless switching between **System Default**, **Light Mode**, and **Dark Mode** (`#121212`).
- **Multi-Currency Support**: Choose your preferred currency symbol and code (USD `$`, EUR `€`, GBP `£`, ETB `Br`).
- **Data Management**: Complete on-device database reset and onboarding guide replay.
- **Help & FAQs**: Built-in offline guide explaining accounting concepts and app usage.

---

## 🏗 Architecture & Engineering Standards

The codebase follows Domain-Driven Design (DDD) principles with clean layer separation:

```text
lib/
├── app/
│   ├── app.dart              # App root widget & theme mode binding
│   ├── providers.dart        # Riverpod providers, notifiers & state DI
│   ├── router.dart           # GoRouter route declarations & bottom tab shell
│   └── theme/
│       ├── app_colors.dart   # Brand and semantic color tokens
│       └── app_theme.dart    # Light and Dark Material 3 theme configurations
├── core/
│   ├── constants/            # Global app constants
│   ├── errors/               # Typed domain failures (Validation, Storage, NotFound)
│   ├── formatting/           # Currency and relative date formatters
│   ├── utils/                # Money value object (cents integer) & form validators
│   └── widgets/              # Reusable design system widgets (Card, Button, Avatar, Pill)
├── data/
│   ├── models/               # Type-safe JSON serialization models
│   └── repositories/         # Persistent & in-memory repository adapters
├── domain/
│   ├── entities/             # Immutable domain models (Transaction, Friend, BalanceSummary)
│   └── repositories/         # Repository interfaces (Contracts)
├── features/
│   ├── splash/               # Splash screen & onboarding check
│   ├── onboarding/           # Educational walkthrough slides
│   ├── dashboard/            # Home financial overview & balance cards
│   ├── transactions/         # List, filter, add/edit form, and details
│   ├── friends/              # Friends directory, add friend form, and profile ledger
│   ├── settings/             # Theme, currency, and data reset preferences
│   └── help/                 # Offline FAQs and guidance
└── main.dart                 # Application bootstrap & dependency wiring
```

### Key Architectural Highlights

* **Precision Minor-Unit Money (`Money`)**: All currency amounts are stored and calculated as integer cents (`int minorUnits`), completely eliminating binary floating-point rounding drift.
* **Reactive Derived Balances**: Net balances and friend summaries are dynamically computed from active pending transactions using `BalanceSummary.fromTransactions()`. Balances are never denormalized or stored as mutable counters.
* **Offline-First Persistence**: Data persists in `SharedPreferences` as structured JSON models (`PersistentFriendsRepository`, `PersistentTransactionsRepository`), surviving application kills and restarts across Android, iOS, Web, and Desktop.
* **Comprehensive Automated Testing**: 47 unit, repository, state, and widget tests ensuring zero regressions.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.50.0`)
- [Dart SDK](https://dart.dev/get-dart) (`>= 3.14.0`)
- Android Studio / Xcode (for mobile emulators or physical device deployment)

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/elijahizkiel/book-keeping-app-flutter.git
   cd book-keeping-app-flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify code health**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Launch the application**:
   ```bash
   # Run on connected device or emulator
   flutter run

   # Or run on Chrome for quick web preview
   flutter run -d chrome
   ```

---

## 🧪 Testing Suite

The repository contains an exhaustive test suite covering all layers:

```bash
# Run all unit, repository, state, and widget tests
flutter test

# Run specific test suites
flutter test test/unit/                    # Money, BalanceSummary, Validators, Filters
flutter test test/repositories/            # CRUD & Offline Restart Persistence tests
flutter test test/providers/               # Riverpod State Notifiers & Balance derivation
flutter test test/widgets/                 # Isolated screen & widget tests for all 11 views
```

All 47 tests pass out-of-the-box in headless CI environments.

---

## 📦 Continuous Integration & APK Releases

A GitHub Actions workflow is configured under [`.github/workflows/release-apk.yml`](.github/workflows/release-apk.yml).

* **Trigger**: Automatically executes whenever a branch is merged into `master` or manually dispatched.
* **Automated Pipeline**:
  1. Runs `flutter analyze` and `flutter test`.
  2. Compiles production release APK (`flutter build apk --release`).
  3. Tags release as `v1.0.<run_number>`.
  4. Publishes a new GitHub Release with the attached `app-release.apk`.

Download the latest compiled Android APK directly from the [Releases Page](https://github.com/elijahizkiel/book-keeping-app-flutter/releases).

---

## 📚 Detailed Documentation

For in-depth architectural guides, feature documentation, and design specifications, explore the [`docs/`](docs/) directory:

- [**Documentation Index**](docs/index.md)
- [**Architecture & Design Principles**](docs/architecture/overview.md)
- [**Offline Data Layer & Money System**](docs/architecture/offline-data-layer.md)
- [**Transactions Feature Specification**](docs/features/transactions.md)
- [**Friends & Settlement Flow**](docs/features/friends-and-settlement.md)
- [**Navigation & State Management**](docs/features/navigation-and-state.md)
- [**Design System & Theme Tokens**](docs/design-system/tokens-and-ui.md)
- [**CI/CD & Android Release Pipeline**](docs/deployment/ci-cd-releases.md)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
