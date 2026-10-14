import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import 'issuance_styles.dart';

class IssuanceSelect<T> extends StatelessWidget {
  const IssuanceSelect({
    super.key,
    required this.options,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.hintColor,
  });
  final List<AppSelectOption<T>> options;
  final String label, hint;
  final T? value;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final Color? hintColor;
  @override
  Widget build(BuildContext context) {
    return AppSelect<T>(
      options: options,
      value: value,
      onChanged: onChanged,
      label: label,
      hintText: hint,
      enabled: enabled,
      labelSpacing: 8,
      textStyle: issuanceBody(context).copyWith(
        color: value == null
            ? hintColor ?? AppCardIssuanceColors.inputHint
            : context.colors.textPrimary,
      ),
      labelStyle: AppTypography.bodySmall.copyWith(
        fontWeight: FontWeight.w500,
        color: context.colors.textSecondary,
        height: 18 / 12,
        letterSpacing: 0,
      ),
      trailing: issuanceIcon(
        value == null
            ? AppAssets.issuanceSelectEmpty
            : AppAssets.cardFeaturesChevron,
      ),
    );
  }
}
