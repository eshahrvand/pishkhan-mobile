import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

/// The selected-card summary uses 14px rows; block history uses compact 12px rows.
class CardRestrictionDetailRow extends StatelessWidget {
  const CardRestrictionDetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.compact,
    this.valueDirection = TextDirection.rtl,
  });
  final String label;
  final String value;
  final bool compact;
  final TextDirection valueDirection;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.left,
            textDirection: valueDirection,
            style: cardRestrictionDetailStyle(compact).copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: cardRestrictionDetailStyle(compact)
                .copyWith(color: context.colors.textTertiary),
          ),
        ),
      ],
    );
  }
}

TextStyle cardRestrictionDetailStyle(bool compact) => compact
    ? AppTypography.bodySmall.copyWith(height: 18 / 12, letterSpacing: 0)
    : AppTypography.bodyMedium.copyWith(height: 20 / 14, letterSpacing: 0);
