/// Basic prototype formatting, not passport verification or expiry eligibility.
abstract final class PassportValidator {
  static bool latinName(String value) =>
      RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ .'-]*$")
          .hasMatch(value.trim());
  static bool number(String value) =>
      RegExp(r'^[A-Za-z0-9]{3,20}$').hasMatch(value.trim());
  static bool latinAddress(String value) =>
      value.trim().isNotEmpty &&
      RegExp(r'^[\x20-\x7E\n\rÀ-ÖØ-öø-ÿ]+$').hasMatch(value.trim()) &&
      RegExp(r'[A-Za-z]').hasMatch(value);
  static DateTime? expiry(String value) {
    if (!RegExp(r'^[0-9]{4}[/\-][0-9]{2}[/\-][0-9]{2}$').hasMatch(value)) {
      return null;
    }
    final parts = value.split(RegExp(r'[/\-]')).map(int.parse).toList();
    final date = DateTime.utc(parts[0], parts[1], parts[2]);
    return date.year == parts[0] &&
            date.month == parts[1] &&
            date.day == parts[2]
        ? date
        : null;
  }
}
