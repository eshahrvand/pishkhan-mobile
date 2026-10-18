import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'issuance_styles.dart';

class IssuanceCurrentCardRow extends StatelessWidget {
  const IssuanceCurrentCardRow({
    super.key,
    required this.label,
    required this.value,
    required this.asset,
  });
  final String label, value, asset;
  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Text(
            value,
            textDirection: TextDirection.ltr,
            style: issuanceBody(context, medium: true),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          textAlign: TextAlign.right,
          style: issuanceBody(context)
              .copyWith(color: context.colors.textTertiary),
        ),
        const SizedBox(width: 8),
        issuanceIcon(asset),
      ],
    );
  }
}
