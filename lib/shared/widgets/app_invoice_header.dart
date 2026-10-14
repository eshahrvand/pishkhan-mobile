import 'app_invoice_amount.dart';
import 'app_invoice_styles.dart';

import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_invoice.dart';

class AppInvoiceHeader extends StatelessWidget {
  final Color labelColor;
  const AppInvoiceHeader({
    super.key,
    required this.title,
    required this.totalAmount,
    required this.costIcon,
    required this.showToggle,
    required this.isExpanded,
    required this.labelColor,
  });

  final String title;
  final String totalAmount;
  final Widget costIcon;
  final bool showToggle;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: AppInvoiceAmount(
            amount: totalAmount,
            style: getInvoiceTextStyle(
              AppTypography.bodySmall,
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          // Figma pins the cost icon to the physical right and the angle to
          // the physical left, regardless of the surrounding RTL direction.
          textDirection: TextDirection.ltr,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showToggle)
              KeyedSubtree(
                key: const Key('app_invoice_toggle_icon'),
                child: isExpanded
                    ? AppInvoiceIcons.chevronUp()
                    : AppInvoiceIcons.chevronDown(),
              ),
            if (showToggle) const SizedBox(width: 4),
            Text(
              key: const Key('app_invoice_title'),
              title,
              textDirection: TextDirection.rtl,
              style: getInvoiceTextStyle(
                AppTypography.bodySmall,
                color: labelColor,
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              key: const Key('app_invoice_cost_icon'),
              width: 20,
              height: 20,
              child: Center(child: costIcon),
            ),
          ],
        ),
      ],
    );
  }
}
