import 'package:bookkeeping_app/domain/entities/transaction.dart';

enum DateRangeFilter { allTime, thisMonth, last30Days, custom }

enum DirectionFilter { all, owedToUser, owes, settled }

class FilterCriteria {
  final String searchQuery;
  final DirectionFilter directionFilter;
  final DateRangeFilter dateRangeFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String? friendId;
  final String? category;

  const FilterCriteria({
    this.searchQuery = '',
    this.directionFilter = DirectionFilter.all,
    this.dateRangeFilter = DateRangeFilter.allTime,
    this.customStartDate,
    this.customEndDate,
    this.friendId,
    this.category,
  });

  bool matches(Transaction tx, {Map<String, String>? friendNames}) {
    if (friendId != null && tx.friendId != friendId) {
      return false;
    }

    if (category != null &&
        tx.category.toLowerCase() != category!.toLowerCase()) {
      return false;
    }

    // Direction filter
    switch (directionFilter) {
      case DirectionFilter.all:
        break;
      case DirectionFilter.owedToUser:
        if (tx.isSettled || tx.direction != TransactionDirection.owedToUser) {
          return false;
        }
        break;
      case DirectionFilter.owes:
        if (tx.isSettled || tx.direction != TransactionDirection.owes) {
          return false;
        }
        break;
      case DirectionFilter.settled:
        if (!tx.isSettled) {
          return false;
        }
        break;
    }

    // Date range filter
    final now = DateTime.now();
    switch (dateRangeFilter) {
      case DateRangeFilter.allTime:
        break;
      case DateRangeFilter.thisMonth:
        if (tx.date.year != now.year || tx.date.month != now.month) {
          return false;
        }
        break;
      case DateRangeFilter.last30Days:
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        if (tx.date.isBefore(thirtyDaysAgo) || tx.date.isAfter(now)) {
          return false;
        }
        break;
      case DateRangeFilter.custom:
        if (customStartDate != null && tx.date.isBefore(customStartDate!)) {
          return false;
        }
        if (customEndDate != null && tx.date.isAfter(customEndDate!)) {
          return false;
        }
        break;
    }

    // Search query
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      final matchDesc = tx.description.toLowerCase().contains(q);
      final matchCat = tx.category.toLowerCase().contains(q);
      final matchFriend =
          friendNames != null &&
          friendNames[tx.friendId]?.toLowerCase().contains(q) == true;
      if (!matchDesc && !matchCat && !matchFriend) {
        return false;
      }
    }

    return true;
  }

  FilterCriteria copyWith({
    String? searchQuery,
    DirectionFilter? directionFilter,
    DateRangeFilter? dateRangeFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? friendId,
    String? category,
  }) {
    return FilterCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      directionFilter: directionFilter ?? this.directionFilter,
      dateRangeFilter: dateRangeFilter ?? this.dateRangeFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      friendId: friendId ?? this.friendId,
      category: category ?? this.category,
    );
  }
}
