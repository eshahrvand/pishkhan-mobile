/// Required free-text input; whitespace alone is not a value.
abstract final class RequiredTextValidator {
  static bool isValid(String value) => value.trim().isNotEmpty;
}
