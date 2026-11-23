import 'package:bookkeeping_app/domain/entities/transaction.dart';

class TransactionModel {
  static Map<String, dynamic> toJson(Transaction tx) {
    return {
      'id': tx.id,
      'friendId': tx.friendId,
      'description': tx.description,
      'amountMinor': tx.amountMinor,
      'direction': tx.direction.index,
      'status': tx.status.index,
      'category': tx.category,
      'date': tx.date.toIso8601String(),
      'notes': tx.notes,
      'createdAt': tx.createdAt.toIso8601String(),
    };
  }

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      friendId: json['friendId'] as String,
      description: json['description'] as String,
      amountMinor: json['amountMinor'] as int,
      direction: TransactionDirection.values[json['direction'] as int],
      status: SettlementStatus.values[json['status'] as int],
      category: json['category'] as String? ?? 'General',
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
