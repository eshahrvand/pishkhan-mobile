import 'app_invoice_amount.dart';
import 'app_invoice_styles.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class AppInvoiceWalletRow extends StatelessWidget {
  const AppInvoiceWalletRow({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.labelColor,
  });
  final Color labelColor;
  final String label;
  final String amount;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: AppInvoiceAmount(
            amount: amount,
            style: getInvoiceTextStyle(
              AppTypography.bodySmall,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            textDirection: TextDirection.ltr,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: getInvoiceTextStyle(
                    AppTypography.bodySmall,
                    color: labelColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(width: 20, height: 20, child: Center(child: icon)),
            ],
          ),
        ),
      ],
    );
  }
}
