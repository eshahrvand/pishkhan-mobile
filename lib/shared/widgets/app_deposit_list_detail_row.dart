
import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';


class AppDepositListDetailRow extends StatelessWidget {
  const AppDepositListDetailRow({
    super.key,
    required this.leading,
    required this.label,
    required this.alignContentToEdges,
  });
  final Widget leading;
  final String label;
  final bool alignContentToEdges;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          if (alignContentToEdges)
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: leading),
            )
          else
            Flexible(child: leading),
          if (!alignContentToEdges) const Spacer(),
          Text(label, style: _regularStyle(context.colors.textSecondary)),
        ],
      ),
    );
  }

  TextStyle _regularStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
