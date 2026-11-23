import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/features/transactions/add_transaction_view.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_friends_repository.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_transactions_repository.dart';

import '../fixtures/sample_data.dart';
import '../helpers/fake_preferences_repository.dart';

void main() {
  testWidgets('AddTransactionView supports editing existing transaction', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final friendsRepo = InMemoryFriendsRepository(initial: SampleData.friends);
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
          home: AddTransactionView(transactionId: 'tx1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title is 'Edit Transaction'
    expect(find.text('Edit Transaction'), findsOneWidget);
    expect(find.text('Update Transaction'), findsOneWidget);

    // Verify existing data is populated
    expect(find.text('Dinner at Italian Bistro'), findsOneWidget);
    expect(find.text('50.00'), findsOneWidget);

    // Edit the description and amount
    await tester.enterText(find.byType(TextFormField).at(0), '75.00');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Luxury Dinner at Bistro',
    );

    await tester.tap(find.text('Update Transaction'));
    await tester.pumpAndSettle();

    final updatedTx = await txRepo.getTransactionById('tx1');
    expect(updatedTx?.amountMinor, equals(7500));
    expect(updatedTx?.description, equals('Luxury Dinner at Bistro'));
  });
}
