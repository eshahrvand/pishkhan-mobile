import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../shared/certificate_fields.dart';

/// The package textarea has a 130px minimum. This instance needs 90px and
/// Latin numerals, while retaining its own controller across Cubit rebuilds.
class FinancialLatinAddressField extends StatefulWidget {
  const FinancialLatinAddressField({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;
  @override
  State<FinancialLatinAddressField> createState() =>
      _FinancialLatinAddressFieldState();
}

class _FinancialLatinAddressFieldState
    extends State<FinancialLatinAddressField> {
  late final controller = TextEditingController(text: widget.value);
  @override
  void didUpdateWidget(covariant FinancialLatinAddressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (controller.text != widget.value) controller.text = widget.value;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: AppRadius.borderSm,
      borderSide: BorderSide(color: context.colors.border),
    );
    return SizedBox(
      height: 90 * MediaQuery.textScalerOf(context).scale(1),
      child: TextField(
        controller: controller,
        onChanged: widget.onChanged,
        expands: true,
        minLines: null,
        maxLines: null,
        textAlignVertical: TextAlignVertical.top,
        textDirection: TextDirection.ltr,
        autocorrect: false,
        enableSuggestions: false,
        enableIMEPersonalizedLearning: false,
        style: certificateValueStyle(context).copyWith(
          fontFamily: 'CertificateLatin',
          fontSize: 16,
          height: 24 / 16,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: context.colors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          hintText: S.current.financialLatinAddressHint,
          hintTextDirection: TextDirection.ltr,
          hintStyle: certificateValueStyle(context).copyWith(
            fontFamily: 'CertificateLatin',
            fontSize: 16,
            height: 24 / 16,
            color: context.colors.textDisabled,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: context.colors.borderFocus),
          ),
        ),
      ),
    );
  }
}
