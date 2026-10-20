import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class AppAgentCardDetailRow extends StatelessWidget {
  const AppAgentCardDetailRow({super.key, required this.row, this.labelColor});
  final ({String label, String value}) row;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 18),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Expanded(
            child: Text(
              row.value,
              textAlign: TextAlign.left,
              style: _valueStyle,
            ),
          ),
          Expanded(
            child: Text(
              row.label,
              textAlign: TextAlign.right,
              style: _labelStyle.copyWith(color: labelColor),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _labelStyle => AppTypography.bodySmall.copyWith(
    color: const Color(0xFF181D27),
    height: 18 / 12,
    letterSpacing: 0,
  );
  TextStyle get _valueStyle => AppTypography.bodySmall.copyWith(
    color: const Color(0xFF181D27),
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
