
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';


class AppOccupationCardDetailRow extends StatelessWidget {
  const AppOccupationCardDetailRow({
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
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.ltr,
              style: _mediumStyle(AppPalette.gray900),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: _regularStyle(AppPalette.gray700)),
        ],
      ),
    );
  }

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );
  TextStyle _mediumStyle(Color color) =>
      _regularStyle(color).copyWith(fontWeight: FontWeight.w500);
}
