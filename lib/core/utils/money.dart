import 'package:bookkeeping_app/core/errors/failures.dart';

/// Integer-minor unit money utility to prevent floating-point rounding errors.
/// 1 unit of currency (e.g., $1.00) = 100 minor units (cents).
class Money {
  final int minorUnits;

  const Money(this.minorUnits);

  static const Money zero = Money(0);

  /// Parses a decimal string like "10", "10.5", "10.50", " 1,234.56 " into minor units (cents).
  /// Rejects negative amounts, empty values, multiple dots, and invalid characters.
  factory Money.parse(String input) {
    final cleaned = input.replaceAll(',', '').trim();
    if (cleaned.isEmpty) {
      throw const ValidationFailure('Amount cannot be empty');
    }

    final regExp = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!regExp.hasMatch(cleaned)) {
      throw const ValidationFailure('Invalid amount format');
    }

    final parts = cleaned.split('.');
    final whole = int.tryParse(parts[0]);
    if (whole == null) {
      throw const ValidationFailure('Amount is too large');
    }

    int fraction = 0;
    if (parts.length == 2) {
      final fracStr = parts[1].padRight(2, '0');
      fraction = int.parse(fracStr);
    }

    final totalMinor = (whole * 100) + fraction;
    if (totalMinor <= 0) {
      throw const ValidationFailure('Amount must be greater than zero');
    }

    return Money(totalMinor);
  }

  static Money? tryParse(String? input) {
    if (input == null) return null;
    try {
      return Money.parse(input);
    } catch (_) {
      return null;
    }
  }

  double toDouble() => minorUnits / 100.0;

  Money operator +(Money other) => Money(minorUnits + other.minorUnits);
  Money operator -(Money other) => Money(minorUnits - other.minorUnits);
  bool operator <(Money other) => minorUnits < other.minorUnits;
  bool operator <=(Money other) => minorUnits <= other.minorUnits;
  bool operator >(Money other) => minorUnits > other.minorUnits;
  bool operator >=(Money other) => minorUnits >= other.minorUnits;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          minorUnits == other.minorUnits;

  @override
  int get hashCode => minorUnits.hashCode;

  @override
  String toString() => (minorUnits / 100.0).toStringAsFixed(2);
}
