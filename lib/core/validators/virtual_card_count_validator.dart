abstract final class VirtualCardCountValidator {
  static int? parseValidCount(String text, {required int maxCount}) {
    final count = int.tryParse(text);
    return RegExp(r'^[0-9]+$').hasMatch(text) &&
            count != null &&
            count >= 1 &&
            count <= maxCount
        ? count
        : null;
  }
}
