import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

class AppTransferDestinationCardRow extends StatelessWidget {
  const AppTransferDestinationCardRow({
    super.key,
    required this.value,
    required this.label,
    required this.divider,
  });
  final String value;
  final String label;
  final String divider;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                textDirection: TextDirection.ltr,
                style: _valueStyle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: .5,
              child: AvpImage(image: divider, fit: BoxFit.fill),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            fit: FlexFit.loose,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(label, style: _labelStyle),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _labelStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray900,
    height: 18 / 12,
    letterSpacing: 0,
  );
  TextStyle get _valueStyle => AppTypography.bodySmall.copyWith(
    color: AppPalette.gray900,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
