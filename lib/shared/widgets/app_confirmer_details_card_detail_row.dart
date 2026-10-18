import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';


class AppConfirmerDetailsCardDetailRow extends StatelessWidget {
  const AppConfirmerDetailsCardDetailRow({
    super.key,
    required this.value,
    required this.label,
  });
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Expanded(
            child: Text(value, textAlign: TextAlign.left, style: _valueStyle),
          ),
          Expanded(
            child: Text(label, textAlign: TextAlign.right, style: _labelStyle),
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
