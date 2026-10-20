/// Iranian fixed-line telephone number, including its leading area code.
abstract final class TelephoneNumberValidator {
  static bool isValid(String value) => RegExp(r'^0[0-9]{10}$').hasMatch(value);
}
