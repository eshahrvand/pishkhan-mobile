/// Iranian national-code format and mod-11 checksum; no digit normalization.
abstract final class NationalCodeValidator {
  static bool isValid(String value) {
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value) ||
        value.split('').toSet().length == 1) {
      return false;
    }
    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += int.parse(value[i]) * (10 - i);
    }
    final remainder = sum % 11;
    return int.parse(value[9]) == (remainder < 2 ? remainder : 11 - remainder);
  }
}
