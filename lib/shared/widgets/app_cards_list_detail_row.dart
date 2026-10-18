
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';


class AppCardsListDetailRow extends StatelessWidget {
  const AppCardsListDetailRow({
    super.key,
    required this.value,
    required this.label,
    required this.coloredHeader,
  });
  final String value;
  final String label;
  final bool coloredHeader;

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
              overflow: TextOverflow.ellipsis,
              textDirection: TextDirection.ltr,
              style: _mediumStyle(context.colors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: _regularStyle(
              coloredHeader
                  ? context.colors.textTertiary
                  : context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );
  TextStyle _mediumStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
