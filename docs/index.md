# BookKeeping App — Documentation Index

Welcome to the technical and product documentation for the **BookKeeping Flutter App**. This documentation covers system architecture, data models, persistence, UI design systems, feature workflows, and deployment automation.

---

## 📑 Documentation Structure

### 1. Architecture & Core Systems
* [**Architecture Overview**](architecture/overview.md): High-level system design, domain-driven design structure, dependency graph, and modular boundaries.
* [**Offline Data Layer & Money System**](architecture/offline-data-layer.md): Minor-unit integer money arithmetic (`Money`), persistent repository adapters, restart durability, and data models.

### 2. Feature Workflows
* [**Transactions Management**](features/transactions.md): Transaction lifecycle, debt vs credit directional models (`owes` vs `owedToUser`), validation rules, and dynamic date/text filtering.
* [**Friends & Settlement Flow**](features/friends-and-settlement.md): Contact directory, per-friend running ledgers, balance aggregation, and full/partial settlement actions.
* [**Navigation & State Management**](features/navigation-and-state.md): Declarative GoRouter routing, bottom tab shells, deep link handlers, and Riverpod 3 notifier architectures.

### 3. Design System & UX
* [**Design System & Theme Tokens**](design-system/tokens-and-ui.md): Color tokens, typography, cards, balance pills, touch targets, accessibility standards, and dark/light themes.

### 4. Deployment & Operations
* [**CI/CD & Android Release Pipeline**](deployment/ci-cd-releases.md): GitHub Actions workflow, automated Android APK builds, tag versioning, and GitHub Releases publication.

---

## 🎯 Quick Links
* **Repository**: [https://github.com/elijahizkiel/book-keeping-app-flutter](https://github.com/elijahizkiel/book-keeping-app-flutter)
* **Latest Releases**: [GitHub Releases Page](https://github.com/elijahizkiel/book-keeping-app-flutter/releases)
* **Root Readme**: [README.md](../README.md)
