enum TransactionDirection {
  /// The user owes money to the friend (Debt)
  owes,

  /// The friend owes money to the user (Credit)
  owedToUser,
}

enum SettlementStatus { pending, settled }

class Transaction {
  final String id;
  final String friendId;
  final String description;
  final int amountMinor; // in cents
  final TransactionDirection direction;
  final SettlementStatus status;
  final String category;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.friendId,
    required this.description,
    required this.amountMinor,
    required this.direction,
    this.status = SettlementStatus.pending,
    this.category = 'General',
    required this.date,
    this.notes,
    required this.createdAt,
  });

  bool get isSettled => status == SettlementStatus.settled;
  bool get isPending => status == SettlementStatus.pending;
  bool get isDebt => direction == TransactionDirection.owes;
  bool get isCredit => direction == TransactionDirection.owedToUser;

  Transaction copyWith({
    String? id,
    String? friendId,
    String? description,
    int? amountMinor,
    TransactionDirection? direction,
    SettlementStatus? status,
    String? category,
    DateTime? date,
    String? notes,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      friendId: friendId ?? this.friendId,
      description: description ?? this.description,
      amountMinor: amountMinor ?? this.amountMinor,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          friendId == other.friendId &&
          description == other.description &&
          amountMinor == other.amountMinor &&
          direction == other.direction &&
          status == other.status &&
          category == other.category &&
          date == other.date &&
          notes == other.notes;

  @override
  int get hashCode =>
      id.hashCode ^
      friendId.hashCode ^
      description.hashCode ^
      amountMinor.hashCode ^
      direction.hashCode ^
      status.hashCode ^
      category.hashCode ^
      date.hashCode ^
      notes.hashCode;
}
