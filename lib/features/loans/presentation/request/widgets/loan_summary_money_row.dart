import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';
import 'package:pishkhan_mobile/core/config/constant.dart';

import 'loan_money.dart';

class LoanSummaryMoneyRow extends StatelessWidget {
  const LoanSummaryMoneyRow({
    super.key,
    required this.label,
    required this.amountRial,
  });
  final String label;
  final int amountRial;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: AvpImage(
            image: '${AppConstants.baseImage}issuance_summary_divider.svg',
            height: .5,
            fit: BoxFit.fill,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(child: LoanMoney(amountRial: amountRial, fontSize: 12)),
      ],
    );
  }
}
