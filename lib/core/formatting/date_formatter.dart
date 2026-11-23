import 'package:intl/intl.dart';

class DateFormatter {
  static String formatFull(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatRelative(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    final target = DateTime(date.year, date.month, date.day);

    final diffDays = today.difference(target).inDays;
    if (diffDays == 0) return 'Today';
    if (diffDays == 1) return 'Yesterday';
    if (diffDays == -1) return 'Tomorrow';
    if (diffDays > 1 && diffDays < 7) return '$diffDays days ago';

    return formatFull(date);
  }
}
