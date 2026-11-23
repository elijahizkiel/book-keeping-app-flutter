import 'package:flutter_test/flutter_test.dart';
import 'package:bookkeeping_app/domain/entities/balance_summary.dart';
import 'package:bookkeeping_app/domain/entities/transaction.dart';

import '../fixtures/sample_data.dart';

void main() {
  group('BalanceSummary Domain Aggregation Tests', () {
    test('returns zero summary for empty transactions list', () {
      final summary = BalanceSummary.fromTransactions([]);
      expect(summary.owedToUserMinor, equals(0));
      expect(summary.owedByUserMinor, equals(0));
      expect(summary.netBalanceMinor, equals(0));
      expect(summary.isZero, isTrue);
      expect(summary.isPositive, isFalse);
      expect(summary.isNegative, isFalse);
    });

    test('correctly calculates net balance for pure credit (owed to user)', () {
      final txs = [
        Transaction(
          id: '1',
          friendId: 'f1',
          description: 'Lunch',
          amountMinor: 2500, // $25.00
          direction: TransactionDirection.owedToUser,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        Transaction(
          id: '2',
          friendId: 'f2',
          description: 'Movie tickets',
          amountMinor: 3000, // $30.00
          direction: TransactionDirection.owedToUser,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      final summary = BalanceSummary.fromTransactions(txs);
      expect(summary.owedToUserMinor, equals(5500));
      expect(summary.owedByUserMinor, equals(0));
      expect(summary.netBalanceMinor, equals(5500));
      expect(summary.isPositive, isTrue);
    });

    test('correctly calculates net balance for pure debt (user owes)', () {
      final txs = [
        Transaction(
          id: '1',
          friendId: 'f1',
          description: 'Gas share',
          amountMinor: 1500, // $15.00
          direction: TransactionDirection.owes,
          date: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      final summary = BalanceSummary.fromTransactions(txs);
      expect(summary.owedToUserMinor, equals(0));
      expect(summary.owedByUserMinor, equals(1500));
      expect(summary.netBalanceMinor, equals(-1500));
      expect(summary.isNegative, isTrue);
    });

    test('strictly ignores settled transactions from balance calculation', () {
      final summary = BalanceSummary.fromTransactions(SampleData.transactions);
      // Sample data:
      // tx1: owedToUser 5000 (pending)
      // tx2: owes 2000 (pending)
      // tx3: owedToUser 750 (SETTLED -> must NOT count)
      // tx4: owes 1500 (pending)
      expect(summary.owedToUserMinor, equals(5000));
      expect(summary.owedByUserMinor, equals(3500));
      expect(summary.netBalanceMinor, equals(1500)); // +$15.00 net
      expect(summary.isPositive, isTrue);
    });

    test('calculates per-friend balance correctly', () {
      final aliceTxs = SampleData.transactions.where((t) => t.friendId == 'f1');
      final aliceSummary = BalanceSummary.fromTransactions(aliceTxs);
      // Alice: tx1 (credit 5000), tx4 (debt 1500). Net = +3500
      expect(aliceSummary.owedToUserMinor, equals(5000));
      expect(aliceSummary.owedByUserMinor, equals(1500));
      expect(aliceSummary.netBalanceMinor, equals(3500));
    });
  });
}
