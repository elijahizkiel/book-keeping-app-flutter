# Design System & UI Specifications

This document outlines the visual tokens, theme definitions, and component guidelines for the app.

---

## 1. Color Palette & Tokens (`AppColors`)

### Brand
* **Primary Brand Green**: `#4CAE4F`
* **Primary Dark**: `#388E3C`
* **Primary Light**: `#C8E6C9`

### Financial Semantics
* **Debt (You owe)**: `#F44336` (Background: `#FFEBEE`)
* **Credit (Owed to you)**: `#4CAE4F` (Background: `#E8F5E9`)

### Neutrals
* **Light Theme**:
  * Background: `#F6F7F6`
  * Surface: `#FFFFFF`
  * Text Primary: `#1B1B1B`
  * Border: `#E0E0E0`
* **Dark Theme**:
  * Background: `#121212`
  * Surface: `#1E1E1E`
  * Elevated Surface: `#2A2A2A`
  * Text Primary: `#F5F5F5`
  * Border: `#2C2C2C`

---

## 2. Reusable UI Components (`lib/core/widgets/`)

* **`AppCard`**: Uniform border radius (16px) with dynamic borders and theme-aware surface coloring.
* **`AppButton`**: Accessible 50px interactive height, supporting primary, secondary, outline, and danger variants.
* **`AvatarBadge`**: Circular badge (20–36px radius) rendering friend initials fallback.
* **`BalancePill`**: Directional financial badge with up/down arrows and text indicators.
* **`EmptyStateView`**: Informative empty screen state with circular icon container, descriptive title, and optional call-to-action button.

---

## 3. Accessibility Standards

* Minimum interactive touch targets of 48×48 dp.
* Financial balances always combine color with explicit text labels (`You owe` vs `Owed to you`).
* Safe keyboard handling via `SafeArea`, scrollable forms, and `viewInsetsOf(context)`.
