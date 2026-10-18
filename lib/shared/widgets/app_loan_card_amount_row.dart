import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';


class AppLoanCardAmountRow extends StatelessWidget {
  const AppLoanCardAmountRow({
    super.key,
    required this.value,
    required this.label,
  });
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Expanded(
            child: Row(
              textDirection: TextDirection.ltr,
              children: [
                Text('ریال', style: _labelStyle),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: _valueStyle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, textAlign: TextAlign.right, style: _labelStyle),
          ),
        ],
      ),
    );
  }

  TextStyle get _labelStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray700,
    height: 18 / 12,
    letterSpacing: 0,
  );
  TextStyle get _valueStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray800,
    fontWeight: FontWeight.w600,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
