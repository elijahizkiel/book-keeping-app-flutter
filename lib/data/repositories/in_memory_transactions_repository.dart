import 'dart:async';

import 'package:bookkeeping_app/core/errors/failures.dart';
import 'package:bookkeeping_app/domain/entities/filter_criteria.dart';
import 'package:bookkeeping_app/domain/entities/transaction.dart';
import 'package:bookkeeping_app/domain/repositories/transactions_repository.dart';

class InMemoryTransactionsRepository implements TransactionsRepository {
  final List<Transaction> _transactions = [];
  final _controller = StreamController<List<Transaction>>.broadcast();

  InMemoryTransactionsRepository({List<Transaction>? initial}) {
    if (initial != null) {
      _transactions.addAll(initial);
    }
  }

  void _notify() {
    _controller.add(List.unmodifiable(_transactions));
  }

  @override
  Future<List<Transaction>> getTransactions([FilterCriteria? filter]) async {
    final list = List<Transaction>.from(_transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    if (filter == null) {
      return List.unmodifiable(list);
    }
    return List.unmodifiable(list.where((tx) => filter.matches(tx)));
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByFriend(String friendId) async {
    final list = _transactions.where((t) => t.friendId == friendId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    _notify();
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) {
      throw const NotFoundFailure('Transaction not found');
    }
    _transactions[index] = transaction;
    _notify();
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    _notify();
  }

  @override
  Future<void> settleTransaction(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw const NotFoundFailure('Transaction not found');
    }
    _transactions[index] = _transactions[index].copyWith(
      status: SettlementStatus.settled,
    );
    _notify();
  }

  @override
  Future<void> settleAllForFriend(String friendId) async {
    for (int i = 0; i < _transactions.length; i++) {
      if (_transactions[i].friendId == friendId) {
        _transactions[i] = _transactions[i].copyWith(
          status: SettlementStatus.settled,
        );
      }
    }
    _notify();
  }

  @override
  Stream<List<Transaction>> watchTransactions([FilterCriteria? filter]) {
    return _controller.stream.map((list) {
      final sorted = List<Transaction>.from(list)
        ..sort((a, b) => b.date.compareTo(a.date));
      if (filter == null) return sorted;
      return sorted.where((tx) => filter.matches(tx)).toList();
    });
  }

  void dispose() {
    _controller.close();
  }
}
