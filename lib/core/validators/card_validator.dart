/// A 16-digit card number with a Luhn checksum. Issuer/ownership checks are server-owned.
abstract final class CardValidator {
  static bool isValid(String value) {
    if (!RegExp(r'^[0-9]{16}$').hasMatch(value)) return false;
    var sum = 0;
    for (var i = 0; i < value.length; i++) {
      var digit = int.parse(value[i]);
      if (i.isEven) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
    }
    return sum % 10 == 0;
  }
}
