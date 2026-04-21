import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toFormattedString({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return DateFormat(format).format(this);
  }

  String toDateString({String format = 'yyyy-MM-dd'}) {
    return DateFormat(format).format(this);
  }

  String toTimeString({String format = 'HH:mm'}) {
    return DateFormat(format).format(this);
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool isTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  int getDaysDifference(DateTime other) {
    return difference(other).inDays;
  }

  bool isBetween(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end);
  }
}

extension StringExtension on String {
  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  bool isValidPassword() {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
    );
    return passwordRegex.hasMatch(this);
  }

  bool isValidPhone() {
    final phoneRegex =
        RegExp(r'^[+]?[(]?[0-9]{1,4}[)]?[-\s.]?[0-9]{1,4}[-\s.]?[0-9]{1,9}$');
    return phoneRegex.hasMatch(this);
  }

  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  bool isPasswordStrong() {
    // Strong password: at least 12 chars, uppercase, lowercase, number, special char
    final strongPasswordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{12,}$',
    );
    return strongPasswordRegex.hasMatch(this);
  }

  String truncate(int length, {String ellipsis = '...'}) {
    if (this.length <= length) return this;
    return '${substring(0, length - ellipsis.length)}$ellipsis';
  }

  String toTitleCase() {
    return replaceAllMapped(
      RegExp(r'(?:^|[-\s])[a-z]'),
      (Match match) => match.group(0)!.toUpperCase(),
    );
  }
}

extension IntExtension on int {
  String toFormattedString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match match) => '${match.group(1)},',
    );
  }

  Duration toDuration({required DurationUnit unit}) {
    switch (unit) {
      case DurationUnit.seconds:
        return Duration(seconds: this);
      case DurationUnit.minutes:
        return Duration(minutes: this);
      case DurationUnit.hours:
        return Duration(hours: this);
      case DurationUnit.days:
        return Duration(days: this);
    }
  }
}

enum DurationUnit { seconds, minutes, hours, days }

extension DoubleExtension on double {
  String toFormattedCurrency({String currency = '₹', int decimals = 2}) {
    return '$currency${toStringAsFixed(decimals).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+\.)'),
      (Match match) => '${match.group(1)},',
    )}';
  }

  String toPercentage({int decimals = 1}) {
    return '${(this * 100).toStringAsFixed(decimals)}%';
  }
}
