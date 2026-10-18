
import 'package:flutter/material.dart';

import 'app_invoice.dart';

class AppInvoiceAmount extends StatelessWidget {
  const AppInvoiceAmount({
    super.key,
    required this.amount,
    required this.style,
    this.isPrimary = false,
  });
  final String amount;
  final TextStyle style;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        isPrimary
            ? AppInvoiceIcons.currencyPrimary()
            : AppInvoiceIcons.currency(),
        const SizedBox(width: 2),
        Flexible(
          child: Text(amount, overflow: TextOverflow.ellipsis, style: style),
        ),
      ],
    );
  }
}
