import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/features/friends/friend_detail_view.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_friends_repository.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_transactions_repository.dart';

import '../fixtures/sample_data.dart';
import '../helpers/fake_preferences_repository.dart';

void main() {
  testWidgets(
    'FriendDetailView displays profile, net balance, and transaction history',
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
          child: const MaterialApp(home: FriendDetailView(friendId: 'f1')),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Friend Profile Info
      expect(find.text('Alice Johnson'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);

      // Verify Per-Friend Balance
      expect(find.text('Alice Johnson owes you'), findsOneWidget);
      expect(find.text('\$35.00'), findsOneWidget);

      // Verify Actions
      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.text('Settle All'), findsOneWidget);

      // Verify Transaction History
      expect(find.text('Transaction History'), findsOneWidget);
      expect(find.text('Dinner at Italian Bistro'), findsOneWidget);
      expect(find.text('Groceries reimbursement'), findsOneWidget);
    },
  );
}
