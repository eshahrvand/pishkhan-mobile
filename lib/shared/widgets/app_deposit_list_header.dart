import 'package:avp_ui/avp_ui.dart';
import 'package:flutter/material.dart';

import 'app_deposit_list.dart';

class AppDepositListHeader extends StatelessWidget {
  const AppDepositListHeader({
    super.key,
    required this.alignContentToEdges,
    required this.depositIcon,
    required this.moreIcon,
    required this.onMoreTap,
    required this.title,
  });
  final bool alignContentToEdges;
  final Widget? depositIcon;
  final Widget? moreIcon;
  final VoidCallback? onMoreTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final more = SizedBox(
      width: 20,
      height: 20,
      child: Center(child: moreIcon ?? AppDepositListIcons.moreHorizontal()),
    );
    return SizedBox(
      height: 20,
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          onMoreTap == null
              ? more
              : InkWell(
                  onTap: onMoreTap,
                  borderRadius: AppRadius.borderXs,
                  child: more,
                ),
          if (!alignContentToEdges) const Spacer(),
          if (alignContentToEdges) const SizedBox(width: 8),
          if (alignContentToEdges)
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: _mediumStyle(colors.textPrimary),
              ),
            )
          else
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: _mediumStyle(colors.textPrimary),
              ),
            ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            height: 20,
            child: Center(child: depositIcon ?? AppDepositListIcons.deposit()),
          ),
        ],
      ),
    );
  }

  TextStyle _mediumStyle(Color color) => AppTypography.bodySmall.copyWith(
    color: color,
    fontWeight: FontWeight.w500,
    height: 18 / 12,
    letterSpacing: 0,
  );
}
