import 'package:intl/intl.dart';

class AppDateUtils {
  static const String timezone = 'Asia/Kolkata';

  static String todayYmd() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static String ymdToDmy(String? ymd) {
    if (ymd == null || ymd.isEmpty) return '';
    try {
      final date = DateTime.parse(ymd);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return '';
    }
  }

  static String dmyToYmd(String dmy) {
    final pattern = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$');
    final match = pattern.firstMatch(dmy.trim());
    if (match == null) throw FormatException('Invalid date format. Use DD-MM-YYYY');
    return '\${match.group(3)}-\${match.group(2)}-\${match.group(1)}';
  }

  static int diffDays(String fromYmd, String toYmd) {
    try {
      final from = DateTime.parse(fromYmd);
      final to = DateTime.parse(toYmd);
      return to.difference(from).inDays;
    } catch (_) {
      return 0;
    }
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  static String formatDate(DateTime dt) {
    return DateFormat('dd-MM-yyyy').format(dt);
  }

  static String formatDateShort(DateTime dt) {
    return DateFormat('dd MMM').format(dt);
  }

  static DateTime parseYmd(String ymd) {
    return DateTime.parse(ymd);
  }

  static DateTime? tryParseYmd(String? ymd) {
    if (ymd == null || ymd.isEmpty) return null;
    try {
      return DateTime.parse(ymd);
    } catch (_) {
      return null;
    }
  }

  static String monthLabel(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String dayOfWeekShort(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  static List<DateTime> getDaysInMonth(DateTime month) {
    final first = startOfMonth(month);
    final last = endOfMonth(month);
    return List.generate(
      last.day,
      (index) => DateTime(first.year, first.month, index + 1),
    );
  }

  static String getRelativeDate(String? ymd) {
    if (ymd == null || ymd.isEmpty) return '';
    final today = todayYmd();
    final diff = diffDays(today, ymd);
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 0 && diff <= 7) return 'In \$diff days';
    if (diff < 0 && diff >= -7) return '\${-diff} days ago';
    
    return ymdToDmy(ymd);
  }
}
