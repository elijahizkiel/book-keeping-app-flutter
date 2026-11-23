import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookkeeping_app/data/repositories/persistent_friends_repository.dart';
import 'package:bookkeeping_app/data/repositories/persistent_transactions_repository.dart';
import 'package:bookkeeping_app/domain/entities/friend.dart';
import 'package:bookkeeping_app/domain/entities/transaction.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Offline-First Persistence Tests (Data Survives Restarts)', () {
    test('PersistentFriendsRepository persists and reloads data across app restarts', () async {
      final prefs = await SharedPreferences.getInstance();

      // Session 1: Add a friend
      final repo1 = PersistentFriendsRepository(prefs);
      final friend = Friend(
        id: 'f_persist_1',
        name: 'Sarah Connor',
        email: 'sarah@sky.net',
        phone: '+1 555-9000',
        createdAt: DateTime(2026, 3, 1),
      );
      await repo1.addFriend(friend);

      // Session 2: Instantiate new repository instance referencing the same shared preferences
      final repo2 = PersistentFriendsRepository(prefs);
      final friends = await repo2.getFriends();

      expect(friends.length, equals(1));
      expect(friends.first.id, equals('f_persist_1'));
      expect(friends.first.name, equals('Sarah Connor'));
      expect(friends.first.email, equals('sarah@sky.net'));
      expect(friends.first.phone, equals('+1 555-9000'));
    });

    test('PersistentTransactionsRepository persists, updates, and reloads data across restarts', () async {
      final prefs = await SharedPreferences.getInstance();

      // Session 1: Add transactions and settle one
      final repo1 = PersistentTransactionsRepository(prefs);
      final tx1 = Transaction(
        id: 'tx_p1',
        friendId: 'f_persist_1',
        description: 'Team Lunch',
        amountMinor: 3250,
        direction: TransactionDirection.owedToUser,
        date: DateTime(2026, 3, 2),
        createdAt: DateTime(2026, 3, 2),
      );
      final tx2 = Transaction(
        id: 'tx_p2',
        friendId: 'f_persist_1',
        description: 'Taxi ride',
        amountMinor: 1200,
        direction: TransactionDirection.owes,
        date: DateTime(2026, 3, 3),
        createdAt: DateTime(2026, 3, 3),
      );

      await repo1.addTransaction(tx1);
      await repo1.addTransaction(tx2);
      await repo1.settleTransaction('tx_p2');

      // Session 2: Fresh instance (simulating app restart)
      final repo2 = PersistentTransactionsRepository(prefs);
      final list = await repo2.getTransactions();

      expect(list.length, equals(2));
      final loadedTx1 = await repo2.getTransactionById('tx_p1');
      final loadedTx2 = await repo2.getTransactionById('tx_p2');

      expect(loadedTx1?.amountMinor, equals(3250));
      expect(loadedTx1?.isSettled, isFalse);

      expect(loadedTx2?.amountMinor, equals(1200));
      expect(loadedTx2?.isSettled, isTrue);
    });
  });
}
