import 'package:avp_ui/avp_ui.dart';

/// Parses normalized YYYY/MM/DD input using the same calendar as the UI.
abstract final class JalaliDateParser {
  static DateTime? parse(String value) {
    if (!RegExp(r'^\d{4}/\d{2}/\d{2}$').hasMatch(value)) return null;
    final parts = value.split('/').map(int.parse).toList();
    final year = parts[0], month = parts[1], day = parts[2];
    if (year < 1000 || month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }
    final target = year * 10000 + month * 100 + day;
    // The package exposes Gregorian -> Jalali only. Find its exact inverse
    // within the two Gregorian years containing this Jalali year.
    final start = DateTime.utc(year + 621);
    var low = 0;
    var high = DateTime.utc(year + 623).difference(start).inDays;
    while (low <= high) {
      final middle = (low + high) ~/ 2;
      final date = start.add(Duration(days: middle));
      final jalali = JalaliDate.fromDateTime(date);
      final actual = jalali.year * 10000 + jalali.month * 100 + jalali.day;
      if (actual == target) return date;
      if (actual < target) {
        low = middle + 1;
      } else {
        high = middle - 1;
      }
    }
    return null;
  }
}
