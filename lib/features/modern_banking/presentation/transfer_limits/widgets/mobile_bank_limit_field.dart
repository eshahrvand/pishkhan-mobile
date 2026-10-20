import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

/// Repeated amount field with its bank-provided limit and display helper.
class MobileBankLimitField extends StatelessWidget {
  const MobileBankLimitField({
    super.key,
    required this.label,
    required this.value,
    required this.currentAmount,
    required this.maximum,
    required this.toman,
    required this.isEditing,
    required this.isError,
    required this.enabled,
    required this.onChanged,
  });
  final String label;
  final String value;
  final int currentAmount;
  final int maximum;
  final int toman;
  final bool isEditing;
  final bool isError;
  final bool enabled;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!
              .copyWith(height: 18 / 12, color: context.colors.textSecondary),
        ),
        const SizedBox(height: 8),
        AppTextField(
          value: isEditing ? value : CurrencyFormatter.format(currentAmount),
          readOnly: !isEditing,
          enabled: enabled,
          normalizeDigits: true,
          keyboardType: TextInputType.number,
          maxLength: 12,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textStyle: Theme.of(context).textTheme.bodyMedium,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          suffixIcon: Text(
            S.current.rialCurrency,
            style: Theme.of(context).textTheme.bodyMedium!
                .copyWith(color: context.colors.textTertiary),
          ),
          errorText: isError ? S.current.modernLimitError : null,
          focusRing: AppTextFieldFocusRing.none,
          onChanged: onChanged,
        ),
        if (isEditing) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox.square(
                dimension: 14,
                child: AvpImage(image: AppAssets.passwordInfo),
              ),
              const SizedBox(width: 8),
              Text(
                S.current.modernToman(CurrencyFormatter.format(toman)),
                style: Theme.of(context).textTheme.bodySmall!
                    .copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppPasswordServiceColors.cameraNotice,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                SizedBox.square(
                  dimension: 20,
                  child: AvpImage(image: AppAssets.passwordCameraInfo),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    S.current.modernMaximumLimit(
                      CurrencyFormatter.format(maximum),
                    ),
                    style: Theme.of(context).textTheme.bodySmall!
                        .copyWith(height: 18 / 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
