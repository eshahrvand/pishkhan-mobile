import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../deposit_list/widgets/deposit_ui.dart';

TextStyle certificateLabelStyle(BuildContext context) =>
    Theme.of(context).textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.w500,
      height: 18 / 12,
      letterSpacing: 0,
      color: context.colors.textSecondary,
    );
TextStyle certificateValueStyle(BuildContext context) => Theme.of(context)
    .textTheme
    .bodyMedium!
    .copyWith(
      height: 20 / 14,
      letterSpacing: 0,
      color: context.colors.textPrimary,
    );

class CertificateSelect<T> extends StatelessWidget {
  const CertificateSelect({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.onChanged,
    this.value,
    this.enabled = true,
  });
  final String label, hint;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final T? value;
  final bool enabled;
  @override
  Widget build(BuildContext context) => AppSelect<T>(
    label: label,
    hintText: hint,
    value: value,
    options: options,
    onChanged: onChanged,
    enabled: enabled,
    labelSpacing: 8,
    labelStyle: certificateLabelStyle(context),
    textStyle: certificateValueStyle(context).copyWith(
      color: value == null
          ? context.colors.textDisabled
          : context.colors.textPrimary,
    ),
    trailing: depositIcon(
      value == null
          ? AppAssets.certificateChevronHint
          : AppAssets.certificateChevron,
      size: 20,
    ),
  );
}

/// Labeled package input with certificate-instance typography.
class CertificateInput extends StatelessWidget {
  const CertificateInput({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    this.onChanged,
    this.readOnly = false,
    this.numeric = false,
    this.latin = false,
    this.addonEnd,
    this.maxLength,
  });
  final String label, hint, value;
  final ValueChanged<String>? onChanged;
  final bool readOnly, numeric, latin;
  final Widget? addonEnd;
  final int? maxLength;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: certificateLabelStyle(context)),
      const SizedBox(height: 8),
      AppTextField(
        value: value,
        hintText: hint,
        onChanged: onChanged,
        readOnly: readOnly,
        normalizeDigits: numeric,
        maxLength: maxLength,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        textDirection: latin ? TextDirection.ltr : TextDirection.rtl,
        textAlign: TextAlign.right,
        hintTextDirection: TextDirection.rtl,
        textStyle: certificateValueStyle(context),
        suffixIcon: addonEnd,
      ),
    ],
  );
}
