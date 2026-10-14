/// Iranian mobile-number format; input must already contain Latin digits.
abstract final class PhoneNumberValidator {
  static bool isValid(String value) => RegExp(r'^09[0-9]{9}$').hasMatch(value);
}
