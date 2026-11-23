import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/features/dashboard/dashboard_view.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_friends_repository.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_transactions_repository.dart';

import '../fixtures/sample_data.dart';
import '../helpers/fake_preferences_repository.dart';

void main() {
  testWidgets(
    'DashboardView displays net balance, summary cards, and quick actions',
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
          child: const MaterialApp(home: DashboardView()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header and Hero net balance
      expect(find.text('Financial Overview'), findsOneWidget);
      expect(find.text('Total Net Balance'), findsOneWidget);
      expect(
        find.text('+\$15.00'),
        findsOneWidget,
      ); // Net balance of sample data

      // Verify Summary Cards
      expect(find.text('Owed to you'), findsOneWidget);
      expect(find.text('\$50.00'), findsOneWidget);
      expect(find.text('You owe'), findsOneWidget);
      expect(find.text('\$35.00'), findsOneWidget);

      // Verify Quick Actions
      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.text('Add Friend'), findsOneWidget);

      // Verify Recent Activities
      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('Dinner at Italian Bistro'), findsOneWidget);
      expect(find.text('Uber ride share'), findsOneWidget);
    },
  );
}
