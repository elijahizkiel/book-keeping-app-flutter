import 'package:bookkeeping_app/domain/entities/transaction.dart';
import 'package:bookkeeping_app/domain/entities/filter_criteria.dart';

abstract class TransactionsRepository {
  Future<List<Transaction>> getTransactions([FilterCriteria? filter]);
  Future<Transaction?> getTransactionById(String id);
  Future<List<Transaction>> getTransactionsByFriend(String friendId);
  Future<Transaction> addTransaction(Transaction transaction);
  Future<Transaction> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<void> settleTransaction(String id);
  Future<void> settleAllForFriend(String friendId);
  Stream<List<Transaction>> watchTransactions([FilterCriteria? filter]);
}
