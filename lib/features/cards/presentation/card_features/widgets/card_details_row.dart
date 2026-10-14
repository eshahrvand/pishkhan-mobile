import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class CardDetailsRow extends StatelessWidget {
  const CardDetailsRow({
    super.key,
    required this.label,
    required this.value,
    this.textDirection = TextDirection.rtl,
  });
  final String label;
  final String value;
  final TextDirection textDirection;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              height: 18 / 12,
              letterSpacing: 0,
              color: context.colors.textTertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              textDirection: textDirection,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelMedium.copyWith(
                height: 18 / 12,
                letterSpacing: 0,
                color: context.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
