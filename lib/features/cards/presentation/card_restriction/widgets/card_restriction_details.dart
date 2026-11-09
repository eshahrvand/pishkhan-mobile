import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/card_restriction.dart';
import '../../../domain/entities/card_service_data.dart';
import '../../shared/card_service_widgets.dart';
import 'card_restriction_labels.dart';
import 'card_restriction_detail_row.dart';

class CardRestrictionDetailsCard extends StatelessWidget {
  const CardRestrictionDetailsCard({super.key, required this.card});
  final RestrictionCard card;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(card.blockDetails == null ? 16 : 14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: AppRadius.borderSm,
      ),
      child: Column(
        children: [
          CardRestrictionDetailRow(
            value: card.deposit.number,
            valueDirection: TextDirection.ltr,
            label: S.current.cardRestrictionLinkedDeposit,
            compact: card.blockDetails != null,
          ),
          const SizedBox(height: 12),
          const CardServiceRowDivider(),
          const SizedBox(height: 12),
          CardRestrictionDetailRow(
            value: card.deposit.kind == CardDepositKind.qarz
                ? S.current.cardFeatureQarz
                : S.current.cardServiceCurrentDeposit,
            label: S.current.cardFeatureDepositType,
            compact: card.blockDetails != null,
          ),
          if (card.blockDetails != null) ...[
            const SizedBox(height: 12),
            const CardServiceRowDivider(),
            const SizedBox(height: 12),
            CardRestrictionDetailRow(
              value: cardRestrictionReasonLabel(card.blockDetails!.reason),
              label: S.current.depositBlockedReason,
              compact: card.blockDetails != null,
            ),
            const SizedBox(height: 12),
            const CardServiceRowDivider(),
            const SizedBox(height: 12),
            CardRestrictionDetailRow(
              value: JalaliDateFormatter.format(card.blockDetails!.blockedAt),
              label: S.current.depositBlockedDate,
              compact: card.blockDetails != null,
            ),
            const SizedBox(height: 12),
            const CardServiceRowDivider(),
            const SizedBox(height: 12),
            CardRestrictionDetailRow(
              value: card.blockDetails!.description,
              label: S.current.depositRestrictionDescription,
              compact: card.blockDetails != null,
            ),
          ],
        ],
      ),
    );
  }
}
