import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class IssuanceSummaryRow extends StatelessWidget {
  const IssuanceSummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.asset,
  });
  final String label, value, asset;
  @override
  Widget build(BuildContext context) {
    final small = AppTypography.bodySmall.copyWith(
      height: 18 / 12,
      letterSpacing: 0,
    );
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Flexible(
          child: Text(
            value,
            style: small.copyWith(
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: .5,
            child: AvpImage(image: asset, fit: BoxFit.fill),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: small.copyWith(color: context.colors.textTertiary)),
      ],
    );
  }
}
