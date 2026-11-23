import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/features/transactions/transactions_view.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_friends_repository.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_transactions_repository.dart';

import '../fixtures/sample_data.dart';
import '../helpers/fake_preferences_repository.dart';

void main() {
  testWidgets(
    'TransactionsView shows transaction list, search, and filter chips',
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
          child: const MaterialApp(home: TransactionsView()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Title & Search
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify Filter Chips
      expect(find.widgetWithText(ChoiceChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Owed to me'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'I owe'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Settled'), findsOneWidget);

      // Verify List Items
      expect(find.text('Dinner at Italian Bistro'), findsOneWidget);
      expect(find.text('Uber ride share'), findsOneWidget);
      expect(find.text('Coffee at Starbucks'), findsOneWidget);

      // Tap 'Settled' filter chip
      await tester.tap(find.widgetWithText(ChoiceChip, 'Settled'));
      await tester.pumpAndSettle();

      // Only Coffee at Starbucks is settled
      expect(find.text('Coffee at Starbucks'), findsOneWidget);
      expect(find.text('Dinner at Italian Bistro'), findsNothing);
    },
  );
}
