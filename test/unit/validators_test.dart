import 'package:flutter_test/flutter_test.dart';
import 'package:bookkeeping_app/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validates friend name correctly', () {
      expect(
        Validators.validateFriendName(''),
        equals('Friend name is required'),
      );
      expect(
        Validators.validateFriendName(null),
        equals('Friend name is required'),
      );
      expect(
        Validators.validateFriendName('a'),
        equals('Name must be at least 2 characters'),
      );
      expect(
        Validators.validateFriendName('A' * 51),
        equals('Name cannot exceed 50 characters'),
      );
      expect(Validators.validateFriendName('John Doe'), isNull);
    });

    test('validates monetary amount correctly', () {
      expect(Validators.validateAmount(''), equals('Amount is required'));
      expect(
        Validators.validateAmount('0'),
        equals('Amount must be greater than zero'),
      );
      expect(Validators.validateAmount('-10'), equals('Invalid amount format'));
      expect(Validators.validateAmount('abc'), equals('Invalid amount format'));
      expect(Validators.validateAmount('25.50'), isNull);
      expect(Validators.validateAmount('100'), isNull);
    });

    test('validates description correctly', () {
      expect(
        Validators.validateDescription(''),
        equals('Description is required'),
      );
      expect(
        Validators.validateDescription('D' * 101),
        equals('Description cannot exceed 100 characters'),
      );
      expect(Validators.validateDescription('Coffee run'), isNull);
    });

    test('validates optional email correctly', () {
      expect(Validators.validateEmail(''), isNull);
      expect(Validators.validateEmail(null), isNull);
      expect(
        Validators.validateEmail('invalid-email'),
        equals('Please enter a valid email address'),
      );
      expect(Validators.validateEmail('test@example.com'), isNull);
    });

    test('validates optional phone number correctly', () {
      expect(Validators.validatePhone(''), isNull);
      expect(Validators.validatePhone(null), isNull);
      expect(
        Validators.validatePhone('123'),
        equals('Please enter a valid phone number'),
      );
      expect(Validators.validatePhone('+1 555-0199'), isNull);
    });
  });
}
