import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/features/transactions/transaction_detail_view.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_friends_repository.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_transactions_repository.dart';

import '../fixtures/sample_data.dart';
import '../helpers/fake_preferences_repository.dart';

void main() {
  testWidgets(
    'TransactionDetailView displays transaction info and settles transaction',
    (tester) async {
      final friendsRepo = InMemoryFriendsRepository(
        initial: SampleData.friends,
      );
      final txRepo = InMemoryTransactionsRepository(
        initial: SampleData.transactions,
      );
      final fakePrefs = FakePreferencesRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            friendsRepositoryProvider.overrideWithValue(friendsRepo),
            transactionsRepositoryProvider.overrideWithValue(txRepo),
            preferencesRepositoryProvider.overrideWithValue(fakePrefs),
          ],
          child: const MaterialApp(
            home: TransactionDetailView(transactionId: 'tx1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Transaction Details
      expect(find.text('Transaction Details'), findsOneWidget);
      expect(find.text('Alice Johnson'), findsOneWidget);
      expect(find.text('\$50.00'), findsOneWidget);
      expect(find.text('Dinner at Italian Bistro'), findsOneWidget);

      // Verify Settle Action
      expect(find.text('Mark as Settled'), findsOneWidget);
      await tester.tap(find.text('Mark as Settled'));
      await tester.pumpAndSettle();

      final tx = await txRepo.getTransactionById('tx1');
      expect(tx?.isSettled, isTrue);
    },
  );
}
