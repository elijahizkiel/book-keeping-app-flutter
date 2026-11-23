import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookkeeping_app/core/errors/failures.dart';
import 'package:bookkeeping_app/data/models/friend_model.dart';
import 'package:bookkeeping_app/domain/entities/friend.dart';
import 'package:bookkeeping_app/domain/repositories/friends_repository.dart';

class PersistentFriendsRepository implements FriendsRepository {
  static const _keyFriends = 'bookkeeping_friends_store_v1';
  final SharedPreferences _prefs;
  final List<Friend> _cache = [];
  final _controller = StreamController<List<Friend>>.broadcast();

  PersistentFriendsRepository(this._prefs) {
    _load();
  }

  void _load() {
    final raw = _prefs.getString(_keyFriends);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        _cache.clear();
        for (final item in decoded) {
          _cache.add(FriendModel.fromJson(item as Map<String, dynamic>));
        }
      } catch (_) {
        _cache.clear();
      }
    }
    _notify();
  }

  Future<void> _persist() async {
    final list = _cache.map((f) => FriendModel.toJson(f)).toList();
    await _prefs.setString(_keyFriends, jsonEncode(list));
    _notify();
  }

  void _notify() {
    _controller.add(List.unmodifiable(_cache));
  }

  @override
  Future<List<Friend>> getFriends() async {
    return List.unmodifiable(_cache);
  }

  @override
  Future<Friend?> getFriendById(String id) async {
    try {
      return _cache.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Friend> addFriend(Friend friend) async {
    final exists = _cache.any(
      (f) => f.name.trim().toLowerCase() == friend.name.trim().toLowerCase(),
    );
    if (exists) {
      throw const DuplicateFailure('A friend with this name already exists');
    }
    _cache.add(friend);
    await _persist();
    return friend;
  }

  @override
  Future<Friend> updateFriend(Friend friend) async {
    final index = _cache.indexWhere((f) => f.id == friend.id);
    if (index == -1) {
      throw const NotFoundFailure('Friend not found');
    }
    _cache[index] = friend;
    await _persist();
    return friend;
  }

  @override
  Future<void> deleteFriend(String id) async {
    _cache.removeWhere((f) => f.id == id);
    await _persist();
  }

  @override
  Stream<List<Friend>> watchFriends() {
    return _controller.stream;
  }

  Future<void> clearAll() async {
    _cache.clear();
    await _prefs.remove(_keyFriends);
    _notify();
  }
}
