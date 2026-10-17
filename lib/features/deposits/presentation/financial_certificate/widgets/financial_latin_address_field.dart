import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class FinancialLatinAddressField extends StatelessWidget {
  const FinancialLatinAddressField({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return AppTextField(
      value: value,
      onChanged: onChanged,
      focusRing: AppTextFieldFocusRing.none,
      minLines: 2,
      maxLines: null,
      multilineHeight: 90 * MediaQuery.textScalerOf(context).scale(1),
      textDirection: TextDirection.ltr,
      hintTextDirection: TextDirection.ltr,
      hintText: S.current.financialLatinAddressHint,
      textStyle: Theme.of(context).textTheme.bodyLarge!
          .copyWith(fontFamily: 'CertificateLatin', height: 24 / 16),
      normalizeDigits: false,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
    );
  }
}
