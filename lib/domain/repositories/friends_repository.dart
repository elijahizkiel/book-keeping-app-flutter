import 'package:bookkeeping_app/domain/entities/friend.dart';

abstract class FriendsRepository {
  Future<List<Friend>> getFriends();
  Future<Friend?> getFriendById(String id);
  Future<Friend> addFriend(Friend friend);
  Future<Friend> updateFriend(Friend friend);
  Future<void> deleteFriend(String id);
  Stream<List<Friend>> watchFriends();
}
