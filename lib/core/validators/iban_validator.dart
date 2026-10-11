/// Iranian IBAN (IR + 24 digits), validated using the ISO 13616 mod-97 check.
abstract final class IbanValidator {
  static bool isValid(String value) {
    if (!RegExp(r'^IR[0-9]{24}$').hasMatch(value)) return false;
    // I=18, R=27; rearrange the first four characters without large integers.
    final rearranged = '${value.substring(4)}1827${value.substring(2, 4)}';
    var remainder = 0;
    for (final digit in rearranged.codeUnits) {
      remainder = (remainder * 10 + digit - 48) % 97;
    }
    return remainder == 1;
  }
}
