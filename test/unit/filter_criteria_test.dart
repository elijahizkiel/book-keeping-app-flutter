import 'package:flutter_test/flutter_test.dart';
import 'package:bookkeeping_app/domain/entities/filter_criteria.dart';
import 'package:bookkeeping_app/domain/entities/transaction.dart';

import '../fixtures/sample_data.dart';

void main() {
  group('FilterCriteria Unit Tests', () {
    test('filters by direction correctly', () {
      const owesFilter = FilterCriteria(directionFilter: DirectionFilter.owes);
      final owesList = SampleData.transactions
          .where((t) => owesFilter.matches(t))
          .toList();
      expect(owesList.length, equals(2));
      expect(
        owesList.every(
          (t) => t.direction == TransactionDirection.owes && !t.isSettled,
        ),
        isTrue,
      );

      const creditFilter = FilterCriteria(
        directionFilter: DirectionFilter.owedToUser,
      );
      final creditList = SampleData.transactions
          .where((t) => creditFilter.matches(t))
          .toList();
      expect(creditList.length, equals(1));
      expect(creditList.first.id, equals('tx1'));

      const settledFilter = FilterCriteria(
        directionFilter: DirectionFilter.settled,
      );
      final settledList = SampleData.transactions
          .where((t) => settledFilter.matches(t))
          .toList();
      expect(settledList.length, equals(1));
      expect(settledList.first.id, equals('tx3'));
    });

    test('filters by friendId correctly', () {
      const friendFilter = FilterCriteria(friendId: 'f2');
      final list = SampleData.transactions
          .where((t) => friendFilter.matches(t))
          .toList();
      expect(list.length, equals(1));
      expect(list.first.friendId, equals('f2'));
    });

    test('filters by search text across description and friend name', () {
      final names = {'f1': 'Alice Johnson', 'f2': 'Bob Smith'};
      const searchBistro = FilterCriteria(searchQuery: 'Bistro');
      expect(
        searchBistro.matches(SampleData.tx1Credit, friendNames: names),
        isTrue,
      );
      expect(
        searchBistro.matches(SampleData.tx2Debt, friendNames: names),
        isFalse,
      );

      const searchFriend = FilterCriteria(searchQuery: 'Alice');
      expect(
        searchFriend.matches(SampleData.tx1Credit, friendNames: names),
        isTrue,
      );
    });
  });
}
