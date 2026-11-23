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
  testWidgets(
    'AddTransactionView validates fields and submits new transaction',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final friendsRepo = InMemoryFriendsRepository(
        initial: SampleData.friends,
      );
      final txRepo = InMemoryTransactionsRepository(initial: []);
      final fakePrefs = FakePreferencesRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            friendsRepositoryProvider.overrideWithValue(friendsRepo),
            transactionsRepositoryProvider.overrideWithValue(txRepo),
            preferencesRepositoryProvider.overrideWithValue(fakePrefs),
          ],
          child: const MaterialApp(home: AddTransactionView()),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Title and Direction selector
      expect(find.text('New Transaction'), findsOneWidget);
      expect(find.text('Owed to me (+)'), findsOneWidget);
      expect(find.text('I owe (-)'), findsOneWidget);

      final saveButton = find.text('Save Transaction');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(find.text('Amount is required'), findsOneWidget);
      expect(find.text('Description is required'), findsOneWidget);

      // Fill valid data
      await tester.enterText(
        find.byType(TextFormField).at(0),
        '45.00',
      ); // Amount
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Concert ticket',
      ); // Description

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      final txs = await txRepo.getTransactions();
      expect(txs.length, equals(1));
      expect(txs.first.amountMinor, equals(4500));
      expect(txs.first.description, equals('Concert ticket'));
    },
  );
}
