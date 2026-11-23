import 'package:bookkeeping_app/domain/entities/friend.dart';

class FriendModel {
  static Map<String, dynamic> toJson(Friend friend) {
    return {
      'id': friend.id,
      'name': friend.name,
      'email': friend.email,
      'phone': friend.phone,
      'avatarUrl': friend.avatarUrl,
      'createdAt': friend.createdAt.toIso8601String(),
    };
  }

  static Friend fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
