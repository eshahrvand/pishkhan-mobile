import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class AppDepositCardPlainRow extends StatelessWidget {
  const AppDepositCardPlainRow({
    super.key,
    required this.value,
    required this.label,
  });
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: _valueStyle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,
          style: _labelStyle,
        ),
      ],
    );
  }

  TextStyle get _valueStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.white,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );
  TextStyle get _labelStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.white,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
