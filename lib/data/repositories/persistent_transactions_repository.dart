import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookkeeping_app/core/errors/failures.dart';
import 'package:bookkeeping_app/data/models/transaction_model.dart';
import 'package:bookkeeping_app/domain/entities/filter_criteria.dart';
import 'package:bookkeeping_app/domain/entities/transaction.dart';
import 'package:bookkeeping_app/domain/repositories/transactions_repository.dart';

class PersistentTransactionsRepository implements TransactionsRepository {
  static const _keyTransactions = 'bookkeeping_transactions_store_v1';
  final SharedPreferences _prefs;
  final List<Transaction> _cache = [];
  final _controller = StreamController<List<Transaction>>.broadcast();

  PersistentTransactionsRepository(this._prefs) {
    _load();
  }

  void _load() {
    final raw = _prefs.getString(_keyTransactions);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        _cache.clear();
        for (final item in decoded) {
          _cache.add(TransactionModel.fromJson(item as Map<String, dynamic>));
        }
      } catch (_) {
        _cache.clear();
      }
    }
    _notify();
  }

  Future<void> _persist() async {
    final list = _cache.map((t) => TransactionModel.toJson(t)).toList();
    await _prefs.setString(_keyTransactions, jsonEncode(list));
    _notify();
  }

  void _notify() {
    _controller.add(List.unmodifiable(_cache));
  }

  @override
  Future<List<Transaction>> getTransactions([FilterCriteria? filter]) async {
    final list = List<Transaction>.from(_cache);
    list.sort((a, b) => b.date.compareTo(a.date));
    if (filter == null) {
      return List.unmodifiable(list);
    }
    return List.unmodifiable(list.where((tx) => filter.matches(tx)));
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      return _cache.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByFriend(String friendId) async {
    final list = _cache.where((t) => t.friendId == friendId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(list);
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    _cache.add(transaction);
    await _persist();
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final index = _cache.indexWhere((t) => t.id == transaction.id);
    if (index == -1) {
      throw const NotFoundFailure('Transaction not found');
    }
    _cache[index] = transaction;
    await _persist();
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _cache.removeWhere((t) => t.id == id);
    await _persist();
  }

  @override
  Future<void> settleTransaction(String id) async {
    final index = _cache.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw const NotFoundFailure('Transaction not found');
    }
    _cache[index] = _cache[index].copyWith(status: SettlementStatus.settled);
    await _persist();
  }

  @override
  Future<void> settleAllForFriend(String friendId) async {
    for (int i = 0; i < _cache.length; i++) {
      if (_cache[i].friendId == friendId) {
        _cache[i] = _cache[i].copyWith(status: SettlementStatus.settled);
      }
    }
    await _persist();
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

  Future<void> clearAll() async {
    _cache.clear();
    await _prefs.remove(_keyTransactions);
    _notify();
  }
}
