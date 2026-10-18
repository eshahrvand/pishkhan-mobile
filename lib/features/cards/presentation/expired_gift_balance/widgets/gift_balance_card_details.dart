import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/generated/l10n.dart';

import '../../../domain/entities/card_service_data.dart';
import '../../shared/card_service_widgets.dart';

/// The same card details are used in selection and the removable review list.
class GiftBalanceCardDetails extends StatelessWidget {
  const GiftBalanceCardDetails({super.key, required this.card, this.deposit});
  final ExpiredGiftCard card;
  final CardServiceDeposit? deposit;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GiftBalanceDetailRow(
          label: S.current.cardFeatureNumber,
          value: card.number,
        ),
        const SizedBox(height: 8),
        if (deposit != null) ...[
          const CardServiceRowDivider(),
          const SizedBox(height: 8),
          GiftBalanceDetailRow(
            label: S.current.cardFeatureDeposit,
            value: deposit!.number,
          ),
          const SizedBox(height: 8),
        ],
        const CardServiceRowDivider(),
        const SizedBox(height: 8),
        GiftBalanceDetailRow(
          label: S.current.giftBalanceRemaining,
          value: CurrencyFormatter.format(card.balanceRial),
        ),
      ],
    );
  }
}

class GiftBalanceDetailRow extends StatelessWidget {
  const GiftBalanceDetailRow({
    super.key,
    required this.label,
    required this.value,
  });
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: cardServiceSmall(context))),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textDirection: TextDirection.ltr,
            style: cardServiceSmall(
              context,
              color: context.colors.textPrimary,
              medium: true,
            ),
          ),
        ),
      ],
    );
  }
}
