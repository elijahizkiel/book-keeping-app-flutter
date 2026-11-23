# Friends & Settlement Feature Specification

This document covers contact tracking, balance aggregation per friend, and settlement mechanics.

---

## 1. Contact Management (`Friend`)

* **Fields**: `id`, `name`, optional `email`, optional `phone`, `avatarUrl`, `createdAt`.
* **Validation**:
  * Name must be between 2 and 50 characters.
  * Duplicate friend names (case-insensitive) are strictly prevented.
  * Email and phone fields validate format if supplied.
* **Avatar Fallback**: Automated initials generation from first and last words of the friend's name (e.g., "Sarah Connor" -> "SC").

---

## 2. Dynamic Running Ledger & Balance Calculation

The application computes friend balances dynamically rather than relying on stored counters:

$$\text{Net Balance} = \sum \text{Pending Owed To User} - \sum \text{Pending User Owes}$$

* **Net > 0**: Friend owes you money (Credit). Displayed with a green badge: `Owed $XX.XX`.
* **Net < 0**: You owe the friend money (Debt). Displayed with a red badge: `You owe $XX.XX`.
* **Net = 0**: Settled up. Displayed with a gray badge: `All Settled Up`.

---

## 3. Settle All Flow

In `FriendDetailView`:
* Displays full ledger history of transactions associated with that friend.
* **Settle All Action**:
  * Triggers `TransactionsRepository.settleAllForFriend(friendId)`.
  * Flags all pending transactions for that contact as `SettlementStatus.settled`.
  * Recalculates both the contact's running ledger and the global dashboard balances.
