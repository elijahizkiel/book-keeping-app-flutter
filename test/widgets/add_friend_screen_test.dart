import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookkeeping_app/features/friends/add_friend_view.dart';
import 'package:bookkeeping_app/app/providers.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_friends_repository.dart';

import '../helpers/fake_preferences_repository.dart';

void main() {
  testWidgets('AddFriendView validates name input and adds friend', (
    tester,
  ) async {
    final friendsRepo = InMemoryFriendsRepository(initial: []);
    final fakePrefs = FakePreferencesRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          friendsRepositoryProvider.overrideWithValue(friendsRepo),
          preferencesRepositoryProvider.overrideWithValue(fakePrefs),
        ],
        child: const MaterialApp(home: AddFriendView()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Add Friend'), findsOneWidget);

    // Validate empty form submit
    await tester.tap(find.text('Save Friend'));
    await tester.pumpAndSettle();

    expect(find.text('Friend name is required'), findsOneWidget);

    // Enter valid friend name and submit
    await tester.enterText(find.byType(TextFormField).at(0), 'Michael Scott');
    await tester.tap(find.text('Save Friend'));
    await tester.pumpAndSettle();

    final friends = await friendsRepo.getFriends();
    expect(friends.length, equals(1));
    expect(friends.first.name, equals('Michael Scott'));
  });
}
