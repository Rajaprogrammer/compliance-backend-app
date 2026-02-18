import 'package:intl/intl.dart';

class AppDateUtils {
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
    if (match == null) throw FormatException('Invalid date');
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
}
