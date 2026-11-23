import 'package:flutter_test/flutter_test.dart';
import 'package:bookkeeping_app/core/errors/failures.dart';
import 'package:bookkeeping_app/domain/entities/friend.dart';
import 'package:bookkeeping_app/data/repositories/in_memory_friends_repository.dart';

import '../fixtures/sample_data.dart';

void main() {
  late InMemoryFriendsRepository repository;

  setUp(() {
    repository = InMemoryFriendsRepository(initial: SampleData.friends);
  });

  group('FriendsRepository CRUD & Persistence Tests', () {
    test('retrieves all friends correctly', () async {
      final list = await repository.getFriends();
      expect(list.length, equals(3));
      expect(
        list.map((f) => f.name),
        containsAll(['Alice Johnson', 'Bob Smith', 'Charlie Brown']),
      );
    });

    test('retrieves friend by ID and handles missing ID', () async {
      final friend = await repository.getFriendById('f1');
      expect(friend, isNotNull);
      expect(friend!.name, equals('Alice Johnson'));

      final missing = await repository.getFriendById('unknown');
      expect(missing, isNull);
    });

    test('adds new friend successfully', () async {
      final newFriend = Friend(
        id: 'f4',
        name: 'David Miller',
        createdAt: DateTime.now(),
      );
      final added = await repository.addFriend(newFriend);
      expect(added.id, equals('f4'));

      final list = await repository.getFriends();
      expect(list.length, equals(4));
    });

    test('rejects duplicate friend names with DuplicateFailure', () async {
      final duplicate = Friend(
        id: 'f4',
        name: 'Alice Johnson', // Case-insensitive duplicate
        createdAt: DateTime.now(),
      );
      expect(
        () => repository.addFriend(duplicate),
        throwsA(isA<DuplicateFailure>()),
      );
    });

    test('updates friend correctly', () async {
      final updated = SampleData.friendAlice.copyWith(name: 'Alice Cooper');
      await repository.updateFriend(updated);

      final fetched = await repository.getFriendById('f1');
      expect(fetched?.name, equals('Alice Cooper'));
    });

    test('deletes friend correctly', () async {
      await repository.deleteFriend('f3');
      final list = await repository.getFriends();
      expect(list.length, equals(2));
      expect(await repository.getFriendById('f3'), isNull);
    });
  });
}
