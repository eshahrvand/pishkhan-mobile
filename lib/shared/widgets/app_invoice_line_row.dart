import 'app_invoice_amount.dart';
import 'app_invoice_styles.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_invoice.dart';

class AppInvoiceLineRow extends StatelessWidget {
  const AppInvoiceLineRow({
    super.key,
    required this.line,
    required this.labelColor,
  });
  final Color labelColor;
  final AppInvoiceLine line;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: AppInvoiceAmount(
            amount: line.amount,
            style: getInvoiceTextStyle(
              AppTypography.bodySmall,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            textDirection: TextDirection.ltr,
            children: [
              Flexible(
                child: Text(
                  line.label,
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
              SizedBox(width: 20, height: 20, child: Center(child: line.icon)),
            ],
          ),
        ),
      ],
    );
  }
}
