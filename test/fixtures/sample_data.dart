import 'package:bookkeeping_app/domain/entities/friend.dart';
import 'package:bookkeeping_app/domain/entities/transaction.dart';

class SampleData {
  static final friendAlice = Friend(
    id: 'f1',
    name: 'Alice Johnson',
    email: 'alice@example.com',
    phone: '555-0101',
    createdAt: DateTime(2026, 1, 1),
  );

  static final friendBob = Friend(
    id: 'f2',
    name: 'Bob Smith',
    email: 'bob@example.com',
    createdAt: DateTime(2026, 1, 2),
  );

  static final friendCharlie = Friend(
    id: 'f3',
    name: 'Charlie Brown',
    createdAt: DateTime(2026, 1, 3),
  );

  static List<Friend> get friends => [friendAlice, friendBob, friendCharlie];

  static final tx1Credit = Transaction(
    id: 'tx1',
    friendId: 'f1', // Alice owes user $50.00
    description: 'Dinner at Italian Bistro',
    amountMinor: 5000,
    direction: TransactionDirection.owedToUser,
    category: 'Food',
    date: DateTime(2026, 2, 10, 19, 30),
    createdAt: DateTime(2026, 2, 10, 19, 30),
  );

  static final tx2Debt = Transaction(
    id: 'tx2',
    friendId: 'f2', // User owes Bob $20.00
    description: 'Uber ride share',
    amountMinor: 2000,
    direction: TransactionDirection.owes,
    category: 'Travel',
    date: DateTime(2026, 2, 11, 8, 15),
    createdAt: DateTime(2026, 2, 11, 8, 15),
  );

  static final tx3Settled = Transaction(
    id: 'tx3',
    friendId: 'f1',
    description: 'Coffee at Starbucks',
    amountMinor: 750,
    direction: TransactionDirection.owedToUser,
    status: SettlementStatus.settled,
    category: 'Food',
    date: DateTime(2026, 2, 9, 9, 0),
    createdAt: DateTime(2026, 2, 9, 9, 0),
  );

  static final tx4AliceDebt = Transaction(
    id: 'tx4',
    friendId: 'f1', // User owes Alice $15.00
    description: 'Groceries reimbursement',
    amountMinor: 1500,
    direction: TransactionDirection.owes,
    category: 'Groceries',
    date: DateTime(2026, 2, 12, 14, 0),
    createdAt: DateTime(2026, 2, 12, 14, 0),
  );

  static List<Transaction> get transactions => [
    tx1Credit,
    tx2Debt,
    tx3Settled,
    tx4AliceDebt,
  ];
}
