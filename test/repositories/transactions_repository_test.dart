import 'package:flutter_test/flutter_test.dart';
import 'package:bookkeeping_app/domain/entities/transaction.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_transactions_repository.dart';

import '../fixtures/sample_data.dart';

void main() {
  late InMemoryTransactionsRepository repository;

  setUp(() {
    repository = InMemoryTransactionsRepository(
      initial: SampleData.transactions,
    );
  });

  group('TransactionsRepository Tests', () {
    test('fetches all transactions sorted by date descending', () async {
      final txs = await repository.getTransactions();
      expect(txs.length, equals(4));
      // First transaction must have latest date
      expect(txs.first.id, equals('tx4')); // Feb 12
    });

    test('retrieves transactions by specific friend', () async {
      final aliceTxs = await repository.getTransactionsByFriend('f1');
      expect(aliceTxs.length, equals(3));
      expect(aliceTxs.every((t) => t.friendId == 'f1'), isTrue);
    });

    test('adds new transaction', () async {
      final newTx = Transaction(
        id: 'tx_new',
        friendId: 'f2',
        description: 'Concert Ticket',
        amountMinor: 8000,
        direction: TransactionDirection.owedToUser,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await repository.addTransaction(newTx);

      final list = await repository.getTransactions();
      expect(list.length, equals(5));
      expect(await repository.getTransactionById('tx_new'), isNotNull);
    });

    test('settles an individual transaction', () async {
      expect(
        (await repository.getTransactionById('tx1'))?.status,
        equals(SettlementStatus.pending),
      );

      await repository.settleTransaction('tx1');
      final tx1 = await repository.getTransactionById('tx1');
      expect(tx1?.status, equals(SettlementStatus.settled));
      expect(tx1?.isSettled, isTrue);
    });

    test('settles all transactions for a given friend', () async {
      // Alice ('f1') has pending transactions tx1 and tx4
      await repository.settleAllForFriend('f1');
      final aliceTxs = await repository.getTransactionsByFriend('f1');
      expect(aliceTxs.every((t) => t.isSettled), isTrue);
    });

    test('deletes a transaction', () async {
      await repository.deleteTransaction('tx2');
      final tx2 = await repository.getTransactionById('tx2');
      expect(tx2, isNull);

      final list = await repository.getTransactions();
      expect(list.length, equals(3));
    });
  });
}
