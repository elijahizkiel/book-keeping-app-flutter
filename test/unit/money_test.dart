import 'package:flutter_test/flutter_test.dart';
import 'package:bookkeeping_app/core/utils/money.dart';
import 'package:bookkeeping_app/core/errors/failures.dart';

void main() {
  group('Money Value Object Tests', () {
    test('parses integer minor units correctly from decimal string', () {
      expect(Money.parse('10.00').minorUnits, equals(1000));
      expect(Money.parse('0.50').minorUnits, equals(50));
      expect(Money.parse('0.05').minorUnits, equals(5));
      expect(Money.parse('100').minorUnits, equals(10000));
      expect(Money.parse('1,250.75').minorUnits, equals(125075));
      expect(Money.parse(' 45.99 ').minorUnits, equals(4599));
    });

    test('rejects empty, negative, or zero amounts with ValidationFailure', () {
      expect(() => Money.parse(''), throwsA(isA<ValidationFailure>()));
      expect(() => Money.parse('   '), throwsA(isA<ValidationFailure>()));
      expect(() => Money.parse('0'), throwsA(isA<ValidationFailure>()));
      expect(() => Money.parse('0.00'), throwsA(isA<ValidationFailure>()));
      expect(() => Money.parse('-10'), throwsA(isA<ValidationFailure>()));
      expect(() => Money.parse('-5.50'), throwsA(isA<ValidationFailure>()));
    });

    test('rejects malformed numbers and non-numeric inputs', () {
      expect(() => Money.parse('abc'), throwsA(isA<ValidationFailure>()));
      expect(
        () => Money.parse('12.345'),
        throwsA(isA<ValidationFailure>()),
      ); // >2 decimals
      expect(() => Money.parse('12..34'), throwsA(isA<ValidationFailure>()));
      expect(() => Money.parse('\$50'), throwsA(isA<ValidationFailure>()));
    });

    test(
      'converts to double and string correctly without binary floating drift',
      () {
        final money = Money(1999);
        expect(money.toDouble(), equals(19.99));
        expect(money.toString(), equals('19.99'));
      },
    );

    test('supports exact arithmetic operations', () {
      final m1 = Money(1500); // $15.00
      final m2 = Money(2550); // $25.50
      expect((m1 + m2).minorUnits, equals(4050));
      expect((m2 - m1).minorUnits, equals(1050));
      expect(m1 < m2, isTrue);
      expect(m2 > m1, isTrue);
      expect(Money(1500) == m1, isTrue);
    });
  });
}
