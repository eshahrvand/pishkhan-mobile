/// Local syntax only; ownership and eligibility are checked by the service.
abstract final class ChequeRequestValidator {
  static bool isChequeNumberValid(String value) =>
      value.length <= 32 && RegExp(r'^[0-9]+(?:/[0-9]+)?$').hasMatch(value);

  static bool isJudicialLetterNumberValid(String value) =>
      value.length <= 32 && RegExp(r'^[0-9]+$').hasMatch(value);
}
