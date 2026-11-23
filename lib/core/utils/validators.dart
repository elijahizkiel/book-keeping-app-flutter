import 'package:bookkeeping_app/core/errors/failures.dart';
import 'package:bookkeeping_app/core/utils/money.dart';

class Validators {
  static String? validateFriendName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Friend name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    try {
      final money = Money.parse(value);
      if (money.minorUnits <= 0) {
        return 'Amount must be greater than zero';
      }
    } on ValidationFailure catch (e) {
      return e.message;
    } catch (_) {
      return 'Enter a valid amount (e.g. 25.00)';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length > 100) {
      return 'Description cannot exceed 100 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
}
