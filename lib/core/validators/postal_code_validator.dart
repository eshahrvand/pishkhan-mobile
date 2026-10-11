/// Ten-digit postal-code format. Address existence is verified by the bank.
abstract final class PostalCodeValidator {
  static bool isValid(String value) => RegExp(r'^[0-9]{10}$').hasMatch(value);
}
