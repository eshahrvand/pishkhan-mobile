import 'package:pishkhan_mobile/core/config/constant.dart';
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

class ModernBankReceipt extends StatelessWidget {
  const ModernBankReceipt({
    super.key,
    required this.message,
    this.trackingCode,
    this.prototypeNotice,
    this.illustrationTopSpacing = 124,
  });
  final String message;
  final String? trackingCode;
  final String? prototypeNotice;
  final double illustrationTopSpacing;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: illustrationTopSpacing),
        Center(
          child: SizedBox(
            width: 95.01,
            height: 100,
            child: AvpImage(
              image: '${AppConstants.baseImage}modern_success.svg',
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          S.current.passwordStatusRegisteredTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!
              .copyWith(fontWeight: FontWeight.w600, height: 20 / 14),
        ),
        const SizedBox(height: 24),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!
              .copyWith(height: 20 / 14),
        ),
        if (trackingCode != null) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: AppRadius.borderSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    S.current.passwordTracking,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                SelectableText(
                  trackingCode!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
        ],
        if (prototypeNotice != null) ...[
          const SizedBox(height: 12),
          Text(
            prototypeNotice!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall!
                .copyWith(color: context.colors.textTertiary),
          ),
        ],
      ],
    );
  }
}
