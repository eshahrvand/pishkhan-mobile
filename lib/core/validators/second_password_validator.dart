/// Pure Latin-digit validation. Input normalization belongs to presentation.
abstract final class SecondPasswordValidator {
  static bool hasValidLength(String value) =>
      RegExp(r'^[0-9]{4,6}$').hasMatch(value);
  static bool hasSafePattern(String value) {
    if (!hasValidLength(value)) return false;
    for (var length = 1; length <= value.length ~/ 2; length++) {
      if (value.length % length == 0 &&
          List.filled(
                value.length ~/ length,
                value.substring(0, length),
              ).join() ==
              value) {
        return false;
      }
    }
    final ascending = List.generate(
      value.length - 1,
      (i) => int.parse(value[i + 1]) == (int.parse(value[i]) + 1) % 10,
    ).every((v) => v);
    final descending = List.generate(
      value.length - 1,
      (i) => int.parse(value[i + 1]) == (int.parse(value[i]) + 9) % 10,
    ).every((v) => v);
    return !ascending && !descending;
  }

  static bool avoidsKnownDates(String value, Iterable<String> dates) =>
      hasValidLength(value) && !dates.contains(value);
  static bool isValid(String value, Iterable<String> dates) =>
      hasValidLength(value) &&
      hasSafePattern(value) &&
      avoidsKnownDates(value, dates);

  /// The supplied example is 3R12345678. Receipt format remains bank-defined;
  /// this prototype checks one Latin letter and digits only (4–20 characters).
  static bool validSerial(String value) =>
      value.length >= 4 &&
      value.length <= 20 &&
      RegExp(r'^[A-Za-z0-9]+$').hasMatch(value) &&
      RegExp(r'[A-Za-z]').allMatches(value).length == 1 &&
      RegExp(r'[0-9]').hasMatch(value);
}
