import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

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
    this.trailing,
    this.enabled = true,
  });
  final String label;
  final String hint;
  final List<AppSelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final T? value;
  final Widget? trailing;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return AppSelect<T>(
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
      trailing:
          trailing ??
          SizedBox.square(
            dimension: 20,
            child: Center(
              child: AvpImage(
                image: value == null
                    ? AppAssets.certificateChevronHint
                    : AppAssets.certificateChevron,
              ),
            ),
          ),
    );
  }
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
    this.textStyle,
    this.errorText,
    this.enabled = true,
  });
  final String label;
  final String hint;
  final String value;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final bool numeric;
  final bool latin;
  final Widget? addonEnd;
  final int? maxLength;
  final TextStyle? textStyle;
  final String? errorText;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: certificateLabelStyle(context)),
        const SizedBox(height: 8),
        AppTextField(
          value: value,
          enabled: enabled,
          errorText: errorText,
          hintText: hint,
          onChanged: onChanged,
          readOnly: readOnly,
          normalizeDigits: numeric,
          maxLength: maxLength,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          textDirection: latin ? TextDirection.ltr : TextDirection.rtl,
          textAlign: TextAlign.right,
          hintTextDirection: TextDirection.rtl,
          textStyle: textStyle ?? certificateValueStyle(context),
          suffixIcon: addonEnd,
        ),
      ],
    );
  }
}
