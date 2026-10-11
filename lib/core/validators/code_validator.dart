/// Fixed-length numeric codes such as OTPs and the prototype numeric captcha.
abstract final class CodeValidator {
  static bool isValid(String value, {required int length}) =>
      length > 0 &&
      value.length == length &&
      RegExp(r'^[0-9]+$').hasMatch(value);
}
