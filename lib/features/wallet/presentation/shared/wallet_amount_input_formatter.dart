import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/services.dart';

/// Presentation-only grouping that preserves the caret while inserting separators.
class WalletAmountInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp('[,٬]'), '');
    final amount = int.tryParse(digits);
    if (amount == null || digits.length > 15) return newValue;
    final formatted = CurrencyFormatter.format(amount, usePersianDigits: false);
    final beforeCaret = newValue.text.substring(
      0,
      newValue.selection.extentOffset.clamp(0, newValue.text.length),
    );
    final digitsBeforeCaret = beforeCaret.replaceAll(RegExp('[,٬]'), '').length;
    var caret = 0;
    var seen = 0;
    while (caret < formatted.length && seen < digitsBeforeCaret) {
      if (formatted[caret] != ',') seen++;
      caret++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: caret),
    );
  }
}
