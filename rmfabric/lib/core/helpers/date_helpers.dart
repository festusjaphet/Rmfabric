import 'package:intl/intl.dart';

class DateHelpers {
  static String dayId(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  static String weekId(DateTime date) {
    final weekNum = _isoWeekNumber(date);
    final year = date.month < 2 && weekNum > 50 ? date.year - 1 : date.year;
    return '${year}_W${weekNum.toString().padLeft(2, '0')}';
  }

  static String monthId(DateTime date) => DateFormat('yyyy-MM').format(date);

  static int _isoWeekNumber(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final weekday = date.weekday;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }

  static String formatCurrency(double amount) =>
      NumberFormat.currency(symbol: 'Tsh ', decimalDigits: 2).format(amount);

  static String formatDate(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('dd MMM yyyy, hh:mm a').format(date);

  static DateTime startOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  static DateTime endOfWeek(DateTime date) =>
      date.add(Duration(days: 7 - date.weekday));

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);
}
