import 'dart:async';

import 'package:bookkeeping_app/core/errors/failures.dart';
import 'package:bookkeeping_app/domain/entities/friend.dart';
import 'package:bookkeeping_app/domain/repositories/friends_repository.dart';

class InMemoryFriendsRepository implements FriendsRepository {
  final List<Friend> _friends = [];
  final _controller = StreamController<List<Friend>>.broadcast();

  InMemoryFriendsRepository({List<Friend>? initial}) {
    if (initial != null) {
      _friends.addAll(initial);
    }
  }

  void _notify() {
    _controller.add(List.unmodifiable(_friends));
  }

  @override
  Future<List<Friend>> getFriends() async {
    return List.unmodifiable(_friends);
  }

  @override
  Future<Friend?> getFriendById(String id) async {
    try {
      return _friends.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Friend> addFriend(Friend friend) async {
    final exists = _friends.any(
      (f) => f.name.trim().toLowerCase() == friend.name.trim().toLowerCase(),
    );
    if (exists) {
      throw const DuplicateFailure('A friend with this name already exists');
    }
    _friends.add(friend);
    _notify();
    return friend;
  }

  @override
  Future<Friend> updateFriend(Friend friend) async {
    final index = _friends.indexWhere((f) => f.id == friend.id);
    if (index == -1) {
      throw const NotFoundFailure('Friend not found');
    }
    _friends[index] = friend;
    _notify();
    return friend;
  }

  @override
  Future<void> deleteFriend(String id) async {
    _friends.removeWhere((f) => f.id == id);
    _notify();
  }

  @override
  Stream<List<Friend>> watchFriends() {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
