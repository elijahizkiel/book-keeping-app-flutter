import 'package:intl/intl.dart';

class MoneyFormatter {
  static String format(
    int minorUnits, {
    String currencyCode = 'USD',
    String? symbol,
    bool showSign = false,
  }) {
    final double value = minorUnits.abs() / 100.0;
    final formatter = NumberFormat.currency(
      name: currencyCode,
      symbol: symbol ?? (currencyCode == 'USD' ? '\$' : '$currencyCode '),
      decimalDigits: 2,
    );

    final formatted = formatter.format(value);
    if (showSign) {
      if (minorUnits > 0) return '+$formatted';
      if (minorUnits < 0) return '-$formatted';
    } else if (minorUnits < 0) {
      return '-$formatted';
    }
    return formatted;
  }
}
