import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';
import 'package:pishkhan_mobile/shared/assets/app_assets.dart';

import '../../shared/modern_bank_notice.dart';

class MobileBankPending extends StatelessWidget {
  const MobileBankPending({super.key, required this.trackingCode});
  final String trackingCode;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          S.current.modernRequestStatus,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!
              .copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox.square(
                      dimension: 16,
                      child: AvpImage(image: AppAssets.modernStatusCheck),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: context.colors.borderSubtle,
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox.square(
                      dimension: 16,
                      child: AvpImage(image: AppAssets.modernStatusCheck),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 36,
                  color: context.colors.borderSubtle,
                ),
                SizedBox.square(
                  dimension: 20,
                  child: AvpImage(image: AppAssets.modernStatusWait),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.current.modernSerialStep,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 38),
                  Text(
                    S.current.modernPaymentStep,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 38),
                  Text(
                    S.current.modernKycStep,
                    style: Theme.of(context).textTheme.bodySmall!
                        .copyWith(color: context.colors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.current.modernAwaitingIdentity,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
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
                trackingCode,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 1,
          child: AvpImage(image: AppAssets.modernDivider, fit: BoxFit.fill),
        ),
        const SizedBox(height: 20),
        ModernBankNotice(message: S.current.modernUsernameNotice),
        const SizedBox(height: 16),
        ModernBankNotice(message: S.current.modernRefundNotice),
      ],
    );
  }
}
